@ Adding basic stack management here for now, please update

.text
.global main
main:
    @ Push the Stack 
    SUB sp, sp, #4          
    STR lr, [sp, #0]

    ## TODO: prompt for user input: generate keys, encrypt, or decrypt?

    ## TODO: Option 1: Generate keys
        ## TODO: prompt user for p + q, limit < 50 and check input

        ## TODO: call cpubexp and cprivexp, output to keys.txt

    ## TODO: Option 2: Encrypt a message: call encrypt, which already saves the encrypted message to encrypted.txt

    ## TODO: Option 3: Decrypt a message: call decrypt, which already saves to plaintext.txt
    
    @ Pop the Stack 
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr
