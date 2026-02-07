"""
Vector types for NTL.

Provides Julia wrappers for NTL's Vec<T> template types:
- VecZZ: Vector of arbitrary-precision integers
- VecZZ_p: Vector of modular integers
- VecGF2: Vector of binary field elements
"""

"""
    AbstractVec{T}

Abstract supertype for all NTL vector wrappers.
Subtypes implement the AbstractVector{T} interface.
"""
abstract type AbstractVec{T} <: AbstractVector{T} end

# TODO: Implement VecZZ in Phase 4 (T026-T028)
# struct VecZZ <: AbstractVec{ZZ}
#     wrapped::Vec_ZZ_Allocated
# end

# TODO: Implement VecZZ_p in Phase 6a (T058)
# struct VecZZ_p <: AbstractVec{ZZ_p}
#     wrapped::Vec_ZZ_p_Allocated
# end

# TODO: Implement VecGF2 in Phase 6c (T082)
# struct VecGF2 <: AbstractVec{GF2}
#     wrapped::Vec_GF2_Allocated
# end
