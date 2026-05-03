#
# Program Name: RSA.s
# Author: Team 2
# Date: 03/05/2026
# Purpose: Main entry point for RSA program.
#

.text

# Function Name: main
# Purpose: Program entry point. Displays the RSA menu in a loop and dispatches
#          to generateKeys, encryptMain, or decryptMain based on user input.
#          Returns to the C runtime when the user selects Exit (option 4).
# Inputs:
#   none
# Outputs:
#   none
# lr: saved at [sp+0] so we can return to the C runtime
.global main
main:
    @ Push the Stack 
    SUB sp, sp, #4          
    STR lr, [sp, #0]

    main_loop:
        #Print menu
        LDR r0, =menu_prompt
        BL  printf

        # Read user choice into menu_choice
        LDR r0, =fmt_int
        LDR r1, =menu_choice
        BL  scanf
        CMP r0, #1
        # Flush bad input from stdin
        BLNE drain_stdin

        # Load chosen value
        LDR r0, =menu_choice
        LDR r0, [r0]

        #Branch to selected option
        CMP r0, #1
        BEQ main_generate_keys
        CMP r0, #2
        BEQ main_encrypt
        CMP r0, #3
        BEQ main_decrypt
        CMP r0, #4
        BEQ main_exit

        # Invalid input, loop again
        LDR r0, =menu_invalid
        BL  printf
        B   main_loop

    main_generate_keys:
        # generate public and private keys
        BL generateKeys
        B main_loop

    main_encrypt:
        #Encrypt a message
        BL  encryptMain
        B   main_loop

    main_decrypt:
        #Decrypt a message
        BL  decryptMain
        B   main_loop

    main_exit:

    @ Pop the Stack 
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr

# Function Name: generateKeys
# Purpose: Generate an RSA key pair and save it to data/keys.txt.
# Prompts for primes p and q, computes n = p*q and phi, prompts for e (validated by cpubexp), derives d = modinv(e, phi) via cprivexp, then prints and writes the key set.
# Inputs:
#   all values read from stdin
# Outputs:
#   results printed to stdout and saved to data/keys.txt
# Registers used:
#   r4: holds n_val when building the fprintf argument list
#   r5: file ptr for data/keys.txt
.global generateKeys
generateKeys:
    # push the stack
    SUB sp, sp, #16
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]

    generateKeys_prompt_p_loop:
        # prompt user to enter p
        LDR r0, =prompt_p
        BL printf
        # scan user value for p_val
        LDR r0, =fmt_int
        LDR r1, =p_val
        BL scanf
        CMP r0, #1
        # Flush bad input from stdin
        BLNE drain_stdin

        # call isPrime(p_val) to determine if the value is prime.
        LDR r0, =p_val
        LDR r0, [r0]
        BL isPrime

        # if isPrime(p_val) == 0 [r0], then p_val is prime, branch to generateKeys_prompt_q_loop
        CMP r0, #1
        BEQ generateKeys_prompt_q_loop

        # print error message and loop back to to generateKeys_prompt_p_loop
        LDR r0, =pq_error_msg
        LDR r1, =p_val
        LDR r1, [r1]
        BL printf
        B generateKeys_prompt_p_loop

    generateKeys_prompt_q_loop:
        # prompt user to enter q
        LDR r0, =prompt_q
        BL printf
        # scan user value for q_val
        LDR r0, =fmt_int
        LDR r1, =q_val
        BL scanf
        CMP r0, #1
        # Flush bad input from stdin
        BLNE drain_stdin

        # call isPrime(q_val) to determine if the value is prime.
        LDR r0, =q_val
        LDR r0, [r0]
        BL isPrime

        # if isPrime(q_val) == 1 [r0], then q_val is prime, branch to generateKeys_calculate_n
        CMP r0, #1
        BEQ generateKeys_calculate_n

        # print error message and loop back to to generateKeys_prompt_q_loop
        LDR r0, =pq_error_msg
        LDR r1, =q_val
        LDR r1, [r1]
        BL printf
        B generateKeys_prompt_q_loop

    generateKeys_calculate_n:
        # Load p_val -> r0 and q_val -> r1, use calcN to calculate phi = p * q
        LDR r0, =p_val
        LDR r0, [r0]
        LDR r1, =q_val
        LDR r1, [r1]
        BL calcN
        # calcN returns n in r0, store it in the n_val variable
        LDR r1, =n_val
        STR r0, [r1]

        # Fall through to generateKeys_calculate_phi
    generateKeys_calculate_phi:
        # Load p_val -> r0 and q_val -> r1, use calcPhi to calculate phi = (p - 1)*( q - 1 )
        LDR r0, =p_val
        LDR r0, [r0]
        LDR r1, =q_val
        LDR r1, [r1]
        CMP r0, r1
        BEQ generateKeys_phi_equal
        # p != q: phi = (p-1)*(q-1)
        BL calcPhi
        B  generateKeys_phi_store
        # special case when p=q
        generateKeys_phi_equal:
            # p == q: phi = p*(p-1)
            BL calcPhiEqual
    generateKeys_phi_store:
        # store phi result in phi_val
        LDR r1, =phi_val
        STR r0, [r1]

    generateKeys_pubexp_loop:
        # prompt user to enter e
        LDR r0, =prompt_e_gen
        LDR r1, =phi_val
        LDR r1, [r1]
        BL printf
        # scan user value for e_val
        LDR r0, =fmt_int
        LDR r1, =e_val
        BL scanf
        CMP r0, #1
        # Flush bad input from stdin
        BLNE drain_stdin

        # call cpubexp(phi, e) to determine if e is valid
        # load phi_val -> r0, e_val -> r1
        LDR r0, =phi_val
        LDR r0, [r0]
        LDR r1, =e_val
        LDR r1, [r1]
        BL cpubexp

        # if cpubexp return status code != 0, loop back to to generateKeys_pubexp_loop
        CMP r0, #0
        BNE generateKeys_pubexp_loop
        # fall through to generateKeys_privexp
    generateKeys_privexp:
        # Call cprivexp(e, phi) -> d [r0]
        # Load e -> r0, phi -> r1
        LDR r0, =e_val
        LDR r0, [r0]
        LDR r1, =phi_val
        LDR r1, [r1]

        BL cprivexp
        # d is returned in r0, store [r0] in d_val

        LDR r1, =d_val
        STR r0, [r1]

        # fall through to generateKeys_print_keys
    
    generateKeys_print_keys:
        # Print e_val, d_val, and n_val
        LDR r0, =print_keys_msg
        LDR r1, =e_val
        LDR r1, [r1]
        LDR r2, =d_val 
        LDR r2, [r2]
        LDR r3, =n_val
        LDR r3, [r3]
        BL printf
        # Fall through to generateKeys_save_keys
    generateKeys_save_keys:
        # open the file 
        LDR r0, =keys_file_name
        LDR r1, =mode_w
        BL fopen
        # save file pointer in r5
        MOV r5, r0
        CMP r5, #0
        BEQ generateKeys_file_error

        # load n_val -> r4 and push onto the stack (to be used by fprint)
        LDR r4, =n_val
        LDR r4, [r4]
        SUB sp, sp, #8
        STR r4, [sp, #0]


        # set up registers r0 -> r3
        MOV r0, r5  @ move file pointer to r0
        LDR r1, =print_keys_msg
        LDR r2, =e_val
        LDR r2, [r2]
        LDR r3, =d_val
         LDR r3, [r3]

        # write to the file using fprintf
        BL fprintf

        # cleanup the stack, no need to pop r4 and r5, since they were not clobbered in fprintf
        ADD sp, sp, #8

        # close the file
        MOV r0, r5
        BL fclose

        # branch to generateKeys_end
        B  generateKeys_end

    generateKeys_file_error:
        LDR r0, =err_keys_file
        BL  printf
        @ fall through to generateKeys_end
    generateKeys_end:
        # pop the stack
        LDR r5, [sp, #8]
        LDR r4, [sp, #4]
        LDR lr, [sp, #0]
        ADD sp, sp, #16
        MOV pc, lr
# END generate

# Function Name: encryptMain
# Purpose: Encrypt a plaintext message using RSA public-key encryption. Reads the message (up to 127 chars), exponent e and modulus n
# from stdin, then for each character m computes c = m^e mod n and writes the space-separated ciphertext integers to data/encrypted.txt.
# Inputs:
#   message and keys read from stdin
# Outputs:
#   ciphertext written to data/encrypted.txt
# Registers used:
#   r4: e (public exponent)
#   r5: n (modulus)
#   r6: walking pointer through message_buf
#   r7: FILE* for data/encrypted.txt

.global encryptMain
encryptMain:
    SUB  sp, sp, #24
    STR  lr, [sp, #0]
    STR  r4, [sp, #4]
    STR  r5, [sp, #8]
    STR  r6, [sp, #12]
    STR  r7, [sp, #16]
    STR  r8, [sp, #20]

    # Prompt and read plaintext message
    LDR  r0, =prompt_message
    BL   printf
 
        LDR  r0, =fmt_str
    LDR  r1, =message_buf
    BL   scanf
 
    # Prompt and read public key exponent (e)
    LDR  r0, =prompt_e
    BL   printf 
 
    LDR  r0, =fmt_int
    LDR  r1, =val_e
    BL   scanf
    CMP  r0, #1
    # Flush bad input from stdin
    BLNE drain_stdin

    # Validate e > 0
    LDR  r0, =val_e
    LDR  r0, [r0]
    CMP  r0, #1
    BLE  encryptMain_invalid_e

    # Prompt and read modulus (n)
    LDR  r0, =prompt_n
    BL   printf 
 
    LDR  r0, =fmt_int
    LDR  r1, =val_n
    BL   scanf
    CMP  r0, #1
    # Flush bad input from stdin
    BLNE drain_stdin

    # Validate n > 0
    LDR  r0, =val_n
    LDR  r0, [r0]
    CMP  r0, #0
    BLE  encryptMain_invalid_n

    # Open encrypted.txt for writing
    LDR  r0, =enc_file_name
    LDR  r1, =mode_w
    BL   fopen
    MOV  r7, r0
    CMP  r7, #0
    BEQ  encryptMain_file_error
    # Load e->r4 and n->r5 and input array ptr -> r6
    LDR  r4, =val_e
    LDR  r4, [r4]
    LDR  r5, =val_n
    LDR  r5, [r5]

    LDR  r6, =message_buf

    # Loop: for each char in input array, compute c = m^e mod n
    # and write c as a space-separated integer to encrypted.txt
    encryptMain_loop:
        #load next byte from input char array
        LDRB r0, [r6]
        #null terminator = end of array
        CMP  r0, #0
        BEQ  encryptMain_loop_done
        #r1 = e
        MOV  r1, r4
        #r2 = n
        MOV  r2, r5
        BL   encrypt
        # r3 = r0 = c = m^e mod n, save ciphertext value
        MOV  r3, r0
        #r0 = file pointer
        MOV  r0, r7
        LDR  r1, =fmt_enc_out
        MOV  r2, r3
        BL   fprintf
        # advance to next element in input array
        ADD  r6, r6, #1
        B    encryptMain_loop
    encryptMain_loop_done:

    # Close file
        MOV  r0, r7
        BL   fclose
 
    # Print success message
        LDR  r0, =enc_str_success
        BL   printf
        B    encryptMain_exit

    encryptMain_file_error:
        LDR  r0, =err_enc_file
        BL   printf
        B    encryptMain_exit

    encryptMain_invalid_e:
        LDR  r0, =err_invalid_e
        BL   printf
        B    encryptMain_exit

    encryptMain_invalid_n:
        LDR  r0, =err_invalid_n
        BL   printf
        B    encryptMain_exit

    encryptMain_exit:
    LDR  r7, [sp, #16]
    LDR  r6, [sp, #12]
    LDR  r5, [sp, #8]
    LDR  r4, [sp, #4]
    LDR  lr, [sp, #0]
    ADD  sp, sp, #24
    MOV  pc, lr
 
#END encryptMain


# Function Name: decryptMain
# Purpose: Decrypt ciphertext produced by encryptMain using RSA. Reads private exponent d and modulus n from stdin, reads each
# space-delimited ciphertext integer c from data/encrypted.txt, computes m = c^d mod n, and writes the recovered ASCII characters
# to data/plaintext.txt.
# Inputs:
#   d and n read from stdin; ciphertext read from data/encrypted.txt
# Outputs:
#   plaintext written to data/plaintext.txt
# Registers used:
#   r4: d (private exponent)
#   r5: n (modulus)
#   r6: count of chars written to detect empty ciphertext file
#   r7: FILE* for data/plaintext.txt (output)
#   r8: FILE* for data/encrypted.txt (input)

.global decryptMain
decryptMain:
    SUB  sp, sp, #24
    STR  lr, [sp, #0]
    STR  r4, [sp, #4]
    STR  r5, [sp, #8]
    STR  r6, [sp, #12]
    STR  r7, [sp, #16]
    STR  r8, [sp, #20]

    # Prompt and read private exponent (d)
    LDR  r0, =prompt_d
    BL   printf
 
    LDR  r0, =fmt_int
    LDR  r1, =val_d
    BL   scanf
    CMP  r0, #1
    # Flush bad input from stdin
    BLNE drain_stdin

    # Validate d > 0
    LDR  r0, =val_d
    LDR  r0, [r0]
    CMP  r0, #0
    BLE  decryptMain_invalid_d

    # Open encrypted.txt for reading
    LDR  r0, =enc_file_name
    LDR  r1, =mode_r
    BL   fopen
    MOV  r8, r0
    CMP  r8, #0
    BEQ  decryptMain_file_enc_error

    # Prompt and read modulus (n)
    LDR  r0, =prompt_n
    BL   printf

    LDR  r0, =fmt_int
    LDR  r1, =val_n
    BL   scanf
    CMP  r0, #1
    # Flush bad input from stdin
    BLNE drain_stdin

    # Validate n > 0
    LDR  r5, =val_n
    LDR  r5, [r5]
    CMP  r5, #0
    BLE  decryptMain_invalid_n

    # Open plaintext.txt for writing
    LDR  r0, =plain_file_name
    LDR  r1, =mode_w
    BL   fopen
    MOV  r7, r0
    CMP  r7, #0
    BEQ  decryptMain_file_plain_error

    # Load d and n
    LDR  r4, =val_d
    LDR  r4, [r4]
    MOV  r6, #0

    # Loop: read each space-delimited integer from encrypted.txt,
    # compute m = c^d mod n, write ASCII char to plaintext.txt
    decryptMain_loop:
        # r8 file pointer (encrypted.txt)
        MOV  r0, r8
        LDR  r1, =fmt_int
        #temp address for scanned integer
        LDR  r2, =temp_val
        BL   fscanf
        #fscanf returns 1 on success, EOF otherwise
        CMP  r0, #1
        BNE  decryptMain_done
        LDR  r0, =temp_val
        #r0 = c (next integer from input array)
        LDR  r0, [r0]
        #r1 = d
        MOV  r1, r4
        # r2 = n
        MOV  r2, r5
        BL   decrypt
        #r0 = m = c^d mod n -> ASCII char
        #fputc(int c, FILE *stream): r0=char, r1=file pointer
        MOV  r1, r7
        BL   fputc
        # Increment count
        ADD  r6, r6, #1
        B    decryptMain_loop
    decryptMain_done:
        CMP  r6, #0
        BEQ  decryptMain_empty_cipher
        MOV  r0, r8
        BL   fclose
        MOV  r0, r7
        BL   fclose
        LDR  r0, =dec_str_success
        BL   printf
        B    decryptMain_exit

    decryptMain_empty_cipher:
        MOV  r0, r8
        BL   fclose
        MOV  r0, r7
        BL   fclose
        LDR  r0, =err_empty_cipher
        BL   printf
        B    decryptMain_exit

    decryptMain_file_enc_error:
        LDR  r0, =err_dec_enc_file
        BL   printf
        B    decryptMain_exit

    decryptMain_file_plain_error:
        MOV  r0, r8
        BL   fclose
        LDR  r0, =err_dec_plain_file
        BL   printf
        B    decryptMain_exit

    decryptMain_invalid_d:
        LDR  r0, =err_invalid_d
        BL   printf
        B    decryptMain_exit

    decryptMain_invalid_n:
        MOV  r0, r8
        BL   fclose
        LDR  r0, =err_invalid_n
        BL   printf
        B    decryptMain_exit

    decryptMain_exit:
    LDR  r8, [sp, #20]
    LDR  r7, [sp, #16]
    LDR  r6, [sp, #12]
    LDR  r5, [sp, #8]
    LDR  r4, [sp, #4]
    LDR  lr, [sp, #0]
    ADD  sp, sp, #24
    MOV  pc, lr

#END decryptMain

# Function Name: drain_stdin
# Purpose: Consume and discard all characters in the stdin buffer up to and including the next newline. Called after a failed scanf to clear
# stale bytes so the next scanf attempt does not fail immediately.
# Inputs:
#   none
# Outputs:
#   none
.global drain_stdin
drain_stdin:
    SUB  sp, sp, #4
    STR  lr, [sp, #0]
drain_stdin_loop:
    BL   getchar
    CMP  r0, #10            @ '\n'
    BNE  drain_stdin_loop
    LDR  lr, [sp, #0]
    ADD  sp, sp, #4
    MOV  pc, lr

.data
    # Shared
    prompt_n:           .asciz "Enter modulus (n): \n"
    fmt_str:            .asciz " %127[^\n]"
    fmt_int:            .asciz "%d"
    mode_r:             .asciz "r"
    mode_w:             .asciz "w"
    enc_file_name:      .asciz "data/encrypted.txt"
    plain_file_name:    .asciz "data/plaintext.txt"
    keys_file_name:    .asciz "data/keys.txt"
    message_buf:        .skip 128

    # Main menu
    menu_prompt:        .asciz "\nRSA Menu:\n  1. Generate Keys\n  2. Encrypt a Message\n  3. Decrypt a Message\n  4. Exit\nEnter choice: "
    menu_invalid:       .asciz "Invalid choice. Please enter 1, 2, 3 or 4.\n"
    menu_choice:        .word 0
 
    # n written as first token in encrypted.txt
    fmt_n_out:          .asciz "%d "

    # Generate Keys
    prompt_p:           .asciz "Enter a prime value for p: "
    prompt_q:           .asciz "Enter a prime value for q: "
    pq_error_msg:       .asciz "Error. The value %d is not prime. Please try again.\n"
    prompt_e_gen:       .asciz "Enter a value for e, such that 1 < e < %d: "
    e_error_msg:        .asciz "Error. The value for e [ %d ] must be greater than 1 and less than %d. Please try again.\n "
    print_keys_msg:     .asciz "Success!\n  Your public key exponent (e) is: %d\n  Your private key exponent (d) is: %d\n  Your modulus (n) is: %d\n"
    p_val:              .word 0
    q_val:              .word 0
    phi_val:            .word 0
    n_val:              .word 0
    e_val:              .word 0
    d_val:              .word 0

    # Encrypt
    prompt_message:     .asciz "Enter plaintext message: \n"
    prompt_e:           .asciz "Enter public key exponent (e): \n"
    val_e:              .word 0
    #space-separated ciphertext integers
    fmt_enc_out:        .asciz "%d "
    enc_str_success:    .asciz "Encryption Complete. Output written to data/encrypted.txt.\n"
    err_enc_file:       .asciz "Error: could not open data/encrypted.txt for writing. Check data/ directory exists.\n"
    err_invalid_e:      .asciz "Error: e must be greater than 1.\n"
    err_invalid_n:      .asciz "Error: n must be greater than 0.\n"

    # Decrypt
    prompt_d:           .asciz "Enter private key exponent (d): \n"
    val_d:              .word 0
    val_n:              .word 0
    dec_str_success:    .asciz "Decryption complete. Output written to data/plaintext.txt.\n"
    err_dec_enc_file:   .asciz "Error: could not open data/encrypted.txt for reading. Encrypt a message first.\n"
    err_dec_plain_file: .asciz "Error: could not open data/plaintext.txt for writing. Check data/ directory exists.\n"
    err_empty_file:     .asciz "Error: data/encrypted.txt is empty or contains no valid data.\n"
    err_empty_cipher:   .asciz "Error: data/encrypted.txt contained no ciphertext integers.\n"
    err_invalid_d:      .asciz "Error: d must be greater than 0.\n"
    err_keys_file:      .asciz "Error: could not open data/keys.txt for writing. Check data/ directory exists.\n"
    # scratch word for fscanf
    temp_val:           .word 0
 
# END RSA.s

