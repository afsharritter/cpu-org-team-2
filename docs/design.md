# Course Project: ARM Programming RSA Algorithm - Design Document

Course: EN.605.204.81.SP26
Date Created: 2026-02-06
Last Update: 2026-02-06

Team Members:

- Sandra Banaszak
- Elizabeth Fuller
- Savlatjon Khuseynov
- James Ritter
- Kangjie Mi
- Dana Zhang

## Overview & Context (Savlatjon)

This design document describes the architecture, module breakdown, function specifications, data flow, and implementation plan for a team-developed ARM Assembly program that implements the RSA (Rivest-Shamir-Adleman) public-key cryptographic algorithm. The document serves as a collaborative blueprint to guide implementation and ensure all team members share a unified understanding before coding.

RSA is an asymmetric cryptography system used to generate a public and private key pair for encryption and decryption. This key pair has multiple uses, including digital signatures and symmetric key exchanges. Generating a key pair begins with selecting two distinct, large prime numbers, p and q. For this example, we are going to use small prime numbers p = 11 and q = 13. From these numbers, we can generate a modulus n = p _ q = 143 by taking the product of the two chosen prime numbers. Next, we take the lowest common multiple (LCM) of p - 1 and q - 1. Here, LCM(10, 12) = 60. We will call this function λ(n)(lambda(n)). We then choose an integer e strictly greater than 2 and strictly less than λ(n) (so, 2 < e < λ(n)). The greatest common divisor of e and λ(n) must be equal to 1, meaning e and λ(n) are coprime. In this case, our encryption exponent is e = 7. From this, we can calculate the decryption exponent d such that d = 1 _ mod(λ(n)). Hence, d = 43. Now we have a public key formed from the modulus n and the encryption exponent e, and a private key formed from the modulus n and the decryption exponent d. Everything calculated should remain a secret except for n and e, which form the public key. Now, a third party can encrypt some plaintext with our public key, and we can decrypt it using our private key.

## Scope & Responsibilities (James)

### In Scope

- The program will prompt the user to enter values for `p`, `q`, and `e`, generate the public and private keys, and display them to the user.
- The program will prompt the user to enter a message, encrypt it, and save it in the file called `encrypted.txt`.
- The program will open the file called `encrypted.txt`, decrypt it, and save it in the file called `decrypted.txt`.

### Out of Scope

- The program will not accept `p` and `q` values larger than 50.
- The program will not generate `e`. It will prompt the user to enter this value.
- The program will not allow the user to read the encrypted file from a custom path.
- The program will not allow the user to save the decrypted file at a custom path.

### Responsibilities

This program will have the following responsibilities:

1. Display a menu prompting the user to:
   a. Generate public/private keys.
   b. Encrypt a message.
   c. Decrypt a file.
2. Generate Private and Public Keys
   a. Prompt the user to enter values for `p`, `q`, and `e`.
   b. Check if `p` and `q` are prime.
   c. Calculate `n = p * q`
   d. Calculate `phi = (p - 1) * (q - 1)`
   e. Validate that `e` is a positive integer, $1 < e < phi$, and `e` is coprime to `phi` through the function called `cpubexp`
   f. Calculate the private key `d` such that $d = (1 + x * phi) / e$.
3. Encrypt a message
   a. Prompt the user to enter a message.
   b. Encrypt each character in sequence via the `encrypt` function.
   c. Save the encrypted message in a file called `encrypted.txt`.
4. Decrypt a message
   a. Open the file called `encrypted.txt`.
   b. Decrypt each character in sequence using the `decrypt` function.
   c. Save the decrypted message in a file called `decrypted.txt`.

## Goals & Milestones

### Goals (James)

- Goal 1: Deliver a working RSA encoder/decoder in ARM32 assembly that meets all project requirements listed above.
- Goal 2: Maintain a clean separation of concerns between the main program (user interaction, program flow, filesystem) and the RSALib.s library (encryption/decryption math routines).
- Goal 3: Ensure correctness and readability through incremental testing at each major feature milestone.
- Goal 4: Validate robustness by testing with another group’s implementation and handling invalid inputs gracefully.

