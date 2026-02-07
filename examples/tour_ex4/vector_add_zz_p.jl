#!/usr/bin/env julia
"""
NTL Tour Example 4.3: Vector Addition over Z/pZ

Corresponds to NTL C++ example that demonstrates vector operations
in modular arithmetic.

This Julia version uses VecZZ_p for efficient modular vector operations.
"""

using LibNTL

println("=== Vector Addition over Z/pZ ===\n")

# Example 1: Basic vector addition
println("Example 1: Basic vector addition mod 17")
with_modulus(ZZ(17)) do
    a = VecZZ_p([ZZ_p(5), ZZ_p(10), ZZ_p(15)])
    b = VecZZ_p([ZZ_p(3), ZZ_p(8), ZZ_p(12)])

    println("a = ", a)
    println("b = ", b)

    # Element-wise addition
    x = a + b
    println("a + b = ", x)
    # Expected: [8 1 10] since 10+8=18≡1, 15+12=27≡10 (mod 17)

    # Subtraction
    y = a - b
    println("a - b = ", y)
    # Expected: [2 2 3]

    # Negation
    z = -a
    println("-a = ", z)
    # Expected: [12 7 2] since -5≡12, -10≡7, -15≡2 (mod 17)
end
println()

# Example 2: Scalar multiplication
println("Example 2: Scalar multiplication mod 23")
with_modulus(ZZ(23)) do
    v = VecZZ_p([ZZ_p(1), ZZ_p(2), ZZ_p(3), ZZ_p(4), ZZ_p(5)])
    println("v = ", v)

    # Scalar multiplication
    scaled = ZZ_p(3) * v
    println("3 * v = ", scaled)
    # Expected: [3 6 9 12 15]

    # Integer scalar multiplication
    doubled = 2 * v
    println("2 * v = ", doubled)
    # Expected: [2 4 6 8 10]
end
println()

# Example 3: Building vectors dynamically
println("Example 3: Building a vector of residues mod 7")
with_modulus(ZZ(7)) do
    v = VecZZ_p()

    # Push elements
    for i in 1:10
        push!(v, i)  # Auto-reduces mod 7
    end
    println("Residues 1..10 mod 7: ", v)
    # Expected: [1 2 3 4 5 6 0 1 2 3]

    # Sum using iteration
    sum_val = ZZ_p(0)
    for x in v
        sum_val = sum_val + x
    end
    println("Sum of all elements: ", rep(sum_val))
    # 1+2+3+4+5+6+0+1+2+3 = 27 ≡ 6 (mod 7)
end
println()

# Example 4: 0-indexed access (NTL style)
println("Example 4: 0-indexed vs 1-indexed access")
with_modulus(ZZ(11)) do
    v = VecZZ_p([ZZ_p(10), ZZ_p(20), ZZ_p(30)])
    println("v = ", v)

    println("1-indexed: v[1] = ", v[1], ", v[2] = ", v[2], ", v[3] = ", v[3])
    println("0-indexed: v(0) = ", v(0), ", v(1) = ", v(1), ", v(2) = ", v(2))
end

println("\nExample completed successfully!")
