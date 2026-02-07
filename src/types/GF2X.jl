"""
    GF2X - Polynomials over GF(2)

Julia wrapper for NTL's GF2X class providing polynomial arithmetic over the binary field.
"""

# High-level interface

"""
    degree(f::GF2X) -> Int

Return the degree of the polynomial. Returns -1 for the zero polynomial.
"""
degree(f::GF2X) = GF2X_deg(f)

"""
    coeff(f::GF2X, i::Integer) -> GF2

Return the coefficient of x^i in f.
"""
coeff(f::GF2X, i::Integer) = GF2X_coeff(f, Int(i))

"""
    setcoeff!(f::GF2X, i::Integer, c::GF2)

Set the coefficient of x^i in f to c.
"""
setcoeff!(f::GF2X, i::Integer, c::GF2) = GF2X_setcoeff!(f, Int(i), c)
setcoeff!(f::GF2X, i::Integer, c::Integer) = setcoeff!(f, i, GF2(c))

"""
    leading(f::GF2X) -> GF2

Return the leading (highest degree) coefficient of f.
"""
leading(f::GF2X) = GF2X_leadcoeff(f)

"""
    constant(f::GF2X) -> GF2

Return the constant term (coefficient of x^0) of f.
"""
constant(f::GF2X) = GF2X_constterm(f)

# Indexing
Base.getindex(f::GF2X, i::Integer) = coeff(f, i)

"""
    derivative(f::GF2X) -> GF2X

Compute the formal derivative of f.
"""
derivative(f::GF2X) = GF2X_diff(f)

"""
    is_irreducible(f::GF2X) -> Bool

Test if the polynomial f is irreducible over GF(2).
"""
is_irreducible(f::GF2X) = GF2X_is_irreducible(f)

# Evaluation (callable syntax)
(f::GF2X)(x::GF2) = GF2X_eval(f, x)
(f::GF2X)(x::Integer) = f(GF2(x))

# Display
Base.show(io::IO, f::GF2X) = print(io, GF2X_to_string(f))

# Predicates
Base.iszero(f::GF2X) = GF2X_iszero(f)

# Hash
function Base.hash(f::GF2X, h::UInt)
    result = h
    for i in 0:degree(f)
        result = hash(coeff(f, i), result)
    end
    return result
end

# Comparison
function Base.:(==)(f::GF2X, g::GF2X)
    if degree(f) != degree(g)
        return false
    end
    for i in 0:degree(f)
        if coeff(f, i) != coeff(g, i)
            return false
        end
    end
    return true
end

# Arithmetic operators
Base.:+(f::GF2X, g::GF2X) = GF2X_add(f, g)
Base.:-(f::GF2X, g::GF2X) = GF2X_sub(f, g)
Base.:-(f::GF2X) = GF2X_negate(f)
Base.:*(f::GF2X, g::GF2X) = GF2X_mul(f, g)

# Division
Base.div(f::GF2X, g::GF2X) = GF2X_div(f, g)
Base.rem(f::GF2X, g::GF2X) = GF2X_rem(f, g)
Base.divrem(f::GF2X, g::GF2X) = GF2X_divrem(f, g)

# GCD
Base.gcd(f::GF2X, g::GF2X) = GF2X_gcd(f, g)

# Iteration
Base.length(f::GF2X) = max(0, degree(f) + 1)
Base.eltype(::Type{<:GF2X}) = GF2

function Base.iterate(f::GF2X, state=0)
    if state > degree(f)
        return nothing
    end
    return (coeff(f, state), state + 1)
end
