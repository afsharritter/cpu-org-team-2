#
# Program Name: RSA.s
# Author: Team 2
# Date: 03/05/2026
# Purpose: Main entry point for RSA program.
#

.text
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

        # Invalid input, loop again
        LDR r0, =menu_invalid
        BL  printf
        B   main_loop

    main_generate_keys:
        # TODO: Generate keys — prompt for p, q, e; call cpubexp/cprivexp; save to keys.txt
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

    @ Pop the Stack 
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr
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
        BL calcPhi
        # calcPhi return phi in r0, store it in the phi_val variable
        LDR r1, =phi_val
        STR r0, [r1]

    generateKeys_pubexp_loop:
        # prompt user to enter e
        LDR r0, =prompt_e
        LDR r1, =phi_val
        LDR r1, [r1]
        BL printf
        # scan user value for e_val
        LDR r0, =fmt_int
        LDR r1, =e_val
        BL scanf

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

        # fall through to generateKeys_end
    generateKeys_end:
        # pop the stack
        LDR r5, [sp, #8]
        LDR r4, [sp, #4]
        LDR lr, [sp, #0]
        ADD sp, sp, #16
        MOV pc, lr
# END generate
.global encryptMain
encryptMain:
    SUB  sp, sp, #4
    STR  lr, [sp, #0]
 
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
 
    # Prompt and read modulus (n)
    LDR  r0, =prompt_n
    BL   printf 
 
    LDR  r0, =fmt_int
    LDR  r1, =val_n
    BL   scanf
 
    # Open encrypted.txt for writing
    LDR  r0, =enc_file_name
    LDR  r1, =mode_w
    BL   fopen
    MOV  r8, r0
 
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
        MOV  r0, r8
        LDR  r1, =fmt_enc_out
        MOV  r2, r3
        BL   fprintf
        # advance to next element in input array
        ADD  r6, r6, #1
        B    encryptMain_loop
    encryptMain_loop_done:

    # Close file
    MOV  r0, r8
    BL   fclose
 
    # Print success message
    LDR  r0, =enc_str_success
    BL   printf
 
    LDR  lr, [sp, #0]
    ADD  sp, sp, #4
    MOV  pc, lr
 
#END encryptMain


.global decryptMain
decryptMain:
    SUB  sp, sp, #4
    STR  lr, [sp, #0]
 
    # Prompt and read private exponent (d)
    LDR  r0, =prompt_d
    BL   printf
 
    LDR  r0, =fmt_int
    LDR  r1, =val_d
    BL   scanf
 
    # Prompt and read modulus (n)
    LDR  r0, =prompt_n
    BL   printf
 
    LDR  r0, =fmt_int
    LDR  r1, =val_n
    BL   scanf
 
    # Open encrypted.txt for reading
    LDR  r0, =enc_file_name
    LDR  r1, =mode_r
    BL   fopen
    MOV  r8, r0
 
    # Open plaintext.txt for writing
    LDR  r0, =plain_file_name
    LDR  r1, =mode_w
    BL   fopen
    MOV  r9, r0
 
    # Load d and n
    LDR  r4, =val_d
    LDR  r4, [r4]
 
    LDR  r5, =val_n
    LDR  r5, [r5]
 
    # Loop: read each space-delimited integer from encrypted.txt (input int array),
    # compute m = c^d mod n, write ASCII char to plaintext.txt (output char array)
    # r4 = d, r5 = n, r8 = encrypted.txt fp, r9 = plaintext.txt fp
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
        MOV  r1, r9
        BL   fputc
        B    decryptMain_loop
    decryptMain_done:

    # Close files
    MOV  r0, r8
    BL   fclose
 
    MOV  r0, r9
    BL   fclose
 
    # Print success message
    LDR  r0, =dec_str_success
    BL   printf
 
    LDR  lr, [sp, #0]
    ADD  sp, sp, #4
    MOV  pc, lr
 
    # TODOs:
    # Error if file not found
    # Error if file is empty
    # Check for valid inputs
    # Write d, n to encrypted.txt as well?

#END decryptMain

.data
    # Shared
    prompt_n:           .asciz "Enter modulus (n): \n"
    fmt_str:            .asciz "%127s"
    fmt_int:            .asciz "%d"
    mode_r:             .asciz "r"
    mode_w:             .asciz "w"
    enc_file_name:      .asciz "../data/encrypted.txt"
    plain_file_name:    .asciz "../data/plaintext.txt"
    keys_file_name:    .asciz "../data/keys.txt"
    message_buf:        .skip 100

    # Main menu
    menu_prompt:        .asciz "\nRSA Menu:\n  1. Generate Keys\n  2. Encrypt a Message\n  3. Decrypt a Message\nEnter choice: "
    menu_invalid:       .asciz "Invalid choice. Please enter 1, 2, or 3.\n"
    menu_choice:        .word 0
 
    # Generate Keys
    prompt_p:           .asciz "Enter a prime value for p: "
    prompt_q:           .asciz "Enter a prime value for q: "
    pq_error_msg:       .asciz "Error. The value %d is not prime. Please try again.\n"
    prompt_e:           .asciz "Enter a value for e, such that 1 < e < %d: "
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
    fmt_enc_out:        .asciz "%d "    @ space-separated integer format for output array
    enc_str_success:    .asciz "Encryption Complete. Output written to encrypted.txt."
 
    # Decrypt
    prompt_d:           .asciz "Enter private key exponent (d): \n"
    val_d:              .word 0
    val_n:              .word 0
    dec_str_success:    .asciz "Decryption Complete. Output written to plaintext.txt."
    #scratch word for fscanf
    temp_val:           .word 0
 
# END RSA.s