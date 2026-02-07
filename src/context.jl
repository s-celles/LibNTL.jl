"""
Context management patterns for NTL modular types.

Provides RAII-style context management using Julia's do-block syntax
to safely manage modulus state for ZZ_p, zz_p, ZZ_pE types.

# Available Patterns

- `with_modulus(f, p::ZZ)` - Execute with ZZ_p modulus set to p
- `with_modulus(f, p::Int, ::Type{zz_p})` - Execute with zz_p modulus set to p
- `with_extension(f, P::ZZ_pX)` - Execute with ZZ_pE extension set to P
"""

# Note: with_modulus for ZZ_p is already defined in types/ZZ_p.jl

# TODO: Implement with_modulus for zz_p in Phase 6b (T072)
# function with_modulus(f::Function, p::Int, ::Type{zz_p})
#     ...
# end

# TODO: Implement with_extension for ZZ_pE in Phase 7 (T098)
# function with_extension(f::Function, P::ZZ_pX)
#     ...
# end
