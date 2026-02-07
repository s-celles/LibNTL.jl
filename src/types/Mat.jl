"""
Matrix types for NTL.

Provides Julia wrappers for NTL's Mat<T> template types:
- MatZZ: Matrix of arbitrary-precision integers
- MatGF2: Matrix of binary field elements
"""

"""
    AbstractMat{T}

Abstract supertype for all NTL matrix wrappers.
Subtypes implement the AbstractMatrix{T} interface.
"""
abstract type AbstractMat{T} <: AbstractMatrix{T} end

# TODO: Implement MatZZ in Phase 4 (T029-T031)
# struct MatZZ <: AbstractMat{ZZ}
#     wrapped::Mat_ZZ_Allocated
# end

# TODO: Implement MatGF2 in Phase 6c (T081)
# struct MatGF2 <: AbstractMat{GF2}
#     wrapped::Mat_GF2_Allocated
# end
