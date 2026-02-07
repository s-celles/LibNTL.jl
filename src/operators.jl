"""
    Operators for NTL types.

This module provides Base operator overloads for NTL types (ZZ, ZZ_p, ZZX)
to enable idiomatic Julia syntax.
"""

# ============================================================================
# ZZ Arithmetic Operators
# ============================================================================

# Addition
Base.:+(a::ZZ, b::ZZ) = ZZ_add(a, b)

# Subtraction
Base.:-(a::ZZ, b::ZZ) = ZZ_sub(a, b)

# Multiplication
Base.:*(a::ZZ, b::ZZ) = ZZ_mul(a, b)

# Negation
Base.:-(a::ZZ) = ZZ_negate(a)

# Power
function Base.:^(a::ZZ, n::Integer)
    if n < 0
        throw(DomainError(n, "Exponent must be non-negative for ZZ"))
    end
    ZZ_power(a, Int(n))
end

# ============================================================================
# ZZ Division Operators
# ============================================================================

"""
    Base.div(a::ZZ, b::ZZ) -> ZZ

Integer division (quotient) of a by b.
Throws `DomainError` if b is zero.
"""
function Base.div(a::ZZ, b::ZZ)
    if iszero(b)
        throw(DomainError(b, "Division by zero"))
    end
    ZZ_div(a, b)
end

"""
    Base.rem(a::ZZ, b::ZZ) -> ZZ

Remainder of integer division of a by b.
Throws `DomainError` if b is zero.
"""
function Base.rem(a::ZZ, b::ZZ)
    if iszero(b)
        throw(DomainError(b, "Division by zero"))
    end
    ZZ_rem(a, b)
end

"""
    Base.mod(a::ZZ, b::ZZ) -> ZZ

Modulo operation (always non-negative result).
Throws `DomainError` if b is zero.
"""
function Base.mod(a::ZZ, b::ZZ)
    if iszero(b)
        throw(DomainError(b, "Division by zero"))
    end
    r = ZZ_rem(a, b)
    # Ensure result is non-negative
    if sign(r) < 0
        r = r + abs(b)
    end
    return r
end

"""
    Base.divrem(a::ZZ, b::ZZ) -> (ZZ, ZZ)

Return quotient and remainder of integer division.
Throws `DomainError` if b is zero.
"""
function Base.divrem(a::ZZ, b::ZZ)
    if iszero(b)
        throw(DomainError(b, "Division by zero"))
    end
    ZZ_divrem(a, b)
end

# ============================================================================
# ZZ Comparison Operators
# ============================================================================

# Note: C++ returns int (0/1), convert to Bool for Julia
Base.:(==)(a::ZZ, b::ZZ) = ZZ_equal(a, b) != 0
Base.:(<)(a::ZZ, b::ZZ) = ZZ_less(a, b) != 0
Base.:(<=)(a::ZZ, b::ZZ) = ZZ_lesseq(a, b) != 0
Base.isless(a::ZZ, b::ZZ) = ZZ_less(a, b) != 0

# ============================================================================
# ZZ Predicates
# ============================================================================

"""
    Base.iszero(z::ZZ) -> Bool

Check if z is zero.
"""
Base.iszero(z::ZZ) = ZZ_iszero(z) != 0

"""
    Base.isone(z::ZZ) -> Bool

Check if z is one.
"""
Base.isone(z::ZZ) = ZZ_isone(z) != 0

"""
    Base.isodd(z::ZZ) -> Bool

Check if z is odd.
"""
Base.isodd(z::ZZ) = ZZ_isodd(z) != 0

"""
    Base.iseven(z::ZZ) -> Bool

Check if z is even.
"""
Base.iseven(z::ZZ) = ZZ_isodd(z) == 0

"""
    Base.sign(z::ZZ) -> Int

Return the sign of z: -1, 0, or 1.
"""
Base.sign(z::ZZ) = ZZ_sign(z)

