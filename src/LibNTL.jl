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
```
"""
module LibNTL

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

# Conversions and operators
include("conversions.jl")
include("operators.jl")

# Type exports
export ZZ, ZZ_p, ZZ_pContext, ZZX
export InvModError

# Function exports for ZZ
export numbits, numbytes

# Function exports for ZZ_p
export ZZ_p_init!, ZZ_p_modulus, with_modulus
export rep, save!, restore!

# Function exports for ZZX
export degree, coeff, setcoeff!, leading, constant
export content, primpart, derivative

end # module LibNTL
