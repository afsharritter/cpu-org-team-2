.text
.global generateKeys
generateKeys:
    # push the stack
    SUB sp, sp, #16
    STR lr, [sp, #0]
    STR r4, [sp, #4]
    STR r5, [sp, #8]

    generateKeys_prompt_p_loop:
        # prompt user to enter p
        LDR r0, =prompt_p
        BL printf
        # scan user value for p_val
        LDR r0, =fmt_int
        LDR r1, =p_val
        BL scanf

        # call isPrime(p_val) to determine if the value is prime.
        LDR r0, =p_val
        LDR r0, [r0]
        BL isPrime

        # if isPrime(p_val) == 0 [r0], then p_val is prime, branch to generateKeys_prompt_q_loop
        CMP r0, #1
        BEQ generateKeys_prompt_q_loop

        # print error message and loop back to to generateKeys_prompt_p_loop
        LDR r0, =pq_error_msg
        LDR r1, =p_val
        LDR r1, [r1]
        BL printf
        B generateKeys_prompt_p_loop

    generateKeys_prompt_q_loop:
        # prompt user to enter q
        LDR r0, =prompt_q
        BL printf
        # scan user value for q_val
        LDR r0, =fmt_int
        LDR r1, =q_val
        BL scanf

        # call isPrime(q_val) to determine if the value is prime.
        LDR r0, =q_val
        LDR r0, [r0]
        BL isPrime

        # if isPrime(q_val) == 1 [r0], then q_val is prime, branch to generateKeys_calculate_n
        CMP r0, #1
        BEQ generateKeys_calculate_n

        # print error message and loop back to to generateKeys_prompt_q_loop
        LDR r0, =pq_error_msg
        LDR r1, =q_val
        LDR r1, [r1]
        BL printf
        B generateKeys_prompt_q_loop

    generateKeys_calculate_n:
        # Load p_val -> r0 and q_val -> r1, use calcN to calculate phi = p * q
        LDR r0, =p_val
        LDR r0, [r0]
        LDR r1, =q_val
        LDR r1, [r1]
        BL calcN
        # calcN returns n in r0, store it in the n_val variable
        LDR r1, =n_val
        STR r0, [r1]

        # Fall through to generateKeys_calculate_phi
    generateKeys_calculate_phi:
        # Load p_val -> r0 and q_val -> r1, use calcPhi to calculate phi = (p - 1)*( q - 1 )
        LDR r0, =p_val
        LDR r0, [r0]
        LDR r1, =q_val
        LDR r1, [r1]
        BL calcPhi
        # calcPhi return phi in r0, store it in the phi_val variable
        LDR r1, =phi_val
        STR r0, [r1]

    generateKeys_pubexp_loop:
        # prompt user to enter e
        LDR r0, =prompt_e_gen
        LDR r1, =phi_val
        LDR r1, [r1]
        BL printf
        # scan user value for e_val
        LDR r0, =fmt_int
        LDR r1, =e_val
        BL scanf

        # call cpubexp(phi, e) to determine if e is valid
        # load phi_val -> r0, e_val -> r1
        LDR r0, =phi_val
        LDR r0, [r0]
        LDR r1, =e_val
        LDR r1, [r1]
        BL cpubexp

        # if cpubexp return status code != 0, loop back to to generateKeys_pubexp_loop
        CMP r0, #0
        BNE generateKeys_pubexp_loop
        # fall through to generateKeys_privexp
    generateKeys_privexp:
        # Call cprivexp(e, phi) -> d [r0]
        # Load e -> r0, phi -> r1
        LDR r0, =e_val
        LDR r0, [r0]
        LDR r1, =phi_val
        LDR r1, [r1]

        BL cprivexp
        # d is returned in r0, store [r0] in d_val

        LDR r1, =d_val
        STR r0, [r1]

        # fall through to generateKeys_print_keys
    
    generateKeys_print_keys:
        # Print e_val, d_val, and n_val
        LDR r0, =print_keys_msg
        LDR r1, =e_val
        LDR r1, [r1]
        LDR r2, =d_val 
        LDR r2, [r2]
        LDR r3, =n_val
        LDR r3, [r3]
        BL printf
        # Fall through to generateKeys_save_keys
    generateKeys_save_keys:
        # open the file 
        LDR r0, =keys_file_name
        LDR r1, =mode_w
        BL fopen
        # save file pointer in r5
        MOV r5, r0

        # load n_val -> r4 and push onto the stack (to be used by fprint)
        LDR r4, =n_val
        LDR r4, [r4]
        SUB sp, sp, #8
        STR r4, [sp, #0]


        # set up registers r0 -> r3
        MOV r0, r5  @ move file pointer to r0
        LDR r1, =print_keys_msg
        LDR r2, =e_val
        LDR r2, [r2]
        LDR r3, =d_val
        LDR r3, [r3]

        # write to the file using fprintf
        BL fprintf

        # cleanup the stack, no need to pop r4 and r5, since they were not clobbered in fprintf
        ADD sp, sp, #8

        # close the file
        MOV r0, r5
        BL fclose

        # fall through to generateKeys_end
    generateKeys_end:
        # pop the stack
        LDR r5, [sp, #8]
        LDR r4, [sp, #4]
        LDR lr, [sp, #0]
        ADD sp, sp, #16
        MOV pc, lr
# END generateKeys


.data
    # Shared
    fmt_int:            .asciz "%d"
    mode_r:             .asciz "r"
    mode_w:             .asciz "w"
    keys_file_name:    .asciz "../data/keys.txt"

    # Generate Keys
    prompt_p:           .asciz "Enter a prime value for p: "
    prompt_q:           .asciz "Enter a prime value for q: "
    pq_error_msg:       .asciz "Error. The value %d is not prime. Please try again.\n"
    prompt_e_gen:       .asciz "Enter a value for e, such that 1 < e < %d: "
    e_error_msg:        .asciz "Error. The value for e [ %d ] must be greater than 1 and less than %d. Please try again.\n "
    print_keys_msg:     .asciz "Success!\n  Your public key exponent (e) is: %d\n  Your private key exponent (d) is: %d\n  Your modulus (n) is: %d\n"
    p_val:              .word 0
    q_val:              .word 0
    phi_val:            .word 0
    n_val:              .word 0
    e_val:              .word 0
    d_val:              .word 0


    