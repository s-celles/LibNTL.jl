"""
    ZZ_pX - Polynomials over Z/pZ

Julia wrapper for NTL's ZZ_pX class providing polynomial arithmetic over Z/pZ.
"""

# High-level interface

"""
    ZZ_pX(coeffs::AbstractVector)

Construct a polynomial from a vector of coefficients.
coeffs[1] is the constant term, coeffs[2] is the x coefficient, etc.
"""
function ZZ_pX(coeffs::AbstractVector{ZZ_p})
    f = ZZ_pX()
    for (i, c) in enumerate(coeffs)
        setcoeff!(f, i - 1, c)
    end
    return f
end

# Convenience constructors
ZZ_pX(coeffs::Vector{<:Integer}) = ZZ_pX([ZZ_p(c) for c in coeffs])

"""
    degree(f::ZZ_pX) -> Int

Return the degree of the polynomial. Returns -1 for the zero polynomial.
"""
degree(f::ZZ_pX) = ZZ_pX_deg(f)

"""
    coeff(f::ZZ_pX, i::Integer) -> ZZ_p

Return the coefficient of x^i in f.
"""
coeff(f::ZZ_pX, i::Integer) = ZZ_pX_coeff(f, Int(i))

"""
    setcoeff!(f::ZZ_pX, i::Integer, c::ZZ_p)

Set the coefficient of x^i in f to c.
"""
setcoeff!(f::ZZ_pX, i::Integer, c::ZZ_p) = ZZ_pX_setcoeff(f, Int(i), c)
setcoeff!(f::ZZ_pX, i::Integer, c::Integer) = setcoeff!(f, i, ZZ_p(c))

"""
    leading(f::ZZ_pX) -> ZZ_p

Return the leading (highest degree) coefficient of f.
"""
leading(f::ZZ_pX) = ZZ_pX_leadcoeff(f)

"""
    constant(f::ZZ_pX) -> ZZ_p

Return the constant term (coefficient of x^0) of f.
"""
constant(f::ZZ_pX) = ZZ_pX_constterm(f)

# Indexing
Base.getindex(f::ZZ_pX, i::Integer) = coeff(f, i)

"""
    derivative(f::ZZ_pX) -> ZZ_pX

Compute the formal derivative of f.
"""
derivative(f::ZZ_pX) = ZZ_pX_diff(f)

"""
    is_irreducible(f::ZZ_pX) -> Bool

Test if the polynomial f is irreducible over the current modulus.
"""
is_irreducible(f::ZZ_pX) = ZZ_pX_is_irreducible(f)

# Evaluation (callable syntax)
(f::ZZ_pX)(x::ZZ_p) = ZZ_pX_eval(f, x)
(f::ZZ_pX)(x::Integer) = f(ZZ_p(x))

# Display
Base.show(io::IO, f::ZZ_pX) = print(io, ZZ_pX_to_string(f))

# Predicates
Base.iszero(f::ZZ_pX) = ZZ_pX_iszero(f)

# Hash
function Base.hash(f::ZZ_pX, h::UInt)
    result = h
    for i in 0:degree(f)
        result = hash(coeff(f, i), result)
    end
    return result
end

# Comparison
function Base.:(==)(f::ZZ_pX, g::ZZ_pX)
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
Base.:+(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_add(f, g)
Base.:-(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_sub(f, g)
Base.:-(f::ZZ_pX) = ZZ_pX_negate(f)
Base.:*(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_mul(f, g)

# Division
Base.div(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_div(f, g)
Base.rem(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_rem(f, g)
Base.divrem(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_divrem(f, g)

# GCD
Base.gcd(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_gcd(f, g)

# Iteration
Base.length(f::ZZ_pX) = max(0, degree(f) + 1)
Base.eltype(::Type{<:ZZ_pX}) = ZZ_p

function Base.iterate(f::ZZ_pX, state=0)
    if state > degree(f)
        return nothing
    end
    return (coeff(f, state), state + 1)
end
