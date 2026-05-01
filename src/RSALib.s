#
# Program Name: RSALib.s
# Author: Team 2
# Date: 03/05/2026
# Purpose: A code library containing  mathematical functions to implement the RSA algorithm.
#

.global pow
.global modulo
.global isPrime
.global gcd
.global calcN
.global calcPhi
.global cpubexp
.global cprivexp
.global modinv
.global encrypt
.global decrypt

.text

#
# Function Name: pow
# Purpose: Function to perform exponentiation.
# Inputs:
#   - r0: Base
#   - r1: Exponent
# Outputs:
#   - r0: Result of base^exp
#
.type pow, %function
pow:
    # Save r4 and lr on stack
    PUSH {r4, lr}
    MOV r4, r0
    MOV r0, #1

    # Check if exponent is 0
    CMP r1, #0
    BEQ .Lpow_end

.Lpow_loop:
    # Multiply result by base and decrement exponent
    MUL r0, r0, r4
    SUBS r1, r1, #1
    BNE .Lpow_loop

.Lpow_end:
    # Return to caller
    POP {r4, pc}
#END OF pow

#
# Function Name: modulo
# Purpose: Function to perform modulo operation.
# Inputs:
#   - r0: Dividend
#   - r1: Divisor
# Outputs:
#   - r0: Remainder
#
.type modulo, %function
modulo:
    # Save Link Register to stack since we are making a BL call inside
    PUSH {lr}
    
    # Check for division by zero
    CMP r1, #0
    BEQ .Lmod_zero

    # Call the math function __aeabi_uidivmod
    BL __aeabi_uidivmod
    
    # Move the remainder into r0 to return it.
    MOV r0, r1
    POP {pc}

.Lmod_zero:
    # Fallback for division by zero
    MOV r0, #0
    POP {pc}
#END OF modulo

#
# Function Name: isPrime
# Purpose: Checks if a given integer is a prime number.
# Inputs:
#   - r0: Integer to check (p)
# Outputs:
#   - r0: 1 if prime, 0 if not prime
#
.type isPrime, %function
isPrime:
    # Save r4, r5, and Link Register to stack
    PUSH {r4, r5, lr}   
    MOV r4, r0          

    # If p <= 1, it is not prime
    CMP r4, #1
    BLE .Lnot_prime

    # If p == 2, it is prime
    CMP r4, #2
    BEQ .Lis_prime

    # Initialize our loop counter (divisor) to 2
    MOV r5, #2          

.Lprime_loop:
    # If our divisor has reached p, we found no factors. It is prime!
    CMP r5, r4
    BGE .Lis_prime      

    # Set up arguments for the modulo function call: p mod divisor
    MOV r0, r4          
    MOV r1, r5          
    BL modulo           

    # Check the remainder returned in r0
    CMP r0, #0
    BEQ .Lnot_prime     

    # Increment divisor and loop again
    ADD r5, r5, #1
    B .Lprime_loop

.Lnot_prime:
    # Return 0 (False)
    MOV r0, #0          
    POP {r4, r5, pc}    

.Lis_prime:
    # Return 1 (True)
    MOV r0, #1          
    POP {r4, r5, pc}
#END OF isPrime

