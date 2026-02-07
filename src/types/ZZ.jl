"""
    ZZ - Arbitrary-Precision Integers

Julia wrapper for NTL's ZZ class providing unlimited precision integer arithmetic.
In development mode (when the C++ wrapper is not available), uses Julia's BigInt.
"""

if _LIBNTL_DEV_MODE
    include("ZZ_dev.jl")
else
    include("ZZ_prod.jl")
end

# Size queries (work in both modes)

"""
    numbits(z::ZZ) -> Int

Return the number of bits in the binary representation of |z|.
Returns 0 for z = 0.
"""
numbits(z::ZZ) = ZZ_numbits(z)

"""
    numbytes(z::ZZ) -> Int

Return the number of bytes needed to represent |z|.
Returns 0 for z = 0.
"""
numbytes(z::ZZ) = ZZ_numbytes(z)
