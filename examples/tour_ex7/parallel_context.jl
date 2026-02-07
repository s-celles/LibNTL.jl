#!/usr/bin/env julia
"""
Tour Example 7c: Parallel Computation with Context Management

This example demonstrates how to properly handle modular arithmetic
contexts when doing parallel computation. In NTL, modular contexts
are thread-local and must be saved/restored when using threads.

In Julia, we use `with_modulus` to ensure each thread has the
correct modulus set for its computations.

Corresponds to context management patterns in NTL tour example 7:
https://libntl.org/doc/tour-ex7.html

Run with multiple threads:
    julia --threads=4 parallel_context.jl
"""

using LibNTL

"""
    parallel_modular_mul!(x::VecZZ_p, a::VecZZ_p, b::VecZZ_p, modulus::ZZ)

Parallel element-wise modular multiplication with explicit modulus context.
Each thread sets up its own modular context to ensure correctness.
"""
function parallel_modular_mul!(x::VecZZ_p, a::VecZZ_p, b::VecZZ_p, modulus::ZZ)
    n = length(a)
    @assert length(b) == n "Vectors must have same length"
    @assert length(x) == n "Result vector must have same length"

    Threads.@threads for i in 1:n
        # In the pure Julia fallback, modulus is global, but in a native
        # NTL binding, we would need to save/restore context per thread.
        # This pattern shows the intended usage:
        with_modulus(modulus) do
            x[i] = a[i] * b[i]
        end
    end
    return x
end

"""
    parallel_sum_mod_p(values::Vector{ZZ}, modulus::ZZ)

Sum large integers modulo p in parallel using reduction.
Uses thread-safe accumulation with a lock.
"""
function parallel_sum_mod_p(input_values::Vector{ZZ}, modulus::ZZ)
    # Use a dictionary for thread-local sums (thread IDs may vary in task pools)
    partial_sums = Dict{Int,ZZ}()
    sums_lock = ReentrantLock()

    Threads.@threads for i in eachindex(input_values)
        tid = Threads.threadid()
        lock(sums_lock) do
            if !haskey(partial_sums, tid)
                partial_sums[tid] = ZZ(0)
            end
            partial_sums[tid] = partial_sums[tid] + input_values[i]
        end
    end

    # Combine partial sums under the modulus
    with_modulus(modulus) do
        total = ZZ_p(0)
        for (_, s) in partial_sums
            total = total + ZZ_p(s)
        end
        return total
    end
end