# ============================================================================
# ZZ GCD Operations
# ============================================================================

"""
    Base.gcd(a::ZZ, b::ZZ) -> ZZ

Compute the greatest common divisor of a and b.
"""
Base.gcd(a::ZZ, b::ZZ) = ZZ_gcd(a, b)

"""
    Base.gcdx(a::ZZ, b::ZZ) -> (ZZ, ZZ, ZZ)

Extended GCD: returns (d, s, t) such that d = gcd(a, b) = a*s + b*t.
"""
Base.gcdx(a::ZZ, b::ZZ) = ZZ_gcdx(a, b)

# ============================================================================
# ZZ Absolute Value
# ============================================================================

"""
    Base.abs(z::ZZ) -> ZZ

Return the absolute value of z.
"""
Base.abs(z::ZZ) = ZZ_abs(z)

# ============================================================================
# ZZ Mixed-Type Operations (ZZ with Integer)
# ============================================================================

# These rely on promotion rules defined in conversions.jl
# The following explicit methods provide optimized paths for common cases

# Addition with integers
Base.:+(a::ZZ, b::Integer) = a + ZZ(b)
Base.:+(a::Integer, b::ZZ) = ZZ(a) + b

# Subtraction with integers
Base.:-(a::ZZ, b::Integer) = a - ZZ(b)
Base.:-(a::Integer, b::ZZ) = ZZ(a) - b

# Multiplication with integers
Base.:*(a::ZZ, b::Integer) = a * ZZ(b)
Base.:*(a::Integer, b::ZZ) = ZZ(a) * b

# Division with integers
Base.div(a::ZZ, b::Integer) = div(a, ZZ(b))
Base.div(a::Integer, b::ZZ) = div(ZZ(a), b)
Base.rem(a::ZZ, b::Integer) = rem(a, ZZ(b))
Base.rem(a::Integer, b::ZZ) = rem(ZZ(a), b)
Base.mod(a::ZZ, b::Integer) = mod(a, ZZ(b))
Base.mod(a::Integer, b::ZZ) = mod(ZZ(a), b)

# Comparison with integers
Base.:(==)(a::ZZ, b::Integer) = a == ZZ(b)
Base.:(==)(a::Integer, b::ZZ) = ZZ(a) == b
Base.:(<)(a::ZZ, b::Integer) = a < ZZ(b)
Base.:(<)(a::Integer, b::ZZ) = ZZ(a) < b
Base.:(<=)(a::ZZ, b::Integer) = a <= ZZ(b)
Base.:(<=)(a::Integer, b::ZZ) = ZZ(a) <= b
Base.isless(a::ZZ, b::Integer) = isless(a, ZZ(b))
Base.isless(a::Integer, b::ZZ) = isless(ZZ(a), b)

# GCD with integers
Base.gcd(a::ZZ, b::Integer) = gcd(a, ZZ(b))
Base.gcd(a::Integer, b::ZZ) = gcd(ZZ(a), b)

# ============================================================================
# ZZ_p Arithmetic Operators
# ============================================================================

# Addition
Base.:+(a::ZZ_p, b::ZZ_p) = ZZ_p_add(a, b)

# Subtraction
Base.:-(a::ZZ_p, b::ZZ_p) = ZZ_p_sub(a, b)

# Multiplication
Base.:*(a::ZZ_p, b::ZZ_p) = ZZ_p_mul(a, b)

# Negation
Base.:-(a::ZZ_p) = ZZ_p_negate(a)

# Division
function Base.:/(a::ZZ_p, b::ZZ_p)
    if iszero(b)
        throw(DomainError(b, "Division by zero"))
    end
    ZZ_p_div(a, b)
end

# Power
Base.:^(a::ZZ_p, n::Integer) = ZZ_p_power(a, Int(n))
Base.:^(a::ZZ_p, n::ZZ) = ZZ_p_power_ZZ(a, n)

