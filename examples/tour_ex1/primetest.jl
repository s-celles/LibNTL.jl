#!/usr/bin/env julia
"""
NTL Tour Example 1.4: Primality Testing

Corresponds to NTL C++ example:
```cpp
long PrimeTest(const ZZ& n, long t) {
    PrimeSeq s;
    long p = s.next();
    // ... Miller-Rabin implementation
}
```

This Julia version demonstrates NTL's ProbPrime function and PrimeSeq
iterator for primality testing.
"""

using LibNTL

println("=== Primality Testing Examples ===\n")

# Example 1: Test some numbers for primality
test_numbers = [ZZ(2), ZZ(17), ZZ(100), ZZ(1000000007), ZZ(1000000011)]

for n in test_numbers
    if ProbPrime(n)
        println("$n is probably prime")
    else
        println("$n is composite")
    end
end

# Example 2: Generate primes using PrimeSeq
println("\nFirst 20 primes using PrimeSeq:")
ps = PrimeSeq()
primes = Int[]
for p in ps
    p > 100 && break
    push!(primes, p)
end
println(primes)

# Example 3: Count primes up to N
println("\nCounting primes up to 1000:")
let
    ps = PrimeSeq()
    prime_count = 0
    for p in ps
        p > 1000 && break
        prime_count += 1
    end
    println("There are $prime_count primes up to 1000")
end
# The exact count is 168

# Example 4: Find a large prime
println("\nFinding a large probable prime:")
let
    # Start with a large odd number and search
    candidate = ZZ("1" * "0"^50 * "1")  # 10^50 + 1
    while !ProbPrime(candidate)
        candidate += 2  # Check odd numbers only
    end
    println("Found probable prime near 10^50: $candidate")
    println("Number of bits: $(numbits(candidate))")
end

# Example 5: High-confidence primality test
println("\nHigh-confidence primality test:")
n = ZZ(1000000007)
# Use 50 Miller-Rabin iterations for very high confidence
is_prime = ProbPrime(n, 50)
println("$n is probably prime (50 trials): $is_prime")

println("\nExample completed successfully!")
