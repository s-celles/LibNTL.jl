#!/usr/bin/env julia
"""
NTL Tour Example 3.2: Cyclotomic Polynomials

Corresponds to NTL C++ example that demonstrates computing cyclotomic
polynomials.

The n-th cyclotomic polynomial Φₙ(x) is the minimal polynomial of
primitive n-th roots of unity. It satisfies:
- xⁿ - 1 = ∏_{d|n} Φ_d(x)
- degree(Φₙ) = φ(n)  (Euler's totient function)

This Julia version demonstrates the cyclotomic() function.
"""

using LibNTL

println("=== Cyclotomic Polynomial Examples ===\n")

# Compute first several cyclotomic polynomials
println("First 12 cyclotomic polynomials:")
println("-" ^ 40)
for n in 1:12
    phi_n = cyclotomic(n)
    println("Φ_$n(x) = ", phi_n, "  (degree $(degree(phi_n)))")
end
println()

# Verify the key property: x^n - 1 = product of Φ_d for d | n
function divisors(n::Int)
    divs = Int[]
    for d in 1:n
        if mod(n, d) == 0
            push!(divs, d)
        end
    end
    return divs
end

println("Verifying x^n - 1 = ∏_{d|n} Φ_d(x):")
println("-" ^ 40)
for n in [4, 6, 8, 12]
    # Build x^n - 1
    coeffs = [ZZ(0) for _ in 1:(n+1)]
    coeffs[1] = ZZ(-1)
    coeffs[n+1] = ZZ(1)
    xn_minus_1 = ZZX(coeffs)

    # Compute product of cyclotomic polynomials
    product = ZZX([ZZ(1)])  # Start with 1
    divs = divisors(n)
    for d in divs
        product = product * cyclotomic(d)
    end

    if product == xn_minus_1
        println("n = $n: x^$n - 1 = Φ_", join(divs, " × Φ_"), " ✓")
    else
        println("n = $n: MISMATCH!")
    end
end
println()

# Special properties of cyclotomic polynomials
println("Special cyclotomic polynomials:")
println("-" ^ 40)

# Φ_p for prime p
println("\nFor prime p, Φ_p(x) = 1 + x + x² + ... + x^(p-1):")
for p in [2, 3, 5, 7, 11]
    phi_p = cyclotomic(p)
    println("  Φ_$p(x) = ", phi_p)
end

# Φ_{2^n} = x^{2^{n-1}} + 1
println("\nFor n = 2^k, Φ_n(x) = x^(n/2) + 1:")
for k in 1:4
    local nval = 2^k
    phi_n = cyclotomic(nval)
    println("  Φ_$nval(x) = ", phi_n)
end

# Evaluation at x = 1: Φ_n(1) for prime power n
println("\nΦ_n(1) for prime power n equals the prime:")
for (p, e) in [(2, 1), (2, 2), (3, 1), (5, 1), (7, 1)]
    local nval = p^e
    phi_n = cyclotomic(nval)
    value = phi_n(ZZ(1))
    println("  Φ_$nval(1) = ", value)
end

# Large cyclotomic polynomial
println("\nLarge cyclotomic polynomial:")
let n = 30
    phi_n = cyclotomic(n)
    println("Φ_$n(x) has degree $(degree(phi_n))")
    println("Leading coefficient: ", leading(phi_n))
    println("Constant term: ", constant(phi_n))
end

println("\nExample completed successfully!")
