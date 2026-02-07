"""
Development mode implementation for ZZ_pE (extension field elements) using pure Julia.

ZZ_pE represents elements of GF(p^k) = Z/pZ[x] / (P(x)) where P is an
irreducible polynomial of degree k over Z/pZ.
"""

# Thread-local extension polynomial storage
const _ZZ_pE_modulus_ref = Ref{ZZ_pX}(ZZ_pX())

"""
    ZZ_pE

Extension field element. In development mode, this is represented as a
polynomial of degree < k where k = degree of the extension.
"""
mutable struct ZZ_pE
    rep::ZZ_pX  # Representative polynomial (degree < extension degree)

    function ZZ_pE(p::ZZ_pX, ::Nothing)
        # Reduce mod extension polynomial if needed
        ext_poly = _ZZ_pE_modulus_ref[]
        if !iszero(ext_poly) && degree(p) >= degree(ext_poly)
            _, r = divrem(p, ext_poly)
            new(r)
        else
            new(copy(p))
        end
    end
end

"""
    ZZ_pEContext

Context for saving/restoring ZZ_pE extension polynomial state.
"""
mutable struct ZZ_pEContext
    extension_poly::ZZ_pX
    ZZ_pEContext() = new(ZZ_pX())
end

# Constructors
ZZ_pE() = ZZ_pE(ZZ_pX(), nothing)
ZZ_pE(c::ZZ_p) = ZZ_pE(ZZ_pX(c), nothing)
ZZ_pE(c::Integer) = ZZ_pE(ZZ_p(c))
ZZ_pE(p::ZZ_pX) = ZZ_pE(p, nothing)

# Extension field initialization
function ZZ_pE_init(P::ZZ_pX)
    if !is_irreducible(P)
        @warn "Extension polynomial may not be irreducible"
    end
    _ZZ_pE_modulus_ref[] = copy(P)
end

ZZ_pE_degree() = degree(_ZZ_pE_modulus_ref[])
ZZ_pE_modulus() = copy(_ZZ_pE_modulus_ref[])

ZZ_pEContext_save(ctx::ZZ_pEContext) = (ctx.extension_poly = copy(_ZZ_pE_modulus_ref[]); nothing)
ZZ_pEContext_restore(ctx::ZZ_pEContext) = (_ZZ_pE_modulus_ref[] = copy(ctx.extension_poly); nothing)

ZZ_pE_rep(a::ZZ_pE) = copy(a.rep)

# Reduce mod extension polynomial
function _reduce_ZZ_pE(p::ZZ_pX)
    ext_poly = _ZZ_pE_modulus_ref[]
    if iszero(ext_poly) || degree(p) < degree(ext_poly)
        return p
    end
    _, r = divrem(p, ext_poly)
    return r
end

# Arithmetic
function ZZ_pE_add(a::ZZ_pE, b::ZZ_pE)
    ZZ_pE(_reduce_ZZ_pE(a.rep + b.rep), nothing)
end

function ZZ_pE_sub(a::ZZ_pE, b::ZZ_pE)
    ZZ_pE(_reduce_ZZ_pE(a.rep - b.rep), nothing)
end

function ZZ_pE_mul(a::ZZ_pE, b::ZZ_pE)
    ZZ_pE(_reduce_ZZ_pE(a.rep * b.rep), nothing)
end

function ZZ_pE_negate(a::ZZ_pE)
    ZZ_pE(-a.rep, nothing)
end

# Extended Euclidean algorithm for polynomials
function _ZZ_pX_xgcd(a::ZZ_pX, b::ZZ_pX)
    if iszero(b)
        return (a, ZZ_pX(ZZ_p(1)), ZZ_pX())
    end

    # Initialize
    old_r, r = a, b
    old_s, s = ZZ_pX(ZZ_p(1)), ZZ_pX()

    while !iszero(r)
        q = div(old_r, r)
        old_r, r = r, old_r - q * r
        old_s, s = s, old_s - q * s
    end

    # Make monic
    if !iszero(old_r) && !iszero(leading(old_r))
        lc_inv = inv(leading(old_r))
        for i in 0:degree(old_r)
            setcoeff!(old_r, i, coeff(old_r, i) * lc_inv)
        end
        for i in 0:degree(old_s)
            setcoeff!(old_s, i, coeff(old_s, i) * lc_inv)
        end
    end

    return (old_r, old_s)
end

function ZZ_pE_inv(a::ZZ_pE)
    if iszero(a.rep)
        throw(DomainError(a, "Inverse of zero"))
    end

    ext_poly = _ZZ_pE_modulus_ref[]
    g, s = _ZZ_pX_xgcd(a.rep, ext_poly)

    # g should be 1 (constant) for irreducible extension
    if degree(g) != 0
        throw(DomainError(a, "Element is not invertible (extension may not be a field)"))
    end

    # s * a ≡ g (mod ext_poly)
    # So s / g is the inverse
    g_inv = inv(constant(g))
    result = ZZ_pX()
    for i in 0:degree(s)
        setcoeff!(result, i, coeff(s, i) * g_inv)
    end

    ZZ_pE(result, nothing)
end

function ZZ_pE_div(a::ZZ_pE, b::ZZ_pE)
    ZZ_pE_mul(a, ZZ_pE_inv(b))
end

function ZZ_pE_power(a::ZZ_pE, e::Int64)
    if e == 0
        return ZZ_pE(ZZ_p(1))
    end
    if e < 0
        return ZZ_pE_power(ZZ_pE_inv(a), -e)
    end

    result = ZZ_pE(ZZ_p(1))
    base = copy(a)

    while e > 0
        if e & 1 == 1
            result = ZZ_pE_mul(result, base)
        end
        base = ZZ_pE_mul(base, base)
        e >>= 1
    end

    return result
end

function ZZ_pE_power_ZZ(a::ZZ_pE, e::ZZ)
    ZZ_pE_power(a, Int64(e.value))
end

ZZ_pE_iszero(a::ZZ_pE) = iszero(a.rep)
ZZ_pE_isone(a::ZZ_pE) = degree(a.rep) == 0 && isone(constant(a.rep))

# Random element
function ZZ_pE_random()
    d = ZZ_pE_degree()
    p = ZZ_pX()
    for i in 0:(d-1)
        # Random coefficient in ZZ_p
        m = ZZ_p_modulus()
        c = ZZ_p(rand(0:Int64(m.value)-1))
        setcoeff!(p, i, c)
    end
    ZZ_pE(p, nothing)
end

# Copy
Base.copy(a::ZZ_pE) = ZZ_pE(copy(a.rep), nothing)
Base.deepcopy_internal(a::ZZ_pE, dict::IdDict) = copy(a)
