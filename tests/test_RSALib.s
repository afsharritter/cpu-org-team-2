#
# Program Name: test_RSALib.s
# Author: Team 2
# Date: 04/17/2026
# Purpose: Unit Testing for RSALib math functions using macro.
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

.macro test_3arg func, arg1, arg2, arg3, msg
    MOV r0, \arg1
    MOV r1, \arg2
    MOV r2, \arg3
    BL \func
    MOV r1, r0
    LDR r0, =\msg
    BL printf
.endm

# cpubexp(phi, e) returns 0=valid, 1=invalid
# macro saves/restores phi and e to print them alongside result
.macro test_cpubexp phi, e, msg
    MOV r0, \phi
    MOV r1, \e
    BL cpubexp
    MOV r2, r0
    MOV r0, \phi
    MOV r1, \e
    # r0=phi r1=e r2=result — but printf needs fmt in r0
    # so push phi/e, load fmt, then pass as args
    SUB sp, sp, #4
    STR r2, [sp, #0]
    LDR r0, =\msg
    MOV r1, \phi
    MOV r2, \e
    LDR r3, [sp, #0]
    ADD sp, sp, #4
    BL printf
.endm

main:
    # push the stack
    SUB sp, sp, #8
    STR lr, [sp, #0]
    STR r4, [sp, #4]

    # pow_mod(base, exp, n) Tests
    test_3arg pow_mod, #5, #3, #13, msg_pm1
    test_3arg pow_mod, #7, #0, #77, msg_pm2
    test_3arg pow_mod, #33, #7, #77, msg_pm3
    test_3arg pow_mod, #72, #7, #143, msg_pm4
    test_3arg pow_mod, #19, #103, #143, msg_pm5

    # pow(base, exp) Tests
    test_2arg pow, #5, #3, msg_pow1
    test_2arg pow, #7, #0, msg_pow2
    test_2arg pow, #0, #5, msg_pow3
    test_2arg pow, #1, #10, msg_pow4
    test_2arg pow, #2, #10, msg_pow5

    # modulo(dividend, divisor) Tests
    test_2arg modulo, #100, #15, msg_mod1
    test_2arg modulo, #5, #10, msg_mod2
    test_2arg modulo, #20, #5, msg_mod3
    test_2arg modulo, #17, #1, msg_mod4
    test_2arg modulo, #10, #0, msg_mod5

    # isPrime(p) Tests
    test_1arg isPrime, #13, msg_pri1
    test_1arg isPrime, #15, msg_pri2
    test_1arg isPrime, #2, msg_pri3
    test_1arg isPrime, #1, msg_pri4
    test_1arg isPrime, #0, msg_pri5

    # calcN(p, q) Tests
    test_2arg calcN, #7, #11, msg_n1
    test_2arg calcN, #5, #5, msg_n2
    test_2arg calcN, #13, #1, msg_n3
    test_2arg calcN, #17, #0, msg_n4
    test_2arg calcN, #47, #43, msg_n5

    # calcPhi(p, q) Tests  -> (p-1)(q-1)
    test_2arg calcPhi, #7, #11, msg_phi1
    test_2arg calcPhi, #13, #17, msg_phi2
    test_2arg calcPhi, #1, #11, msg_phi3
    test_2arg calcPhi, #2, #2, msg_phi4
    test_2arg calcPhi, #47, #43, msg_phi5

    # gcd(a, b) Tests
    test_2arg gcd, #54, #24, msg_gcd1
    test_2arg gcd, #17, #13, msg_gcd2
    test_2arg gcd, #15, #15, msg_gcd3
    test_2arg gcd, #20, #5, msg_gcd4
    test_2arg gcd, #24, #54, msg_gcd5

    # modinv(e, phi) Tests
    test_2arg modinv, #7, #120, msg_inv1
    test_2arg modinv, #7, #60,  msg_inv2
    test_2arg modinv, #3, #40,  msg_inv3
    test_2arg modinv, #17, #120, msg_inv4
    test_2arg modinv, #11, #60, msg_inv5

    # cprivexp(e, phi) Tests
    test_2arg cprivexp, #7, #120, msg_cp1
    test_2arg cprivexp, #7, #60,  msg_cp2

    # cpubexp(phi, e) Tests — returns 0=valid, 1=invalid
    test_cpubexp #120, #7,  msg_cpub1
    test_cpubexp #60,  #7,  msg_cpub2
    test_cpubexp #120, #1,  msg_cpub3
    test_cpubexp #60,  #60, msg_cpub4
    test_cpubexp #120, #6,  msg_cpub5

    # encrypt(m, e, n) Tests
    test_3arg encrypt, #72, #7, #143, msg_enc1
    test_3arg encrypt, #33, #7, #77,  msg_enc2
    test_3arg encrypt, #97, #7, #143, msg_enc3
    test_3arg encrypt, #1,  #7, #143, msg_enc4
    test_3arg encrypt, #0,  #7, #77,  msg_enc5

    # decrypt(c, d, n) Tests
    test_3arg decrypt, #19,  #103, #143, msg_dec1
    test_3arg decrypt, #33,  #43,  #77,  msg_dec2
    test_3arg decrypt, #59,  #103, #143, msg_dec3
    test_3arg decrypt, #1,   #103, #143, msg_dec4
    test_3arg decrypt, #0,   #43,  #77,  msg_dec5

    LDR r0, =msg_done
    BL printf
    # pop the stack
    LDR r4, [sp, #4]
    LDR lr, [sp, #0]
    ADD sp, sp, #8
    MOV pc, lr

.data
    # pow_mod
    msg_pm1: .asciz "pow_mod Test 1: 5^3 mod 13    | Exp: 8   | Act: %d\n"
    msg_pm2: .asciz "pow_mod Test 2: 7^0 mod 77    | Exp: 1   | Act: %d\n"
    msg_pm3: .asciz "pow_mod Test 3: 33^7 mod 77   | Exp: 33  | Act: %d\n"
    msg_pm4: .asciz "pow_mod Test 4: 72^7 mod 143  | Exp: 19  | Act: %d\n"
    msg_pm5: .asciz "pow_mod Test 5: 19^103 mod 143| Exp: 72  | Act: %d\n\n"

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
    msg_phi1: .asciz "calcPhi Test 1: 7, 11  | Exp: 60   | Act: %d\n"
    msg_phi2: .asciz "calcPhi Test 2: 13, 17 | Exp: 192  | Act: %d\n"
    msg_phi3: .asciz "calcPhi Test 3: 1, 11  | Exp: 0    | Act: %d\n"
    msg_phi4: .asciz "calcPhi Test 4: 2, 2   | Exp: 1    | Act: %d\n"
    msg_phi5: .asciz "calcPhi Test 5: 47, 43 | Exp: 1932 | Act: %d\n\n"

    # gcd
    msg_gcd1: .asciz "gcd Test 1: 54, 24 | Exp: 6    | Act: %d\n"
    msg_gcd2: .asciz "gcd Test 2: 17, 13 | Exp: 1    | Act: %d\n"
    msg_gcd3: .asciz "gcd Test 3: 15, 15 | Exp: 15   | Act: %d\n"
    msg_gcd4: .asciz "gcd Test 4: 20, 5  | Exp: 5    | Act: %d\n"
    msg_gcd5: .asciz "gcd Test 5: 24, 54 | Exp: 6    | Act: %d\n\n"

    # modinv
    msg_inv1: .asciz "modinv Test 1: modinv(7, 120)  | Exp: 103 | Act: %d\n"
    msg_inv2: .asciz "modinv Test 2: modinv(7, 60)   | Exp: 43  | Act: %d\n"
    msg_inv3: .asciz "modinv Test 3: modinv(3, 40)   | Exp: 27  | Act: %d\n"
    msg_inv4: .asciz "modinv Test 4: modinv(17, 120) | Exp: 113 | Act: %d\n"
    msg_inv5: .asciz "modinv Test 5: modinv(11, 60)  | Exp: 11  | Act: %d\n\n"

    # cprivexp
    msg_cp1: .asciz "cprivexp Test 1: cprivexp(7, 120) | Exp: 103 | Act: %d\n"
    msg_cp2: .asciz "cprivexp Test 2: cprivexp(7, 60)  | Exp: 43  | Act: %d\n\n"

    # cpubexp (phi=%d, e=%d) -> status %d  where 0=valid 1=invalid
    msg_cpub1: .asciz "cpubexp Test 1: phi=120, e=7  | Exp: 0 (valid)   | phi=%d e=%d res=%d\n"
    msg_cpub2: .asciz "cpubexp Test 2: phi=60,  e=7  | Exp: 0 (valid)   | phi=%d e=%d res=%d\n"
    msg_cpub3: .asciz "cpubexp Test 3: phi=120, e=1  | Exp: 1 (invalid) | phi=%d e=%d res=%d\n"
    msg_cpub4: .asciz "cpubexp Test 4: phi=60,  e=60 | Exp: 1 (invalid) | phi=%d e=%d res=%d\n"
    msg_cpub5: .asciz "cpubexp Test 5: phi=120, e=6  | Exp: 1 (invalid) | phi=%d e=%d res=%d\n\n"

    # encrypt
    msg_enc1: .asciz "Encrypt Test 1: 72^7  mod 143 | Exp: 19  | Act: %d\n"
    msg_enc2: .asciz "Encrypt Test 2: 33^7  mod 77  | Exp: 33  | Act: %d\n"
    msg_enc3: .asciz "Encrypt Test 3: 97^7  mod 143 | Exp: 59  | Act: %d\n"
    msg_enc4: .asciz "Encrypt Test 4: 1^7   mod 143 | Exp: 1   | Act: %d\n"
    msg_enc5: .asciz "Encrypt Test 5: 0^7   mod 77  | Exp: 0   | Act: %d\n\n"

    # decrypt
    msg_dec1: .asciz "Decrypt Test 1: 19^103  mod 143 | Exp: 72 | Act: %d\n"
    msg_dec2: .asciz "Decrypt Test 2: 33^43   mod 77  | Exp: 33 | Act: %d\n"
    msg_dec3: .asciz "Decrypt Test 3: 59^103  mod 143 | Exp: 97 | Act: %d\n"
    msg_dec4: .asciz "Decrypt Test 4: 1^103   mod 143 | Exp: 1  | Act: %d\n"
    msg_dec5: .asciz "Decrypt Test 5: 0^43    mod 77  | Exp: 0  | Act: %d\n\n"

    msg_done: .asciz "Tests completed\n"
