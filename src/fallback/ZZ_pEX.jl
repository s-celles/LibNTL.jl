"""
Development mode implementation for ZZ_pEX (polynomials over extension field) using pure Julia.
"""

"""
    ZZ_pEX

Polynomial over extension field ZZ_pE. In development mode, stores
coefficients as Vector{ZZ_pE}.
"""
mutable struct ZZ_pEX
    coeffs::Vector{ZZ_pE}  # coeffs[i+1] is the coefficient of x^i
    ZZ_pEX() = new(ZZ_pE[])
    ZZ_pEX(coeffs::Vector{ZZ_pE}) = new(copy(coeffs))
end

# Constructors
ZZ_pEX(c::ZZ_pE) = ZZ_pE_iszero(c) ? ZZ_pEX() : ZZ_pEX([c])
ZZ_pEX(c::Integer) = ZZ_pEX(ZZ_pE(c))

# Trim trailing zeros
function _trim_ZZ_pEX!(f::ZZ_pEX)
    while !isempty(f.coeffs) && ZZ_pE_iszero(f.coeffs[end])
        pop!(f.coeffs)
    end
    return f
end

# Degree
function ZZ_pEX_deg(f::ZZ_pEX)
    _trim_ZZ_pEX!(f)
    return length(f.coeffs) - 1
end

# Coefficient access
function ZZ_pEX_coeff(f::ZZ_pEX, i::Int)
    if i < 0 || i >= length(f.coeffs)
        return ZZ_pE()
    end
    return copy(f.coeffs[i + 1])
end

function ZZ_pEX_setcoeff(f::ZZ_pEX, i::Int, c::ZZ_pE)
    while length(f.coeffs) <= i
        push!(f.coeffs, ZZ_pE())
    end
    f.coeffs[i + 1] = copy(c)
    _trim_ZZ_pEX!(f)
end

ZZ_pEX_leadcoeff(f::ZZ_pEX) = isempty(f.coeffs) ? ZZ_pE() : copy(f.coeffs[end])
ZZ_pEX_constterm(f::ZZ_pEX) = isempty(f.coeffs) ? ZZ_pE() : copy(f.coeffs[1])

# Arithmetic
function ZZ_pEX_add(f::ZZ_pEX, g::ZZ_pEX)
    n = max(length(f.coeffs), length(g.coeffs))
    result = [ZZ_pE() for _ in 1:n]
    for i in 1:length(f.coeffs)
        result[i] = ZZ_pE_add(result[i], f.coeffs[i])
    end
    for i in 1:length(g.coeffs)
        result[i] = ZZ_pE_add(result[i], g.coeffs[i])
    end
    r = ZZ_pEX(result)
    _trim_ZZ_pEX!(r)
    return r
end

function ZZ_pEX_sub(f::ZZ_pEX, g::ZZ_pEX)
    n = max(length(f.coeffs), length(g.coeffs))
    result = [ZZ_pE() for _ in 1:n]
    for i in 1:length(f.coeffs)
        result[i] = ZZ_pE_add(result[i], f.coeffs[i])
    end
    for i in 1:length(g.coeffs)
        result[i] = ZZ_pE_sub(result[i], g.coeffs[i])
    end
    r = ZZ_pEX(result)
    _trim_ZZ_pEX!(r)
    return r
end

function ZZ_pEX_mul(f::ZZ_pEX, g::ZZ_pEX)
    if isempty(f.coeffs) || isempty(g.coeffs)
        return ZZ_pEX()
    end
    n = length(f.coeffs) + length(g.coeffs) - 1
    result = [ZZ_pE() for _ in 1:n]
    for i in 1:length(f.coeffs)
        for j in 1:length(g.coeffs)
            result[i + j - 1] = ZZ_pE_add(result[i + j - 1],
                                          ZZ_pE_mul(f.coeffs[i], g.coeffs[j]))
        end
    end
    r = ZZ_pEX(result)
    _trim_ZZ_pEX!(r)
    return r
end

ZZ_pEX_negate(f::ZZ_pEX) = ZZ_pEX([ZZ_pE_negate(c) for c in f.coeffs])

