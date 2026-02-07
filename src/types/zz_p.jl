"""
High-level interface for zz_p (single-precision modular integers).

zz_p is NTL's optimized type for modular arithmetic when the
modulus fits in a single machine word (typically < 2^62).
"""

# Initialization
"""
    zz_p_init!(p::Integer)

Initialize the global zz_p modulus. Must be called before using zz_p values.
The modulus should be a prime that fits in a machine word.

# Example
```julia
zz_p_init!(17)
x = zz_p(5)
```
"""
function zz_p_init!(p::Integer)
    zz_p_init(Int64(p))
end

"""
    zz_p_FFTInit!(i::Integer)

Initialize zz_p with the i-th FFT prime from NTL's table.
This is optimized for FFT-based polynomial multiplication.

# Example
```julia
zz_p_FFTInit!(0)  # Use first FFT prime
```
"""
function zz_p_FFTInit!(i::Integer)
    zz_p_FFTInit(Int64(i))
end

"""
    zz_p_modulus()

Get the current zz_p modulus.
"""
zz_p_modulus

# Context management
"""
    zz_pContext

Context for saving and restoring zz_p modulus state.
"""
zz_pContext

"""
    save!(ctx::zz_pContext)

Save the current zz_p modulus into the context.
"""
save!(ctx::zz_pContext) = zz_pContext_save(ctx)

"""
    restore!(ctx::zz_pContext)

Restore the zz_p modulus from the context.
"""
restore!(ctx::zz_pContext) = zz_pContext_restore(ctx)

"""
    with_small_modulus(f::Function, p::Integer)

Execute function f with zz_p modulus temporarily set to p.

# Example
```julia
with_small_modulus(17) do
    x = zz_p(5)
    y = x^2
    println(y)  # 8
end
```
"""
function with_small_modulus(f::Function, p::Integer)
    ctx = zz_pContext()
    save!(ctx)
    try
        zz_p_init!(p)
        return f()
    finally
        restore!(ctx)
    end
end

# Representation
"""
    rep(a::zz_p) -> Int64

Get the integer representative of a modular value.
"""
rep(a::zz_p) = zz_p_rep(a)

# Arithmetic operators
Base.:+(a::zz_p, b::zz_p) = zz_p_add(a, b)
Base.:-(a::zz_p, b::zz_p) = zz_p_sub(a, b)
Base.:*(a::zz_p, b::zz_p) = zz_p_mul(a, b)
Base.:-(a::zz_p) = zz_p_negate(a)
Base.inv(a::zz_p) = zz_p_inv(a)
Base.:/(a::zz_p, b::zz_p) = zz_p_div(a, b)
Base.:^(a::zz_p, e::Integer) = zz_p_power(a, Int64(e))

# Predicates
Base.iszero(a::zz_p) = zz_p_iszero(a)
Base.isone(a::zz_p) = zz_p_isone(a)

# Comparison
Base.:(==)(a::zz_p, b::zz_p) = zz_p_rep(a) == zz_p_rep(b)
Base.hash(a::zz_p, h::UInt) = hash(zz_p_rep(a), h)

# Display
function Base.show(io::IO, a::zz_p)
    print(io, zz_p_rep(a))
end

# Zero and one
Base.zero(::Type{zz_p}) = zz_p(0)
Base.one(::Type{zz_p}) = zz_p(1)

# Conversion
(::Type{Int64})(a::zz_p) = zz_p_rep(a)
