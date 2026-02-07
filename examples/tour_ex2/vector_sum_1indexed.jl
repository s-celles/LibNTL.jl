#!/usr/bin/env julia
"""
NTL Tour Example 2.2: Vector Sum (1-indexed style)

Corresponds to NTL C++ example that demonstrates reading and summing
vector elements. This Julia version uses natural 1-based indexing.

NTL C++ can use both 0-indexed and 1-indexed access:
```cpp
SetLength(v, n);
for (i = 1; i <= n; i++) cin >> v(i);
acc = 0; for (i = 1; i <= n; i++) acc += v(i);
```

Julia naturally uses 1-based indexing, making this translation more direct.
"""

using LibNTL

println("=== Vector Sum Example (1-indexed, Julia-natural) ===\n")

# Create and populate a vector
values = [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]  # First 10 perfect squares
v = VecZZ(values)
println("Vector of first 10 perfect squares: ", v)
println("Length: ", length(v))

# Sum using Julia's natural 1-based iteration
acc = ZZ(0)
for i in eachindex(v)
    global acc
    acc = acc + v[i]
end
println("Sum (1-indexed loop): ", acc)

# Using Julia's sum function
println("Sum (Julia sum()): ", sum(v))

# Verify: sum of 1^2 + 2^2 + ... + 10^2 = n(n+1)(2n+1)/6 = 10*11*21/6 = 385
expected = ZZ(385)
@assert sum(v) == expected "Sum should be 385"

# Example with large integers
println("\nLarge integer example:")
large_v = VecZZ([ZZ(10)^50, ZZ(10)^100, ZZ(10)^150])
println("Vector: [10^50, 10^100, 10^150]")
println("Sum has $(numbits(sum(large_v))) bits")

println("\nExample completed successfully!")
