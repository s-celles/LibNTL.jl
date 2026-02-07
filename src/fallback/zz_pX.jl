"""
Development mode implementation for zz_pX using pure Julia.

zz_pX is NTL's polynomial type over single-precision modular integers.
"""

"""
    zz_pX

Polynomial over zz_p (small prime field). In development mode,
stores coefficients as Vector{zz_p}.
"""
mutable struct zz_pX
    coeffs::Vector{zz_p}  # coeffs[i+1] is the coefficient of x^i
    zz_pX() = new(zz_p[])
    zz_pX(coeffs::Vector{zz_p}) = new(copy(coeffs))
end

# Constructors
zz_pX(c::zz_p) = c.value == 0 ? zz_pX() : zz_pX([c])
zz_pX(c::Integer) = zz_pX(zz_p(c))

# Trim trailing zeros
function _trim_zz_pX!(f::zz_pX)
    while !isempty(f.coeffs) && f.coeffs[end].value == 0
        pop!(f.coeffs)
    end
    return f
end

# Mock C++ wrapper functions
function zz_pX_deg(f::zz_pX)
    _trim_zz_pX!(f)
    return length(f.coeffs) - 1
end

function zz_pX_coeff(f::zz_pX, i::Int)
    if i < 0 || i >= length(f.coeffs)
        return zz_p(0)
    end
    return copy(f.coeffs[i + 1])
end

function zz_pX_setcoeff(f::zz_pX, i::Int, c::zz_p)
    # Extend if needed
    while length(f.coeffs) <= i
        push!(f.coeffs, zz_p(0))
    end
    f.coeffs[i + 1] = copy(c)
    _trim_zz_pX!(f)
end

zz_pX_leadcoeff(f::zz_pX) = isempty(f.coeffs) ? zz_p(0) : copy(f.coeffs[end])
zz_pX_constterm(f::zz_pX) = isempty(f.coeffs) ? zz_p(0) : copy(f.coeffs[1])

function zz_pX_add(f::zz_pX, g::zz_pX)
    n = max(length(f.coeffs), length(g.coeffs))
    result = [zz_p(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        result[i] = zz_p_add(result[i], f.coeffs[i])
    end
    for i in 1:length(g.coeffs)
        result[i] = zz_p_add(result[i], g.coeffs[i])
    end
    r = zz_pX(result)
    _trim_zz_pX!(r)
    return r
end

function zz_pX_sub(f::zz_pX, g::zz_pX)
    n = max(length(f.coeffs), length(g.coeffs))
    result = [zz_p(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        result[i] = zz_p_add(result[i], f.coeffs[i])
    end
    for i in 1:length(g.coeffs)
        result[i] = zz_p_sub(result[i], g.coeffs[i])
    end
    r = zz_pX(result)
    _trim_zz_pX!(r)
    return r
end

function zz_pX_mul(f::zz_pX, g::zz_pX)
    if isempty(f.coeffs) || isempty(g.coeffs)
        return zz_pX()
    end
    n = length(f.coeffs) + length(g.coeffs) - 1
    result = [zz_p(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        for j in 1:length(g.coeffs)
            result[i + j - 1] = zz_p_add(result[i + j - 1],
                                         zz_p_mul(f.coeffs[i], g.coeffs[j]))
        end
    end
    r = zz_pX(result)
    _trim_zz_pX!(r)
    return r
end

zz_pX_negate(f::zz_pX) = zz_pX([zz_p_negate(c) for c in f.coeffs])

function zz_pX_divrem(f::zz_pX, g::zz_pX)
    _trim_zz_pX!(f)
    _trim_zz_pX!(g)

    if isempty(g.coeffs)
        throw(DomainError(g, "Division by zero polynomial"))
    end

    q_coeffs = zz_p[]
    r = [copy(c) for c in f.coeffs]

    lc_g = g.coeffs[end]
    lc_g_inv = zz_p_inv(lc_g)
    deg_g = length(g.coeffs) - 1

    while length(r) - 1 >= deg_g
        deg_r = length(r) - 1
        lc_r = r[end]

        coef = zz_p_mul(lc_r, lc_g_inv)
        pos = deg_r - deg_g

        while length(q_coeffs) <= pos
            push!(q_coeffs, zz_p(0))
        end
        q_coeffs[pos + 1] = coef

        for i in 0:deg_g
            r[pos + i + 1] = zz_p_sub(r[pos + i + 1], zz_p_mul(coef, g.coeffs[i + 1]))
        end

        # Remove leading zeros from r
        while !isempty(r) && r[end].value == 0
            pop!(r)
        end
    end

    (zz_pX(q_coeffs), zz_pX(r))
end

zz_pX_div(f::zz_pX, g::zz_pX) = zz_pX_divrem(f, g)[1]
zz_pX_rem(f::zz_pX, g::zz_pX) = zz_pX_divrem(f, g)[2]

function zz_pX_gcd(f::zz_pX, g::zz_pX)
    _trim_zz_pX!(f)
    _trim_zz_pX!(g)

    a = zz_pX([copy(c) for c in f.coeffs])
    b = zz_pX([copy(c) for c in g.coeffs])

    while !isempty(b.coeffs)
        a, b = b, zz_pX_rem(a, b)
    end

    # Make monic
    if !isempty(a.coeffs)
        lc = a.coeffs[end]
        lc_inv = zz_p_inv(lc)
        for i in eachindex(a.coeffs)
            a.coeffs[i] = zz_p_mul(a.coeffs[i], lc_inv)
        end
    end

    return a
end

function zz_pX_diff(f::zz_pX)
    if length(f.coeffs) <= 1
        return zz_pX()
    end
    result = zz_p[]
    for i in 2:length(f.coeffs)
        push!(result, zz_p_mul(zz_p(i - 1), f.coeffs[i]))
    end
    r = zz_pX(result)
    _trim_zz_pX!(r)
    return r
end

function zz_pX_eval(f::zz_pX, x::zz_p)
    if isempty(f.coeffs)
        return zz_p(0)
    end
    result = copy(f.coeffs[end])
    for i in length(f.coeffs)-1:-1:1
        result = zz_p_add(zz_p_mul(result, x), f.coeffs[i])
    end
    return result
end

zz_pX_iszero(f::zz_pX) = (_trim_zz_pX!(f); isempty(f.coeffs))

function zz_pX_to_string(f::zz_pX)
    _trim_zz_pX!(f)
    if isempty(f.coeffs)
        return "[0]"
    end
    return "[" * join([string(zz_p_rep(c)) for c in f.coeffs], " ") * "]"
end

# Irreducibility test
function zz_pX_is_irreducible(f::zz_pX)
    _trim_zz_pX!(f)
    d = length(f.coeffs) - 1

    if d <= 0
        return false
    end
    if d == 1
        return true
    end

    # For degree 2 or 3, check for roots
    p = zz_p_modulus()
    if d <= 3 && p <= 1000
        for i in 0:(p - 1)
            if zz_pX_eval(f, zz_p(i)).value == 0
                return false
            end
        end
        return true
    end

    # Check if f shares a factor with its derivative
    df = zz_pX_diff(f)
    if isempty(df.coeffs)
        return false
    end

    g = zz_pX_gcd(f, df)
    if length(g.coeffs) > 1
        return false
    end

    return true
end

# Copy
Base.copy(f::zz_pX) = zz_pX([copy(c) for c in f.coeffs])
Base.deepcopy_internal(f::zz_pX, dict::IdDict) = copy(f)
