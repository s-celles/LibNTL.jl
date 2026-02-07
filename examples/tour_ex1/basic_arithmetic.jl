#!/usr/bin/env julia
"""
NTL Tour Example 1.1: Basic Arithmetic with Big Integers

Corresponds to NTL C++ example:
```cpp
#include <NTL/ZZ.h>
using namespace NTL;

int main() {
    ZZ a, b, c;
    cin >> a >> b;
    c = (a+1)*(b+1);
    cout << c << "\\n";
}
```

This Julia version demonstrates arbitrary-precision integer arithmetic.
"""

using LibNTL

# Create big integers
a = ZZ(123456789)
b = ZZ(987654321)

# Compute (a+1)*(b+1)
c = (a + 1) * (b + 1)

println("a = $a")
println("b = $b")
println("(a+1)*(b+1) = $c")

# Verify result
expected = (BigInt(123456789) + 1) * (BigInt(987654321) + 1)
@assert c == ZZ(expected) "Result mismatch!"

println("\nExample completed successfully!")