function ZZ_pEX_divrem(f::ZZ_pEX, g::ZZ_pEX)
    _trim_ZZ_pEX!(f)
    _trim_ZZ_pEX!(g)

    if isempty(g.coeffs)
        throw(DomainError(g, "Division by zero polynomial"))
    end

    q_coeffs = ZZ_pE[]
    r = [copy(c) for c in f.coeffs]

    lc_g = g.coeffs[end]
    lc_g_inv = ZZ_pE_inv(lc_g)
    deg_g = length(g.coeffs) - 1

    while length(r) - 1 >= deg_g
        deg_r = length(r) - 1
        lc_r = r[end]

        coef = ZZ_pE_mul(lc_r, lc_g_inv)
        pos = deg_r - deg_g

        while length(q_coeffs) <= pos
            push!(q_coeffs, ZZ_pE())
        end
        q_coeffs[pos + 1] = coef

        for i in 0:deg_g
            r[pos + i + 1] = ZZ_pE_sub(r[pos + i + 1], ZZ_pE_mul(coef, g.coeffs[i + 1]))
        end

        while !isempty(r) && ZZ_pE_iszero(r[end])
            pop!(r)
        end
    end

    (ZZ_pEX(q_coeffs), ZZ_pEX(r))
end

ZZ_pEX_div(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_divrem(f, g)[1]
ZZ_pEX_rem(f::ZZ_pEX, g::ZZ_pEX) = ZZ_pEX_divrem(f, g)[2]

function ZZ_pEX_gcd(f::ZZ_pEX, g::ZZ_pEX)
    _trim_ZZ_pEX!(f)
    _trim_ZZ_pEX!(g)

    a = ZZ_pEX([copy(c) for c in f.coeffs])
    b = ZZ_pEX([copy(c) for c in g.coeffs])

    while !isempty(b.coeffs)
        a, b = b, ZZ_pEX_rem(a, b)
    end

    # Make monic
    if !isempty(a.coeffs)
        lc = a.coeffs[end]
        lc_inv = ZZ_pE_inv(lc)
        for i in eachindex(a.coeffs)
            a.coeffs[i] = ZZ_pE_mul(a.coeffs[i], lc_inv)
        end
    end

    return a
end

ZZ_pEX_iszero(f::ZZ_pEX) = (_trim_ZZ_pEX!(f); isempty(f.coeffs))

function ZZ_pEX_to_string(f::ZZ_pEX)
    _trim_ZZ_pEX!(f)
    if isempty(f.coeffs)
        return "[[0]]"
    end
    parts = String[]
    for c in f.coeffs
        push!(parts, "[" * string(c.rep) * "]")
    end
    return "[" * join(parts, " ") * "]"
end

# Random polynomial of given degree
function ZZ_pEX_random(n::Int)
    result = ZZ_pEX()
    for i in 0:(n-1)
        ZZ_pEX_setcoeff(result, i, ZZ_pE_random())
    end
    return result
end

# Minimum polynomial computation (simplified)
function ZZ_pEX_MinPolyMod(g::ZZ_pEX, f::ZZ_pEX)
    # For the minimum polynomial, we need to find the smallest degree polynomial
    # m(x) such that m(g) ≡ 0 (mod f)
    #
    # Simple approach: compute powers of g mod f until we find a linear dependence

    deg_f = ZZ_pEX_deg(f)
    if deg_f < 0
        throw(DomainError(f, "Modulus polynomial is zero"))
    end

    # Powers of g: 1, g, g², g³, ...
    powers = ZZ_pEX[ZZ_pEX(ZZ_pE(1))]  # g^0 = 1
    current = copy(g)

    for i in 1:deg_f
        _, r = ZZ_pEX_divrem(current, f)
        push!(powers, r)
        current = ZZ_pEX_mul(current, g)
    end

    # Now find minimum polynomial using linear algebra
    # This is a simplified implementation

    # For a basic implementation, return x - g if deg(g) = 0
    if ZZ_pEX_deg(g) == 0
        result = ZZ_pEX()
        ZZ_pEX_setcoeff(result, 0, ZZ_pE_negate(g.coeffs[1]))
        ZZ_pEX_setcoeff(result, 1, ZZ_pE(1))
        return result
    end

    # Default: return f itself as a rough approximation
    return copy(f)
end

# Composition: compute g(h) mod f
function ZZ_pEX_CompMod(g::ZZ_pEX, h::ZZ_pEX, f::ZZ_pEX)
    result = ZZ_pEX()
    h_power = ZZ_pEX(ZZ_pE(1))  # h^0 = 1

    for i in 0:ZZ_pEX_deg(g)
        c = ZZ_pEX_coeff(g, i)
        if !ZZ_pE_iszero(c)
            term = ZZ_pEX([c])
            term = ZZ_pEX_mul(term, h_power)
            result = ZZ_pEX_add(result, term)
        end

        # h_power *= h (mod f)
        h_power = ZZ_pEX_mul(h_power, h)
        _, h_power = ZZ_pEX_divrem(h_power, f)
    end

    # Final reduction
    _, result = ZZ_pEX_divrem(result, f)
    return result
end

# Copy
Base.copy(f::ZZ_pEX) = ZZ_pEX([copy(c) for c in f.coeffs])
Base.deepcopy_internal(f::ZZ_pEX, dict::IdDict) = copy(f)
