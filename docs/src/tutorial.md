# Tutorial

This tutorial covers common usage patterns for LibNTL.jl.

## Basic Usage

### Arbitrary-Precision Integers (ZZ)

```julia
using LibNTL

# Create integers
a = ZZ(42)
b = ZZ("12345678901234567890")
c = ZZ(big"999999999999999999999999")

# Arithmetic
sum = a + b
diff = b - a
prod = a * b
quot = div(b, a)
remainder = rem(b, a)

# Power
squared = a^2
big_power = ZZ(2)^1000  # 2^1000

# GCD
g = gcd(ZZ(48), ZZ(18))  # 6
d, s, t = gcdx(ZZ(48), ZZ(18))  # d = 48*s + 18*t

# Convert to/from BigInt
big_val = convert(BigInt, b)
back_to_zz = ZZ(big_val)

# Display
println(a)  # 42
println("Bits: ", numbits(b))  # Number of bits
```

### Modular Arithmetic (ZZ_p)

```julia
using LibNTL

# Set the modulus (must be > 1)
p = ZZ(17)
ZZ_p_init!(p)

# Create elements mod p
x = ZZ_p(5)
y = ZZ_p(12)

# Arithmetic (automatically reduced mod p)
sum = x + y      # 0 (since 5 + 12 = 17 ≡ 0 mod 17)
prod = x * y     # 9 (since 5 * 12 = 60 ≡ 9 mod 17)

# Inverse
inv_x = inv(x)   # 7 (since 5 * 7 = 35 ≡ 1 mod 17)

# Power
powered = x^10

# Get underlying value
val = rep(x)     # Returns ZZ in [0, p-1]

# Check current modulus
println("Modulus: ", ZZ_p_modulus())  # 17
```

### Context Switching

```julia
using LibNTL

# Work with different moduli
ZZ_p_init!(ZZ(17))
a = ZZ_p(5)

# Use with_modulus for temporary modulus change
result = with_modulus(ZZ(23)) do
    b = ZZ_p(7)
    inv(b)  # Inverse mod 23
end

# Original modulus is restored
println(ZZ_p_modulus())  # 17
```

### Polynomials over Z (ZZX)

```julia
using LibNTL

# Create polynomials
zero_poly = ZZX()              # 0
const_poly = ZZX(ZZ(5))        # 5
linear = ZZX([ZZ(1), ZZ(2)])   # 1 + 2x

# Build polynomial by setting coefficients
f = ZZX()
setcoeff!(f, 0, ZZ(1))   # constant term
setcoeff!(f, 2, ZZ(3))   # x^2 coefficient
setcoeff!(f, 4, ZZ(1))   # x^4 coefficient
# f = 1 + 3x^2 + x^4

# Query polynomial
println("Degree: ", degree(f))        # 4
println("Leading: ", leading(f))      # 1
println("Constant: ", constant(f))    # 1
println("Coeff of x^2: ", coeff(f, 2)) # 3
println("Coeff of x^3: ", coeff(f, 3)) # 0 (not set)

# Arithmetic
g = ZZX([ZZ(1), ZZ(1)])  # 1 + x
product = f * g
sum = f + g

# Division
q, r = divrem(f, g)  # f = q*g + r

# GCD
h = gcd(f, g)

# Evaluate polynomial
x = ZZ(2)
result = f(x)  # 1 + 3*4 + 16 = 29

# Derivative
df = derivative(f)  # 6x + 4x^3

# Content and primitive part
c = content(f)      # GCD of coefficients
pp = primpart(f)    # f / content(f)
```

## Common Patterns

### RSA-style Modular Exponentiation

```julia
using LibNTL

# Generate a prime modulus
p = ZZ("104729")  # A prime number

ZZ_p_init!(p)

# Base and exponent
base = ZZ_p(12345)
exponent = ZZ("1000000007")

# Modular exponentiation
result = base^exponent

println("12345^1000000007 mod 104729 = ", rep(result))
```

### Polynomial GCD

```julia
using LibNTL

# f(x) = x^3 - 1 = (x-1)(x^2+x+1)
f = ZZX([ZZ(-1), ZZ(0), ZZ(0), ZZ(1)])

# g(x) = x^2 - 1 = (x-1)(x+1)
g = ZZX([ZZ(-1), ZZ(0), ZZ(1)])

# GCD should be (x-1) up to constant
h = gcd(f, g)
println("GCD: ", h)  # Should be proportional to (x - 1)
```

### Large Integer Factorization Setup

```julia
using LibNTL

# Check if a number might be prime
n = ZZ("170141183460469231731687303715884105727")  # 2^127 - 1 (Mersenne prime)

# Count bits
println("Bits: ", numbits(n))  # 127

# Basic primality test via trial division up to small bound
is_composite = false
for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    if rem(n, ZZ(p)) == ZZ(0) && n != ZZ(p)
        is_composite = true
        println("Divisible by ", p)
        break
    end
end

if !is_composite
    println("Not divisible by small primes")
end
```

