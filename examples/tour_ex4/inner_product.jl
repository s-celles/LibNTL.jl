#!/usr/bin/env julia
"""
NTL Tour Example 4.4: Inner Product with Optimization

Corresponds to NTL C++ example that demonstrates computing inner products
with delayed modular reduction for efficiency.

In C++, the optimization involves accumulating in ZZ and reducing once.
This Julia version demonstrates both approaches.
"""

using LibNTL

println("=== Inner Product over Z/pZ ===\n")

# Example 1: Basic inner product
println("Example 1: Basic inner product mod 17")
with_modulus(ZZ(17)) do
    a = VecZZ_p([ZZ_p(2), ZZ_p(3), ZZ_p(4)])
    b = VecZZ_p([ZZ_p(5), ZZ_p(6), ZZ_p(7)])

    println("a = ", a)
    println("b = ", b)

    # Compute inner product: sum of a[i] * b[i]
    ip = inner_product(a, b)
    println("Inner product <a, b> = ", rep(ip))
    # 2*5 + 3*6 + 4*7 = 10 + 18 + 28 = 56 ≡ 5 (mod 17)
end
println()

# Example 2: Optimized inner product (delayed reduction)
println("Example 2: Optimized inner product with delayed reduction")
with_modulus(ZZ(1000000007)) do  # Large prime
    n = 1000
    a = VecZZ_p([ZZ_p(i) for i in 1:n])
    b = VecZZ_p([ZZ_p(i) for i in 1:n])

    # Method 1: Standard (many reductions)
    t1 = @elapsed begin
        ip1 = inner_product(a, b)
    end
    println("Standard inner product:   ", rep(ip1), " (", round(t1*1000, digits=3), " ms)")

    # Method 2: Delayed reduction (accumulate in ZZ, reduce once)
    t2 = @elapsed begin
        ip2 = inner_product_zz(a, b)
    end
    println("Optimized inner product:  ", rep(ip2), " (", round(t2*1000, digits=3), " ms)")

    # Verify they give the same result
    @assert ip1 == ip2 "Results should match"
    println("Results match: ✓")
end
println()

# Example 3: Manual implementation comparison
println("Example 3: Manual vs library implementation")
with_modulus(ZZ(101)) do
    a = VecZZ_p([ZZ_p(10), ZZ_p(20), ZZ_p(30), ZZ_p(40)])
    b = VecZZ_p([ZZ_p(1), ZZ_p(2), ZZ_p(3), ZZ_p(4)])

    # Manual implementation (like NTL C++ example)
    function manual_inner_product(a::VecZZ_p, b::VecZZ_p)
        accum = ZZ(0)
        for i in 1:length(a)
            accum += rep(a[i]) * rep(b[i])
        end
        return ZZ_p(accum)  # Single reduction at the end
    end

    ip_lib = inner_product(a, b)
    ip_manual = manual_inner_product(a, b)

    println("a = ", a)
    println("b = ", b)
    println("Library result:  ", rep(ip_lib))
    println("Manual result:   ", rep(ip_manual))
    # 10*1 + 20*2 + 30*3 + 40*4 = 10 + 40 + 90 + 160 = 300 ≡ 98 (mod 101)

    @assert ip_lib == ip_manual "Results should match"
end
println()

# Example 4: Orthogonality check
println("Example 4: Orthogonality check")
with_modulus(ZZ(7)) do
    # Two vectors that are orthogonal mod 7
    u = VecZZ_p([ZZ_p(1), ZZ_p(2), ZZ_p(3)])
    v = VecZZ_p([ZZ_p(2), ZZ_p(6), ZZ_p(1)])  # 2, -1, 1 in mod 7

    ip = inner_product(u, v)
    println("u = ", u)
    println("v = ", v)
    println("<u, v> = ", rep(ip))
    # 1*2 + 2*6 + 3*1 = 2 + 12 + 3 = 17 ≡ 3 (mod 7)

    # Create orthogonal vector
    w = VecZZ_p([ZZ_p(1), ZZ_p(3), ZZ_p(0)])
    ip_uw = inner_product(u, w)
    println("w = ", w)
    println("<u, w> = ", rep(ip_uw))
    # 1*1 + 2*3 + 3*0 = 1 + 6 + 0 = 7 ≡ 0 (mod 7) - orthogonal!

    if iszero(ip_uw)
        println("u and w are orthogonal mod 7 ✓")
    end
end

println("\nExample completed successfully!")
