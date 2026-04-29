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
 
    # Load e and n
    LDR  r4, =val_e
    LDR  r4, [r4]
 
    LDR  r5, =val_n
    LDR  r5, [r5]
 
    LDR  r6, =message_buf

    # Loop each character of the plaintext message
enc_char_loop:
    LDRB r7, [r6]
    CMP  r7, #0
    BEQ  enc_char_loop_end
 
    # encrypt(m, e, n) -> r0 = c
    MOV  r0, r7
    MOV  r1, r4
    MOV  r2, r5
    BL   encrypt
 
    # fprintf(file, "%d ", c)
    MOV  r2, r0
    LDR  r1, =fmt_cipher
    MOV  r0, r8
    BL   fprintf
 
    ADD  r6, r6, #1
    B    enc_char_loop

 enc_char_loop_end:
    # Write trailing newline
    LDR  r1, =fmt_newline
    MOV  r0, r8
    BL   fprintf
    
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
    CMP  r0, #0
    BEQ  dec_err_no_file
    MOV  r8, r0
 
    # Read contents into read_buf
    LDR  r0, =read_buf
    MOV  r1, #1
    MOV  r2, #512
    MOV  r3, r8
    BL   fread
    MOV  r10, r0
 
    # Close encrypted.txt
    MOV  r0, r8
    BL   fclose
 
    # Check if file was empty
    CMP  r10, #0
    BEQ  dec_err_empty
 
    # Null-terminate the buffer
    LDR  r0, =read_buf
    ADD  r0, r0, r10
    MOV  r1, #0
    STRB r1, [r0]
 
    # Open plaintext.txt for writing
    LDR  r0, =plain_file_name
    LDR  r1, =mode_w
    BL   fopen
    CMP  r0, #0
    BEQ  dec_err_no_plain
    MOV  r9, r0
 
    # Load d and n
    LDR  r4, =val_d
    LDR  r4, [r4]
 
    LDR  r5, =val_n
    LDR  r5, [r5]
 
    LDR  r6, =read_buf
 
    #  token loop: parse each integer, decrypt, write char
dec_token_loop:
    # Skip spaces
dec_skip_spaces:
    LDRB r7, [r6]
    CMP  r7, #0
    BEQ  dec_token_loop_end
    CMP  r7, #' '
    BNE  dec_parse_token
    ADD  r6, r6, #1
    B    dec_skip_spaces
 
    # Parse integer from buffer
dec_parse_token:
    # Skip newlines and carriage returns too
    CMP  r7, #10
    BEQ  dec_skip_char
    CMP  r7, #13
    BEQ  dec_skip_char
 
    # Manual integer parse
    MOV  r7, #0 

dec_parse_loop:
    LDRB r0, [r6]
    CMP  r0, #'0'
    BLT  dec_parse_done
    CMP  r0, #'9'
    BGT  dec_parse_done
    MOV  r1, #10
    MUL  r7, r7, r1
    SUB  r0, r0, #'0'
    ADD  r7, r7, r0
    ADD  r6, r6, #1
    B    dec_parse_loop
 
dec_parse_done:
    # decrypt(c, d, n) -> r0 = m
    MOV  r0, r7
    MOV  r1, r4
    MOV  r2, r5
    BL   decrypt
 
    # fprintf(plaintext.txt, "%c", m)
    MOV  r2, r0
    LDR  r1, =fmt_char
    MOV  r0, r9
    BL   fprintf
 
    B    dec_token_loop
 
dec_skip_char:
    ADD  r6, r6, #1
    B    dec_token_loop
 
dec_token_loop_end:
    # Close plaintext.txt
    MOV  r0, r9
    BL   fclose
 
    # Print decrypted message to stdout
    LDR  r0, =dec_msg_hdr
    BL   printf
 
    # Re-open plaintext.txt to read and display
    LDR  r0, =plain_file_name
    LDR  r1, =mode_r
    BL   fopen
    MOV  r8, r0
 
    LDR  r0, =message_buf
    MOV  r1, #1
    MOV  r2, #127
    MOV  r3, r8
    BL   fread
 
    # Null-terminate what was read
    LDR  r1, =message_buf
    ADD  r1, r1, r0
    MOV  r2, #0
    STRB r2, [r1]
 
    MOV  r0, r8
    BL   fclose
 
    LDR  r0, =message_buf
    BL   printf
 
    LDR  r0, =fmt_newline
    BL   printf
 
    # Print success message
    LDR  r0, =dec_str_success
    BL   printf
 
    B    dec_return
 
dec_err_no_file:
    LDR  r0, =dec_err_file_msg
    BL   printf
    B    dec_return
 
dec_err_empty:
    LDR  r0, =dec_err_empty_msg
    BL   printf
    B    dec_return
 
dec_err_no_plain:
    LDR  r0, =dec_err_plain_msg
    BL   printf
    B    dec_return
 
dec_return:
    LDR  lr, [sp, #0]
    ADD  sp, sp, #4
    MOV  pc, lr
 
#END decryptMain

.data
    # Shared
    prompt_n:           .asciz "Enter modulus (n): \n"
    fmt_str:            .asciz "%127s"
    fmt_int:            .asciz "%d"
    fmt_cipher:         .asciz "%d "
    fmt_char:           .asciz "%c"
    fmt_newline:        .asciz "\n"
    mode_r:             .asciz "r"
    mode_w:             .asciz "w"
    enc_file_name:      .asciz "../data/encrypted.txt"
    plain_file_name:    .asciz "../data/plaintext.txt"
    message_buf:        .skip 128
 
    # Encrypt
    prompt_message:     .asciz "Enter plaintext message: \n"
    prompt_e:           .asciz "Enter public key exponent (e): \n"
    val_e:              .word 0
    enc_str_success:    .asciz "Encryption Complete. Output written to encrypted.txt."
 
    # Decrypt
    prompt_d:           .asciz "Enter private key exponent (d): \n"
    val_d:              .word 0
    val_n:              .word 0
    read_buf:           .skip 513
    dec_msg_hdr:        .asciz "\nDecrypted message:\n"
    dec_str_success:    .asciz "Decryption Complete. Output written to plaintext.txt.\n"
    dec_err_file_msg:   .asciz "Error: encrypted.txt not found.\n"
    dec_err_empty_msg:  .asciz "Error: encrypted.txt is empty.\n"
    dec_err_plain_msg:  .asciz "Error: Could not open plaintext.txt for writing.\n"
 
# END RSA.s