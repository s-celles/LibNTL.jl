"""
Development mode implementation for GF2 (binary field) using pure Julia.
"""

"""
    GF2

Element of GF(2), the field with two elements {0, 1}.
Arithmetic is performed mod 2.
"""
struct GF2
    value::Bool
    GF2(v::Bool) = new(v)
end

# Constructors
GF2() = GF2(false)
GF2(x::Integer) = GF2(isodd(x))
GF2(x::GF2) = x

# Conversion to integer
Base.Int(x::GF2) = Int(x.value)
Base.Bool(x::GF2) = x.value

# Predicates
Base.iszero(x::GF2) = !x.value
Base.isone(x::GF2) = x.value

# Arithmetic (all mod 2)
Base.:+(x::GF2, y::GF2) = GF2(xor(x.value, y.value))
Base.:-(x::GF2, y::GF2) = x + y  # In GF(2), subtraction = addition
Base.:-(x::GF2) = x  # Negation is identity in GF(2)
Base.:*(x::GF2, y::GF2) = GF2(x.value && y.value)

# Division (only valid when y is nonzero)
function Base.inv(x::GF2)
    iszero(x) && throw(DomainError(x, "Cannot invert zero in GF(2)"))
    return x  # 1/1 = 1 in GF(2)
end

Base.:/(x::GF2, y::GF2) = x * inv(y)

# Power
function Base.:^(x::GF2, n::Integer)
    n < 0 && return inv(x)^(-n)
    n == 0 && return GF2(1)
    return x  # x^n = x for x in GF(2), n > 0
end

# Comparison
Base.:(==)(x::GF2, y::GF2) = x.value == y.value
Base.hash(x::GF2, h::UInt) = hash(x.value, h)

# Display
Base.show(io::IO, x::GF2) = print(io, Int(x))

# Copy
Base.copy(x::GF2) = x  # Immutable
Base.deepcopy_internal(x::GF2, ::IdDict) = x

# Zero and one
Base.zero(::Type{GF2}) = GF2(0)
Base.one(::Type{GF2}) = GF2(1)
Base.zero(::GF2) = GF2(0)
Base.one(::GF2) = GF2(1)
