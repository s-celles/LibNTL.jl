"""
Exception types for LibNTL.

This module defines custom exception types for NTL operations
that can fail in predictable ways.
"""

"""
    InvModError(a::Any, n::Any)

Exception thrown when computing a modular inverse fails because
`gcd(a, n) ≠ 1`.

# Fields
- `a`: The value that failed to be inverted
- `n`: The modulus

# Example
```julia
try
    inv(ZZ_p(0))
catch e::InvModError
    println("Cannot invert ", e.a, " mod ", e.n)
end
```
"""
struct InvModError <: Exception
    a::Any  # The value that failed to invert
    n::Any  # The modulus
end

function Base.showerror(io::IO, e::InvModError)
    print(io, "InvModError: gcd(a, n) ≠ 1 for a = ", e.a, ", n = ", e.n)
end
