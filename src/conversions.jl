"""
    Conversions between NTL types and Julia types.

This module provides conversion methods between NTL types (ZZ, ZZ_p, ZZX)
and standard Julia types (BigInt, Int64, etc.).
"""

# ============================================================================
# ZZ <-> BigInt Conversions
# ============================================================================

"""
    Base.convert(::Type{BigInt}, z::ZZ) -> BigInt

Convert a ZZ to a Julia BigInt.

# Examples
```julia
convert(BigInt, ZZ(42))  # big"42"
BigInt(ZZ("12345678901234567890"))  # big"12345678901234567890"
```
"""
function Base.convert(::Type{BigInt}, z::ZZ)
    parse(BigInt, string(z))
end

"""
    Base.BigInt(z::ZZ) -> BigInt

Convert a ZZ to a Julia BigInt.
"""
Base.BigInt(z::ZZ) = convert(BigInt, z)

"""
    Base.convert(::Type{ZZ}, x::BigInt) -> ZZ

Convert a Julia BigInt to a ZZ.

# Examples
```julia
convert(ZZ, big"42")  # ZZ(42)
```
"""
Base.convert(::Type{ZZ}, x::BigInt) = ZZ(x)

# ============================================================================
# ZZ <-> Int64 Conversions
# ============================================================================

"""
    Base.convert(::Type{Int64}, z::ZZ) -> Int64

Convert a ZZ to an Int64. Throws `InexactError` if the value
doesn't fit in an Int64.

# Examples
```julia
convert(Int64, ZZ(42))  # 42
convert(Int64, ZZ(typemax(Int64)))  # 9223372036854775807
```

# Throws
- `InexactError` if the ZZ value is outside Int64 range
"""
function Base.convert(::Type{Int64}, z::ZZ)
    # Get the value as BigInt first for safe comparison
    big_val = convert(BigInt, z)
    if big_val > typemax(Int64) || big_val < typemin(Int64)
        throw(InexactError(:convert, Int64, z))
    end
    return Int64(big_val)
end

# ============================================================================
# Promotion Rules
# ============================================================================

# Promote Integer types to ZZ when mixed with ZZ
Base.promote_rule(::Type{ZZ}, ::Type{<:Integer}) = ZZ

# Conversion from Integer to ZZ for promotion
Base.convert(::Type{ZZ}, x::Integer) = ZZ(x)
