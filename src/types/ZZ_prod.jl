"""
Production mode implementation for ZZ using NTL via CxxWrap.
"""

const _libntl_julia_path = ENV["LIBNTL_JULIA_PATH"]

@wrapmodule(() -> _libntl_julia_path, :define_julia_module)

function __init__()
    @initcxx
end

# ZZ constructors for production mode
# Note: ZZ(::Int64) is already defined by CxxWrap via .constructor<long>()
ZZ(s::AbstractString) = ZZ_from_string(String(s))
ZZ(x::BigInt) = ZZ_from_string(string(x))

# For other Integer types (not Int64), convert via string
ZZ(x::Int32) = ZZ(Int64(x))
ZZ(x::Int128) = ZZ_from_string(string(x))
ZZ(x::UInt64) = ZZ_from_string(string(x))
ZZ(x::UInt128) = ZZ_from_string(string(x))

Base.string(z::ZZ) = ZZ_to_string(z)
Base.show(io::IO, z::ZZ) = print(io, string(z))
Base.hash(z::ZZ, h::UInt) = hash(string(z), h)

# Copy: CxxWrap types need to use the exposed copy method
function Base.copy(z::ZZ)
    # Create new ZZ from string representation
    ZZ_from_string(ZZ_to_string(z))
end
Base.deepcopy_internal(z::ZZ, dict::IdDict) = copy(z)
