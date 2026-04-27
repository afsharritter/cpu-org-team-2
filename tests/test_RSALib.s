#
# Program Name: test_RSALib.s
# Author: Team 2
# Date: 04/17/2026
# Purpose: Automated Unit Testing for RSALib math functions using macro.
#

.syntax unified
.text
.global main

# Macro to avoid repeting
.macro test_1arg func, arg1, msg
    MOV r0, \arg1
    BL \func
    MOV r1, r0
    LDR r0, =\msg
    BL printf
.endm

.macro test_2arg func, arg1, arg2, msg
    MOV r0, \arg1
    MOV r1, \arg2
    BL \func
    MOV r1, r0
    LDR r0, =\msg
    BL printf
.endm

main:
    PUSH {r4, lr}

    # pow(base, exp) Tests
    test_2arg pow.
    test_2arg pow,
    test_2arg pow, 
    test_2arg pow,
    test_2arg pow,

    # modulo(dividend, divisor) Tests
    test_2arg modulo,
    test_2arg modulo,
    test_2arg modulo,
    test_2arg modulo,
    test_2arg modulo,

    # isPrime(p) Tests
    test_1arg isPrime,
    test_1arg isPrime,
    test_1arg isPrime,
    test_1arg isPrime,
    test_1arg isPrime,

    # calcN(p, q) Tests
    test_2arg calcN, 
    test_2arg calcN,
    test_2arg calcN,
    test_2arg calcN,
    test_2arg calcN,

    # calcPhi(p, q) Tests  -> (p-1)(q-1)
    test_2arg calcPhi,
    test_2arg calcPhi,
    test_2arg calcPhi,
    test_2arg calcPhi,
    test_2arg calcPhi,


    # gcd(a, b) Tests
    test_2arg gcd
    test_2arg gcd 
    test_2arg gcd 
    test_2arg gcd
    test_2arg gcd

    LDR r0, =msg_done
    BL printf
    POP {r4, pc}

.data
    # pow
    msg_pow1: .asciz "Pow Test 1: 5^3   | Exp: 125  | Act: %d\n"
    msg_pow2: .asciz "Pow Test 2: 7^0   | Exp: 1    | Act: %d\n"
    msg_pow3: .asciz "Pow Test 3: 0^5   | Exp: 0    | Act: %d\n"
    msg_pow4: .asciz "Pow Test 4: 1^10  | Exp: 1    | Act: %d\n"
    msg_pow5: .asciz "Pow Test 5: 2^10  | Exp: 1024 | Act: %d\n\n"

    # module
    msg_mod1: .asciz "Modulo Test 1: 100 mod 15 | Exp: 10   | Act: %d\n"
    msg_mod2: .asciz "Modulo Test 2: 5 mod 10   | Exp: 5    | Act: %d\n"
    msg_mod3: .asciz "Modulo Test 3: 20 mod 5   | Exp: 0    | Act: %d\n"
    msg_mod4: .asciz "Modulo Test 4: 17 mod 1   | Exp: 0    | Act: %d\n"
    msg_mod5: .asciz "Modulo Test 5: 10 mod 0   | Exp: 0    | Act: %d\n\n"

    # isPrime
    msg_pri1: .asciz "isPrime Test 1: p = 13 | Exp: 1    | Act: %d\n"
    msg_pri2: .asciz "isPrime Test 2: p = 15 | Exp: 0    | Act: %d\n"
    msg_pri3: .asciz "isPrime Test 3: p = 2  | Exp: 1    | Act: %d\n"
    msg_pri4: .asciz "isPrime Test 4: p = 1  | Exp: 0    | Act: %d\n"
    msg_pri5: .asciz "isPrime Test 5: p = 0  | Exp: 0    | Act: %d\n\n"

    # calcN
    msg_n1:   .asciz "calcN Test 1: 7, 11  | Exp: 77   | Act: %d\n"
    msg_n2:   .asciz "calcN Test 2: 5, 5   | Exp: 25   | Act: %d\n"
    msg_n3:   .asciz "calcN Test 3: 13, 1  | Exp: 13   | Act: %d\n"
    msg_n4:   .asciz "calcN Test 4: 17, 0  | Exp: 0    | Act: %d\n"
    msg_n5:   .asciz "calcN Test 5: 47, 43 | Exp: 2021 | Act: %d\n\n"

    # calcPhu
    msg_phi1: .asciz "calcPhi Test 5: 7, 11  | Exp: 60   | Act: %d\n"
    msg_phi2: .asciz "calcPhi Test 5: 13, 17 | Exp: 192  | Act: %d\n"
    msg_phi3: .asciz "calcPhi Test 5: 1, 11  | Exp: 0    | Act: %d\n"
    msg_phi4: .asciz "calcPhi Test 5: 2, 2   | Exp: 1    | Act: %d\n"
    msg_phi5: .asciz "calcPhi Test 5: 47, 43 | Exp: 1932 | Act: %d\n\n"

    # gcd
    msg_gcd1: .asciz "gcd Test 1: 54, 24 | Exp: 6    | Act: %d\n"
    msg_gcd2: .asciz "gcd Test 2: 17, 13 | Exp: 1    | Act: %d\n"
    msg_gcd3: .asciz "gcd Test 3: 15, 15 | Exp: 15   | Act: %d\n"
    msg_gcd4: .asciz "gcd Test 4: 20, 5  | Exp: 5    | Act: %d\n"
    msg_gcd5: .asciz "gcd Test 5: 24, 54 | Exp: 6    | Act: %d\n\n"

    msg_done: .asciz "Tests completed\n"
