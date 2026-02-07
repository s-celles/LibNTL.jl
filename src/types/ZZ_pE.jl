"""
High-level interface for ZZ_pE (extension field elements).

ZZ_pE represents elements of GF(p^k), the finite field with p^k elements,
implemented as Z/pZ[x] / (P(x)) where P is an irreducible polynomial of degree k.
"""

# Initialization
"""
    ZZ_pE_init!(P::ZZ_pX)

Initialize the extension field with irreducible polynomial P.
The ZZ_p modulus must be set before calling this.

# Example
```julia
ZZ_p_init!(ZZ(17))          # Set base field
P = ZZ_pX([ZZ_p(1), ZZ_p(0), ZZ_p(1)])  # x² + 1
ZZ_pE_init!(P)              # Now working in GF(17²)
```
"""
function ZZ_pE_init!(P::ZZ_pX)
    ZZ_pE_init(P)
end

"""
    ZZ_pE_degree() -> Int

Get the degree of the extension (dimension over base field).
"""
ZZ_pE_degree

"""
    ZZ_pE_modulus() -> ZZ_pX

Get the irreducible polynomial defining the extension.
"""
ZZ_pE_modulus

# Context management
"""
    ZZ_pEContext

Context for saving and restoring ZZ_pE extension state.
"""
ZZ_pEContext

"""
    save!(ctx::ZZ_pEContext)

Save the current extension field into the context.
"""
save!(ctx::ZZ_pEContext) = ZZ_pEContext_save(ctx)

"""
    restore!(ctx::ZZ_pEContext)

Restore the extension field from the context.
"""
restore!(ctx::ZZ_pEContext) = ZZ_pEContext_restore(ctx)

"""
    with_extension(f::Function, P::ZZ_pX)

Execute function f with extension field temporarily set by polynomial P.

# Example
```julia
ZZ_p_init!(ZZ(17))
P = ZZ_pX([ZZ_p(1), ZZ_p(0), ZZ_p(1)])  # x² + 1

with_extension(P) do
    a = ZZ_pE_random()
    b = a^2
    println(b)
end
```
"""
function with_extension(f::Function, P::ZZ_pX)
    ctx = ZZ_pEContext()
    save!(ctx)
    try
        ZZ_pE_init!(P)
        return f()
    finally
        restore!(ctx)
    end
end

# Representation
"""
    rep(a::ZZ_pE) -> ZZ_pX

Get the polynomial representative of an extension field element.
"""
rep(a::ZZ_pE) = ZZ_pE_rep(a)

# Arithmetic operators
Base.:+(a::ZZ_pE, b::ZZ_pE) = ZZ_pE_add(a, b)
Base.:-(a::ZZ_pE, b::ZZ_pE) = ZZ_pE_sub(a, b)
Base.:*(a::ZZ_pE, b::ZZ_pE) = ZZ_pE_mul(a, b)
Base.:-(a::ZZ_pE) = ZZ_pE_negate(a)
Base.inv(a::ZZ_pE) = ZZ_pE_inv(a)
Base.:/(a::ZZ_pE, b::ZZ_pE) = ZZ_pE_div(a, b)
Base.:^(a::ZZ_pE, e::Integer) = ZZ_pE_power(a, Int64(e))
Base.:^(a::ZZ_pE, e::ZZ) = ZZ_pE_power_ZZ(a, e)

# Predicates
Base.iszero(a::ZZ_pE) = ZZ_pE_iszero(a)
Base.isone(a::ZZ_pE) = ZZ_pE_isone(a)

# Comparison
Base.:(==)(a::ZZ_pE, b::ZZ_pE) = rep(a) == rep(b)

# Display
function Base.show(io::IO, a::ZZ_pE)
    print(io, rep(a))
end

# Zero and one
Base.zero(::Type{ZZ_pE}) = ZZ_pE()
Base.one(::Type{ZZ_pE}) = ZZ_pE(1)

# Random element
"""
    rand(::Type{ZZ_pE}) -> ZZ_pE

Generate a random element of the extension field.
"""
Base.rand(::Type{ZZ_pE}) = ZZ_pE_random()

# Export
export ZZ_pE, ZZ_pEContext
export ZZ_pE_init!, ZZ_pE_degree, ZZ_pE_modulus, with_extension
