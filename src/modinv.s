.text
.global cprivexp, modinv
cprivexp:
    @ Push the stack
    PUSH {lr} 

    @ Load e and phi
    LDR r0, =e 
    LDR r0, [r0] 
    LDR r1, =phi 
    LDR r1, [r1] 

    @ Call modinv(e, phi), returns d in r0
    BL modinv

    @ Store r0 in d
    LDR r1, =d
    STR r0, [r1]

    @ Pop the stack
    POP {lr}
    BX lr

modinv:
    @ Push the stack
    PUSH {r4, lr}

    @ Store r1 (phi) in r4 for use in the return_old_c_negative, if needed
    MOV r4, r1

    @ Store e (r0) -> curr_r (r2) to init modinv_loop
    LDR r2, =curr_r
    STR r0, [r2]
    @ Store phi (r1) -> old_r (r2) to init modinv_loop
    LDR r2, =old_r
    STR r1, [r2]

    @ Load initial values for old_c and curr_c
    LDR r2, =old_c
    MOV r3, #0
    STR r3, [r2]
    LDR r2, =curr_c
    MOV r3, #1
    STR r3, [r2]

    @ Branch to the modinv_loop
    B modinv_loop


modinv_loop: 
    @ If curr_r == 0, exit the loop
    LDR r0, =curr_r
    LDR r0, [r0]
    CMP r0, #0
    BEQ modinv_loop_complete
    @ otherwise continue to modinv_divide_and_set_r_c:
    B modinv_divide_and_set_r_c

modinv_divide_and_set_r_c:
    @ Load old_r and curr_r into r0 and r1, respectively
    LDR r0, =old_r 
    LDR r0, [r0]
    LDR r1, =curr_r
    LDR r1, [r1]

    @ Divide r0 = old_r/curr_r and store in q
    BL __aeabi_idiv
    @ IMPORTANT!!! r0 now contains q!!! DO NOT OVERWRITE THIS REGISTER

    @ update old_r and curr_r
    LDR r1, =old_r
    LDR r1, [r1]
    LDR r2, =curr_r
    LDR r2, [r2]
    @ get "new_r" (r3) = old_r - q * curr_r
    MUL r3, r0, r2      @ r3 = q * curr_r = r0 * r2
    SUB r3, r1, r3      @ r3 = old_r - (q * curr_r) = r1 - r3
    @ store new values for old_r and curr_r
    LDR r1, =old_r      @ Load the pointer to old_r in r1
    STR r2, [r1]        @ Store [curr_r] (r2) -> old_r (r1)
    LDR r2, =curr_r     @ Load the pointer to curr_r in r2
    STR r3, [r2]        @ Store the value of "new_r" (r3) -> curr_r

    @ update old_c and curr_c
    LDR r1, =old_c
    LDR r1, [r1]
    LDR r2, =curr_c
    LDR r2, [r2]
    @ get "new_c" (r3) = old_c - q * curr_c
    MUL r3, r0, r2      @ r3 = q * curr_c = r0 * r2
    SUB r3, r1, r3      @ r3 = old_c - (q * curr_c) = r1 - r3
    @ store new values for old_c and curr_c
    LDR r1, =old_c      @ Load the pointer to old_c in r1
    STR r2, [r1]        @ Store [curr_c] (r2) -> old_c (r1)
    LDR r2, =curr_c     @ Load the pointer to curr_c in r2
    STR r3, [r2]        @ Store the value of "new_c" (r3) -> curr_c

    B modinv_loop

modinv_loop_complete:
    @ Check if old_c is negative, and if so adjust by adding phi
    LDR r0, =old_c
    LDR r0, [r0]
    CMP r0, #0
    @ If less than 0, branch to return_old_c_negative
    BLT return_old_c_negative
    @ Otherwise branch to modinv_complete
    B modinv_complete

return_old_c_negative:
    LDR r0, =old_c
    LDR r0, [r0]
    #grab phi parked in r4 for this purpose
    ADD r0, r0, r4
    B modinv_complete

modinv_complete: 
    @ return the value in r0
    POP {r4, lr}
    BX lr


.data
    old_r: .word 0
    curr_r: .word 0
    old_c: .word 0
    curr_c: .word 1
    e: .word 11
    phi: .word 192
    d: .word 0