"""
    ZZ - Arbitrary-Precision Integers

Julia wrapper for NTL's ZZ class providing unlimited precision integer arithmetic.
"""

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