### Milestones (James)

- Milestone 1 - Software Design Doc
- Milestone 2, Components of Use Case 1 - Validate p and q with isPrime(), calc_n(), calc_phi(), gcd(), isValid_e(), modinv(), save to file
- Milestone 3, Components of Use Cases 2 and 3 - prompt for user input, read from file, pow(), mod(), numeric to ascii conversion
- Milestone 4, Modular implementation of Use cases 1/2/3 without looping - prompt for user for use case, proceeed to call use case modules that fail on invalid input
- Milestone 5 - Implement looping and codify functional testing
- Milestone 6 - Bonus Opportunity for message exchange with another group

## Proposed Solution & Use Cases (Elizabeth)

## Technical Architecture

Diagrams (James)

- Key generation
<img width="1769" height="4730" alt="generate_keys" src="https://github.com/user-attachments/assets/e97839c2-9359-4135-8047-7e28955707d7" />

- Message enryption
<img width="1635" height="2263" alt="encrypt_message" src="https://github.com/user-attachments/assets/cdd9fdad-62fb-4f36-b54a-e491484d5984" />

- Message decryption
<img width="1634" height="2263" alt="decrypt_message" src="https://github.com/user-attachments/assets/ca09b6b4-951d-4841-8d09-565e0789d975" />


### TODO: Add detailed function definitions here (All team members)
- `pow(n, e)`: Computes and returns exponentiation.
  - inputs: r0 -> n, r1 -> e
  - outputs: r0 -> n^e
    
- `isPrime(n)`: Check for a prime number and returns 1('true') or 0('false').
  - inputs: r0 -> n
  - outputs: r0 -> 0(false), 1(true)
    
- `cprivexp(e, phi)`: Computes and returns the RSA private exponent `d` such that $d = (1 + x * phi) / e$ (d is the modular inverse of `e mod phi`).
  - inputs: r0 -> e, r1 -> phi
  - outputs: r0 -> d

## Testing (Savlatjon)

Testing Strategy
The proposed testing plan - we will test our application on three different levels: unit testing for individual functions of the RSA library, orchestration/UI validation for input validation, and finally end-to-end testing for file handling and flow of the algorithm. We have also considered the ARM architecture for our system; thus, we will carry out our validation directly on the Mystic Beast server.

Our phases for testing will be as follows:

1. Unit Validation - This involves validating individual functions such as isPrime(), gcd(), pow(), etc.
2. Orchestration/UI Validation - This involves validating our main program to ensure it is prompting the user appropriately, validating input appropriately (e.g., input values for prime numbers must be less than or equal to 50), etc.
3. End-to-End (Integration) Testing - This involves validating our main program to ensure it can successfully encrypt a message entered by the user, save it appropriately to a file named encrypted.txt, read it back appropriately, decrypt it, and save it to a file named plaintext.txt.

Examples:

Unit tests

- isPrime(11, 13) -> True.
- isPrime(9, 1) -> False.
- gcd(7, 120) -> 1.

UI/Input tests

- p or q > 50 -> Prompts user to re-enter the value.

End-to-End tests

- Encryption Enter a string "Hello from TEAM x" -> Converts characters to ASCII, encrypts each separately, and writes to "encrypted.txt".

## Open Questions

## Timeline (Elizabeth)

Software Design Doc Due: Mar 1

Try to coordinate w/ another group by April 15
Final Project Due: May 3

## Team Roles & Responsibilities

- Sandra Banaszak - Encrypt/Decrypt (RSA Lib pow(), mod())
- Elizabeth Fuller - Generate Public (RSA Lib gcd(), calc_n(), calc_phi(), cpubexp())
- Savlatjon Khuseynov - Testing (RSA Lib isPrime())
- James Ritter - Generate Private Keys (RSA Lib cprivexp(), modinv()), I/O
- Kangjie Mi - CLI/program branching logic
- Dana Zhang - Unit tests
