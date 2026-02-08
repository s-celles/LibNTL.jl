# Type Reference

## ZZ - Arbitrary-Precision Integers

```@docs
ZZ
numbits
numbytes
```

### Arithmetic

ZZ supports all standard Julia arithmetic operators:

- `+`, `-`, `*`: Addition, subtraction, multiplication
- `^`: Power (non-negative integer exponents)
- `div`, `rem`, `mod`, `divrem`: Integer division operations
- `gcd`, `gcdx`: GCD and extended GCD

### Conversion

```julia
# From various types
ZZ(42)                    # From Int
ZZ("12345678901234567890")  # From String
ZZ(big"999999999999")     # From BigInt

# To other types
BigInt(ZZ(42))            # To BigInt
convert(Int64, ZZ(42))    # To Int64 (throws if overflow)
string(ZZ(42))            # To String
```

### Predicates

- `iszero(z)`: Check if zero
- `isone(z)`: Check if one
- `isodd(z)`, `iseven(z)`: Parity checks
- `sign(z)`: Returns -1, 0, or 1

## ZZ_p - Modular Integers

```@docs
ZZ_p
ZZ_p_init!
ZZ_p_modulus
with_modulus
rep
save!
restore!
```

### Modulus Management

Before using ZZ_p, you must set a modulus:

```julia
ZZ_p_init!(ZZ(17))  # All operations are now mod 17
```

For temporary modulus changes:

```julia
with_modulus(ZZ(23)) do
    # Operations here use modulus 23
    a = ZZ_p(20)
    println(rep(a))  # 20
end
# Original modulus is restored
```

### Arithmetic

ZZ_p supports:

- `+`, `-`, `*`: Field operations
- `/`: Division (via multiplicative inverse)
- `^`: Power
- `inv`: Multiplicative inverse

## ZZ_pContext

```@docs
ZZ_pContext
```

For manual context management:

```julia
ctx = ZZ_pContext()
save!(ctx)        # Save current modulus
ZZ_p_init!(ZZ(31))  # Change modulus
# ... work with modulus 31 ...
restore!(ctx)     # Restore previous modulus
```

## ZZX - Polynomials over Z

```@docs
ZZX
degree
coeff
setcoeff!
leading
constant
derivative
content
primpart
```

### Construction

```julia
# From coefficient vector [a_0, a_1, ..., a_n]
f = ZZX([ZZ(1), ZZ(2), ZZ(3)])  # 1 + 2x + 3x^2

# From scalar (constant polynomial)
g = ZZX(ZZ(5))  # 5

# Zero polynomial
h = ZZX()
```

### Coefficient Access

```julia
f = ZZX([ZZ(1), ZZ(2), ZZ(3)])
degree(f)     # 2
f[0]          # ZZ(1) - constant term
f[2]          # ZZ(3) - leading coefficient
leading(f)    # ZZ(3)
constant(f)   # ZZ(1)
```

### Arithmetic

- `+`, `-`, `*`: Polynomial arithmetic
- `c * f`, `f * c`: Scalar multiplication
- `div`, `rem`, `divrem`: Polynomial division
- `gcd`: Polynomial GCD

### Polynomial Operations

```julia
f = ZZX([ZZ(1), ZZ(2), ZZ(3)])

# Evaluation
f(ZZ(5))  # Evaluate at x = 5

# Derivative
derivative(f)  # 2 + 6x

# Content and primitive part
g = ZZX([ZZ(6), ZZ(12), ZZ(18)])
content(g)   # ZZ(6)
primpart(g)  # 1 + 2x + 3x^2
```

### Iteration

ZZX supports iteration over coefficients:

```julia
f = ZZX([ZZ(1), ZZ(2), ZZ(3)])
for c in f
    println(c)
end
# Output: 1, 2, 3
```

## ZZ_pX - Polynomials over Z/pZ

```@docs
ZZ_pX
is_irreducible
```

### Construction

```julia
ZZ_p_init!(ZZ(17))  # Set modulus first
f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(3)])  # 1 + 2x + 3x^2 mod 17
```

### Operations

ZZ_pX supports:
- `+`, `-`, `*`: Polynomial arithmetic mod p
- `div`, `rem`, `divrem`: Polynomial division
- `gcd`: Polynomial GCD (returns monic)
- `is_irreducible`: Test irreducibility

## VecZZ - Vectors of Integers

```@docs
VecZZ
```

### Construction

```julia
v = VecZZ(5)  # Vector of 5 zeros
v = VecZZ([ZZ(1), ZZ(2), ZZ(3)])  # From coefficient array
```

### Indexing

VecZZ supports both 0-indexed and 1-indexed access:

```julia
v = VecZZ([ZZ(10), ZZ(20), ZZ(30)])
v[1]   # 10 (1-indexed)
v(0)   # 10 (0-indexed, callable syntax)
```

## MatZZ - Matrices of Integers

```@docs
MatZZ
```

### Construction

```julia
M = MatZZ(3, 3)  # 3x3 zero matrix
```

### Operations

```julia
A = MatZZ(2, 2)
A[1,1] = ZZ(1); A[1,2] = ZZ(2)
A[2,1] = ZZ(3); A[2,2] = ZZ(4)

nrows(A)  # 2
ncols(A)  # 2
```

## Number Theory Functions

```@docs
PowerMod
ProbPrime
RandomBnd
RandomBits
bit
next!
reset!
```

## Polynomial Functions

```@docs
factor
cyclotomic
```

## InvModError

```@docs
InvModError
```

Thrown when computing a modular inverse fails:

```julia
ZZ_p_init!(ZZ(10))
try
    inv(ZZ_p(5))  # 5 has no inverse mod 10
catch e::InvModError
    println("Cannot invert ", e.a, " mod ", e.n)
end
```

## GF2 - Binary Field Elements

```@docs
GF2
```

## GF2X - Polynomials over GF(2)

```@docs
GF2X
```

## VecGF2 - Vectors over GF(2)

```@docs
VecGF2
```

## MatGF2 - Matrices over GF(2)

```@docs
MatGF2
gauss!
matrix_rank
```

## zz_p - Small Prime Modular Integers

```@docs
zz_p
zz_pContext
zz_p_init!
zz_p_FFTInit!
zz_p_modulus
with_small_modulus
```

## zz_pX - Polynomials over zz_p

```@docs
zz_pX
```

## VecZZ_p - Vectors of Modular Integers

```@docs
VecZZ_p
inner_product
inner_product_zz
```

## ZZ_pE - Extension Field Elements

```@docs
ZZ_pE
ZZ_pEContext
ZZ_pE_init!
ZZ_pE_degree
ZZ_pE_modulus
with_extension
```

## ZZ_pEX - Polynomials over Extension Fields

```@docs
ZZ_pEX
random
MinPolyMod
CompMod
```

## RR - Arbitrary-Precision Floating Point

```@docs
RR
RR_SetPrecision!
RR_precision
RR_SetOutputPrecision!
RR_OutputPrecision
RR_pi
```

## Abstract Types

```@docs
AbstractVec
AbstractMat
```
