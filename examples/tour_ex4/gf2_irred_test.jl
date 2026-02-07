#!/usr/bin/env julia
"""
NTL Tour Example 4.7: Irreducibility Testing over GF(2)

Corresponds to NTL C++ example that demonstrates testing polynomial
irreducibility over the binary field GF(2), along with matrix operations.

This Julia version demonstrates GF2, GF2X, VecGF2, and MatGF2 types.
"""

using LibNTL

println("=== Irreducibility Testing over GF(2) ===\n")

# Example 1: Basic GF(2) arithmetic
println("Example 1: Basic GF(2) arithmetic")
z = GF2(0)
o = GF2(1)

println("  0 + 0 = ", z + z, "  (XOR)")
println("  0 + 1 = ", z + o)
println("  1 + 1 = ", o + o, "  (1 ⊕ 1 = 0)")
println("  1 * 1 = ", o * o, "  (AND)")
println("  -1 = ", -o, "  (negation is identity)")
println()

# Example 2: Polynomials over GF(2)
println("Example 2: Polynomials over GF(2)")

# x^2 + x + 1 is the first irreducible polynomial of degree 2
f1 = GF2X([1, 1, 1])  # 1 + x + x^2
println("  f1 = 1 + x + x² = ", f1)
println("  degree(f1) = ", degree(f1))
println("  is_irreducible(f1) = ", is_irreducible(f1))
println()

# x^2 + 1 = (x + 1)^2 over GF(2) is reducible
f2 = GF2X([1, 0, 1])  # 1 + x^2
println("  f2 = 1 + x² = ", f2)
println("  is_irreducible(f2) = ", is_irreducible(f2))
println("  Note: x² + 1 = (x + 1)² in GF(2)")
println()

# Example 3: Count irreducible polynomials
println("Example 3: Count irreducible monic polynomials over GF(2)")

# Degree 2: should be 1 (x^2 + x + 1)
let count2 = 0
    for a in 0:1
        f = GF2X([GF2(1), GF2(a), GF2(1)])  # 1 + ax + x^2
        if is_irreducible(f)
            println("  Degree 2 irreducible: ", f)
            count2 += 1
        end
    end
    println("  Total degree 2: $count2")
end
println()

# Degree 3: should be 2 (x^3 + x + 1 and x^3 + x^2 + 1)
let count3 = 0
    for a in 0:1, b in 0:1
        # Monic: x^3 + ax^2 + bx + 1 (constant term 1 for irreducible)
        f = GF2X([GF2(1), GF2(b), GF2(a), GF2(1)])
        if is_irreducible(f)
            println("  Degree 3 irreducible: ", f)
            count3 += 1
        end
    end
    println("  Total degree 3: $count3")
end

# Theory: Number of monic irreducible polynomials of degree n over GF(2)
# is given by (2^n - Σ over d|n, d<n of I_d * d) / n, where I_d is count for degree d
# Degree 1: 2 (x, x+1)
# Degree 2: (4 - 2*1)/2 = 1
# Degree 3: (8 - 2*1)/3 = 2
println()

# Example 4: Polynomial arithmetic
println("Example 4: Polynomial arithmetic in GF(2)[x]")
g = GF2X([1, 1])  # 1 + x
h = GF2X([1, 1, 1])  # 1 + x + x^2

product = g * h
println("  (1 + x) * (1 + x + x²) = ", product)
println("  = 1 + x³ (expansion: 1 + x + x + x² + x² + x³ = 1 + x³)")

# Division
q, r = divrem(product, g)
println("  (1 + x³) ÷ (1 + x) = ", q, " remainder ", r)
println()

# GCD
println("  gcd(x² + 1, x + 1) = gcd((x+1)², (x+1)) = ", gcd(f2, g))
println()

# Example 5: Vectors over GF(2)
println("Example 5: Vectors over GF(2)")
v1 = VecGF2([1, 0, 1, 1])
v2 = VecGF2([1, 1, 0, 1])

println("  v1 = ", v1)
println("  v2 = ", v2)
println("  v1 + v2 = ", v1 + v2, "  (XOR)")
println("  inner_product(v1, v2) = ", inner_product(v1, v2))
println("    = 1*1 + 0*1 + 1*0 + 1*1 = 1 + 0 + 0 + 1 = 0")
println()

# Example 6: Matrices over GF(2) and Gaussian elimination
println("Example 6: Matrices over GF(2) and rank")

# Identity matrix
I3 = eye_gf2(3)
println("  3x3 Identity matrix:")
println("  ", I3)
println("  rank = ", matrix_rank(I3))
println()

# A matrix with rank 2
M = MatGF2([1 0 1; 0 1 1; 1 1 0])
println("  Matrix M (row 3 = row 1 + row 2 in GF(2)):")
println("  ", M)
println("  rank = ", matrix_rank(M))
println()

# Matrix-vector multiplication
A = MatGF2([1 0; 0 1; 1 1])  # 3x2 matrix
v = VecGF2([1, 1])

println("  A = ", A)
println("  v = ", v)
w = A * v
println("  A * v = ", w)
println()

# Example 7: Polynomial evaluation
println("Example 7: Polynomial evaluation")
f = GF2X([1, 1, 1])  # 1 + x + x^2
println("  f(x) = 1 + x + x² = ", f)
println("  f(0) = 1 + 0 + 0 = ", f(GF2(0)))
println("  f(1) = 1 + 1 + 1 = ", f(GF2(1)))
println()

println("Example completed successfully!")
