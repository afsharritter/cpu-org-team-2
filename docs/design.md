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

## Overview & Context

This is a Design Document describes the architecture, module breakdown, function specifications, data flow, and implementation plan for a team-developed ARM Assembly program that implements the RSA (Rivest-Shamir-Adleman) public-key cryptographic algorithm. The document serves as a collaborative blueprint to guide implementation and ensure all team members share a unified understanding before coding begins.

TODO: Add information about the math behind the algorithm (~1 paragraph) (Savlatjon / Sandra)

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

- Milestone : Complete Software Design Doc & Technical Architecture Plan
- Milestone : User prompting and general program flow completed
- Milestone : Public & Private Key Generation functionality completed and tested
- Milestone : Encryption functionality completed and tested
- Milestone : Decryption functionality completed and tested
- Milestone : Perform end-to-end program testing
- Milestone : Collaborate with another group to test our program

## Proposed Solution & Use Cases (Elizabeth)

## Technical Architecture

### TODO: Add diagrams here (James w/ input from the group)

### TODO: Add detailed function definitions here (All team members)

- cprivexp(e, phi): Computes and returns the RSA private exponent `d` such that $d = (1 + x * phi) / e$ (d is the modular inverse of `e mod phi`).
  - inputs: r0 -> e, r1 -> phi
  - outputs: r0 -> d

## Testing (Savlatjon)

Test Key Generation
Test1 | p | q Expected Behavior Status
Test2 | 7 | 11 Both prime, n=77; proceed to e entry. PASS
Test3 | 11| 13 Both prime, n=143; recommended key set. PASS
Test4 | 4 | 11 p=4 not prime; prompt user to re-enter p. FAIL
Test5 | 7 | 9 q=9 not prime; prompt user to re-enter q. FAIL
Test6 | 1 | 1 Both rejected (1 is not prime). FAIL

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
