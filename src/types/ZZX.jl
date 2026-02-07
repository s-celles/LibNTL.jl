"""
    ZZX - Polynomials over Integers

Julia wrapper for NTL's ZZX class providing polynomial arithmetic over Z.
"""

# High-level interface

"""
    ZZX(coeffs::AbstractVector)

Construct a polynomial from a vector of coefficients.
coeffs[1] is the constant term, coeffs[2] is the x coefficient, etc.
"""
function ZZX(coeffs::AbstractVector)
    f = ZZX()
    for (i, c) in enumerate(coeffs)
        setcoeff!(f, i - 1, c isa ZZ ? c : ZZ(c))
    end
    return f
end

# Convenience constructor for Integer vectors
ZZX(coeffs::Vector{<:Integer}) = ZZX([ZZ(c) for c in coeffs])

"""
    degree(f::ZZX) -> Int

Return the degree of the polynomial. Returns -1 for the zero polynomial.
"""
degree(f::ZZX) = ZZX_deg(f)

"""
    coeff(f::ZZX, i::Integer) -> ZZ

Return the coefficient of x^i in f.
"""
coeff(f::ZZX, i::Integer) = ZZX_coeff(f, Int(i))

"""
    setcoeff!(f::ZZX, i::Integer, c::ZZ)

Set the coefficient of x^i in f to c.
"""
setcoeff!(f::ZZX, i::Integer, c::ZZ) = ZZX_setcoeff(f, Int(i), c)
setcoeff!(f::ZZX, i::Integer, c::Integer) = setcoeff!(f, i, ZZ(c))

"""
    leading(f::ZZX) -> ZZ

Return the leading (highest degree) coefficient of f.
"""
leading(f::ZZX) = ZZX_leadcoeff(f)

"""
    constant(f::ZZX) -> ZZ

Return the constant term (coefficient of x^0) of f.
"""
constant(f::ZZX) = ZZX_constterm(f)

# Indexing
Base.getindex(f::ZZX, i::Integer) = coeff(f, i)

"""
    derivative(f::ZZX) -> ZZX

Compute the formal derivative of f.
"""
derivative(f::ZZX) = ZZX_diff(f)

"""
    content(f::ZZX) -> ZZ

Compute the content (GCD of all coefficients) of f.
"""
content(f::ZZX) = ZZX_content(f)

"""
    primpart(f::ZZX) -> ZZX

Compute the primitive part (f / content(f)) of f.
"""
primpart(f::ZZX) = ZZX_primpart(f)

# Evaluation (callable syntax)
(f::ZZX)(x::ZZ) = ZZX_eval(f, x)
(f::ZZX)(x::Integer) = f(ZZ(x))

# Display
Base.show(io::IO, f::ZZX) = print(io, ZZX_to_string(f))

# Hash
function Base.hash(f::ZZX, h::UInt)
    result = h
    for i in 0:degree(f)
        result = hash(coeff(f, i), result)
    end
    return result
end

# Comparison
function Base.:(==)(f::ZZX, g::ZZX)
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

# Iteration
Base.length(f::ZZX) = max(0, degree(f) + 1)
Base.eltype(::Type{<:ZZX}) = typeof(ZZ(0))
Base.eltype(f::ZZX) = typeof(ZZ(0))

function Base.iterate(f::ZZX, state=0)
    if state > degree(f)
        return nothing
    end
    return (coeff(f, state), state + 1)
end
