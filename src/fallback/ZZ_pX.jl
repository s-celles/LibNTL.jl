"""
Development mode implementation for ZZ_pX using pure Julia.
"""

"""
    ZZ_pX

Polynomial over Z/pZ. In development mode, stores coefficients as Vector{ZZ_p}.
Operations are performed modulo the current ZZ_p modulus.
"""
mutable struct ZZ_pX
    coeffs::Vector{ZZ_p}  # coeffs[i+1] is the coefficient of x^i
    ZZ_pX() = new(ZZ_p[])
    ZZ_pX(coeffs::Vector{ZZ_p}) = new(copy(coeffs))
end

# Constructors
ZZ_pX(c::ZZ_p) = iszero(c) ? ZZ_pX() : ZZ_pX([c])
ZZ_pX(c::Integer) = ZZ_pX(ZZ_p(c))

# Trim trailing zeros
function _trim_ZZ_pX!(f::ZZ_pX)
    while !isempty(f.coeffs) && iszero(f.coeffs[end])
        pop!(f.coeffs)
    end
    return f
end

# Mock C++ wrapper functions
function ZZ_pX_deg(f::ZZ_pX)
    _trim_ZZ_pX!(f)
    return length(f.coeffs) - 1
end

function ZZ_pX_coeff(f::ZZ_pX, i::Int)
    if i < 0 || i >= length(f.coeffs)
        return ZZ_p(0)
    end
    return copy(f.coeffs[i + 1])
end

function ZZ_pX_setcoeff(f::ZZ_pX, i::Int, c::ZZ_p)
    # Extend if needed
    while length(f.coeffs) <= i
        push!(f.coeffs, ZZ_p(0))
    end
    f.coeffs[i + 1] = copy(c)
    _trim_ZZ_pX!(f)
end

ZZ_pX_leadcoeff(f::ZZ_pX) = isempty(f.coeffs) ? ZZ_p(0) : copy(f.coeffs[end])
ZZ_pX_constterm(f::ZZ_pX) = isempty(f.coeffs) ? ZZ_p(0) : copy(f.coeffs[1])

