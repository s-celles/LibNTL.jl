"""
Development mode implementation for RR (arbitrary precision float) using pure Julia.

RR provides arbitrary-precision floating point arithmetic. In fallback mode,
we use BigFloat which provides similar capabilities.
"""

# Thread-local precision settings
const _RR_precision_ref = Ref{Int64}(150)  # Default 150 bits
const _RR_output_precision_ref = Ref{Int64}(10)  # Default 10 decimal digits

"""
    RR

Arbitrary-precision floating point type. In development mode, wraps BigFloat.
"""
mutable struct RR
    value::BigFloat

    function RR(bf::BigFloat, ::Nothing)
        new(bf)
    end
end

# Constructors
RR() = RR(BigFloat(0), nothing)
RR(x::Float64) = RR(setprecision(() -> BigFloat(x), _RR_precision_ref[]), nothing)
RR(x::Integer) = RR(setprecision(() -> BigFloat(x), _RR_precision_ref[]), nothing)
RR(x::BigFloat) = RR(setprecision(() -> BigFloat(x), _RR_precision_ref[]), nothing)

function RR_from_ZZ(z::ZZ)
    RR(setprecision(() -> BigFloat(z.value), _RR_precision_ref[]), nothing)
end

function RR_from_string(s::String)
    RR(setprecision(() -> parse(BigFloat, s), _RR_precision_ref[]), nothing)
end

function RR_to_string(r::RR)
    digits = _RR_output_precision_ref[]
    # Format with specified precision using BigFloat's built-in formatting
    setprecision(_RR_precision_ref[]) do
        # Use string interpolation with precision specifier
        buf = IOBuffer()
        show(IOContext(buf, :compact => true), r.value)
        s = String(take!(buf))
        # Truncate to requested digits if needed
        if length(s) > digits + 2  # +2 for "0." prefix
            parts = split(s, ".")
            if length(parts) == 2
                int_part = parts[1]
                frac_part = first(parts[2], digits)
                return int_part * "." * frac_part
            end
        end
        return s
    end
end

# Precision management
function RR_SetPrecision(p::Int64)
    _RR_precision_ref[] = p
end

function RR_precision()
    _RR_precision_ref[]
end

function RR_SetOutputPrecision(p::Int64)
    _RR_output_precision_ref[] = p
end

function RR_OutputPrecision()
    _RR_output_precision_ref[]
end

# Helper to perform operation at current precision
function _rr_op(f)
    setprecision(_RR_precision_ref[]) do
        f()
    end
end

# Arithmetic
function RR_add(a::RR, b::RR)
    RR(_rr_op(() -> a.value + b.value), nothing)
end

function RR_sub(a::RR, b::RR)
    RR(_rr_op(() -> a.value - b.value), nothing)
end

function RR_mul(a::RR, b::RR)
    RR(_rr_op(() -> a.value * b.value), nothing)
end

function RR_div(a::RR, b::RR)
    if iszero(b.value)
        throw(DomainError(b, "Division by zero"))
    end
    RR(_rr_op(() -> a.value / b.value), nothing)
end

function RR_negate(a::RR)
    RR(_rr_op(() -> -a.value), nothing)
end

function RR_abs(a::RR)
    RR(_rr_op(() -> abs(a.value)), nothing)
end

function RR_sqrt(a::RR)
    if a.value < 0
        throw(DomainError(a, "Square root of negative number"))
    end
    RR(_rr_op(() -> sqrt(a.value)), nothing)
end

function RR_exp(a::RR)
    RR(_rr_op(() -> exp(a.value)), nothing)
end

function RR_log(a::RR)
    if a.value <= 0
        throw(DomainError(a, "Logarithm of non-positive number"))
    end
    RR(_rr_op(() -> log(a.value)), nothing)
end

function RR_sin(a::RR)
    RR(_rr_op(() -> sin(a.value)), nothing)
end

function RR_cos(a::RR)
    RR(_rr_op(() -> cos(a.value)), nothing)
end

function RR_power(a::RR, e::Int64)
    RR(_rr_op(() -> a.value ^ e), nothing)
end

function RR_power_RR(a::RR, e::RR)
    RR(_rr_op(() -> a.value ^ e.value), nothing)
end

# Predicates
RR_iszero(a::RR) = iszero(a.value)
RR_isone(a::RR) = isone(a.value)

# Comparison
function RR_compare(a::RR, b::RR)
    if a.value < b.value
        return -1
    elseif a.value > b.value
        return 1
    else
        return 0
    end
end

RR_less(a::RR, b::RR) = a.value < b.value
RR_lesseq(a::RR, b::RR) = a.value <= b.value
RR_equal(a::RR, b::RR) = a.value == b.value

# Pi constant
function RR_ComputePi()
    RR(_rr_op(() -> BigFloat(π)), nothing)
end

# Copy
Base.copy(a::RR) = RR(copy(a.value), nothing)
Base.deepcopy_internal(a::RR, dict::IdDict) = copy(a)
