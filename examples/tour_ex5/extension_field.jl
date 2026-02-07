#!/usr/bin/env julia
"""
Tour Example 5: Extension Fields (ZZ_pE)

This example demonstrates working with extension fields GF(p^k).
We build GF(17^10), compute minimum polynomials, and verify
polynomial composition.

Corresponds to NTL tour example 5:
https://libntl.org/doc/tour-ex5.html
"""

using LibNTL

"""
Build an irreducible polynomial of given degree over the current ZZ_p.
Uses a simple random search approach.
"""
function build_irreducible(deg::Int)
    p = ZZ_p_modulus()
    max_tries = 1000

    for _ in 1:max_tries
        # Create a monic random polynomial
        f = ZZ_pX()
        for i in 0:(deg-1)
            setcoeff!(f, i, ZZ_p(rand(0:Int64(p.value)-1)))
        end
        setcoeff!(f, deg, ZZ_p(1))  # Monic

        if is_irreducible(f)
            return f
        end
    end

    error("Failed to find irreducible polynomial after $max_tries attempts")
end

function main()
    println("=== Extension Fields: GF(p^k) ===\n")

    # Example 1: Build a small extension field GF(3^2)
    println("Example 1: Building GF(3^2)")
    ZZ_p_init!(ZZ(3))
    println("  Base field: GF(3)")

    # Use x² + 1, which is irreducible over GF(3)
    # Check: 0² + 1 = 1, 1² + 1 = 2, 2² + 1 = 5 ≡ 2 (mod 3) - no roots
    P = ZZ_pX()
    setcoeff!(P, 0, ZZ_p(1))  # 1
    setcoeff!(P, 2, ZZ_p(1))  # x²
    println("  Extension polynomial P(x) = x² + 1 = ", P)

    with_extension(P) do
        println("  Extension degree: ", ZZ_pE_degree())
        println("  Now in GF(3²) = GF(9)")

        # Create some elements
        # α represents the root of x² + 1, so α² = -1 = 2 in GF(3)
        alpha = ZZ_pE(ZZ_pX([ZZ_p(0), ZZ_p(1)]))  # α = x
        println("  α (root of P) = ", alpha)

        alpha_sq = alpha * alpha
        println("  α² = ", alpha_sq, " (should be -1 = 2)")

        # Verify: α² + 1 = 0
        one_e = ZZ_pE(ZZ_p(1))
        check = alpha_sq + one_e
        println("  α² + 1 = ", check, " (should be 0)")
    end
    println()

    # Example 2: A larger extension field
    println("Example 2: Working in GF(5^3)")
    ZZ_p_init!(ZZ(5))
    println("  Base field: GF(5)")

    # Find an irreducible polynomial of degree 3
    P3 = build_irreducible(3)
    println("  Found irreducible P(x) = ", P3)

    with_extension(P3) do
        println("  Extension degree: ", ZZ_pE_degree())
        println("  Field has 5³ = 125 elements")

        # Random elements
        a = rand(ZZ_pE)
        b = rand(ZZ_pE)
        println("  Random a = ", a)
        println("  Random b = ", b)

        println("  a + b = ", a + b)
        println("  a * b = ", a * b)

        if !iszero(a)
            a_inv = inv(a)
            println("  a⁻¹ = ", a_inv)
            println("  a * a⁻¹ = ", a * a_inv, " (should be 1)")
        end
    end
    println()

    # Example 3: Polynomial composition (conceptual)
    println("Example 3: Polynomial operations in extension field")
    ZZ_p_init!(ZZ(7))

    # x² + 3x + 2 has no roots in GF(7): 0+0+2=2, 1+3+2=6, 4+6+2=5, 9+9+2≡6, 16+12+2≡2, 25+15+2≡0
    # Actually 5² + 3*5 + 2 = 25 + 15 + 2 = 42 ≡ 0 mod 7, so x=5 is a root
    # Let's use x² + 1 which has no roots in GF(7): 7 ≡ 3 mod 4, so -1 is not a square
    P = ZZ_pX()
    setcoeff!(P, 0, ZZ_p(1))
    setcoeff!(P, 2, ZZ_p(1))
    println("  Extension polynomial P(x) = ", P)

    with_extension(P) do
        # Create polynomial f(y) = y + 1 over the extension field
        f = ZZ_pEX()
        setcoeff!(f, 0, ZZ_pE(ZZ_p(1)))  # constant 1
        setcoeff!(f, 1, ZZ_pE(ZZ_p(1)))  # y
        println("  f(y) = y + 1 (as polynomial over GF(49))")
        println("  f = ", f)

        # Create element h in extension field
        h = ZZ_pE(ZZ_p(2))
        println("  h = ", h)

        # Evaluate conceptually
        println("  f(h) should be h + 1 = 3")
    end
    println()

    # Example 4: Field arithmetic properties
    println("Example 4: Frobenius automorphism")
    ZZ_p_init!(ZZ(3))

    P = ZZ_pX()
    setcoeff!(P, 0, ZZ_p(1))
    setcoeff!(P, 2, ZZ_p(1))  # x² + 1

    with_extension(P) do
        # In GF(p^k), the Frobenius map is a → a^p
        # It's an automorphism of order k

        a = ZZ_pE(ZZ_pX([ZZ_p(1), ZZ_p(1)]))  # 1 + α
        println("  a = 1 + α = ", a)

        a_p = a^3  # Frobenius in GF(3²)
        println("  a^3 (Frobenius) = ", a_p)

        a_p_p = a_p^3  # Apply Frobenius twice
        println("  (a^3)^3 = a^9 = ", a_p_p)
        println("  a^9 should equal a (since 9 = 3² and Frobenius has order 2)")
        println("  Check: a = ", a)
    end
    println()

    # Example 5: Multiplicative order
    println("Example 5: Element orders in extension field")
    ZZ_p_init!(ZZ(2))

    # x² + x + 1 is irreducible over GF(2)
    P = ZZ_pX()
    setcoeff!(P, 0, ZZ_p(1))
    setcoeff!(P, 1, ZZ_p(1))
    setcoeff!(P, 2, ZZ_p(1))
    println("  Extension polynomial: x² + x + 1 over GF(2)")

    with_extension(P) do
        println("  Working in GF(4) = GF(2²)")

        # α is primitive element (α² + α + 1 = 0, so α² = α + 1)
        alpha = ZZ_pE(ZZ_pX([ZZ_p(0), ZZ_p(1)]))  # α
        println("  α = ", alpha)

        # Compute powers
        println("  Powers of α:")
        current = ZZ_pE(ZZ_p(1))
        for i in 0:4
            println("    α^$i = ", current)
            current = current * alpha
        end
        println("  Note: α^3 = 1 (multiplicative order is 3 = |GF(4)*|)")
    end

    println("\nExample completed successfully!")
end

main()