# ============================================================================
# ZZ_p Inverse
# ============================================================================

"""
    Base.inv(a::ZZ_p) -> ZZ_p

Compute the multiplicative inverse of a modulo p.

# Throws
- `InvModError` if a is zero or gcd(a, p) != 1
"""
function Base.inv(a::ZZ_p)
    if iszero(a)
        throw(InvModError(rep(a), ZZ_p_modulus()))
    end
    try
        ZZ_p_inv(a)
    catch e
        # Convert C++ exception to InvModError
        throw(InvModError(rep(a), ZZ_p_modulus()))
    end
end

# ============================================================================
# ZZ_p Comparison
# ============================================================================

"""
    Base.:(==)(a::ZZ_p, b::ZZ_p) -> Bool

Check if two ZZ_p values are equal.
"""
Base.:(==)(a::ZZ_p, b::ZZ_p) = rep(a) == rep(b)

# ============================================================================
# ZZ_p Predicates
# ============================================================================

"""
    Base.iszero(a::ZZ_p) -> Bool

Check if a is zero (mod p).
"""
Base.iszero(a::ZZ_p) = ZZ_p_iszero(a) != 0

"""
    Base.isone(a::ZZ_p) -> Bool

Check if a is one (mod p).
"""
Base.isone(a::ZZ_p) = ZZ_p_isone(a) != 0

# ============================================================================
# ZZX Arithmetic Operators
# ============================================================================

# Addition
Base.:+(f::ZZX, g::ZZX) = ZZX_add(f, g)

# Subtraction
Base.:-(f::ZZX, g::ZZX) = ZZX_sub(f, g)

# Multiplication
Base.:*(f::ZZX, g::ZZX) = ZZX_mul(f, g)

# Scalar multiplication
Base.:*(c::ZZ, f::ZZX) = ZZX_mul_scalar(c, f)
Base.:*(f::ZZX, c::ZZ) = ZZX_mul_scalar(c, f)
Base.:*(c::Integer, f::ZZX) = ZZ(c) * f
Base.:*(f::ZZX, c::Integer) = f * ZZ(c)

# Negation
Base.:-(f::ZZX) = ZZX_negate(f)

# ============================================================================
# ZZX Division Operators
# ============================================================================

"""
    Base.div(f::ZZX, g::ZZX) -> ZZX

Polynomial division (quotient) of f by g.
Throws `DomainError` if g is zero.
"""
function Base.div(f::ZZX, g::ZZX)
    if iszero(g)
        throw(DomainError(g, "Division by zero polynomial"))
    end
    ZZX_div(f, g)
end

"""
    Base.rem(f::ZZX, g::ZZX) -> ZZX

Remainder of polynomial division of f by g.
Throws `DomainError` if g is zero.
"""
function Base.rem(f::ZZX, g::ZZX)
    if iszero(g)
        throw(DomainError(g, "Division by zero polynomial"))
    end
    ZZX_rem(f, g)
end

"""
    Base.divrem(f::ZZX, g::ZZX) -> (ZZX, ZZX)

Return quotient and remainder of polynomial division.
Throws `DomainError` if g is zero.
"""
function Base.divrem(f::ZZX, g::ZZX)
    if iszero(g)
        throw(DomainError(g, "Division by zero polynomial"))
    end
    ZZX_divrem(f, g)
end

# ============================================================================
# ZZX GCD
# ============================================================================

"""
    Base.gcd(f::ZZX, g::ZZX) -> ZZX

Compute the GCD of two polynomials.
"""
Base.gcd(f::ZZX, g::ZZX) = ZZX_gcd(f, g)

# ============================================================================
# ZZX Predicates
# ============================================================================

"""
    Base.iszero(f::ZZX) -> Bool

Check if f is the zero polynomial.
"""
Base.iszero(f::ZZX) = ZZX_iszero(f) != 0
