"""
High-level interface for RR (arbitrary-precision floating point).

RR provides floating-point arithmetic with configurable precision,
suitable for computations requiring more precision than Float64.
"""

# Precision management
"""
    RR_SetPrecision!(p::Integer)

Set the precision for RR computations to p bits.
Default is 150 bits.

# Example
```julia
RR_SetPrecision!(500)  # 500 bits ≈ 150 decimal digits
```
"""
function RR_SetPrecision!(p::Integer)
    RR_SetPrecision(Int64(p))
end

"""
    RR_precision() -> Int

Get the current RR precision in bits.
"""
RR_precision

"""
    RR_SetOutputPrecision!(p::Integer)

Set the number of decimal digits for RR output.
Default is 10 digits.

# Example
```julia
RR_SetOutputPrecision!(50)  # Show 50 decimal digits
```
"""
function RR_SetOutputPrecision!(p::Integer)
    RR_SetOutputPrecision(Int64(p))
end

"""
    RR_OutputPrecision() -> Int

Get the current RR output precision in decimal digits.
"""
RR_OutputPrecision

# Constructors
"""
    RR(x)

Create an arbitrary-precision floating point number from x.
Supports Float64, Integer, String, and ZZ inputs.

# Examples
```julia
a = RR(3.14159)
b = RR("0.1")  # Exact decimal representation
c = RR(ZZ(10)^100)  # Large integer
```
"""
RR(x::AbstractString) = RR_from_string(String(x))
RR(z::ZZ) = RR_from_ZZ(z)

# Pi constant
"""
    RR_pi() -> RR

Compute π to the current precision.
"""
RR_pi() = RR_ComputePi()

# Arithmetic operators
Base.:+(a::RR, b::RR) = RR_add(a, b)
Base.:-(a::RR, b::RR) = RR_sub(a, b)
Base.:*(a::RR, b::RR) = RR_mul(a, b)
Base.:/(a::RR, b::RR) = RR_div(a, b)
Base.:-(a::RR) = RR_negate(a)
Base.abs(a::RR) = RR_abs(a)
Base.sqrt(a::RR) = RR_sqrt(a)
Base.exp(a::RR) = RR_exp(a)
Base.log(a::RR) = RR_log(a)
Base.sin(a::RR) = RR_sin(a)
Base.cos(a::RR) = RR_cos(a)
Base.:^(a::RR, e::Integer) = RR_power(a, Int64(e))
Base.:^(a::RR, e::RR) = RR_power_RR(a, e)

# Predicates
Base.iszero(a::RR) = RR_iszero(a)
Base.isone(a::RR) = RR_isone(a)

# Comparison
Base.:<(a::RR, b::RR) = RR_less(a, b)
Base.:<=(a::RR, b::RR) = RR_lesseq(a, b)
Base.:(==)(a::RR, b::RR) = RR_equal(a, b)
Base.cmp(a::RR, b::RR) = RR_compare(a, b)

# Display
function Base.show(io::IO, a::RR)
    print(io, RR_to_string(a))
end

# Zero and one
Base.zero(::Type{RR}) = RR(0.0)
Base.one(::Type{RR}) = RR(1.0)

# Promotion for mixed operations
Base.promote_rule(::Type{RR}, ::Type{Float64}) = RR
Base.promote_rule(::Type{RR}, ::Type{<:Integer}) = RR

Base.convert(::Type{RR}, x::Float64) = RR(x)
Base.convert(::Type{RR}, x::Integer) = RR(x)

# Additional math functions
Base.tan(a::RR) = sin(a) / cos(a)
Base.log10(a::RR) = log(a) / log(RR(10.0))
Base.log2(a::RR) = log(a) / log(RR(2.0))

# Export
export RR
export RR_SetPrecision!, RR_precision, RR_SetOutputPrecision!, RR_OutputPrecision
export RR_pi
