#!/usr/bin/env julia
"""
NTL Tour Example 2.1: Vector Sum (0-indexed style)

Corresponds to NTL C++ example that demonstrates reading and summing
vector elements using 0-indexed access.

In Julia, we use 1-indexed access as is idiomatic, but this example
shows how NTL-style code would translate to Julia.
"""

using LibNTL

println("=== Vector Sum Example (0-indexed style translation) ===\n")

# Create a vector of big integers
v = VecZZ([ZZ(10), ZZ(20), ZZ(30), ZZ(40), ZZ(50)])
println("Vector: ", v)

# Sum elements using explicit loop (C++ style with index)
# In NTL C++: for (long i = 0; i < v.length(); i++) sum += v[i];
# In Julia we use 1-based indexing: for i = 1:length(v)
let
    sum_val = ZZ(0)
    for i in 1:length(v)
        sum_val = sum_val + v[i]
    end
    println("Sum (explicit loop): ", sum_val)
end

# Julia idiomatic: use sum()
println("Sum (Julia sum()): ", sum(v))

# Verify result: 10 + 20 + 30 + 40 + 50 = 150
@assert sum(v) == ZZ(150) "Sum should be 150"

println("\nExample completed successfully!")
