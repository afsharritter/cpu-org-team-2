# Course Project: ARM Programming RSA Algorithm - Design Document

Course: EN.605.204.81.SP26
Date Created: 2026-02-06
Last Update: 2026-02-06

Team Members:

- Sandra Banaszak
- Elizabeth Fuller
- Savlatjon Khuseynov
- Kangjie Mi
- James Ritter
- Dana Zhang

## Overview & Context

This is a Design Document describes the architecture, module breakdown, function specifications, data flow, and implementation plan for a team-developed ARM Assembly program that implements the RSA (Rivest-Shamir-Adleman) public-key cryptographic algorithm. The document serves as a collaborative blueprint to guide implementation and ensure all team members share a unified understanding before coding begins.

TODO: Add information about the math behind the algorithm (~1 paragraph)

## Scope & Responsibilities

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

Goal 1:

## Proposed Solution & Use Cases

## Technical Architecture

<<<<<<< HEAD
### TODO: Add diagrams here

### TODO: Add detailed function definitions
=======
## Detailed Architecture
>>>>>>> refs/remotes/origin/main

## Alternative Solutions

## Testing

Test Key Generation
Test1 |	p | q 	Expected Behavior	                         Status
Test2 | 7 | 11	Both prime, n=77; proceed to e entry.	     PASS
Test3 | 11| 13	Both prime, n=143; recommended key set.	   PASS
Test4 |	4 |	11	p=4 not prime; prompt user to re-enter p.	 FAIL
Test5 |	7 |	9	  q=9 not prime; prompt user to re-enter q.	 FAIL
Test6 |	1 |	1	  Both rejected (1 is not prime).	           FAIL


## Open Questions

## Timeline

## Team Roles & Responsibilities

- Sandra Banaszak
- Elizabeth Fuller
- Savlatjon Khuseynov
- Kangjie Mi
- James Ritter
- Dana Zhang
