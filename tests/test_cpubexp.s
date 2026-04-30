# Program Name: testcpubexp
# Author: Liz Fuller
# Date: 3/13/2026
# Calls:

.text
.global main

main:
    # push the stack
    SUB sp, sp, #4
    STR lr, [sp, #0]

    #  get gcd
    # Prompt for the input
    LDR r0, =prompt1
    BL printf

    # scan for input
    LDR r0, =input1
    LDR r1, =num1
    LDR r2, =num2
    LDR r3, =num3
    BL scanf

    # load input value and convert
    LDR r0, =num1 // get address
    LDR r0, [r0] // tot value
    LDR r1, =num2 // get address
    LDR r1, [r1] // tot value
    LDR r2, =num3 // get address
    LDR r2, [r2] // tot value

    # save p, q, e
    MOV r4, r0
    MOV r5, r1
    MOV r11, r2

    # use p and q to calculate phi
    BL calcPhi // phi is in r0
    MOV r10, r0 // save phi

    # use p and q to calculate n 
    MOV r0, r4
    MOV r1, r5
    BL calcN
    MOV r9, r0 // save n

    # calculate public exponent
    MOV r0, r10 // phi
    MOV r1, r11 // e
    BL cpubexp

    # status code check 
    CMP r0, #1
    BEQ Failure
        # print the results: e, phi, n
        LDR r0, =output1
        MOV r1, r11
        MOV r2, r10
        MOV r3, r9
        BL printf
        B AllDone


    Failure:
        LDR r0, =failure
        BL printf
        MOV r0, #1
        B AllDone


    AllDone:
        # pop the stack
        LDR lr, [sp, #0]
        ADD sp, sp, #4
        MOV pc, lr


.data
    num1: .word 0
    num2: .word 0
    num3: .word 0
    prompt1: .asciz "enter p, q, and e"
    input1: .asciz "%d,%d,%d"
    output1: .asciz "E is: %d\n phi is: %d\n n is %d\n"
    failure: .asciz "The program has failed\n"
