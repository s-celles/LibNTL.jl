"""
Development mode implementation for zz_p (small prime) using pure Julia.

zz_p is NTL's single-precision modular integer type, optimized for
primes that fit in a machine word. In fallback mode, we use Int64.
"""

# Thread-local modulus storage for zz_p (stores Int64)
const _zz_p_modulus_ref = Ref{Int64}(Int64(0))

# FFT prime table (first few NTL FFT primes)
const _FFT_PRIMES = [
    7681,       # 2^13 * 15/16 + 1
    65537,      # 2^16 + 1  (Fermat prime)
    786433,     # 2^18 * 3 + 1
    5767169,    # 2^19 * 11 + 1
    7340033,    # 2^20 * 7 + 1
    23068673,   # 2^21 * 11 + 1
    104857601,  # 2^22 * 25 + 1
    167772161,  # 2^25 * 5 + 1
    469762049,  # 2^26 * 7 + 1
    998244353,  # 2^23 * 7 * 17 + 1
]

"""
    zz_p

Single-precision modular integer type (for small primes).
In fallback mode, this wraps an Int64.
"""
mutable struct zz_p
    value::Int64

    # Inner constructor - takes already-reduced value
    function zz_p(reduced_value::Int64, ::Nothing)
        new(reduced_value)
    end
end

"""
    zz_pContext

Context for saving/restoring zz_p modulus state.
"""
mutable struct zz_pContext
    modulus::Int64
    zz_pContext() = new(Int64(0))
    zz_pContext(p::Int64) = new(p)
end

# Helper function for modular reduction
function _mod_small(a::Int64, m::Int64)
    r = mod(a, m)
    return r
end

# Public constructors that reduce
zz_p(x::Int64) = zz_p(_mod_small(x, _zz_p_modulus_ref[]), nothing)
zz_p(x::Integer) = zz_p(Int64(x))
zz_p() = zz_p(Int64(0), nothing)

# Modulus management
function zz_p_init(p::Int64)
    if p <= 1
        throw(DomainError(p, "Modulus must be > 1"))
    end
    _zz_p_modulus_ref[] = p
end

function zz_p_FFTInit(i::Int64)
    if i < 0 || i >= length(_FFT_PRIMES)
        throw(ArgumentError("FFT prime index out of range (0-$(length(_FFT_PRIMES)-1))"))
    end
    _zz_p_modulus_ref[] = _FFT_PRIMES[i+1]  # Julia is 1-indexed
end

zz_p_modulus() = _zz_p_modulus_ref[]

zz_pContext_save(ctx::zz_pContext) = (ctx.modulus = _zz_p_modulus_ref[]; nothing)
zz_pContext_restore(ctx::zz_pContext) = (_zz_p_modulus_ref[] = ctx.modulus; nothing)

zz_p_rep(a::zz_p) = a.value

# Arithmetic
zz_p_add(a::zz_p, b::zz_p) = zz_p(_mod_small(a.value + b.value, _zz_p_modulus_ref[]), nothing)
zz_p_sub(a::zz_p, b::zz_p) = zz_p(_mod_small(a.value - b.value, _zz_p_modulus_ref[]), nothing)
zz_p_mul(a::zz_p, b::zz_p) = zz_p(_mod_small(a.value * b.value, _zz_p_modulus_ref[]), nothing)
zz_p_negate(a::zz_p) = zz_p(_mod_small(-a.value, _zz_p_modulus_ref[]), nothing)

function zz_p_inv(a::zz_p)
    g, s, _ = gcdx(a.value, _zz_p_modulus_ref[])
    if g != 1
        throw(DomainError(a.value, "No inverse exists"))
    end
    zz_p(_mod_small(s, _zz_p_modulus_ref[]), nothing)
end

function zz_p_div(a::zz_p, b::zz_p)
    zz_p_mul(a, zz_p_inv(b))
end

zz_p_power(a::zz_p, e::Int64) = zz_p(powermod(a.value, e, _zz_p_modulus_ref[]), nothing)

zz_p_iszero(a::zz_p) = a.value == 0
zz_p_isone(a::zz_p) = a.value == 1

# Copy
Base.copy(a::zz_p) = zz_p(a.value, nothing)
Base.deepcopy_internal(a::zz_p, dict::IdDict) = copy(a)