function main()
    println("=== Parallel Context Management Example ===\n")

    nthreads = Threads.nthreads()
    println("Running with $nthreads thread(s)")
    if nthreads == 1
        println("  Tip: Run with `julia --threads=4 parallel_context.jl` for parallelism")
    end
    println()

    # Example 1: Basic parallel modular multiplication
    println("Example 1: Parallel modular multiplication")
    p = ZZ(1000000007)  # Large prime

    with_modulus(p) do
        a = VecZZ_p([ZZ_p(100), ZZ_p(200), ZZ_p(300), ZZ_p(400)])
        b = VecZZ_p([ZZ_p(5), ZZ_p(6), ZZ_p(7), ZZ_p(8)])
        x = VecZZ_p(4)

        parallel_modular_mul!(x, a, b, p)

        println("  Modulus: $p")
        println("  a = ", a)
        println("  b = ", b)
        println("  a .* b (mod p) = ", x)

        # Verify
        for i in 1:length(a)
            expected = a[i] * b[i]
            @assert rep(x[i]) == rep(expected) "Mismatch at index $i"
        end
        println("  Verification: PASSED")
    end
    println()

    # Example 2: Parallel sum with modular reduction
    println("Example 2: Parallel sum modulo p")
    p2 = ZZ(17)
    values = [ZZ(i^2) for i in 1:20]  # [1, 4, 9, 16, ...]

    result = parallel_sum_mod_p(values, p2)

    # Compute expected sum modulo 17
    expected_sum = sum([i^2 for i in 1:20])  # = 2870
    expected_mod = mod(ZZ(expected_sum), p2)

    println("  Values: 1², 2², ..., 20² = [1, 4, 9, ..., 400]")
    println("  Sum = $expected_sum")
    println("  Sum mod 17 = $result (expected: $expected_mod)")
    @assert rep(result) == expected_mod "Sum mismatch"
    println("  Verification: PASSED")
    println()

    # Example 3: Different moduli in sequence (not parallel)
    println("Example 3: Sequential computation with different moduli")
    primes = [ZZ(5), ZZ(7), ZZ(11), ZZ(13)]
    base_value = ZZ(100)

    println("  Computing 100 mod p for various primes:")
    for p in primes
        with_modulus(p) do
            val = ZZ_p(base_value)
            println("    100 mod $p = $(rep(val))")
        end
    end
    println()

    # Example 4: Parallel Chinese Remainder Theorem setup
    println("Example 4: Parallel CRT residue computation")
    # Given a large number, compute its residues modulo several primes in parallel
    big_number = ZZ(10)^50 + ZZ(12345)
    primes_crt = [ZZ(1000000007), ZZ(1000000009), ZZ(1000000021), ZZ(1000000033)]

    residues = Vector{ZZ}(undef, length(primes_crt))

    Threads.@threads for i in eachindex(primes_crt)
        residues[i] = mod(big_number, primes_crt[i])
    end

    println("  Number: 10^50 + 12345")
    println("  Residues:")
    for (p, r) in zip(primes_crt, residues)
        println("    mod $p = $r")
    end
    println()

    # Example 5: Thread safety demonstration (using ZZ operations, not ZZ_p)
    println("Example 5: Thread-safe parallel sum of squares")
    p5 = ZZ(101)

    # For thread safety, compute in ZZ (not ZZ_p), then reduce at the end
    # This avoids the global modulus state issue
    thread_results = Dict{Int,ZZ}()
    results_lock = ReentrantLock()

    n_iters = 100
    Threads.@threads for i in 1:n_iters
        tid = Threads.threadid()
        # Compute i² as ZZ (thread-safe, no global state)
        squared = ZZ(i) * ZZ(i)
        lock(results_lock) do
            if !haskey(thread_results, tid)
                thread_results[tid] = ZZ(0)
            end
            thread_results[tid] = thread_results[tid] + squared
        end
    end

    # Reduce final result and apply modulus at the end
    total = ZZ(0)
    for (_, r) in thread_results
        total = total + r
    end
    final_result = mod(total, p5)

    # Expected: sum of i² for i=1..100, mod 101
    expected_serial = ZZ(0)
    for i in 1:n_iters
        expected_serial = expected_serial + ZZ(i) * ZZ(i)
    end
    expected_result = mod(expected_serial, p5)

    println("  Parallel sum of i² (i=1..100) mod 101")
    println("  Parallel result: $final_result")
    println("  Serial result:   $expected_result")
    @assert final_result == expected_result "Results differ!"
    println("  Match: VERIFIED")
    println()
    println("  Note: For thread safety with modular arithmetic, compute in ZZ")
    println("  and reduce modulo p at the end. Avoid with_modulus inside @threads")
    println()

    # Example 6: Performance with context switching
    println("Example 6: Context switching overhead")
    p6 = ZZ(1000000007)
    n = 1000
    values6 = VecZZ([ZZ(i) for i in 1:n])

    # Method 1: One context for all
    t1_start = time_ns()
    result1 = ZZ(0)
    with_modulus(p6) do
        for val in values6
            x = ZZ_p(val)
            result1 = result1 + rep(x * x)
        end
    end
    t1_end = time_ns()

    # Method 2: Context per operation (more overhead)
    t2_start = time_ns()
    result2 = ZZ(0)
    for val in values6
        with_modulus(p6) do
            x = ZZ_p(val)
            result2 = result2 + rep(x * x)
        end
    end
    t2_end = time_ns()

    time1 = (t1_end - t1_start) / 1e6
    time2 = (t2_end - t2_start) / 1e6

    println("  Single context (batch):      $(round(time1, digits=3)) ms")
    println("  Context per operation:       $(round(time2, digits=3)) ms")
    println("  Recommendation: Batch operations under single context when possible")

    @assert result1 == result2 "Results differ!"
    println("  Both methods produce same result: VERIFIED")

    println("\nExample completed successfully!")
end

main()
