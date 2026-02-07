#!/usr/bin/env julia
"""
Tour Example 4.6: GCD and Chinese Remainder Theorem

This example demonstrates modular GCD computation and the
Chinese Remainder Theorem (CRT) for polynomial reconstruction.

Note: Full CRT implementation requires advanced infrastructure.
This example shows the conceptual approach using multiple moduli.

Corresponds to NTL tour example 4.6:
https://libntl.org/doc/tour-ex4.html
"""

using LibNTL

"""
Compute GCD of two polynomials modulo a small prime.
Returns a monic polynomial.
"""
function gcd_mod_p(f::ZZX, g::ZZX, p::Integer)
    # Convert ZZX to zz_pX
    zz_p_init!(p)

    # Create zz_pX from ZZX coefficients
    f_p = zz_pX()
    for i in 0:degree(f)
        c = coeff(f, i)
        setcoeff!(f_p, i, Int64(c.value) % p)
    end

    g_p = zz_pX()
    for i in 0:degree(g)
        c = coeff(g, i)
        setcoeff!(g_p, i, Int64(c.value) % p)
    end

    return gcd(f_p, g_p)
end

function main()
    println("=== GCD and Chinese Remainder Theorem ===\n")

    # Example 1: Modular GCD computation
    println("Example 1: GCD computation modulo primes")

    # f = x³ - 1 = (x-1)(x² + x + 1)
    f = ZZX([ZZ(-1), ZZ(0), ZZ(0), ZZ(1)])
    println("  f(x) = x³ - 1 = ", f)

    # g = x² - 1 = (x-1)(x+1)
    g = ZZX([ZZ(-1), ZZ(0), ZZ(1)])
    println("  g(x) = x² - 1 = ", g)

    # GCD over Z
    d = gcd(f, g)
    println("  gcd(f, g) over Z = ", d)

    # GCD mod small primes
    for p in [5, 7, 11, 13]
        d_p = gcd_mod_p(f, g, p)
        println("  gcd(f, g) mod $p = ", d_p)
    end
    println()

    # Example 2: CRT conceptual demonstration
    println("Example 2: CRT concept - reconstructing integers")

    # Simple integer CRT: find x ≡ 2 (mod 3) and x ≡ 3 (mod 5)
    # Solution: x ≡ 8 (mod 15)
    println("  Find x where:")
    println("    x ≡ 2 (mod 3)")
    println("    x ≡ 3 (mod 5)")

    # Verify
    for x in 0:14
        if x % 3 == 2 && x % 5 == 3
            println("  Solution: x = $x (mod 15)")
            break
        end
    end
    println()

    # Example 3: Polynomial GCD verification
    println("Example 3: Verify GCD divides both polynomials")

    # f = x⁴ - 1 = (x² - 1)(x² + 1) = (x-1)(x+1)(x² + 1)
    f = ZZX([ZZ(-1), ZZ(0), ZZ(0), ZZ(0), ZZ(1)])
    println("  f(x) = x⁴ - 1")

    # g = x² - 1 = (x-1)(x+1)
    g = ZZX([ZZ(-1), ZZ(0), ZZ(1)])
    println("  g(x) = x² - 1")

    d = gcd(f, g)
    println("  gcd(f, g) = ", d)

    # Verify d divides both
    q1, r1 = divrem(f, d)
    q2, r2 = divrem(g, d)
    println("  f / gcd: quotient = ", q1, ", remainder = ", r1)
    println("  g / gcd: quotient = ", q2, ", remainder = ", r2)

    if iszero(r1) && iszero(r2)
        println("  ✓ Verified: gcd divides both polynomials")
    end
    println()

    # Example 4: Multiple small primes for modular arithmetic
    println("Example 4: Polynomial evaluation at multiple primes")

    h = ZZX([ZZ(6), ZZ(11), ZZ(6), ZZ(1)])  # x³ + 6x² + 11x + 6 = (x+1)(x+2)(x+3)
    println("  h(x) = x³ + 6x² + 11x + 6 = (x+1)(x+2)(x+3)")

    # Check roots mod different primes
    primes = [5, 7, 11]
    for p in primes
        zz_p_init!(p)
        println("  Roots of h mod $p:")

        roots = Int[]
        for a in 0:(p-1)
            # Evaluate h at a mod p
            val = 0
            for i in 0:degree(h)
                c = coeff(h, i)
                val = (val + Int64(c.value) * powermod(a, i, p)) % p
            end
            if val == 0
                push!(roots, a)
            end
        end

        # The roots should be -1, -2, -3 (mod p)
        expected = [(p - 1) % p, (p - 2) % p, (p - 3) % p]
        println("    Found: ", roots)
        println("    Expected (p-1, p-2, p-3): ", sort(expected))
    end
    println()

    # Example 5: Coefficient size monitoring
    println("Example 5: Coefficient growth in polynomial operations")

    # Start with small coefficients
    a = ZZX([ZZ(1), ZZ(1)])  # x + 1
    b = copy(a)

    println("  Starting with f = x + 1")
    for i in 1:5
        b = b * a
        max_coeff = maximum(abs(coeff(b, j).value) for j in 0:degree(b))
        println("  (x+1)^$i: max coefficient = $max_coeff")
    end
    println("  → Coefficients grow exponentially")
    println("  → CRT allows working mod small primes, then reconstructing")

    println("\nExample completed successfully!")
end

main()
