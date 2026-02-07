"""
High-level interface for ZZ_pEX (polynomials over extension field).
"""

# Degree
"""
    degree(f::ZZ_pEX) -> Int

Get the degree of polynomial f. Returns -1 for the zero polynomial.
"""
degree(f::ZZ_pEX) = ZZ_pEX_deg(f)

# Coefficient access
"""
    coeff(f::ZZ_pEX, i::Integer) -> ZZ_pE

Get the coefficient of x^i in f.
"""
coeff(f::ZZ_pEX, i::Integer) = ZZ_pEX_coeff(f, Int(i))

"""
    setcoeff!(f::ZZ_pEX, i::Integer, c::ZZ_pE)

Set the coefficient of x^i in f to c.
"""
setcoeff!(f::ZZ_pEX, i::Integer, c::ZZ_pE) = ZZ_pEX_setcoeff(f, Int(i), c)

"""
    leading(f::ZZ_pEX) -> ZZ_pE

Get the leading coefficient of f.
"""
leading(f::ZZ_pEX) = ZZ_pEX_leadcoeff(f)

"""
    constant(f::ZZ_pEX) -> ZZ_pE

Get the constant term of f.
"""
constant(f::ZZ_pEX) = ZZ_pEX_constterm(f)

# Arithmetic
Base.:+(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_add(f, g)
Base.:-(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_sub(f, g)
Base.:*(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_mul(f, g)
Base.:-(f::ZZ_pEX) = ZZ_pEX_negate(f)
Base.div(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_div(f, g)
Base.rem(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_rem(f, g)
Base.divrem(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_divrem(f, g)
Base.gcd(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_gcd(f, g)

# Predicates
Base.iszero(f::ZZ_pEX) = ZZ_pEX_iszero(f)

# Display
function Base.show(io::IO, f::ZZ_pEX)
    print(io, ZZ_pEX_to_string(f))
end

# Indexing
Base.getindex(f::ZZ_pEX, i::Integer) = coeff(f, i)
Base.setindex!(f::ZZ_pEX, c::ZZ_pE, i::Integer) = setcoeff!(f, i, c)

# Length
Base.length(f::ZZ_pEX) = max(0, degree(f) + 1)

# Zero
Base.zero(::Type{ZZ_pEX}) = ZZ_pEX()

# Random polynomial
"""
    random(::Type{ZZ_pEX}, n::Integer) -> ZZ_pEX

Generate a random polynomial of degree < n over the extension field.
"""
random(::Type{ZZ_pEX}, n::Integer) = ZZ_pEX_random(Int(n))

# Extension field polynomial functions
"""
    MinPolyMod(g::ZZ_pEX, f::ZZ_pEX) -> ZZ_pEX

Compute the minimum polynomial of g modulo f.
"""
MinPolyMod(g::ZZ_pEX, f::ZZ_pEX) = ZZ_pEX_MinPolyMod(g, f)

"""
    CompMod(g::ZZ_pEX, h::ZZ_pEX, f::ZZ_pEX) -> ZZ_pEX

Compute g(h) mod f (polynomial composition modulo f).
"""
CompMod(g::ZZ_pEX, h::ZZ_pEX, f::ZZ_pEX) = ZZ_pEX_CompMod(g, h, f)

# Export
export ZZ_pEX
export random, MinPolyMod, CompMod
