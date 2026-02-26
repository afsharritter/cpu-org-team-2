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

RSA is an asymmetric cryptography system used to generate a public and private key pair for encryption and decryption. This key pair has multiple uses, including digital signatures and symmetric key exchanges. Generating a key pair begins with selecting two distinct, large prime numbers, p and q. For this example, we are going to use small prime numbers p = 11 and q = 13. From these numbers, we can generate a modulus n = p * q = 143 by taking the product of the two chosen prime numbers. Next, we take the lowest common multiple (LCM) of p - 1 and q - 1. Here, LCM(10, 12) = 60. We will call this function λ(n)(lambda(n)). We then choose an integer e strictly greater than 2 and strictly less than λ(n) (so, 2 < e < λ(n)). The greatest common divisor of e and λ(n) must be equal to 1, meaning e and λ(n) are coprime. In this case, our encryption exponent is e = 7. From this, we can calculate the decryption exponent d such that d = 1 * mod(λ(n)). Hence, d = 43. Now we have a public key formed from the modulus n and the encryption exponent e, and a private key formed from the modulus n and the decryption exponent d. Everything calculated should remain a secret except for n and e, which form the public key. Now, a third party can encrypt some plaintext with our public key, and we can decrypt it using our private key.

## Scope & Responsibilities (James)

### In Scope

- The program will prompt the user to enter values for `p`, `q`, and `e`, generate the public and private keys, and display them to the user.
- The program will prompt the user to enter a message, encrypt it, and save it in the file called `encrypted.txt`.
- The program will open the file called `encrypted.txt`, decrypt it, and save it in the file called `decrypted.txt`.
- TODO: Add more in scope if necessary

### Out of Scope

- The program will not accept `p` and `q` values larger than 50.
- The program will not generate `e`. It will prompt the user to enter this value.
- TODO: Add more out of scope if necessary

### Responsibilities

TODO: Summarize the project requirements document and explain the general workflow of the program.

## Goals & Milestones

### Goals (James)

- Milestone : Complete Software Design Doc & Technical Architecture Plan
- Milestone : Display Prompts for User Actions
- Milestone : Generate Public & Private Keys
- Milestone : Encrypt a Message
- Milestone : Decrypt a Message
- Milestone : Collaborate with another group to test our program

## Proposed Solution & Use Cases (Elizabeth)

## Technical Architecture

### TODO: Add diagrams here (James w/ input from the group)

### TODO: Add detailed function definitions here (All team members)


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
- Encryption	Enter a string "Hello from TEAM x" -> Converts characters to ASCII, encrypts each separately, and writes to "encrypted.txt".

## Open Questions

## Timeline (Elizabeth)

Software Design Doc Due: Mar 1

Try to coordinate w/ another group by April 15
Final Project Due: May 3

## Team Roles & Responsibilities

- Sandra Banaszak - Encrypt/Decrypt (RSA Lib pow(), mod())
- Elizabeth Fuller - Generate Public (RSA Lib gcd(), calc_n(), calc_phi(), cpubexp())
- Savlatjon Khuseynov - UI/Orchestration Portion (RSA Lib isPrime())
- James Ritter - Generate Private Keys (RSA Lib cprivexp()), I/O
- Kangjie Mi -
- Dana Zhang -
