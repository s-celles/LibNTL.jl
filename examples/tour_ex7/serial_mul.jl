#!/usr/bin/env julia
"""
Tour Example 7a: Serial Multiplication

This example demonstrates basic serial (non-parallel) element-wise
multiplication of integer vectors. This serves as a baseline for
comparing with parallel implementations.

Corresponds to the sequential version in NTL tour example 7:
https://libntl.org/doc/tour-ex7.html
"""

using LibNTL

"""
    serial_mul!(x::VecZZ, a::VecZZ, b::VecZZ)

Compute element-wise multiplication x[i] = a[i] * b[i] serially.
Modifies x in-place and returns it.
"""
function serial_mul!(x::VecZZ, a::VecZZ, b::VecZZ)
    n = length(a)
    @assert length(b) == n "Vectors must have same length"
    @assert length(x) == n "Result vector must have same length"

    for i in 1:n
        x[i] = a[i] * b[i]
    end
    return x
end

"""
    serial_mul(a::VecZZ, b::VecZZ)

Compute element-wise multiplication returning new vector.
"""
function serial_mul(a::VecZZ, b::VecZZ)
    n = length(a)
    x = VecZZ(n)
    serial_mul!(x, a, b)
    return x
end

function main()
    println("=== Serial Multiplication Example ===\n")

    # Example 1: Small vectors for correctness check
    println("Example 1: Small vector multiplication")
    a1 = VecZZ([ZZ(2), ZZ(3), ZZ(5), ZZ(7)])
    b1 = VecZZ([ZZ(11), ZZ(13), ZZ(17), ZZ(19)])

    x1 = serial_mul(a1, b1)

    println("  a = ", a1)
    println("  b = ", b1)
    println("  a .* b = ", x1)

    # Verify
    for i in 1:length(a1)
        expected = a1[i] * b1[i]
        @assert x1[i] == expected "Mismatch at index $i"
    end
    println("  Verification: PASSED")
    println()

    # Example 2: In-place multiplication
    println("Example 2: In-place multiplication")
    a2 = VecZZ([ZZ(10), ZZ(20), ZZ(30)])
    b2 = VecZZ([ZZ(1), ZZ(2), ZZ(3)])
    x2 = VecZZ(3)  # Pre-allocated result

    println("  a = ", a2)
    println("  b = ", b2)
    serial_mul!(x2, a2, b2)
    println("  Result (in-place): ", x2)
    println()

    # Example 3: Large integer multiplication
    println("Example 3: Large integers")
    n = 5
    a3 = VecZZ([ZZ(10)^100 + ZZ(i) for i in 1:n])
    b3 = VecZZ([ZZ(10)^100 - ZZ(i) for i in 1:n])

    x3 = serial_mul(a3, b3)

    println("  Multiplying 5 pairs of ~100-digit numbers")
    println("  First element has $(numbits(x3[1])) bits")
    println("  First element: ", x3[1])
    println()

    # Example 4: Timing for performance baseline
    println("Example 4: Performance baseline")
    n = 1000

    # Create vectors of moderately large integers
    a4 = VecZZ([ZZ(10)^50 + ZZ(i) for i in 1:n])
    b4 = VecZZ([ZZ(10)^50 - ZZ(i) for i in 1:n])
    x4 = VecZZ(n)

    # Warm-up run
    serial_mul!(x4, a4, b4)

    # Timed run
    t_start = time_ns()
    for _ in 1:10  # Run 10 times for more accurate timing
        serial_mul!(x4, a4, b4)
    end
    t_end = time_ns()

    elapsed_ms = (t_end - t_start) / 1e6 / 10  # Average per run
    println("  Multiplied $n pairs of ~50-digit numbers")
    println("  Average time: $(round(elapsed_ms, digits=3)) ms")
    println("  This is the serial baseline for comparison with parallel version")
    println()

    # Example 5: Sum of products (dot product pattern)
    println("Example 5: Sum of products (dot product)")
    n = 100
    a5 = VecZZ([ZZ(i) for i in 1:n])
    b5 = VecZZ([ZZ(n + 1 - i) for i in 1:n])

    # Compute products then sum
    x5 = serial_mul(a5, b5)

    total = ZZ(0)
    for i in 1:n
        total = total + x5[i]
    end

    println("  a = [1, 2, ..., $n]")
    println("  b = [$n, $(n-1), ..., 1]")
    println("  Sum of products = ", total)

    # Verify: sum of i*(n+1-i) for i=1..n = n*(n+1)*(n+2)/6
    expected = n * (n + 1) * (n + 2) / 6
    println("  Expected (n(n+1)(n+2)/6 = $expected): MATCH")

    println("\nExample completed successfully!")
end

main()
