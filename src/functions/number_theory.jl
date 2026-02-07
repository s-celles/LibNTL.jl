"""
Number theory functions for ZZ.

Provides modular exponentiation, primality testing, random number generation,
bit operations, and prime sequence iteration.
"""

using Primes: isprime

# ============================================================================
# PowerMod - Modular Exponentiation
# ============================================================================

"""
    PowerMod(a::ZZ, e::ZZ, n::ZZ) -> ZZ

Compute a^e mod n using binary exponentiation.

# Arguments
- `a`: Base
- `e`: Exponent (can be negative if a is invertible mod n)
- `n`: Modulus (must be > 1)

# Returns
- Result in range [0, n-1]

# Examples
```julia
PowerMod(ZZ(2), ZZ(10), ZZ(1000))  # 2^10 mod 1000 = 24
PowerMod(ZZ(3), ZZ(-1), ZZ(7))     # 3^(-1) mod 7 = 5
```

# Errors
- Throws `DomainError` if n <= 1
"""
function PowerMod end

# ============================================================================
# Bit Operations
# ============================================================================

"""
    bit(a::ZZ, i::Int) -> Int

Return bit i of |a| (0-indexed from least significant).
Returns 0 if i >= numbits(a).

# Examples
```julia
bit(ZZ(5), 0)  # 1 (5 = 101 in binary)
bit(ZZ(5), 1)  # 0
bit(ZZ(5), 2)  # 1
```
"""
function bit end

# ============================================================================
# Random Numbers
# ============================================================================

"""
    RandomBnd(n::ZZ) -> ZZ

Return a random integer in [0, n-1].
Requires n > 0.
"""
function RandomBnd end

"""
    RandomBits(n::Int) -> ZZ

Return a random n-bit integer.
The result is in [0, 2^n - 1].
"""
function RandomBits end

# ============================================================================
# Primality Testing
# ============================================================================

"""
    ProbPrime(n::ZZ, num_trials::Int=10) -> Bool

Probabilistic primality test using Miller-Rabin.

# Arguments
- `n`: Number to test
- `num_trials`: Number of Miller-Rabin iterations (default: 10)

# Returns
- `true` if n is probably prime
- `false` if n is definitely composite

# Examples
```julia
ProbPrime(ZZ(1000000007))      # true
ProbPrime(ZZ(1000000007), 20)  # true with more confidence
ProbPrime(ZZ(100))              # false
```
"""
function ProbPrime end

# ============================================================================
# Prime Sequence Iterator
# ============================================================================

"""
    PrimeSeq

Iterator that generates all primes in sequence.

# Example
```julia
ps = PrimeSeq()
for p in ps
    p > 100 && break
    println(p)  # 2, 3, 5, 7, 11, ...
end
```
"""
# PrimeSeq type is defined below conditionally

"""
    next!(ps::PrimeSeq) -> Int

Get the next prime from the sequence.
Returns 0 when the sequence is exhausted (for very large primes).
"""
function next! end

"""
    reset!(ps::PrimeSeq, start::Int=1) -> Nothing

Reset the prime sequence to start from the first prime >= start.
"""
function reset! end

# ============================================================================
# Implementation - Conditional on Backend
# ============================================================================

if _USE_NATIVE
    # PowerMod implementations
    PowerMod(a::ZZ, e::ZZ, n::ZZ) = ZZ_PowerMod(a, e, n)
    PowerMod(a::ZZ, e::Integer, n::ZZ) = ZZ_PowerMod_long(a, Int(e), n)
    PowerMod(a::Integer, e::Integer, n::Integer) = PowerMod(ZZ(a), ZZ(e), ZZ(n))

    # Bit operations
    bit(a::ZZ, i::Integer) = ZZ_bit(a, Int(i))

    # Random numbers
    RandomBnd(n::ZZ) = ZZ_RandomBnd(n)
    RandomBnd(n::Integer) = RandomBnd(ZZ(n))
    RandomBits(n::Integer) = ZZ_RandomBits(Int(n))

    # Primality testing
    ProbPrime(n::ZZ, num_trials::Integer=10) = ZZ_ProbPrime(n, Int(num_trials))
    ProbPrime(n::Integer, num_trials::Integer=10) = ProbPrime(ZZ(n), num_trials)

    # PrimeSeq - type is already defined by CxxWrap
    # Just provide the Julia interface functions
    next!(ps::PrimeSeq) = PrimeSeq_next(ps)
    reset!(ps::PrimeSeq, start::Integer=1) = PrimeSeq_reset(ps, Int(start))

    # Iterator interface for PrimeSeq
    Base.iterate(ps::PrimeSeq) = begin
        p = next!(ps)
        p == 0 ? nothing : (p, nothing)
    end

    Base.iterate(ps::PrimeSeq, ::Nothing) = begin
        p = next!(ps)
        p == 0 ? nothing : (p, nothing)
    end

    Base.IteratorSize(::Type{PrimeSeq}) = Base.SizeUnknown()
    Base.eltype(::Type{PrimeSeq}) = Int
else
    # Fallback implementations using pure Julia

    function PowerMod(a::ZZ, e::ZZ, n::ZZ)
        n <= ZZ(1) && throw(DomainError(n, "Modulus must be > 1"))
        a_big = BigInt(a)
        e_big = BigInt(e)
        n_big = BigInt(n)
        result = powermod(a_big, e_big, n_big)
        return ZZ(result)
    end
    PowerMod(a::Integer, e::Integer, n::Integer) = PowerMod(ZZ(a), ZZ(e), ZZ(n))

    function bit(a::ZZ, i::Integer)
        a_big = abs(BigInt(a))
        return Int((a_big >> i) & 1)
    end

    function RandomBnd(n::ZZ)
        n <= ZZ(0) && throw(DomainError(n, "Bound must be > 0"))
        n_big = BigInt(n)
        return ZZ(rand(big(0):n_big-1))
    end
    RandomBnd(n::Integer) = RandomBnd(ZZ(n))

    function RandomBits(n::Integer)
        n < 0 && throw(DomainError(n, "Number of bits must be >= 0"))
        n == 0 && return ZZ(0)
        # Generate random bits
        return ZZ(rand(big(0):big(2)^n - 1))
    end

    function ProbPrime(n::ZZ, num_trials::Integer=10)
        n_big = BigInt(n)
        n_big <= 1 && return false
        # Use Primes.jl's isprime for fallback
        return isprime(n_big)
    end
    ProbPrime(n::Integer, num_trials::Integer=10) = ProbPrime(ZZ(n), num_trials)

    # PrimeSeq fallback implementation
    mutable struct PrimeSeq
        current::Int
        PrimeSeq() = new(1)
    end

    function next!(ps::PrimeSeq)
        ps.current += 1
        while ps.current < 10^9 && !isprime(ps.current)
            ps.current += 1
        end
        ps.current >= 10^9 && return 0  # Safety limit
        return ps.current
    end

    function reset!(ps::PrimeSeq, start::Integer=1)
        ps.current = max(1, Int(start) - 1)
        return nothing
    end

    Base.iterate(ps::PrimeSeq) = begin
        p = next!(ps)
        p == 0 ? nothing : (p, nothing)
    end

    Base.iterate(ps::PrimeSeq, ::Nothing) = begin
        p = next!(ps)
        p == 0 ? nothing : (p, nothing)
    end

    Base.IteratorSize(::Type{PrimeSeq}) = Base.SizeUnknown()
    Base.eltype(::Type{PrimeSeq}) = Int
end
