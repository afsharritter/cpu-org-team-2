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

    ## TODO: prompt for user input: generate keys, encrypt, or decrypt?

    ## TODO: Option 1: Generate keys
        ## TODO: prompt user for p + q, limit < 50 and check input

        ## TODO: call cpubexp and cprivexp, output to keys.txt

    ## TODO: Option 2: Encrypt a message: call encrypt, which already saves the encrypted message to encrypted.txt

    ## TODO: Option 3: Decrypt a message: call decrypt, which already saves to plaintext.txt
    
    @ Pop the Stack 
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr

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
        CMP  r0, #0        BEQ  encryptMain_done
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
    encryptMain_done:

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
    message_buf:        .skip 100
 
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