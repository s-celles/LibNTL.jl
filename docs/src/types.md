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
