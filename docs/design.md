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


## Scope & Responsibilities

## Goals & Milestones

## Proposed Solution & Use Cases

### Use Case 1: Generate Keys

The user selects the "Generate Keys" option. The program prompts the user to enter values for p and q, along with e.
After validating that p and q is prime and e is a valid exponent. It returns n and e.

### Use case 2: Encrypt Message

## Technical Architecture

### RSA Lib Structure

This library contains the following functions.

- `isPrime(n : int)` -> determines if the argument `n` is a prime number. Returns `1` if prime and `0` if not prime
- `gcd(n1: int, n2: int)` -> returns the value of the greatest common denominator
- `cpubexp(p:int, q:int, e:int)`: validates that the value `e` is a valid public exponent by orchestrating the following functions:
- `modulo(value: int, modulus: int)` -> determines the remainder when dividing `value` by `modulus`
- `modinv(e: int, phi)` -> takes `e` and `phi` and returns `d` such that `(e * d) mod phi = 1`
- `pow(value: int, exponent: int)` -> returns the `value ^ exponent`
- `calc_n(p: int, q: int)` -> calculates `n = p * q`
- `calc_phi(p: int, q: int)` -> calculates `phi = (p - 1) * (q - 1)`

## Alternative Solutions

## Testing

## Open Questions

## Timeline

## Team Roles & Responsibilities

- Sandra Banaszak
- Elizabeth Fuller
- Savlatjon Khuseynov
- Kangjie Mi
- James Ritter
- Dana Zhang
