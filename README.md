# Course Project: ARM Programming RSA Algorithm - Team 2

Repository for the course project on _ARM programming of the RSA algorithm_ for EN.605.204.81.SP26.

**Team 2 Members**:

- Sandra Banaszak
- Elizabeth Fuller
- Savlatjon Khuseynov
- Kangjie Mi
- James Ritter
- Dana Zhang

## To Do List

### Part 1: Due 2026-03-01

#### Design Document

- [ ] Decide on format for design document (e.g., Git + Markdown, shared MS Word)
- [ ] Agree on design document template
- [ ] Assign sections of the design document to team members
- [ ] Create initial draft of the design document
- [ ] Review and finalize the design document

#### RSA Algorithm Planning

- [ ] Develop solution for RSA algorithm in ARM assembly
- [ ] Design technical architecture for the implementation
- [ ] Assign implementation tasks to team members
- [ ] Create timeline for implementation and testing
- [ ] Identify testing strategy for RSA implementation

### Part 2:

#### Implementation

- [ ] Implement the required functions for the RSA algorithm in ARM assembly
- [ ] Integrate the implemented functions into a complete RSA algorithm
- [ ] Test the implementation for correctness and performance
- [ ] Extra Credit Opportunity: Identify another team to exchange messages with.

## Minimum Requirements

1. Display prompts for user actions:
   - [ ] Generate Private & Public keys
   - [ ] Encrypt a message
   - [ ] Decrypt a message
2. Generate Private & Public keys
   - [ ] Display prompts to input two positive integers **p** and **q**. For simplicity, let's keep p < 50 and q < 50. Can be larger if implementing the function for large values.
   - [ ] Check if both integers are prime
   - [ ] Calculate the modulus **n** for the public & private keys: **n = p \* q**
   - [ ] Calculate the totient **Φ(n) = (p - 1)(q - 1)**
   - [ ] Display a prompt and input a small public key exponent value **e**
   - [ ] Implement the following parameters for the public key exponent **e**
     - [ ] **e** must be a postive integer
     - [ ] 1 < **e** < **Φ(n)**
     - [ ] **e** is co-prime to **Φ(n)**. This means that e and Φ(n) share no common factors other than 1. In other words, **gcd(e, Φ(n)) = 1**. gcd : greatest common divisor

   - [ ] Write an ARM function, cpubexp for calculating the public key exponent. Additionally, write an ARM **gcd** function to find the greatest common divisor used in calculating the public key exponent.
   - [ ] Calculate the private key exponent **d** such that **de ≡ 1 (mod Φ(n)) → d = (1 + x \* Φ(n)) / e** for some integer **x**.

3. Encrypt a message
   - [ ] Prompt to enter a message for encryption
     - Example: “Hello from TEAM x” (where x is your team number) or some similar short message
   - [ ] Using the message you have input, determine the ascii equivalent for each character. The numeric ascii value will be used for encryption/decryption purposes. For simplicity, you can encrypt each character separately. I also recommend spaces between each output value so reading will be easier. Your encrypted message should be written to a file called “encrypted.txt”. Make sure you open and close the file properly.
   - We will use the following equation to encrypt the characters of our message. Using our public key values (n, e) for the equation **c = m^e mod n** we have the following:
     - **c** is our cipher text (encrypted text) value
     - **m** is the individual plaintext character of our message “H”,”e”,”l”,”l”,”o”,” “,”f”,”r”,”o”,”m”,” “, “T”,”E”,”A”,"M”,” “,”x” or whatever small message you chose.
     - **e** is the public key exponent from step 2
     - **n** is the calculated modulus from step 2 for our public and private keys
4. Decrypt a message
   - [ ] Open and read the file “encrypted.txt” that contains encrypted text
   - [ ] We will use the following equation to decrypt the characters of our message. Using our private key values (n, d) for the equation **m = 𝒄𝒅 mod n** we have the following:
     - **m** is the decrypted individual plaintext character of our message – should be “H”,”e”,”l”,”l”,”o”,” “,”f”,”r”,”o”,”m”,” “, “T”,”E”,”A”,”M”,” “,”x” or whatever small message you chose.
     - **c** is our cipher text (encrypted text) value
     - **d** is our private key exponent from step 2
     - **n** is the calculated modulus from step 2 for our public and private keys.
   - [ ]Write your decrypted message to a file called “plaintext.txt”
5. Bonus: Since the RSA algorithm is intended for data exchange between parties using private and public keys, try exchanging a message with another team. Find another team that is willing to try the exchange, generate the necessary keys, exchange the appropriate keys, exchange the encrypted file, decrypt the file to obtain the plaintext message. Provide evidence demonstrating the exchange worked. (Information about the team you exchanged with, screenshots, files, etc…)

## Deliverables

### Part 1: Due 2026-03-01

Create and submit a software design document that maps out your team solution. Please submit your team RSA design document in a DOC or PDF file named <YourJHEDID>\_team#\_RSADesignDoc. Each member of a team should submit the same design document.

### Part 2: Due 2026-05-03

- A code library containing **at a minimum** the following functions:
  - [ ] **gcd** – function to find the greatest common divisor
  - [ ] **pow** – function to perform exponentiation
  - [ ] **modulo** – function to perform modulo operation
  - [ ] **cpubexp** – function for all calculations related to the public key exponent
  - [ ] **cprivexp** – function for all calculations related to the private key exponent
  - [ ] **encrypt** – function to perform encryption
  - [ ] **decrypt** – function to perform decryption
- [ ] A main program used to pull everything together as a functioning application.
- [ ] Screenshots, files, etc… that demonstrate your program functioning properly as defined by the requirements.
