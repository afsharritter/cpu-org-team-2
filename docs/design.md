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

### TODO: Unit testing strategy

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
