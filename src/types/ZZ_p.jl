"""
    ZZ_p - Modular Integers

Julia wrapper for NTL's ZZ_p class providing arithmetic in Z/pZ.
"""

if _LIBNTL_DEV_MODE
    include("ZZ_p_dev.jl")
end

# High-level interface (works in both modes)

"""
    ZZ_p_init!(p::ZZ)

Set the global modulus for ZZ_p operations.
Throws `DomainError` if p <= 1.
"""
function ZZ_p_init!(p::ZZ)
    try
        ZZ_p_init(p)
    catch e
        # Convert C++ exception to DomainError
        if occursin("Modulus must be > 1", string(e))
            throw(DomainError(p, "Modulus must be > 1"))
        end
        rethrow(e)
    end
end

ZZ_p_init!(p::Integer) = ZZ_p_init!(ZZ(p))

"""
    save!(ctx::ZZ_pContext)

Save the current modulus state into the context.
"""
save!(ctx::ZZ_pContext) = ZZ_pContext_save(ctx)

"""
    restore!(ctx::ZZ_pContext)

Restore the modulus state from the context.
"""
restore!(ctx::ZZ_pContext) = ZZ_pContext_restore(ctx)

"""
    with_modulus(f::Function, p::ZZ)

Execute function `f` with a temporary modulus `p`.
The original modulus is restored after `f` completes.
"""
function with_modulus(f::Function, p::ZZ)
    old_ctx = ZZ_pContext()
    save!(old_ctx)
    try
        ZZ_p_init!(p)
        return f()
    finally
        restore!(old_ctx)
    end
end

with_modulus(f::Function, p::Integer) = with_modulus(f, ZZ(p))

# ZZ_p(x::ZZ) constructor - only needed for production mode
# Dev mode defines this in ZZ_p_dev.jl
if !_LIBNTL_DEV_MODE
    """
        ZZ_p(x::ZZ)

    Construct a ZZ_p from a ZZ value (reduced mod p).
    """
    function ZZ_p(x::ZZ)
        mod_p = ZZ_p_modulus()
        reduced = rem(x, mod_p)
        if sign(reduced) < 0
            reduced = reduced + mod_p
        end
        if numbits(reduced) <= 62
            return ZZ_p(convert(Int64, reduced))
        else
            error("ZZ value too large for direct ZZ_p construction")
        end
    end
end

"""
    rep(a::ZZ_p) -> ZZ

Get the representative integer in [0, p-1] for a ZZ_p value.
"""
rep(a::ZZ_p) = ZZ_p_rep(a)

# Display
Base.show(io::IO, a::ZZ_p) = print(io, string(rep(a)))

# Hash
Base.hash(a::ZZ_p, h::UInt) = hash(rep(a), h)

# Production mode copy (dev mode copy defined in ZZ_p_dev.jl)
if !_LIBNTL_DEV_MODE
    # Create copy via rep -> ZZ_p conversion
    Base.copy(a::ZZ_p) = ZZ_p(rep(a))
    Base.deepcopy_internal(a::ZZ_p, dict::IdDict) = copy(a)
end