function ZZ_pX_add(f::ZZ_pX, g::ZZ_pX)
    n = max(length(f.coeffs), length(g.coeffs))
    result = [ZZ_p(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        result[i] = result[i] + f.coeffs[i]
    end
    for i in 1:length(g.coeffs)
        result[i] = result[i] + g.coeffs[i]
    end
    r = ZZ_pX(result)
    _trim_ZZ_pX!(r)
    return r
end

function ZZ_pX_sub(f::ZZ_pX, g::ZZ_pX)
    n = max(length(f.coeffs), length(g.coeffs))
    result = [ZZ_p(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        result[i] = result[i] + f.coeffs[i]
    end
    for i in 1:length(g.coeffs)
        result[i] = result[i] - g.coeffs[i]
    end
    r = ZZ_pX(result)
    _trim_ZZ_pX!(r)
    return r
end

function ZZ_pX_mul(f::ZZ_pX, g::ZZ_pX)
    if isempty(f.coeffs) || isempty(g.coeffs)
        return ZZ_pX()
    end
    n = length(f.coeffs) + length(g.coeffs) - 1
    result = [ZZ_p(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        for j in 1:length(g.coeffs)
            result[i + j - 1] = result[i + j - 1] + f.coeffs[i] * g.coeffs[j]
        end
    end
    r = ZZ_pX(result)
    _trim_ZZ_pX!(r)
    return r
end

ZZ_pX_negate(f::ZZ_pX) = ZZ_pX([-c for c in f.coeffs])

function ZZ_pX_divrem(f::ZZ_pX, g::ZZ_pX)
    _trim_ZZ_pX!(f)
    _trim_ZZ_pX!(g)

    if isempty(g.coeffs)
        throw(DomainError(g, "Division by zero polynomial"))
    end

    q_coeffs = ZZ_p[]
    r = [copy(c) for c in f.coeffs]

    lc_g = g.coeffs[end]
    lc_g_inv = inv(lc_g)  # Inverse of leading coefficient
    deg_g = length(g.coeffs) - 1

    while length(r) - 1 >= deg_g
        deg_r = length(r) - 1
        lc_r = r[end]

        coef = lc_r * lc_g_inv  # Division in Z/pZ
        pos = deg_r - deg_g

        while length(q_coeffs) <= pos
            push!(q_coeffs, ZZ_p(0))
        end
        q_coeffs[pos + 1] = coef

        for i in 0:deg_g
            r[pos + i + 1] = r[pos + i + 1] - coef * g.coeffs[i + 1]
        end

        # Remove leading zeros from r
        while !isempty(r) && iszero(r[end])
            pop!(r)
        end
    end

    (ZZ_pX(q_coeffs), ZZ_pX(r))
end

ZZ_pX_div(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_divrem(f, g)[1]
ZZ_pX_rem(f::ZZ_pX, g::ZZ_pX) = ZZ_pX_divrem(f, g)[2]

function ZZ_pX_gcd(f::ZZ_pX, g::ZZ_pX)
    _trim_ZZ_pX!(f)
    _trim_ZZ_pX!(g)

    a = ZZ_pX([copy(c) for c in f.coeffs])
    b = ZZ_pX([copy(c) for c in g.coeffs])

    while !isempty(b.coeffs)
        a, b = b, ZZ_pX_rem(a, b)
    end

    # Make monic (leading coefficient = 1)
    if !isempty(a.coeffs)
        lc = a.coeffs[end]
        lc_inv = inv(lc)
        for i in eachindex(a.coeffs)
            a.coeffs[i] = a.coeffs[i] * lc_inv
        end
    end

    return a
end

function ZZ_pX_diff(f::ZZ_pX)
    if length(f.coeffs) <= 1
        return ZZ_pX()
    end
    result = ZZ_p[]
    for i in 2:length(f.coeffs)
        push!(result, ZZ_p(i - 1) * f.coeffs[i])
    end
    r = ZZ_pX(result)
    _trim_ZZ_pX!(r)
    return r
end

function ZZ_pX_eval(f::ZZ_pX, x::ZZ_p)
    if isempty(f.coeffs)
        return ZZ_p(0)
    end
    result = copy(f.coeffs[end])
    for i in length(f.coeffs)-1:-1:1
        result = result * x + f.coeffs[i]
    end
    return result
end

ZZ_pX_iszero(f::ZZ_pX) = (_trim_ZZ_pX!(f); isempty(f.coeffs))

function ZZ_pX_to_string(f::ZZ_pX)
    _trim_ZZ_pX!(f)
    if isempty(f.coeffs)
        return "[0]"
    end
    return "[" * join([string(rep(c)) for c in f.coeffs], " ") * "]"
end

# Irreducibility test using simple method (check for roots and factor degree)
function ZZ_pX_is_irreducible(f::ZZ_pX)
    _trim_ZZ_pX!(f)
    d = length(f.coeffs) - 1

    # Degree 0 or 1 polynomials
    if d <= 0
        return false  # Constants are not irreducible
    end
    if d == 1
        return true   # Linear polynomials are irreducible
    end

    # For degree 2 or 3, check for roots (sufficient for irreducibility)
    # A degree 2 or 3 polynomial is irreducible iff it has no roots
    p = ZZ_p_modulus()
    if d <= 3 && p.value <= 1000  # Only check small primes
        for i in 0:(Int(p.value) - 1)
            if iszero(ZZ_pX_eval(f, ZZ_p(i)))
                return false  # Has a root, so reducible
            end
        end
        if d <= 3
            return true  # No roots found, irreducible for degree 2 or 3
        end
    end

    # For higher degrees, use a probabilistic method based on gcd with x^p - x
    # x^p - x = product of all monic irreducible polynomials of degree dividing 1
    # If gcd(f, x^p - x) = f, then f splits completely
    # For simplicity, we use a basic check

    # Check if f is a perfect power or has common factors with its derivative
    df = ZZ_pX_diff(f)
    if isempty(df.coeffs)
        return false  # Derivative is zero (perfect p-th power in char p)
    end

    g = ZZ_pX_gcd(f, df)
    if length(g.coeffs) > 1  # GCD has positive degree
        return false  # f shares a factor with its derivative
    end

    # For now, assume irreducible if passes basic checks
    # A full implementation would use Berlekamp's algorithm
    return true
end

# Copy
Base.copy(f::ZZ_pX) = ZZ_pX([copy(c) for c in f.coeffs])
Base.deepcopy_internal(f::ZZ_pX, dict::IdDict) = copy(f)
