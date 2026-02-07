"""
    LibNTL

Julia wrapper for the NTL (Number Theory Library) C++ library.

Provides arbitrary-precision integers (ZZ), modular integers (ZZ_p),
and polynomials over integers (ZZX) with idiomatic Julia syntax.

# Exports
- `ZZ`: Arbitrary-precision integers
- `ZZ_p`: Integers modulo p
- `ZZX`: Polynomials with integer coefficients
- `ZZ_pContext`: Context for saving/restoring ZZ_p modulus
- `ZZ_p_init!`: Set the global ZZ_p modulus
- `ZZ_p_modulus`: Get the current ZZ_p modulus
- `with_modulus`: Execute code with a temporary modulus
- `InvModError`: Exception for failed modular inverse
- `VecZZ`: Vector of arbitrary-precision integers
- `MatZZ`: Matrix of arbitrary-precision integers

# Example
```julia
using LibNTL

# Arbitrary-precision integers
a = ZZ(42)
b = ZZ("12345678901234567890")
c = a + b

# Modular arithmetic
ZZ_p_init!(ZZ(17))
x = ZZ_p(5)
y = inv(x)  # multiplicative inverse mod 17

# Polynomials
f = ZZX([ZZ(1), ZZ(2), ZZ(1)])  # 1 + 2x + x^2

# Vectors and matrices
v = VecZZ([1, 2, 3])
m = MatZZ([1 2; 3 4])
```
"""
module LibNTL

import LinearAlgebra: mul!

# --- Abstract types (must be defined before concrete types) ---
include("types/Vec.jl")
include("types/Mat.jl")

# --- Backend detection ---
const _USE_NATIVE = try
    @eval using libntl_julia_jll
    libntl_julia_jll.is_available()
catch
    false
end

# --- Load backend ---
if _USE_NATIVE
    using CxxWrap
    include("native/init.jl")
else
    include("fallback/ZZ.jl")
    include("fallback/ZZ_p.jl")
    include("fallback/ZZX.jl")
    include("fallback/ZZ_pX.jl")
    include("fallback/VecZZ.jl")
    include("fallback/VecZZ_p.jl")
    include("fallback/MatZZ.jl")
    include("fallback/GF2.jl")
    include("fallback/GF2X.jl")
    include("fallback/VecGF2.jl")
    include("fallback/MatGF2.jl")

    function __init__()
        @warn "libntl_julia_jll not available. Using pure Julia fallback (slower)."
    end
end

# Error types
include("errors.jl")

# High-level type interfaces
include("types/ZZ.jl")
include("types/ZZ_p.jl")
include("types/ZZX.jl")
include("types/ZZ_pX.jl")
include("types/GF2.jl")
include("types/GF2X.jl")

# Context management patterns
include("context.jl")

# Function modules
include("functions/number_theory.jl")
include("functions/factoring.jl")
include("functions/polynomials.jl")

# Conversions and operators
include("conversions.jl")
include("operators.jl")

# Type exports
export ZZ, ZZ_p, ZZ_pContext, ZZX, ZZ_pX
export GF2, GF2X, VecGF2, MatGF2
export AbstractVec, AbstractMat
export VecZZ, VecZZ_p, MatZZ
export InvModError

# ZZ_pX function exports
export is_irreducible

# Matrix/Vector function exports
export nrows, ncols
export mul!
export inner_product, inner_product_zz
export gauss!, matrix_rank, eye_gf2

# Function exports for ZZ
export numbits, numbytes

# Number theory function exports
export PowerMod, bit, RandomBnd, RandomBits, ProbPrime
export PrimeSeq, next!, reset!

# Function exports for ZZ_p
export ZZ_p_init!, ZZ_p_modulus, with_modulus
export rep, save!, restore!

# Function exports for ZZX
export degree, coeff, setcoeff!, leading, constant
export content, primpart, derivative
export factor, cyclotomic

end # module LibNTL
