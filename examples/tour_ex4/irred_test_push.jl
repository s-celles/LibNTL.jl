#!/usr/bin/env julia
"""
NTL Tour Example 4.2: Irreducibility Testing with Context Push

Corresponds to NTL C++ example that demonstrates testing polynomial
irreducibility while managing modulus context.

This Julia version demonstrates the with_modulus pattern for ZZ_pX operations.
"""

using LibNTL

println("=== Irreducibility Testing with Context Management ===\n")

# Example 1: Test same polynomial over different primes
println("Example 1: x² + 1 over various primes")
f_coeffs = [1, 0, 1]  # x^2 + 1

for p in [2, 3, 5, 7, 11, 13]
    with_modulus(ZZ(p)) do
        f = ZZ_pX(f_coeffs)
        irred = is_irreducible(f)
        println("  mod $p: x² + 1 is ", irred ? "irreducible" : "reducible")
    end
end
println()

# Note: x^2 + 1 is irreducible mod p iff -1 is not a quadratic residue mod p
# This happens when p ≡ 3 (mod 4)
println("Theory: x² + 1 is irreducible mod p iff p ≡ 3 (mod 4)")
println("  p=2: special case (1 ≡ 1² mod 2)")
println("  p=3: 3 ≡ 3 (mod 4) → irreducible ✓")
println("  p=5: 5 ≡ 1 (mod 4) → reducible (x² ≡ -1 has solutions 2, 3) ✓")
println("  p=7: 7 ≡ 3 (mod 4) → irreducible ✓")
println("  p=11: 11 ≡ 3 (mod 4) → irreducible ✓")
println("  p=13: 13 ≡ 1 (mod 4) → reducible (x² ≡ -1 has solutions 5, 8) ✓")
println()

# Example 2: Nested modulus contexts
println("Example 2: Nested modulus contexts")
ZZ_p_init!(ZZ(17))
outer_mod = ZZ_p_modulus()
println("Outer modulus: ", outer_mod)

# Create polynomial in outer context
f_outer = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(1)])
println("f in mod 17: ", f_outer)

# Switch to different modulus temporarily
with_modulus(ZZ(5)) do
    inner_mod = ZZ_p_modulus()
    println("  Inner modulus: ", inner_mod)

    f_inner = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(1)])
    println("  f in mod 5: ", f_inner)

    # Note: coefficients are reduced differently
    # In mod 17: [1 2 1]
    # In mod 5: same, but operations would differ
end

# Verify outer modulus is restored
restored_mod = ZZ_p_modulus()
println("Restored modulus: ", restored_mod)
@assert restored_mod == outer_mod "Modulus should be restored after with_modulus"
println()

# Example 3: Building irreducible polynomials
println("Example 3: Count irreducible polynomials of degree 2 over GF(3)")
with_modulus(ZZ(3)) do
    count = 0
    # Enumerate all monic degree-2 polynomials x^2 + ax + b
    for a in 0:2
        for b in 0:2
            f = ZZ_pX([ZZ_p(b), ZZ_p(a), ZZ_p(1)])
            if is_irreducible(f)
                println("  Irreducible: ", f)
                count += 1
            end
        end
    end
    println("Total: $count irreducible monic polynomials of degree 2 over GF(3)")
    # Theory: number of monic irreducible of degree n over GF(q) is approximately q^n/n
    # For n=2, q=3: (3^2 - 3)/2 = 3 (exact formula using Mobius function)
end

println("\nExample completed successfully!")