calcN:
    # push the stack
    SUB sp, sp, #4
    STR lr, [sp, #0]

    MUL r0, r0, r1 // return the product of the two inputs

    # pop the stack
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr
#END calc_n

calcPhi:
    # push the stack
    SUB sp, sp, #4
    STR lr, [sp, #0]

    SUB r0, r0, #1 // first value minus 1

    SUB r1, r1, #1 // second value minus 1

    MUL r0, r0, r1 // return the product of (r0 - 1)(r1 - 1)
    
    # pop the stack
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr
#END calc_phi


cprivexp:
    @ Push the stack
    SUB sp, sp, #8
    STR lr, [sp, #0]

    @ Assume e -> r0
    @ Assume phi -> r1
    @ Call modinv(e, phi), returns d in r0
    BL modinv
    @ modinv returns d in r0

    @ Pop the stack
    LDR lr, [sp, #0]
    ADD sp, sp, #8
    MOV pc, lr
#END cprivexp


modinv:
    @ Push the stack
    SUB sp, sp, #8
    STR lr, [sp, #0]
    STR r4, [sp, #4]

    @ Store r1 (phi) in r4 for use in the modinv_handle_negative_old_c, if needed
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

    @ Fall through to modinv_loop
    modinv_loop: 
        @ If curr_r == 0, exit the loop
        LDR r0, =curr_r
        LDR r0, [r0]
        CMP r0, #0
        BEQ modinv_loop_complete
        @ fall through to modinv_divide_and_set_r_c:


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
        @ If less than 0, branch to modinv_handle_negative_old_c
        BLT modinv_handle_negative_old_c
        @ Fall through to modinv_complete

    modinv_complete: 
        @ return the value in r0
        LDR r4, [sp, #4]
        LDR lr, [sp, #0]
        ADD sp, sp, #8
        MOV pc, lr

    modinv_handle_negative_old_c:
        LDR r0, =old_c
        LDR r0, [r0]
        # grab phi parked in r4 for this purpose
        ADD r0, r0, r4
        B modinv_complete

#END modinv

cpubexp:
    # push the stack
    SUB sp, sp, #4
    STR lr, [sp, #0]

    # assume phi is in r0, e is in r1
    MOV r10, r0 // save phi
    MOV r11, r1 // save e
    
    # if e is not postive, greater than phi, or if they are not coprime, return an error
    # init logical variables:
    MOV r4, #0 //positive
    MOV r5, #0  //less than phi
    MOV r6, #0 //
    MOV r7, #0 //coprime 

    CMP r11, #0
    ADDGE r4, #1
    
    CMP r11, r10
    ADDLE r5, #1

    AND r6, r4, r5
    CMP r6, #1
    BNE Error1 
        BL gcd // phi in r0 and e in r1
        CMP r0, #1
        BGT Error2
            # update status code
            MOV r0, #0
            B EndFunction 
    Error1:
        # output error and return status code
        LDR r0, =error1
        BL printf
        MOV r0, #1
        B EndFunction

    Error2: 
        # output error and return status code
        LDR r0, =error2
        BL printf
        MOV r0, #1
        B EndFunction

    EndFunction:

    # pop the stack
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr

.text
gcd:
    # push the stack
    SUB sp, sp, #4
    STR lr, [sp, #0]

    # use the euclidean algorithm to determine the gcd
    # find the larger number, put larger in r0 and smaller in r1
    CMP r0, r1
    BGE Euclidean
        EOR r0, r0, r1
        EOR r1, r0, r1
        EOR r0, r0, r1
    
    # divide the larger by the smaller, then divide each subsequent result by the remainder
    Euclidean:
        MOV r4, r0 // save larger
        MOV r5, r1 // save smaller
        BL __aeabi_idiv
        MUL r6, r0, r5 // actual product
        SUB r7, r4, r6 // remainder

        MOV r8, #0 // want the remainder to be zero
        CMP r7, r8
        BEQ EndLoop
            # get next value for the next divisor
            MOV r0, r5
            # get value for next dividend
            MOV r1, r7
            B Euclidean

    EndLoop:
        MOV r0, r5 // put the smaller back in r0
        // the final dividend should be in r0 already

    # pop the stack
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr
#END gcd

.data
    error1: .asciz "The value of e is not positive or is greater than phi. \n"
    error2: .asciz "Phi and e are not coprime. \n"
    old_r: .word 0
    curr_r: .word 0
    old_c: .word 0
    curr_c: .word 1

#
# Function Name: encrypt
# Purpose: Encrypts a single plaintext character using RSA.
#          Computes c = m^e mod n by calling pow then modulo.
# Inputs:
#   - r0: m (plaintext character as integer)
#   - r1: e (public key exponent)
#   - r2: n (modulus)
# Outputs:
#   - r0: c (ciphertext integer)
#

.type encrypt, %function
encrypt:
    SUB sp, sp, #12
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]
    MOV r4, r1
    MOV r5, r2
    BL  pow
    MOV r1, r5
    BL  modulo
    LDR r5, [sp, #8]
    LDR r4, [sp, #4]
    LDR lr, [sp, #0]
    ADD sp, sp, #12
    MOV pc, lr
#END encrypt
 

#
# Function Name: decrypt
# Purpose: Decrypts a single ciphertext integer using RSA.
#          Computes m = c^d mod n by calling pow then modulo.
# Inputs:
#   - r0: c (ciphertext integer)
#   - r1: d (private key exponent)
#   - r2: n (modulus)
# Outputs:
#   - r0: m (plaintext character as integer)
#

.type decrypt, %function
decrypt:
    SUB sp, sp, #12
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]
    MOV r4, r1
    MOV r5, r2
    BL  pow
    MOV r1, r5
    BL  modulo
    LDR r5, [sp, #8]
    LDR r4, [sp, #4]
    LDR lr, [sp, #0]
    ADD sp, sp, #12
    MOV pc, lr
    
#END decrypt

#ENDRSALib.s

