.text
.global main

main:
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
    LDR  r0, =file1_name
    LDR  r1, =mode_r
    BL   fopen
    MOV  r8, r0

    # Open plaintext.txt for writing
    LDR r0, =file2_name
    LDR r1, =mode_w
    BL fopen
    mov r9, r0

    # Load d and n
    LDR  r4, =val_d
    LDR  r4, [r4]

    LDR  r5, =val_n
    LDR  r5, [r5]

    LDR  r6, =message_buf

    # Close files
    MOV r0, r8
    bl fclose

    MOV r0, r9
    bl fclose

    # Print success message
    LDR  r0, =str_success
    BL   printf

    LDR  lr, [sp, #0]
    ADD  sp, sp, #4
    MOV  pc, lr

.data
    prompt_d:           .asciz "Enter private key exponent (d): \n"
    prompt_n:           .asciz "Enter modulus (n): \n"

    fmt_str:            .asciz "%127s"
    fmt_int:            .asciz "%d"

    file1_name:         .asciz "../data/encrypted.txt"
    mode_r:         	.asciz "r"
    file2_name:		.asciz "../data/plaintext.txt"
    mode_2:		.asciz "w"

    val_d:              .word 0
    val_n:              .word 0

    message_buf:        .skip 100

    str_success:        .asciz "Encryption Completed. Output written to plaintext.txt."

    # TODOs:
    # Error if file not found
    # Error if file is empty
    # Check for valid inputs
    # Write d, n to encrypted.txt as well? 
