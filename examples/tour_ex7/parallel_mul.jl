#!/usr/bin/env julia
"""
Tour Example 7b: Parallel Multiplication

This example demonstrates parallel element-wise multiplication
using Julia's threading model, providing a Julia-native alternative
to NTL's thread pool (NTL_EXEC_RANGE).

Corresponds to the parallel version in NTL tour example 7:
https://libntl.org/doc/tour-ex7.html

Run with multiple threads:
    julia --threads=4 parallel_mul.jl
"""

using LibNTL

"""
    parallel_mul!(x::VecZZ, a::VecZZ, b::VecZZ)

Compute element-wise multiplication x[i] = a[i] * b[i] in parallel.
Uses Julia's Threads.@threads for parallelization.
Modifies x in-place and returns it.

This is analogous to NTL's:
    NTL_EXEC_RANGE(n, first, last)
        for (long i = first; i < last; i++)
            mul(x[i], a[i], b[i]);
    NTL_EXEC_RANGE_END
"""
function parallel_mul!(x::VecZZ, a::VecZZ, b::VecZZ)
    n = length(a)
    @assert length(b) == n "Vectors must have same length"
    @assert length(x) == n "Result vector must have same length"

    Threads.@threads for i in 1:n
        x[i] = a[i] * b[i]
    end
    return x
end

"""
    parallel_mul(a::VecZZ, b::VecZZ)

Compute element-wise multiplication returning new vector using parallel execution.
"""
function parallel_mul(a::VecZZ, b::VecZZ)
    n = length(a)
    x = VecZZ(n)
    parallel_mul!(x, a, b)
    return x
end

"""
    serial_mul!(x::VecZZ, a::VecZZ, b::VecZZ)

Serial version for comparison.
"""
function serial_mul!(x::VecZZ, a::VecZZ, b::VecZZ)
    n = length(a)
    for i in 1:n
        x[i] = a[i] * b[i]
    end
    return x
end

function main()
    println("=== Parallel Multiplication Example ===\n")

    # Show thread count
    nthreads = Threads.nthreads()
    println("Julia is running with $nthreads thread(s)")
    if nthreads == 1
        println("  Tip: Run with `julia --threads=4 parallel_mul.jl` for parallelism")
    end
    println()

    # Example 1: Correctness check
    println("Example 1: Verify parallel computation is correct")
    a1 = VecZZ([ZZ(2), ZZ(3), ZZ(5), ZZ(7), ZZ(11), ZZ(13)])
    b1 = VecZZ([ZZ(17), ZZ(19), ZZ(23), ZZ(29), ZZ(31), ZZ(37)])

    x_serial = VecZZ(length(a1))
    x_parallel = VecZZ(length(a1))

    serial_mul!(x_serial, a1, b1)
    parallel_mul!(x_parallel, a1, b1)

    println("  a = ", a1)
    println("  b = ", b1)
    println("  Serial result:   ", x_serial)
    println("  Parallel result: ", x_parallel)

    # Verify results match
    for i in 1:length(a1)
        @assert x_serial[i] == x_parallel[i] "Results differ at index $i"
    end
    println("  Results match: VERIFIED")
    println()

    # Example 2: Performance comparison with larger vectors
    println("Example 2: Performance comparison (serial vs parallel)")
    n = 1000

    # Create vectors of large integers for more work per element
    a2 = VecZZ([ZZ(10)^100 + ZZ(i) for i in 1:n])
    b2 = VecZZ([ZZ(10)^100 - ZZ(i) for i in 1:n])
    x2 = VecZZ(n)

    # Warm-up
    serial_mul!(x2, a2, b2)
    parallel_mul!(x2, a2, b2)

    # Time serial version
    iterations = 10
    t_serial_start = time_ns()
    for _ in 1:iterations
        serial_mul!(x2, a2, b2)
    end
    t_serial_end = time_ns()
    serial_ms = (t_serial_end - t_serial_start) / 1e6 / iterations

    # Time parallel version
    t_parallel_start = time_ns()
    for _ in 1:iterations
        parallel_mul!(x2, a2, b2)
    end
    t_parallel_end = time_ns()
    parallel_ms = (t_parallel_end - t_parallel_start) / 1e6 / iterations

    println("  Multiplied $n pairs of ~100-digit numbers")
    println("  Serial time:   $(round(serial_ms, digits=3)) ms (average over $iterations runs)")
    println("  Parallel time: $(round(parallel_ms, digits=3)) ms (average over $iterations runs)")

    if parallel_ms < serial_ms
        speedup = serial_ms / parallel_ms
        println("  Speedup: $(round(speedup, digits=2))x")
    else
        println("  Note: Parallel overhead exceeds benefit at this problem size/thread count")
    end
    println()

    # Example 3: Scaling with vector size
    println("Example 3: Scaling behavior")
    sizes = [100, 500, 1000, 2000]

    println("  Vector size | Serial (ms) | Parallel (ms) | Speedup")
    println("  " * "-"^55)

    for sz in sizes
        a = VecZZ([ZZ(10)^50 + ZZ(i) for i in 1:sz])
        b = VecZZ([ZZ(10)^50 - ZZ(i) for i in 1:sz])
        x = VecZZ(sz)

        # Warm-up
        serial_mul!(x, a, b)
        parallel_mul!(x, a, b)

        # Time both versions
        t_s = time_ns()
        for _ in 1:5
            serial_mul!(x, a, b)
        end
        serial_t = (time_ns() - t_s) / 1e6 / 5

        t_p = time_ns()
        for _ in 1:5
            parallel_mul!(x, a, b)
        end
        parallel_t = (time_ns() - t_p) / 1e6 / 5

        speedup = serial_t / parallel_t
        println("  $(lpad(sz, 11)) | $(lpad(round(serial_t, digits=3), 11)) | $(lpad(round(parallel_t, digits=3), 13)) | $(lpad(round(speedup, digits=2), 7))x")
    end
    println()

    # Example 4: NTL_EXEC_RANGE pattern equivalent
    println("Example 4: Custom parallel range pattern (NTL_EXEC_RANGE equivalent)")

    """
    Execute function f for each index in range 1:n, distributed across threads.
    This is the Julia equivalent of NTL's NTL_EXEC_RANGE macro.
    """
    function exec_range(f::Function, n::Int)
        Threads.@threads for i in 1:n
            f(i)
        end
    end

    # Use the pattern
    a4 = VecZZ([ZZ(i^2) for i in 1:10])
    b4 = VecZZ([ZZ(i) for i in 1:10])
    x4 = VecZZ(10)

    exec_range(10) do i
        x4[i] = a4[i] + b4[i]  # Can be any operation
    end

    println("  a = ", a4)
    println("  b = ", b4)
    println("  Using exec_range pattern: x[i] = a[i] + b[i]")
    println("  Result: ", x4)
    println()

    # Example 5: Thread-local work distribution
    println("Example 5: Show work distribution across threads")
    n = 12
    # Use a dictionary to track work per thread ID (thread IDs may exceed nthreads in task-based pools)
    work_count = Dict{Int,Int}()
    work_lock = ReentrantLock()

    Threads.@threads for i in 1:n
        tid = Threads.threadid()
        lock(work_lock) do
            work_count[tid] = get(work_count, tid, 0) + 1
        end
    end

    println("  Work distribution for $n items:")
    for (tid, count) in sort(collect(work_count))
        println("    Thread $tid: $count items")
    end

    println("\nExample completed successfully!")
end

main()
