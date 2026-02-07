"""
Development mode implementation for ZZ_p using pure Julia.
"""

# Thread-local modulus storage (stores ZZ)
const _ZZ_p_modulus_ref = Ref{ZZ}(ZZ(0))

"""
    ZZ_p

Modular integer type. In development mode, this is a wrapper around ZZ.
"""
mutable struct ZZ_p
    value::ZZ

    # Inner constructor - takes already-reduced value
    # The Nothing parameter distinguishes this from outer constructors
    function ZZ_p(reduced_value::ZZ, ::Nothing)
        new(reduced_value)
    end
end

"""
    ZZ_pContext

Context for saving/restoring ZZ_p modulus state.
"""
mutable struct ZZ_pContext
    modulus::ZZ
    ZZ_pContext() = new(ZZ(0))
    ZZ_pContext(p::ZZ) = new(p)
end

# Helper function for modular reduction
function _mod_zz(a::ZZ, m::ZZ)
    r = ZZ(rem(a.value, m.value))
    if r.value < 0
        r = ZZ(r.value + m.value)
    end
    return r
end

# Public constructors that reduce
ZZ_p(x::ZZ) = ZZ_p(_mod_zz(x, _ZZ_p_modulus_ref[]), nothing)
ZZ_p(x::Int64) = ZZ_p(ZZ(x))
ZZ_p(x::Integer) = ZZ_p(ZZ(x))
ZZ_p() = ZZ_p(ZZ(0))

# Mock C++ wrapper functions
function ZZ_p_init(p::ZZ)
    if p.value <= 1
        throw(DomainError(p, "Modulus must be > 1"))
    end
    _ZZ_p_modulus_ref[] = copy(p)
end

ZZ_p_modulus() = copy(_ZZ_p_modulus_ref[])

ZZ_pContext_save(ctx::ZZ_pContext) = (ctx.modulus = copy(_ZZ_p_modulus_ref[]); nothing)
ZZ_pContext_restore(ctx::ZZ_pContext) = (_ZZ_p_modulus_ref[] = copy(ctx.modulus); nothing)

ZZ_p_rep(a::ZZ_p) = copy(a.value)

ZZ_p_add(a::ZZ_p, b::ZZ_p) = ZZ_p(_mod_zz(ZZ(a.value.value + b.value.value), _ZZ_p_modulus_ref[]), nothing)
ZZ_p_sub(a::ZZ_p, b::ZZ_p) = ZZ_p(_mod_zz(ZZ(a.value.value - b.value.value), _ZZ_p_modulus_ref[]), nothing)
ZZ_p_mul(a::ZZ_p, b::ZZ_p) = ZZ_p(_mod_zz(ZZ(a.value.value * b.value.value), _ZZ_p_modulus_ref[]), nothing)
ZZ_p_negate(a::ZZ_p) = ZZ_p(_mod_zz(ZZ(-a.value.value), _ZZ_p_modulus_ref[]), nothing)

function ZZ_p_inv(a::ZZ_p)
    g, s, _ = gcdx(a.value.value, _ZZ_p_modulus_ref[].value)
    if g != 1
        throw(DomainError(a.value, "No inverse exists"))
    end
    ZZ_p(_mod_zz(ZZ(s), _ZZ_p_modulus_ref[]), nothing)
end

function ZZ_p_div(a::ZZ_p, b::ZZ_p)
    ZZ_p_mul(a, ZZ_p_inv(b))
end

ZZ_p_power(a::ZZ_p, e::Int) = ZZ_p(ZZ(powermod(a.value.value, e, _ZZ_p_modulus_ref[].value)), nothing)
ZZ_p_power_ZZ(a::ZZ_p, e::ZZ) = ZZ_p(ZZ(powermod(a.value.value, e.value, _ZZ_p_modulus_ref[].value)), nothing)

ZZ_p_iszero(a::ZZ_p) = iszero(a.value.value)
ZZ_p_isone(a::ZZ_p) = isone(a.value.value)

# Copy
Base.copy(a::ZZ_p) = ZZ_p(copy(a.value), nothing)
Base.deepcopy_internal(a::ZZ_p, dict::IdDict) = copy(a)
