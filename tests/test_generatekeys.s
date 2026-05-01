.text
.global main
main: 
    SUB sp, sp, #8
    STR lr, [sp, #0]

    BL generateKeys 

    LDR lr, [sp, #0]
    ADD sp, sp, #8
    MOV pc, lr