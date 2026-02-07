#!/usr/bin/env julia
"""
Tour Example 4.5: Irreducibility Testing with Small Primes (zz_p)

This example demonstrates the use of zz_p and zz_pX, NTL's optimized
single-precision modular types, for faster polynomial arithmetic when
the modulus fits in a machine word.

Corresponds to NTL tour example 4.5:
https://libntl.org/doc/tour-ex4.html
"""

using LibNTL

function main()
    println("=== Irreducibility Testing with Small Primes (zz_p) ===\n")

    # Example 1: Basic zz_p arithmetic with small prime
    println("Example 1: Basic zz_p arithmetic with p = 97")
    zz_p_init!(97)
    println("  Modulus: ", zz_p_modulus())

    x = zz_p(42)
    y = zz_p(55)
    println("  x = ", x)
    println("  y = ", y)
    println("  x + y = ", x + y)
    println("  x * y = ", x * y)
    println("  x^2 = ", x^2)
    println("  inv(x) = ", inv(x))
    println("  x * inv(x) = ", x * inv(x))
    println()

    # Example 2: Using FFT primes for polynomial multiplication
    println("Example 2: FFT prime initialization")
    zz_p_FFTInit!(0)
    println("  FFT prime #0: ", zz_p_modulus())
    zz_p_FFTInit!(1)
    println("  FFT prime #1: ", zz_p_modulus())
    println()

    # Example 3: Polynomial irreducibility testing
    println("Example 3: Irreducibility testing over small primes")

    # Test x² + 1 over various small primes
    for p in [3, 5, 7, 11, 13]
        zz_p_init!(p)

        # Create x² + 1
        f = zz_pX()
        setcoeff!(f, 0, 1)
        setcoeff!(f, 2, 1)

        result = is_irreducible(f) ? "irreducible" : "reducible"
        theory = (p % 4 == 3) ? "should be irreducible (p ≡ 3 mod 4)" : "should be reducible (p ≡ 1 mod 4)"
        println("  x² + 1 mod $p: $result ($theory)")
    end
    println()

    # Example 4: Polynomial arithmetic with zz_pX
    println("Example 4: Polynomial arithmetic over GF(31)")
    zz_p_init!(31)

    # f = 1 + 2x + x²
    f = zz_pX()
    setcoeff!(f, 0, 1)
    setcoeff!(f, 1, 2)
    setcoeff!(f, 2, 1)
    println("  f(x) = ", f)

    # g = x + 1
    g = zz_pX()
    setcoeff!(g, 0, 1)
    setcoeff!(g, 1, 1)
    println("  g(x) = ", g)

    h = f * g
    println("  f(x) * g(x) = ", h)

    q, r = divrem(h, g)
    println("  (f*g) / g: quotient = ", q, ", remainder = ", r)
    println()

    # Example 5: GCD computation
    println("Example 5: GCD of polynomials over GF(17)")
    zz_p_init!(17)

    # f = x³ - 1 = (x - 1)(x² + x + 1)
    f = zz_pX()
    setcoeff!(f, 0, -1)
    setcoeff!(f, 3, 1)
    println("  f(x) = x³ - 1 = ", f)

    # g = x² - 1 = (x - 1)(x + 1)
    g = zz_pX()
    setcoeff!(g, 0, -1)
    setcoeff!(g, 2, 1)
    println("  g(x) = x² - 1 = ", g)

    d = gcd(f, g)
    println("  gcd(f, g) = ", d, " (should be x - 1)")
    println()

    # Example 6: Context switching
    println("Example 6: Context switching with with_small_modulus")
    zz_p_init!(7)
    println("  Outer modulus: ", zz_p_modulus())
    println("  3^2 mod 7 = ", rep(zz_p(3)^2))

    with_small_modulus(11) do
        println("  Inner modulus: ", zz_p_modulus())
        println("  3^2 mod 11 = ", rep(zz_p(3)^2))
    end

    println("  Restored modulus: ", zz_p_modulus())
    println()

    # Example 7: Performance comparison hint
    println("Example 7: Performance note")
    println("  zz_p uses machine-word arithmetic for small primes")
    println("  ZZ_p uses arbitrary-precision arithmetic")
    println("  Use zz_p when modulus < ~2^62 for better performance")

    println("\nExample completed successfully!")
end

main()
