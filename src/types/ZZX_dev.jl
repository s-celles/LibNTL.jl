"""
Development mode implementation for ZZX using pure Julia.
"""

"""
    ZZX

Polynomial over integers. In development mode, stores coefficients as Vector{ZZ}.
"""
mutable struct ZZX
    coeffs::Vector{ZZ}  # coeffs[i+1] is the coefficient of x^i
    ZZX() = new(ZZ[])
    ZZX(coeffs::Vector{ZZ}) = new(copy(coeffs))
end

# Constructors
ZZX(c::ZZ) = iszero(c.value) ? ZZX() : ZZX([c])
ZZX(c::Integer) = ZZX(ZZ(c))

# Mock C++ wrapper functions
function ZZX_deg(f::ZZX)
    # Remove trailing zeros
    while !isempty(f.coeffs) && iszero(f.coeffs[end].value)
        pop!(f.coeffs)
    end
    return length(f.coeffs) - 1
end

function ZZX_coeff(f::ZZX, i::Int)
    if i < 0 || i >= length(f.coeffs)
        return ZZ(0)
    end
    return copy(f.coeffs[i + 1])
end

function ZZX_setcoeff(f::ZZX, i::Int, c::ZZ)
    # Extend if needed
    while length(f.coeffs) <= i
        push!(f.coeffs, ZZ(0))
    end
    f.coeffs[i + 1] = copy(c)
    # Trim trailing zeros
    while !isempty(f.coeffs) && iszero(f.coeffs[end].value)
        pop!(f.coeffs)
    end
end

ZZX_leadcoeff(f::ZZX) = isempty(f.coeffs) ? ZZ(0) : copy(f.coeffs[end])
ZZX_constterm(f::ZZX) = isempty(f.coeffs) ? ZZ(0) : copy(f.coeffs[1])

function ZZX_add(f::ZZX, g::ZZX)
    n = max(length(f.coeffs), length(g.coeffs))
    result = [ZZ(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        result[i] = ZZ(result[i].value + f.coeffs[i].value)
    end
    for i in 1:length(g.coeffs)
        result[i] = ZZ(result[i].value + g.coeffs[i].value)
    end
    while !isempty(result) && iszero(result[end].value)
        pop!(result)
    end
    ZZX(result)
end

function ZZX_sub(f::ZZX, g::ZZX)
    n = max(length(f.coeffs), length(g.coeffs))
    result = [ZZ(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        result[i] = ZZ(result[i].value + f.coeffs[i].value)
    end
    for i in 1:length(g.coeffs)
        result[i] = ZZ(result[i].value - g.coeffs[i].value)
    end
    while !isempty(result) && iszero(result[end].value)
        pop!(result)
    end
    ZZX(result)
end

function ZZX_mul(f::ZZX, g::ZZX)
    if isempty(f.coeffs) || isempty(g.coeffs)
        return ZZX()
    end
    n = length(f.coeffs) + length(g.coeffs) - 1
    result = [ZZ(0) for _ in 1:n]
    for i in 1:length(f.coeffs)
        for j in 1:length(g.coeffs)
            result[i + j - 1] = ZZ(result[i + j - 1].value + f.coeffs[i].value * g.coeffs[j].value)
        end
    end
    while !isempty(result) && iszero(result[end].value)
        pop!(result)
    end
    ZZX(result)
end

ZZX_mul_scalar(c::ZZ, f::ZZX) = ZZX([ZZ(c.value * x.value) for x in f.coeffs])
ZZX_negate(f::ZZX) = ZZX([ZZ(-x.value) for x in f.coeffs])

function ZZX_divrem(f::ZZX, g::ZZX)
    if isempty(g.coeffs)
        throw(DomainError(g, "Division by zero polynomial"))
    end
    q_coeffs = ZZ[]
    r = [copy(c) for c in f.coeffs]

    lc_g = g.coeffs[end].value
    deg_g = length(g.coeffs) - 1

    while length(r) - 1 >= deg_g
        deg_r = length(r) - 1
        lc_r = r[end].value

        if rem(lc_r, lc_g) != 0
            break
        end

        coef = div(lc_r, lc_g)
        pos = deg_r - deg_g

        while length(q_coeffs) <= pos
            push!(q_coeffs, ZZ(0))
        end
        q_coeffs[pos + 1] = ZZ(coef)

        for i in 0:deg_g
            r[pos + i + 1] = ZZ(r[pos + i + 1].value - coef * g.coeffs[i + 1].value)
        end

        while !isempty(r) && iszero(r[end].value)
            pop!(r)
        end
    end

    (ZZX(q_coeffs), ZZX(r))
end

ZZX_div(f::ZZX, g::ZZX) = ZZX_divrem(f, g)[1]
ZZX_rem(f::ZZX, g::ZZX) = ZZX_divrem(f, g)[2]

function ZZX_gcd(f::ZZX, g::ZZX)
    if isempty(f.coeffs)
        return ZZX([copy(c) for c in g.coeffs])
    end
    if isempty(g.coeffs)
        return ZZX([copy(c) for c in f.coeffs])
    end

    cf = ZZX_content(f)
    cg = ZZX_content(g)
    pf = ZZX_primpart(f)
    pg = ZZX_primpart(g)

    c = ZZ(gcd(cf.value, cg.value))

    while !isempty(pg.coeffs)
        pf, pg = pg, ZZX_rem(pf, pg)
    end

    result = ZZX_primpart(pf)
    ZZX_mul_scalar(c, result)
end

function ZZX_diff(f::ZZX)
    if length(f.coeffs) <= 1
        return ZZX()
    end
    result = ZZ[]
    for i in 2:length(f.coeffs)
        push!(result, ZZ(BigInt(i - 1) * f.coeffs[i].value))
    end
    while !isempty(result) && iszero(result[end].value)
        pop!(result)
    end
    ZZX(result)
end

function ZZX_content(f::ZZX)
    if isempty(f.coeffs)
        return ZZ(0)
    end
    result = abs(f.coeffs[1].value)
    for i in 2:length(f.coeffs)
        result = gcd(result, abs(f.coeffs[i].value))
    end
    return ZZ(result)
end

function ZZX_primpart(f::ZZX)
    c = ZZX_content(f)
    if iszero(c.value)
        return ZZX()
    end
    ZZX([ZZ(div(x.value, c.value)) for x in f.coeffs])
end

function ZZX_eval(f::ZZX, x::ZZ)
    if isempty(f.coeffs)
        return ZZ(0)
    end
    result = copy(f.coeffs[end])
    for i in length(f.coeffs)-1:-1:1
        result = ZZ(result.value * x.value + f.coeffs[i].value)
    end
    return result
end

ZZX_iszero(f::ZZX) = isempty(f.coeffs)

function ZZX_to_string(f::ZZX)
    if isempty(f.coeffs)
        return "[0]"
    end
    return "[" * join([string(c) for c in f.coeffs], " ") * "]"
end

# Copy
Base.copy(f::ZZX) = ZZX([copy(c) for c in f.coeffs])
Base.deepcopy_internal(f::ZZX, dict::IdDict) = copy(f)
