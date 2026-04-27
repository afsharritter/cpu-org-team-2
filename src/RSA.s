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
 
    LDR  r6, =message_buf
 
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
    enc_str_success:    .asciz "Encryption Complete. Output written to encrypted.txt."
 
    # Decrypt
    prompt_d:           .asciz "Enter private key exponent (d): \n"
    val_d:              .word 0
    val_n:              .word 0
    dec_str_success:    .asciz "Encryption Completed. Output written to plaintext.txt."
 
# END RSA.s