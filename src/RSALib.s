#
# Program Name: RSALib.s
# Author: Team 2
# Date: 03/05/2026
# Purpose: A code library containing  mathematical functions to implement the RSA algorithm.
#

.global pow_mod
.global pow
.global modulo
.global isPrime
.global gcd
.global calcN
.global calcPhi
.global calcPhiEqual
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


# Function Name: pow_mod
# Modular exponentiation: result = base^exp mod n.
# Reduces mod n at every multiplication to prevent overflow.
# Max intermediate value: (n-1)^2 = 76^2 = 5776 (safe in 32-bit).
# Inputs
# r0: base
# r1: exponent
# r2: modulus n
# Outputs:
#  r0: base^exp mod n
pow_mod:
    # push the stack
    SUB  sp, sp, #20
    STR  lr, [sp, #0]
    STR  r4, [sp, #4]
    STR  r5, [sp, #8]
    STR  r6, [sp, #12]
    STR  r7, [sp, #16]
    # r4 = base
    MOV  r4, r0
    # r5 = exp (loop counter)
    MOV  r5, r1
    #r6 = n
    MOV  r6, r2
    #r7 = result
    MOV  r7, #1

    powmod_loop:
        CMP  r5, #0
        BEQ  powmod_done
        # result = (result * base) mod n
        # r0 = result * base
        MUL  r0, r7, r4
        #r1 = n
        MOV  r1, r6
        BL   modulo
        MOV  r7, r0
        SUBS r5, r5, #1
        B    powmod_loop

    powmod_done:
        MOV  r0, r7
        # pop the stack
        LDR  r7, [sp, #16]
        LDR  r6, [sp, #12]
        LDR  r5, [sp, #8]
        LDR  r4, [sp, #4]
        LDR  lr, [sp, #0]
        ADD  sp, sp, #20
        MOV  pc, lr
#END pow_mod

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

#
# Function Name: calcN
# Purpose: Function to calculate modulus n.
# Inputs:
#   - r0: p
#   - r1: q
# Outputs:
#   - r0: n
#
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

#
# Function Name: calcPhi
# Purpose: Function to calculate Euler totient phi.
# Inputs:
#   - r0: p
#   - r1: q
# Outputs:
#   - r0: phi
#
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

#
# Function Name: calcPhiEqual
# Purpose: Function to calculate phi when p and q are equal.
# Inputs:
#   - r0: p
#   - r1: q
# Outputs:
#   - r0: phi
#
calcPhiEqual:
    SUB sp, sp, #4
    STR lr, [sp, #0]
    # r1 = p-1
    SUB r1, r0, #1
    # r0 = p*(p-1)
    MUL r0, r0, r1
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr
#END calcPhiEqual

#
# Function Name: cprivexp
# Purpose: Function to calculate private exponent, d.
# Inputs:
#   - r0: e
#   - r1: phi
# Outputs:
#   - r0: d
#
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

#
# Function Name: modinv
# Purpose: Function to calculate modular inverse.
# Inputs:
#   - r0: e
#   - r1: phi
# Outputs:
#   - r0: modular inverse
#
modinv:

    @ Push the stack
    SUB sp, sp, #32
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]
    STR r6, [sp, #12]
    STR r7, [sp, #16]
    STR r8, [sp, #20]
    STR r9, [sp, #24]
    @ r4 - phi (in case)
    @ r5 - curr_r
    @ r6 - old_r 
    @ r7 - curr_c
    @ r8 - old_c
    @ r9 - q

    @ Store r1 (phi) in r4 for use in the modinv_handle_negative_old_c, if needed
    MOV r4, r1

    @ Store e (r0) -> curr_r (r5) to init modinv_loop
    MOV r5, r0
    @ Store phi (r1) -> old_r (r6) to init modinv_loop
    MOV r6, r1

    @ Load initial values for old_c (0 -> r8) and curr_c (1 -> r7)
    MOV r7, #1
    MOV r8, #0

    @ Fall through to modinv_loop
    modinv_loop: 
        @ If curr_r (r5) == 0, exit the loop
        CMP r5, #0
        BEQ modinv_loop_complete
        @ fall through to modinv_divide_and_set_r_c:

    modinv_divide_and_set_r_c:
        @ Load old_r (r6) and curr_r (r5) into r0 and r1, respectively and divide
        MOV r0, r6
        MOV r1, r5
        @ Divide r0 = old_r/curr_r and store in q (r9)
        BL __aeabi_idiv
        MOV r9, r0

        @ Calculate new_r in r0 = old_r - q * curr_r (r5)
        MUL r0, r9, r5      @ r0 = q (r9) * curr_r (r5)
        SUB r0, r6, r0      @ r0 = old_r - [q * curr_r]
        @ update old_r (r6) with the value for curr_r (r5) and curr_r (r5) with the "new_r" value in r0
        MOV r6, r5
        MOV r5, r0

        @ get "new_c" (r0) = old_c (r8) - q (r9) * curr_c (r7)
        MUL r0, r9, r7      @ r0 = q(r9) * curr_c(r7)
        SUB r0, r8, r0      @ r0 = old_c(r8) - [q * curr_c)
        @ update old_c (r8) with the value for curr_c(r7) and curr_c(r7) with the "new_c" value in r0
        MOV r8, r7
        MOV r7, r0

        B modinv_loop

    modinv_loop_complete:
        @ Check if old_c (r8) is negative, and if so adjust by adding phi
        CMP r8, #0
        @ If less than 0, branch to modinv_handle_negative_old_c
        BLT modinv_handle_negative_old_c
        
        @ Otherwise move old_c (r8) into r0 to return
        MOV r0, r8
        @ Fall through to modinv_complete

    modinv_complete: 
        @ return the value in r0
        LDR r9, [sp, #24]
        LDR r8, [sp, #20]
        LDR r7, [sp, #16]
        LDR r6, [sp, #12]
        LDR r5, [sp, #8]
        LDR r4, [sp, #4]
        LDR lr, [sp, #0]
        ADD sp, sp, #32
        MOV pc, lr

    modinv_handle_negative_old_c:
        # Update old_c(r8) by Adding phi (r4) to old_c (r8) if old_c is negative
        ADD r8, r8, r4
        B modinv_loop_complete

#END modinv

#
# Function Name: cpubexp
# Purpose: Function to calculate public exponent.
# Inputs:
#   - r0: phi
#   - r1: e
# Outputs:
#   - r0: status code
#
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

    #e must be strictly greater than 1
    CMP r11, #1
    ADDGT r4, #1
    
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
#
# Function Name: gcd
# Purpose: Function to calculate the greatest common divisor of two numbers.
# Inputs:
#   - r0: num1
#   - r1: num2
# Outputs:
#   - r0: greatest common divisor
#
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

.text
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
    # r0=m, r1=e, r2=n -> call pow_mod(m, e, n)
    BL  pow_mod
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
    # r0=c, r1=d, r2=n -> call pow_mod(c, d, n)
    BL  pow_mod
    LDR r5, [sp, #8]
    LDR r4, [sp, #4]
    LDR lr, [sp, #0]
    ADD sp, sp, #12
    MOV pc, lr

#END decrypt

#ENDRSALib.s

