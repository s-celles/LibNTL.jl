#!/usr/bin/env julia
"""
NTL Tour Example 3.1: Polynomial Factorization

Corresponds to NTL C++ example that demonstrates factoring polynomials
over the integers.

NTL C++ example:
```cpp
ZZX f;
cin >> f;
Vec< Pair< ZZX, long > > factors;
ZZ c;
factor(c, factors, f);
```

This Julia version demonstrates the factor() function for ZZX polynomials.
"""

using LibNTL

println("=== Polynomial Factorization Examples ===\n")

# Example 1: Factor x^2 - 1 = (x - 1)(x + 1)
println("Example 1: x² - 1")
f1 = ZZX([ZZ(-1), ZZ(0), ZZ(1)])  # -1 + x^2
println("f(x) = ", f1)
c1, factors1 = factor(f1)
println("Content: ", c1)
println("Factors:")
for (p, e) in factors1
    if e == 1
        println("  ", p)
    else
        println("  (", p, ")^", e)
    end
end

# Verify reconstruction
let
    product1 = ZZX([c1])
    for (p, e) in factors1
        for _ in 1:e
            product1 = product1 * p
        end
    end
    println("Product of factors: ", product1)
    @assert product1 == f1 "Factorization failed"
end
println()

# Example 2: Factor x^3 - x = x(x - 1)(x + 1)
println("Example 2: x³ - x")
f2 = ZZX([ZZ(0), ZZ(-1), ZZ(0), ZZ(1)])  # -x + x^3
println("f(x) = ", f2)
c2, factors2 = factor(f2)
println("Content: ", c2)
println("Factors:")
for (p, e) in factors2
    println("  ", p)
end

# Verify
let
    product2 = ZZX([c2])
    for (p, e) in factors2
        for _ in 1:e
            product2 = product2 * p
        end
    end
    @assert product2 == f2 "Factorization failed"
end
println()

# Example 3: Factor x^2 + 2x + 1 = (x + 1)^2
println("Example 3: x² + 2x + 1 = (x + 1)²")
f3 = ZZX([ZZ(1), ZZ(2), ZZ(1)])  # 1 + 2x + x^2
println("f(x) = ", f3)
c3, factors3 = factor(f3)
println("Content: ", c3)
println("Factors:")
for (p, e) in factors3
    if e > 1
        println("  (", p, ")^", e)
    else
        println("  ", p)
    end
end
@assert length(factors3) == 1 && factors3[1][2] == 2 "Should have (x+1)^2"
println()

# Example 4: Factor 6x^2 + 12x + 6 = 6(x + 1)^2
println("Example 4: 6x² + 12x + 6")
f4 = ZZX([ZZ(6), ZZ(12), ZZ(6)])
println("f(x) = ", f4)
c4, factors4 = factor(f4)
println("Content: ", c4)
println("Factors:")
for (p, e) in factors4
    if e > 1
        println("  (", p, ")^", e)
    else
        println("  ", p)
    end
end
@assert c4 == ZZ(6) "Content should be 6"
println()

# Example 5: Irreducible polynomial (no rational roots)
println("Example 5: x² + 1 (irreducible over ℤ)")
f5 = ZZX([ZZ(1), ZZ(0), ZZ(1)])  # 1 + x^2
println("f(x) = ", f5)
c5, factors5 = factor(f5)
println("Content: ", c5)
println("Factors:")
for (p, e) in factors5
    println("  ", p, " (irreducible)")
end
# x^2 + 1 has no rational roots, so should remain as single factor
println()

# Example 6: Constant polynomial
println("Example 6: Constant polynomial 42")
f6 = ZZX(ZZ(42))
println("f(x) = ", f6)
c6, factors6 = factor(f6)
println("Content: ", c6)
println("Factors: ", isempty(factors6) ? "none (constant)" : factors6)
@assert c6 == ZZ(42) && isempty(factors6)

println("\nExample completed successfully!")