## Error Handling

```julia
using LibNTL

# Division by zero
try
    div(ZZ(10), ZZ(0))
catch e
    println("Caught: ", e)  # DomainError
end

# Inverse of zero in ZZ_p
ZZ_p_init!(ZZ(17))
try
    inv(ZZ_p(0))
catch e::InvModError
    println("Cannot invert ", e.a, " mod ", e.n)
end
```

## Performance Tips

1. **Reuse objects**: Avoid creating many small temporary ZZ values in tight loops
2. **Pre-set modulus**: Call `ZZ_p_init!` once before many ZZ_p operations
3. **Use `with_modulus`**: For nested computations with different moduli
4. **Polynomial degree**: Higher degree polynomials use FFT-based multiplication

## Vectors and Matrices

### VecZZ - Vectors of Integers

```julia
using LibNTL

# Create a vector
v = VecZZ([ZZ(1), ZZ(2), ZZ(3), ZZ(4), ZZ(5)])

# 1-indexed access (Julia style)
println(v[1])  # 1

# 0-indexed access (NTL style)
println(v(0))  # 1

# Iteration
for x in v
    println(x)
end

# Modification
v[1] = ZZ(100)
```

### MatZZ - Matrices of Integers

```julia
using LibNTL

# Create a 2x2 matrix
A = MatZZ(2, 2)
A[1,1] = ZZ(1); A[1,2] = ZZ(2)
A[2,1] = ZZ(3); A[2,2] = ZZ(4)

# Dimensions
println("Rows: ", nrows(A))
println("Cols: ", ncols(A))

# Matrix multiplication
B = MatZZ(2, 2)
B[1,1] = ZZ(5); B[1,2] = ZZ(6)
B[2,1] = ZZ(7); B[2,2] = ZZ(8)

C = A * B
println(C[1,1])  # 19
```

## Modular Polynomials (ZZ_pX)

```julia
using LibNTL

# Set modulus first
with_modulus(ZZ(17)) do
    # Create polynomial: 1 + 2x + 3x^2
    f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(3)])

    # Degree and coefficients
    println("Degree: ", degree(f))
    println("Leading coeff: ", leading(f))

    # Arithmetic
    g = ZZ_pX([ZZ_p(1), ZZ_p(1)])  # 1 + x
    println("f + g = ", f + g)
    println("f * g = ", f * g)

    # Division
    q, r = divrem(f, g)
    println("f / g = ", q, " remainder ", r)

    # GCD
    h = gcd(f, g)
    println("gcd(f, g) = ", h)

    # Irreducibility testing
    irred = ZZ_pX([ZZ_p(1), ZZ_p(1), ZZ_p(1)])  # x^2 + x + 1
    println("x^2 + x + 1 irreducible mod 17: ", is_irreducible(irred))
end
```

## Polynomial Factorization

```julia
using LibNTL

# Factor x^4 - 1 over Z
f = ZZX([ZZ(-1), ZZ(0), ZZ(0), ZZ(0), ZZ(1)])

content_val, factors = factor(f)
println("Content: ", content_val)
println("Factors:")
for (poly, mult) in factors
    println("  ", poly, " ^ ", mult)
end
```

## Cyclotomic Polynomials

```julia
using LibNTL

# Generate cyclotomic polynomials
for n in [1, 2, 3, 4, 6, 12]
    phi = cyclotomic(n)
    println("Phi_$n(x) = ", phi, " (degree ", degree(phi), ")")
end
```

## Number Theory Functions

```julia
using LibNTL

# Modular exponentiation
result = PowerMod(ZZ(2), ZZ(100), ZZ(1000000007))
println("2^100 mod 10^9+7 = ", result)

# Primality testing
n = ZZ("170141183460469231731687303715884105727")
println("Is Mersenne prime: ", ProbPrime(n))

# Random numbers
r = RandomBnd(ZZ(1000))
println("Random < 1000: ", r)

# Bit operations
x = ZZ(255)
println("Bits in 255: ", numbits(x))
println("Bit 7: ", bit(x, 7))
```

## Comparison with Julia's BigInt

| Operation | LibNTL.ZZ | Julia BigInt | Notes |
|-----------|-----------|--------------|-------|
| Creation | `ZZ(...)` | `big"..."` | Similar |
| Arithmetic | Same operators | Same operators | ZZ uses NTL's optimized GMP wrapper |
| Modular | `ZZ_p` type | `mod()` function | ZZ_p stores modulus context |
| Polynomials | Native `ZZX` | Manual | ZZX has built-in polynomial ops |
| Vectors | `VecZZ` | `Vector{BigInt}` | VecZZ supports 0-indexed access |
| Matrices | `MatZZ` | `Matrix{BigInt}` | MatZZ has optimized multiplication |
