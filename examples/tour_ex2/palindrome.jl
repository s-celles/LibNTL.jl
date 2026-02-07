#!/usr/bin/env julia
"""
NTL Tour Example 2.3: Palindrome Check

Corresponds to NTL C++ example that demonstrates reversing a vector
and checking if it's a palindrome.

NTL C++ example:
```cpp
void IsIt(const Vec<ZZ>& v) {
    long n = v.length();
    Vec<ZZ> w;
    SetLength(w, n);
    for (i = 0; i < n; i++) w[n-1-i] = v[i];
    if (IsEqual(w, v)) cout << "IsIt is a Palindrome";
    else cout << "IsIt is NOT a Palindrome";
}
```

This Julia version demonstrates VecZZ manipulation and comparison.
"""

using LibNTL

println("=== Palindrome Check Example ===\n")

function is_palindrome(v::VecZZ)
    n = length(v)
    w = VecZZ(n)
    # Reverse the vector
    for i in 1:n
        w[n - i + 1] = v[i]
    end
    return v == w
end

function check_palindrome(v::VecZZ, name::String)
    if is_palindrome(v)
        println("$name $v is a palindrome")
    else
        println("$name $v is NOT a palindrome")
    end
end

# Test with palindrome vectors
v1 = VecZZ([ZZ(1), ZZ(2), ZZ(3), ZZ(2), ZZ(1)])
check_palindrome(v1, "v1")

v2 = VecZZ([ZZ(42)])
check_palindrome(v2, "v2")

v3 = VecZZ([ZZ(5), ZZ(5)])
check_palindrome(v3, "v3")

# Test with non-palindrome vectors
v4 = VecZZ([ZZ(1), ZZ(2), ZZ(3)])
check_palindrome(v4, "v4")

v5 = VecZZ([ZZ(10), ZZ(20), ZZ(30), ZZ(40)])
check_palindrome(v5, "v5")

# Large number palindrome
v6 = VecZZ([ZZ(10)^100, ZZ(12345), ZZ(10)^100])
check_palindrome(v6, "v6")

# Empty vector is a palindrome
v7 = VecZZ()
check_palindrome(v7, "v7 (empty)")

println("\nExample completed successfully!")
