"""
High-level interface for zz_pX (polynomials over single-precision modular integers).
"""

# Degree
"""
    degree(f::zz_pX) -> Int

Get the degree of polynomial f. Returns -1 for the zero polynomial.
"""
degree(f::zz_pX) = zz_pX_deg(f)

# Coefficient access
"""
    coeff(f::zz_pX, i::Integer) -> zz_p

Get the coefficient of x^i in f.
"""
coeff(f::zz_pX, i::Integer) = zz_pX_coeff(f, Int(i))

"""
    setcoeff!(f::zz_pX, i::Integer, c)

Set the coefficient of x^i in f to c.
"""
setcoeff!(f::zz_pX, i::Integer, c::zz_p) = zz_pX_setcoeff(f, Int(i), c)
setcoeff!(f::zz_pX, i::Integer, c::Integer) = zz_pX_setcoeff(f, Int(i), zz_p(c))

"""
    leading(f::zz_pX) -> zz_p

Get the leading coefficient of f.
"""
leading(f::zz_pX) = zz_pX_leadcoeff(f)

"""
    constant(f::zz_pX) -> zz_p

Get the constant term (coefficient of x^0) of f.
"""
constant(f::zz_pX) = zz_pX_constterm(f)

# Arithmetic operators
Base.:+(f::zz_pX, g::zz_pX) = zz_pX_add(f, g)
Base.:-(f::zz_pX, g::zz_pX) = zz_pX_sub(f, g)
Base.:*(f::zz_pX, g::zz_pX) = zz_pX_mul(f, g)
Base.:-(f::zz_pX) = zz_pX_negate(f)
Base.div(f::zz_pX, g::zz_pX) = zz_pX_div(f, g)
Base.rem(f::zz_pX, g::zz_pX) = zz_pX_rem(f, g)
Base.divrem(f::zz_pX, g::zz_pX) = zz_pX_divrem(f, g)
Base.gcd(f::zz_pX, g::zz_pX) = zz_pX_gcd(f, g)

# Evaluation
"""
    (f::zz_pX)(x::zz_p) -> zz_p

Evaluate polynomial f at x.
"""
(f::zz_pX)(x::zz_p) = zz_pX_eval(f, x)

# Predicates
Base.iszero(f::zz_pX) = zz_pX_iszero(f)

"""
    is_irreducible(f::zz_pX) -> Bool

Test if polynomial f is irreducible over the current zz_p field.
"""
is_irreducible(f::zz_pX) = zz_pX_is_irreducible(f)

# Display
function Base.show(io::IO, f::zz_pX)
    print(io, zz_pX_to_string(f))
end

# Indexing (0-based coefficient access)
Base.getindex(f::zz_pX, i::Integer) = coeff(f, i)
Base.setindex!(f::zz_pX, c, i::Integer) = setcoeff!(f, i, c)

# Length (number of coefficients)
Base.length(f::zz_pX) = max(0, degree(f) + 1)

# Zero
Base.zero(::Type{zz_pX}) = zz_pX()
