# zkCTF - Halo2 - Int Division

## Overview

1. This is a quiz about Halo2 usage. The standard answer would not be given to participants
2. Instead, a file would be given, with all necessary structs and missing logics. Participants are required to fill in the blanks, compile the program and run tests
3. Multiple test cases would be given, the prover program shall be tested against them

## Problem description

While doing proof we always face some basic arithematics, such as int division. It is a very intuitive operation on normal programming language, but one might find it a bit harder when doing it in crypto world -- for we always use [Finte Field](https://en.wikipedia.org/wiki/Finite_field). For each non-zero element, it has inverse, so that a normal int division is not obeying ordinary division just like Python. For example, in Fp where p = 11, 10 div 3 = 7 mod 11 -- for inverse of 3 is 4, 11 div 3 = 10 times 4 = 7 mod 11. While we expect an 'ordinary' int division: 10 // 3 = 3. Now you are required to simulate an int division in Halo2. We limit the size as U8. So you are actually implementing an U8 division in a finite file Fr, which is the scalar field of ecliptic curve group BN256.

## Comand

cargo run

## Example

Input 10 3 3
Explain: Proof generates and verifier passes it. It is an U8 division

## Solve

Sumbit quiz.rs to solve the puzzle.
