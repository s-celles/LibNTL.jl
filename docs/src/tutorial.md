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

## Comparison with Julia's BigInt

| Operation | LibNTL.ZZ | Julia BigInt | Notes |
|-----------|-----------|--------------|-------|
| Creation | `ZZ(...)` | `big"..."` | Similar |
| Arithmetic | Same operators | Same operators | ZZ uses NTL's optimized GMP wrapper |
| Modular | `ZZ_p` type | `mod()` function | ZZ_p stores modulus context |
| Polynomials | Native `ZZX` | Manual | ZZX has built-in polynomial ops |
