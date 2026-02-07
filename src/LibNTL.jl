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

using Preferences

# Check if libntl_julia_jll is available
const _HAS_JLL = try
    @eval using libntl_julia_jll
    true
catch
    false
end

# Check for library path in order of precedence:
# 1. libntl_julia_jll (if available)
# 2. Environment variable LIBNTL_JULIA_PATH
# 3. LocalPreferences.toml setting
function _get_libntl_path()
    # First try JLL
    if _HAS_JLL
        return libntl_julia_jll.libntl_julia_path
    end

    # Then check environment variable
    env_path = get(ENV, "LIBNTL_JULIA_PATH", "")
    if !isempty(env_path) && isfile(env_path)
        return env_path
    end

    # Then check preferences
    pref_path = @load_preference("libntl_julia_path", nothing)
    if pref_path !== nothing && isfile(pref_path)
        return pref_path
    end

    return nothing
end

const _LIBNTL_PATH = _get_libntl_path()
const _LIBNTL_DEV_MODE = _LIBNTL_PATH === nothing

# Only load CxxWrap if not in dev mode
if !_LIBNTL_DEV_MODE
    using CxxWrap
    ENV["LIBNTL_JULIA_PATH"] = _LIBNTL_PATH  # Set for ZZ_prod.jl
end

# Error types
include("errors.jl")

# Type wrappers - ZZ, ZZ_p, and ZZX
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
