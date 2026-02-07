# LibNTL.jl

Julia wrapper for the [NTL (Number Theory Library)](https://libntl.org/) C++ library.

## Overview

LibNTL.jl provides Julia bindings for NTL's core number-theoretic types:

- **ZZ**: Arbitrary-precision integers
- **ZZ_p**: Integers modulo p (modular arithmetic)
- **ZZX**: Polynomials with integer coefficients

All types integrate seamlessly with Julia's type system and operators, providing an idiomatic experience for Julia users.

## Installation

```julia
using Pkg
Pkg.add("LibNTL")
```

## Quick Start

```julia
using LibNTL

# Arbitrary-precision integers
a = ZZ(42)
b = ZZ("12345678901234567890")
c = a + b
println("Sum: ", c)

# Modular arithmetic
ZZ_p_init!(ZZ(17))  # Set modulus to 17
x = ZZ_p(5)
y = inv(x)  # Multiplicative inverse: 5 * 7 = 35 = 1 mod 17
println("Inverse of 5 mod 17: ", rep(y))

# Polynomials
f = ZZX([ZZ(1), ZZ(2), ZZ(1)])  # 1 + 2x + x^2
println("f(3) = ", f(ZZ(3)))
```

## Features

- **Full arithmetic support**: Addition, subtraction, multiplication, division, exponentiation
- **BigInt interoperability**: Seamless conversion between ZZ and Julia's BigInt
- **GCD and extended GCD**: Including Bezout coefficients
- **Polynomial operations**: Derivative, content, primitive part, GCD, factorization
- **Modular polynomials**: ZZ_pX with irreducibility testing
- **Vectors and matrices**: VecZZ and MatZZ for linear algebra
- **Thread-local modulus**: Context-based modular arithmetic with save/restore
- **Collection support**: Use ZZ, ZZ_p, ZZX as keys in Dict and elements in Set
- **NTL Tour examples**: Complete Julia translations of NTL tutorial examples

## Contents

```@contents
Pages = ["types.md", "tutorial.md", "examples.md"]
```

## Index

```@index
```
