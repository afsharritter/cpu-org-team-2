# Program Name: EncryptMain.s
# Author: Team 2
# Date: 03/15/2026
# Purpose: Handles user I/O for RSA encryption.
#               Prompts for a plaintext message, public key exponent e,
#               and modulus n. Calls encrypt() and writes results
#               to encrypted.txt.

.text
.global main

main:
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
    LDR  r0, =file_name
    LDR  r1, =file_mode
    BL   fopen      
    MOV  r8, r0

    # Load e and n
    LDR  r4, =val_e
    LDR  r4, [r4]

    LDR  r5, =val_n
    LDR  r5, [r5]

    LDR  r6, =message_buf

    # Close file
    MOV r0, r8
    bl fclose

    # Print success message
    LDR  r0, =str_success
    BL   printf
 
    LDR  lr, [sp, #0]
    ADD  sp, sp, #4
    MOV  pc, lr

.data
    prompt_message:	.asciz "Enter plaintext message: \n"
    prompt_e:       	.asciz "Enter public key exponent (e): \n"
    prompt_n:       	.asciz "Enter modulus (n): \n"

    fmt_str: 		.asciz "%127s"
    fmt_int:		.asciz "%d"

    file_name:		.asciz "../data/encrypted.txt"
    file_mode:		.asciz "w"

    val_e:		.word 0
    val_n:		.word 0
    
    message_buf:	.skip 100

    str_success:	.asciz "Encryption Complete. Output written to encrypted.txt."
