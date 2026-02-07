#!/usr/bin/env julia
"""
NTL Tour Example 4.1: Polynomial Factorization mod p

Corresponds to NTL C++ example that demonstrates factoring polynomials
over finite fields.

This Julia version demonstrates ZZ_pX factorization and irreducibility testing.
"""

using LibNTL

println("=== Polynomial Factorization mod p ===\n")

# Example 1: Factor x^4 - 1 over Z/5Z
println("Example 1: Factor x^4 - 1 over Z/5Z")
with_modulus(ZZ(5)) do
    # x^4 - 1 = x^4 + 4 (mod 5)
    f = ZZ_pX([ZZ_p(4), ZZ_p(0), ZZ_p(0), ZZ_p(0), ZZ_p(1)])
    println("f(x) = ", f)

    # Check roots: x^4 = 1 (mod 5) has solutions 1, 2, 3, 4 (since 5 is prime)
    println("Checking roots:")
    for x in 0:4
        println("  f($x) = ", f(ZZ_p(x)))
    end

    # x = 1: 1 - 1 = 0 ✓
    # x = 2: 16 - 1 = 15 ≡ 0 (mod 5) ✓
    # x = 3: 81 - 1 = 80 ≡ 0 (mod 5) ✓
    # x = 4: 256 - 1 = 255 ≡ 0 (mod 5) ✓
end
println()

# Example 2: Irreducibility testing over Z/2Z
println("Example 2: Irreducibility testing over Z/2Z (GF(2))")
with_modulus(ZZ(2)) do
    # x^2 + x + 1 is irreducible over GF(2)
    f1 = ZZ_pX([ZZ_p(1), ZZ_p(1), ZZ_p(1)])
    println("x² + x + 1: ", f1, " - irreducible: ", is_irreducible(f1))

    # x^2 + 1 = (x + 1)^2 is reducible over GF(2)
    f2 = ZZ_pX([ZZ_p(1), ZZ_p(0), ZZ_p(1)])
    println("x² + 1: ", f2, " - irreducible: ", is_irreducible(f2))

    # x^3 + x + 1 is irreducible over GF(2)
    f3 = ZZ_pX([ZZ_p(1), ZZ_p(1), ZZ_p(0), ZZ_p(1)])
    println("x³ + x + 1: ", f3, " - irreducible: ", is_irreducible(f3))

    # x^3 + x^2 + 1 is also irreducible over GF(2)
    f4 = ZZ_pX([ZZ_p(1), ZZ_p(0), ZZ_p(1), ZZ_p(1)])
    println("x³ + x² + 1: ", f4, " - irreducible: ", is_irreducible(f4))
end
println()

# Example 3: Polynomial arithmetic over Z/17Z
println("Example 3: Polynomial arithmetic over Z/17Z")
with_modulus(ZZ(17)) do
    f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(1)])  # 1 + 2x + x^2 = (x + 1)^2
    g = ZZ_pX([ZZ_p(3), ZZ_p(1)])  # 3 + x

    println("f(x) = ", f)
    println("g(x) = ", g)
    println("f + g = ", f + g)
    println("f * g = ", f * g)

    # Division: (x^2 + 2x + 1) / (x + 3)
    q, r = divrem(f, g)
    println("f / g: quotient = ", q, ", remainder = ", r)

    # Verify: f = g * q + r
    reconstructed = g * q + r
    println("g * q + r = ", reconstructed)
    @assert reconstructed == f "Division verification failed"
end
println()

# Example 4: GCD of polynomials over Z/7Z
println("Example 4: GCD of polynomials over Z/7Z")
with_modulus(ZZ(7)) do
    # f = x^2 - 1 = (x - 1)(x + 1)
    f = ZZ_pX([ZZ_p(6), ZZ_p(0), ZZ_p(1)])  # -1 + x^2 ≡ 6 + x^2 (mod 7)
    # g = x^2 - 2x + 1 = (x - 1)^2
    g = ZZ_pX([ZZ_p(1), ZZ_p(5), ZZ_p(1)])  # 1 - 2x + x^2 ≡ 1 + 5x + x^2 (mod 7)

    println("f(x) = ", f, " (x² - 1)")
    println("g(x) = ", g, " (x² - 2x + 1 = (x-1)²)")

    h = gcd(f, g)
    println("gcd(f, g) = ", h)  # Should be x - 1 (monic form)

    # Verify h divides both f and g
    @assert iszero(rem(f, h)) "GCD should divide f"
    @assert iszero(rem(g, h)) "GCD should divide g"
    println("Verified: gcd divides both polynomials")
end

println("\nExample completed successfully!")
