# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Core Types
- `ZZ` - Arbitrary precision integers with full arithmetic operations
- `ZZ_p` - Integers modulo p with context management
- `ZZ_pContext` - Context for modular arithmetic with `with_modulus` pattern
- `ZZX` - Univariate polynomials over ZZ
- `ZZ_pX` - Univariate polynomials over Z/pZ
- `VecZZ` - Vectors of arbitrary precision integers
- `VecZZ_p` - Vectors over Z/pZ with arithmetic and inner products
- `MatZZ` - Matrices of arbitrary precision integers
- `GF2` - Binary field element {0, 1} with XOR addition and AND multiplication
- `GF2X` - Polynomials over GF(2) with efficient BitVector storage
- `VecGF2` - Vectors over GF(2) with arithmetic operations
- `MatGF2` - Matrices over GF(2) with Gaussian elimination

#### Polynomial Functions
- `factor(f::ZZX)` - Integer polynomial factorization
- `cyclotomic(n)` - Cyclotomic polynomial generation
- `is_irreducible(f::ZZ_pX)` - Irreducibility testing over Z/pZ
- `is_irreducible(f::GF2X)` - Irreducibility testing over GF(2)
- `derivative(f)` - Formal derivative for ZZX and ZZ_pX
- `gcd(f, g)` - GCD for polynomials

#### Number Theory Functions
- `powermod(a, e, m)` - Modular exponentiation
- `jacobi(a, n)` - Jacobi symbol computation
- `probprime(n)` - Probabilistic primality testing

#### Vector/Matrix Operations
- `nrows(M)`, `ncols(M)` - Matrix dimension accessors
- Vector and matrix arithmetic with `+`, `-`, `*`
- 0-indexed and 1-indexed vector access
- `inner_product(a, b)` - Inner product for VecZZ_p
- `inner_product_zz(a, b)` - Optimized inner product with delayed reduction
- `gauss!(m::MatGF2)` - In-place Gaussian elimination over GF(2)
- `matrix_rank(m::MatGF2)` - Compute matrix rank over GF(2)
- `eye_gf2(n)` - Create identity matrix over GF(2)

#### Context Management
- `ZZ_p_init!(p)` - Initialize modular context
- `with_modulus(f, p)` - Scoped modular context

#### NTL Tour Examples
- Tour Example 1: Big integers (4 examples)
  - `basic_arithmetic.jl` - Basic ZZ operations
  - `sum_of_squares.jl` - Computing sums of squares
  - `powermod.jl` - Modular exponentiation
  - `primetest.jl` - Primality testing
- Tour Example 2: Vectors and matrices (4 examples)
  - `vector_sum_0indexed.jl` - 0-indexed vector operations
  - `vector_sum_1indexed.jl` - 1-indexed vector operations
  - `palindrome.jl` - Palindrome checking with vectors
  - `matrix_multiply.jl` - Matrix multiplication
- Tour Example 3: Polynomials (2 examples)
  - `factorization.jl` - Integer polynomial factorization
  - `cyclotomic.jl` - Cyclotomic polynomial generation
- Tour Example 4: Modular polynomials (5 examples)
  - `poly_factor_mod_p.jl` - Polynomial factorization mod p
  - `irred_test_push.jl` - Irreducibility testing with context
  - `vector_add_zz_p.jl` - Vector addition over Z/pZ
  - `inner_product.jl` - Inner product with optimization
  - `gf2_irred_test.jl` - GF(2) types and irreducibility testing

### Infrastructure
- Dual-mode architecture: native C++ wrapper + pure Julia fallback
- Comprehensive test suite (824 tests)
- Integration tests for all 15 examples

[Unreleased]: https://github.com/s-celles/LibNTL.jl/compare/main...HEAD
