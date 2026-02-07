"""
Development mode implementation for ZZ using Julia's BigInt as internal storage.
"""

"""
    ZZ

Arbitrary-precision integer type. In development mode, this is a wrapper around BigInt.
"""
mutable struct ZZ
    value::BigInt
    ZZ(x::BigInt) = new(x)
end

# Constructors
ZZ() = ZZ(big"0")
ZZ(x::Int64) = ZZ(BigInt(x))
ZZ(x::Int32) = ZZ(BigInt(x))
ZZ(x::Integer) = ZZ(BigInt(x))
ZZ(s::AbstractString) = ZZ(parse(BigInt, String(s)))

# Mock functions that would be provided by the C++ wrapper
ZZ_from_string(s::String) = ZZ(parse(BigInt, s))
ZZ_to_string(z::ZZ) = string(z.value)

ZZ_add(a::ZZ, b::ZZ) = ZZ(a.value + b.value)
ZZ_sub(a::ZZ, b::ZZ) = ZZ(a.value - b.value)
ZZ_mul(a::ZZ, b::ZZ) = ZZ(a.value * b.value)
# NTL uses floor division (toward negative infinity), matching Julia's fld
ZZ_div(a::ZZ, b::ZZ) = ZZ(fld(a.value, b.value))
ZZ_rem(a::ZZ, b::ZZ) = ZZ(mod(a.value, b.value))
ZZ_divrem(a::ZZ, b::ZZ) = (ZZ(fld(a.value, b.value)), ZZ(mod(a.value, b.value)))
ZZ_power(a::ZZ, e::Int) = ZZ(a.value^e)
ZZ_negate(a::ZZ) = ZZ(-a.value)
ZZ_abs(a::ZZ) = ZZ(abs(a.value))

ZZ_gcd(a::ZZ, b::ZZ) = ZZ(gcd(a.value, b.value))
function ZZ_gcdx(a::ZZ, b::ZZ)
    d, s, t = gcdx(a.value, b.value)
    (ZZ(d), ZZ(s), ZZ(t))
end

ZZ_equal(a::ZZ, b::ZZ) = a.value == b.value
ZZ_less(a::ZZ, b::ZZ) = a.value < b.value
ZZ_lesseq(a::ZZ, b::ZZ) = a.value <= b.value

ZZ_iszero(a::ZZ) = iszero(a.value)
ZZ_isone(a::ZZ) = isone(a.value)
ZZ_sign(a::ZZ) = sign(a.value)
ZZ_isodd(a::ZZ) = isodd(a.value)

ZZ_numbits(a::ZZ) = a.value == 0 ? 0 : ndigits(abs(a.value), base=2)
ZZ_numbytes(a::ZZ) = a.value == 0 ? 0 : cld(ZZ_numbits(a), 8)

# Display
Base.string(z::ZZ) = ZZ_to_string(z)
Base.show(io::IO, z::ZZ) = print(io, string(z))

# Hash
Base.hash(z::ZZ, h::UInt) = hash(z.value, h)

# Copy
Base.copy(z::ZZ) = ZZ(z.value)
Base.deepcopy_internal(z::ZZ, dict::IdDict) = copy(z)
