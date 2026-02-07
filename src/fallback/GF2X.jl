"""
Development mode implementation for GF2X (polynomials over GF(2)) using pure Julia.
"""

"""
    GF2X

Polynomial over GF(2). Stores coefficients as a BitVector for efficiency.
"""
mutable struct GF2X
    coeffs::BitVector  # coeffs[i+1] is the coefficient of x^i
    GF2X() = new(BitVector())
    GF2X(coeffs::BitVector) = new(copy(coeffs))
end

# Constructors
GF2X(c::GF2) = iszero(c) ? GF2X() : GF2X(BitVector([c.value]))
GF2X(c::Integer) = GF2X(GF2(c))
GF2X(v::Vector{<:Integer}) = GF2X(BitVector([isodd(x) for x in v]))
GF2X(v::Vector{GF2}) = GF2X(BitVector([x.value for x in v]))

# Trim trailing zeros
function _trim_GF2X!(f::GF2X)
    while !isempty(f.coeffs) && !f.coeffs[end]
        pop!(f.coeffs)
    end
    return f
end

# Degree
function GF2X_deg(f::GF2X)
    _trim_GF2X!(f)
    return length(f.coeffs) - 1
end

# Coefficient access
function GF2X_coeff(f::GF2X, i::Int)
    if i < 0 || i >= length(f.coeffs)
        return GF2(0)
    end
    return GF2(f.coeffs[i + 1])
end

function GF2X_setcoeff!(f::GF2X, i::Int, c::GF2)
    while length(f.coeffs) <= i
        push!(f.coeffs, false)
    end
    f.coeffs[i + 1] = c.value
    _trim_GF2X!(f)
end

GF2X_setcoeff!(f::GF2X, i::Int, c::Integer) = GF2X_setcoeff!(f, i, GF2(c))

GF2X_leadcoeff(f::GF2X) = isempty(f.coeffs) ? GF2(0) : GF2(f.coeffs[end])
GF2X_constterm(f::GF2X) = isempty(f.coeffs) ? GF2(0) : GF2(f.coeffs[1])

# Arithmetic
function GF2X_add(f::GF2X, g::GF2X)
    n = max(length(f.coeffs), length(g.coeffs))
    result = BitVector(undef, n)
    for i in 1:n
        a = i <= length(f.coeffs) ? f.coeffs[i] : false
        b = i <= length(g.coeffs) ? g.coeffs[i] : false
        result[i] = xor(a, b)
    end
    r = GF2X(result)
    _trim_GF2X!(r)
    return r
end

GF2X_sub(f::GF2X, g::GF2X) = GF2X_add(f, g)  # Same as addition in GF(2)
GF2X_negate(f::GF2X) = GF2X(copy(f.coeffs))  # Negation is identity

function GF2X_mul(f::GF2X, g::GF2X)
    if isempty(f.coeffs) || isempty(g.coeffs)
        return GF2X()
    end
    n = length(f.coeffs) + length(g.coeffs) - 1
    result = BitVector(undef, n)
    fill!(result, false)
    for i in 1:length(f.coeffs)
        if f.coeffs[i]
            for j in 1:length(g.coeffs)
                if g.coeffs[j]
                    result[i + j - 1] = xor(result[i + j - 1], true)
                end
            end
        end
    end
    r = GF2X(result)
    _trim_GF2X!(r)
    return r
end

function GF2X_divrem(f::GF2X, g::GF2X)
    _trim_GF2X!(f)
    _trim_GF2X!(g)

    if isempty(g.coeffs)
        throw(DomainError(g, "Division by zero polynomial"))
    end

    q_coeffs = BitVector()
    r = BitVector(copy(f.coeffs))

    deg_g = length(g.coeffs) - 1

    while length(r) - 1 >= deg_g
        deg_r = length(r) - 1
        if !r[end]
            pop!(r)
            continue
        end

        pos = deg_r - deg_g

        while length(q_coeffs) <= pos
            push!(q_coeffs, false)
        end
        q_coeffs[pos + 1] = true

        for i in 0:deg_g
            r[pos + i + 1] = xor(r[pos + i + 1], g.coeffs[i + 1])
        end

        # Remove leading zeros
        while !isempty(r) && !r[end]
            pop!(r)
        end
    end

    q = GF2X(q_coeffs)
    _trim_GF2X!(q)
    return (q, GF2X(r))
end

GF2X_div(f::GF2X, g::GF2X) = GF2X_divrem(f, g)[1]
GF2X_rem(f::GF2X, g::GF2X) = GF2X_divrem(f, g)[2]

function GF2X_gcd(f::GF2X, g::GF2X)
    _trim_GF2X!(f)
    _trim_GF2X!(g)

    a = GF2X(copy(f.coeffs))
    b = GF2X(copy(g.coeffs))

    while !isempty(b.coeffs)
        a, b = b, GF2X_rem(a, b)
    end

    # Make monic (leading coefficient = 1, which it always is in GF(2) if nonzero)
    return a
end

# Derivative (formal derivative)
function GF2X_diff(f::GF2X)
    if length(f.coeffs) <= 1
        return GF2X()
    end
    # In GF(2), derivative of x^n is n*x^(n-1) = x^(n-1) if n odd, 0 if n even
    result = BitVector()
    for i in 2:length(f.coeffs)
        if isodd(i - 1)  # coefficient of x^(i-1)
            push!(result, f.coeffs[i])
        else
            push!(result, false)
        end
    end
    r = GF2X(result)
    _trim_GF2X!(r)
    return r
end

# Evaluation
function GF2X_eval(f::GF2X, x::GF2)
    if isempty(f.coeffs)
        return GF2(0)
    end
    result = GF2(f.coeffs[end])
    for i in length(f.coeffs)-1:-1:1
        result = result * x + GF2(f.coeffs[i])
    end
    return result
end

GF2X_iszero(f::GF2X) = (_trim_GF2X!(f); isempty(f.coeffs))

function GF2X_to_string(f::GF2X)
    _trim_GF2X!(f)
    if isempty(f.coeffs)
        return "[0]"
    end
    return "[" * join([string(Int(c)) for c in f.coeffs], " ") * "]"
end

# Irreducibility test
function GF2X_is_irreducible(f::GF2X)
    _trim_GF2X!(f)
    d = length(f.coeffs) - 1

    if d <= 0
        return false  # Constants are not irreducible
    end
    if d == 1
        return true  # Linear polynomials are irreducible
    end

    # For degree 2 or 3, check for roots
    if d <= 3
        for x in [GF2(0), GF2(1)]
            if iszero(GF2X_eval(f, x))
                return false
            end
        end
        if d <= 3
            return true
        end
    end

    # Check if f shares a factor with its derivative
    df = GF2X_diff(f)
    if isempty(df.coeffs)
        return false  # Derivative is zero (perfect square in char 2)
    end

    g = GF2X_gcd(f, df)
    if length(g.coeffs) > 1
        return false
    end

    return true
end

# Copy
Base.copy(f::GF2X) = GF2X(copy(f.coeffs))
Base.deepcopy_internal(f::GF2X, dict::IdDict) = copy(f)
