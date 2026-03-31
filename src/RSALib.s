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
.global calc_n
.global calc_phi


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
        MOV r3, r0 // save larger
        MOV r4, r1 // save smaller
        BL __aeabi_idiv // multiplier in r0, dividend in r1, remainder in r3

        MOV r5, #0 // want the remainder to be zero
        CMP r3, r5
        BEQ EndLoop
            # get next value for the next divisor
            MOV r0, r1
            # get value for next dividend
            MOV r1, r3
            B Euclidean

    EndLoop:
        // the final dividend should be in r0 already

    # pop the stack
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr
#END gcd

calc_n:
    # push the stack
    SUB sp, sp, #4
    STR lr, [sp, #0]

    MUL r0, r0, r1 // return the product of the two inputs

    # pop the stack
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr
#END calc_n

calc_phi:
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

#ENDRSALib.s
