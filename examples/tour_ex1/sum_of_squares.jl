#!/usr/bin/env julia
"""
NTL Tour Example 1.2: Sum of Squares

Corresponds to NTL C++ example:
```cpp
ZZ acc = 0;
while (cin >> val)
    acc += val*val;
cout << acc << "\\n";
```

This Julia version demonstrates accumulating squared values using
arbitrary-precision integers.
"""

using LibNTL

# Sample values
values = [ZZ(1), ZZ(2), ZZ(3), ZZ(4), ZZ(5)]

# Method 1: Explicit loop (C++ style)
acc = ZZ(0)
for v in values
    global acc
    acc += v * v
end
println("Sum of squares (loop): $acc")

# Method 2: Generator expression (Julia idiom)
acc2 = sum(v^2 for v in values)
println("Sum of squares (generator): $acc2")

# Verify: 1 + 4 + 9 + 16 + 25 = 55
@assert acc == ZZ(55) "Result mismatch!"
@assert acc2 == ZZ(55) "Result mismatch!"

# Example with large numbers
large_values = [ZZ(10)^100, ZZ(10)^200, ZZ(10)^300]
large_sum = sum(v^2 for v in large_values)
println("\nSum of squares of 10^100, 10^200, 10^300:")
println("  = 10^200 + 10^400 + 10^600")
println("  has $(numbits(large_sum)) bits")

println("\nExample completed successfully!")
