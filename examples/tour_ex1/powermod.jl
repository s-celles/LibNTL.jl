#!/usr/bin/env julia
"""
NTL Tour Example 1.3: Modular Exponentiation

Corresponds to NTL C++ example:
```cpp
ZZ PowerMod(const ZZ& a, const ZZ& e, const ZZ& n) {
    // ... binary exponentiation implementation
}
```

This Julia version demonstrates NTL's PowerMod function for efficient
modular exponentiation.
"""

using LibNTL

println("=== Modular Exponentiation Examples ===\n")

# Example 1: Small numbers
a = ZZ(2)
e = ZZ(10)
n = ZZ(1000)
result = PowerMod(a, e, n)
println("2^10 mod 1000 = $result")
@assert result == ZZ(24) "Expected 24 (1024 mod 1000)"

# Example 2: Larger exponent
a = ZZ(2)
e = ZZ(100)
n = ZZ(1000000007)  # A large prime
result = PowerMod(a, e, n)
println("2^100 mod 1000000007 = $result")

# Example 3: Very large exponent (RSA-style)
println("\nRSA-style example:")
p = ZZ("104729")  # A prime
q = ZZ("104723")  # Another prime
n = p * q
phi = (p - 1) * (q - 1)
e = ZZ(65537)  # Common RSA public exponent

# Choose a message
m = ZZ(12345)

# Encrypt: c = m^e mod n
c = PowerMod(m, e, n)
println("Message: $m")
println("Encrypted: $c")

# Compute decryption exponent d such that e*d ≡ 1 (mod phi)
# Using extended GCD
d, s, t = gcdx(e, phi)
if d != ZZ(1)
    println("Warning: e and phi not coprime!")
else
    # Make s positive
    d_inv = mod(s, phi)

    # Decrypt: m' = c^d mod n
    m_decrypted = PowerMod(c, d_inv, n)
    println("Decrypted: $m_decrypted")
    @assert m_decrypted == m "Decryption failed!"
end

# Example 4: Fermat's Little Theorem
println("\nFermat's Little Theorem: a^(p-1) ≡ 1 (mod p) for prime p")
p = ZZ(1000000007)
a = ZZ(12345)
result = PowerMod(a, p - 1, p)
println("$a^($p-1) mod $p = $result")
@assert result == ZZ(1) "Fermat's Little Theorem failed!"

println("\nExample completed successfully!")
