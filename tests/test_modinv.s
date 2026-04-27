.text
.global main
.extern modinv
main:
    @ Push the stack
    PUSH {lr}

    @ set e, phi, and d_exp
    LDR r0, =e_in
    MOV r1, #11
    STR r1, [r0]
    LDR r0, =phi
    MOV r1, #192
    STR r1, [r0]
    LDR r0, =d_exp
    MOV r1, #35
    STR r1, [r0]

    @ Load e and phi
    LDR r0, =e_in
    LDR r0, [r0]
    LDR r1, =phi
    LDR r1, [r1]

    @ Call modinv
    BL modinv           @ returns d in r0

    @ Store d_out
    LDR r1, =d_out
    STR r0, [r1]

    @ Load d_exp in r1
    LDR r1, =d_exp
    LDR r1, [r1]
    CMP r0, r1
    BNE main_false
    
main_true:
    LDR r0, =passed_text
    LDR r1, =d_out
    LDR r1, [r1]
    BL printf
    B main_end


main_false:
    LDR r0, =passed_text
    LDR r1, =d_out
    LDR r1, [r1]
    BL printf
    B main_end


main_end:
    @ Pop the stack
    POP {lr}
    BX lr


.data
    e_in: .word 11
    phi: .word 192
    d_out: .word 0
    d_exp: .word 35
    passed_text: .asciz "PASSED: e = 11, phi = 192, d_exp = 35, d_out = %d\n"
    failed_text: .asciz "FAILED: e = 11, phi = 192, d_exp = 35, d_out = %d\n"


