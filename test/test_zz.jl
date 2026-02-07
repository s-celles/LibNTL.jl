# Tests for ZZ (Arbitrary-Precision Integers)

@testset "ZZ Construction" begin
    # Default constructor (zero)
    @test iszero(ZZ())

    # From integers
    @test ZZ(0) == ZZ()
    @test ZZ(42) == ZZ(42)
    @test ZZ(-100) == ZZ(-100)

    # From string
    @test ZZ("0") == ZZ()
    @test ZZ("12345678901234567890") == ZZ("12345678901234567890")
    @test ZZ("-99999999999999999999") == ZZ("-99999999999999999999")

    # Very large numbers (1000+ digits)
    large = "9" ^ 1000
    @test string(ZZ(large)) == large
end

@testset "ZZ Arithmetic" begin
    a = ZZ(100)
    b = ZZ(23)

    # Basic operations
    @test a + b == ZZ(123)
    @test a - b == ZZ(77)
    @test a * b == ZZ(2300)
    @test div(a, b) == ZZ(4)
    @test rem(a, b) == ZZ(8)

    # Division with negative numbers
    @test div(ZZ(-100), ZZ(23)) == ZZ(-5)  # Floor division
    @test rem(ZZ(-100), ZZ(23)) == ZZ(15)  # Matches Julia's rem behavior

    # Power
    @test ZZ(2)^10 == ZZ(1024)
    @test ZZ(3)^20 == ZZ(3486784401)

    # Negation and absolute value
    @test -ZZ(42) == ZZ(-42)
    @test -ZZ(-42) == ZZ(42)
    @test abs(ZZ(-42)) == ZZ(42)
    @test abs(ZZ(42)) == ZZ(42)

    # divrem
    q, r = divrem(ZZ(100), ZZ(23))
    @test q == ZZ(4)
    @test r == ZZ(8)
end

@testset "ZZ Comparison" begin
    @test ZZ(42) == ZZ(42)
    @test ZZ(42) != ZZ(43)
    @test ZZ(42) < ZZ(43)
    @test ZZ(42) <= ZZ(42)
    @test ZZ(42) <= ZZ(43)
    @test ZZ(43) > ZZ(42)
    @test ZZ(43) >= ZZ(43)
    @test ZZ(43) >= ZZ(42)

    # With negative numbers
    @test ZZ(-1) < ZZ(0)
    @test ZZ(-1) < ZZ(1)
    @test ZZ(-100) < ZZ(-99)
end

@testset "ZZ Predicates" begin
    @test iszero(ZZ(0))
    @test !iszero(ZZ(1))
    @test !iszero(ZZ(-1))

    @test isone(ZZ(1))
    @test !isone(ZZ(0))
    @test !isone(ZZ(2))

    @test isodd(ZZ(1))
    @test isodd(ZZ(3))
    @test isodd(ZZ(-5))
    @test !isodd(ZZ(0))
    @test !isodd(ZZ(2))

    @test iseven(ZZ(0))
    @test iseven(ZZ(2))
    @test iseven(ZZ(-4))
    @test !iseven(ZZ(1))

    @test sign(ZZ(42)) == 1
    @test sign(ZZ(-42)) == -1
    @test sign(ZZ(0)) == 0
end

@testset "ZZ GCD" begin
    @test gcd(ZZ(48), ZZ(18)) == ZZ(6)
    @test gcd(ZZ(0), ZZ(5)) == ZZ(5)
    @test gcd(ZZ(5), ZZ(0)) == ZZ(5)
    @test gcd(ZZ(0), ZZ(0)) == ZZ(0)

    # Extended GCD: d = a*s + b*t
    d, s, t = gcdx(ZZ(48), ZZ(18))
    @test d == ZZ(6)
    @test ZZ(48) * s + ZZ(18) * t == d
end

@testset "ZZ Size Queries" begin
    @test numbits(ZZ(0)) == 0
    @test numbits(ZZ(1)) == 1
    @test numbits(ZZ(2)) == 2
    @test numbits(ZZ(255)) == 8
    @test numbits(ZZ(256)) == 9

    @test numbytes(ZZ(0)) == 0
    @test numbytes(ZZ(255)) == 1
    @test numbytes(ZZ(256)) == 2
end

@testset "ZZ Display" begin
    # Test that show works and produces readable output
    buf = IOBuffer()
    show(buf, ZZ(12345))
    @test String(take!(buf)) == "12345"

    show(buf, ZZ(-99999))
    @test String(take!(buf)) == "-99999"
end

@testset "ZZ Hash and Collections" begin
    # Hash consistency
    @test hash(ZZ(42)) == hash(ZZ(42))
    @test hash(ZZ(42)) != hash(ZZ(43))

    # Dict support
    d = Dict{ZZ, String}()
    d[ZZ(1)] = "one"
    d[ZZ(2)] = "two"
    @test d[ZZ(1)] == "one"
    @test d[ZZ(2)] == "two"

    # Set support
    s = Set{ZZ}()
    push!(s, ZZ(1))
    push!(s, ZZ(2))
    push!(s, ZZ(1))  # Duplicate
    @test length(s) == 2
    @test ZZ(1) in s
end

@testset "ZZ Copy" begin
    a = ZZ(42)
    b = copy(a)
    @test a == b
    @test a !== b  # Different objects

    c = deepcopy(a)
    @test a == c
    @test a !== c
end

@testset "ZZ Mixed-Type Operations" begin
    # ZZ with Integer
    @test ZZ(40) + 2 == ZZ(42)
    @test 2 + ZZ(40) == ZZ(42)
    @test ZZ(44) - 2 == ZZ(42)
    @test 44 - ZZ(2) == ZZ(42)
    @test ZZ(21) * 2 == ZZ(42)
    @test 2 * ZZ(21) == ZZ(42)

    # Comparison with Integer
    @test ZZ(42) == 42
    @test 42 == ZZ(42)
    @test ZZ(42) < 43
    @test 41 < ZZ(42)
end

@testset "ZZ Edge Cases" begin
    # Division by zero
    @test_throws DomainError div(ZZ(1), ZZ(0))
    @test_throws DomainError rem(ZZ(1), ZZ(0))

    # Very large numbers
    big_a = ZZ("9" ^ 10000)
    big_b = ZZ("9" ^ 5000)
    @test big_a * big_b == ZZ("9" ^ 10000) * ZZ("9" ^ 5000)

    # Power edge cases
    @test ZZ(0)^0 == ZZ(1)  # 0^0 = 1 by convention
    @test ZZ(1)^1000000 == ZZ(1)
end

# ============================================================================
# Number Theory Functions (Feature 002)
# ============================================================================

@testset "PowerMod" begin
    # Basic modular exponentiation
    @test PowerMod(ZZ(2), ZZ(10), ZZ(1000)) == ZZ(24)  # 2^10 mod 1000 = 1024 mod 1000 = 24
    @test PowerMod(ZZ(3), ZZ(7), ZZ(13)) == ZZ(3)      # 3^7 = 2187 = 168*13 + 3
    @test PowerMod(ZZ(2), ZZ(100), ZZ(1000000007)) == ZZ(976371285)  # Large exponent

    # Edge cases
    @test PowerMod(ZZ(0), ZZ(5), ZZ(7)) == ZZ(0)       # 0^n = 0
    @test PowerMod(ZZ(5), ZZ(0), ZZ(7)) == ZZ(1)       # a^0 = 1

    # Convenience method with Integer arguments
    @test PowerMod(2, 10, 1000) == ZZ(24)

    # Error: modulus must be > 1
    @test_throws DomainError PowerMod(ZZ(2), ZZ(3), ZZ(1))
    @test_throws DomainError PowerMod(ZZ(2), ZZ(3), ZZ(0))
end

@testset "Bit Operations" begin
    # bit(a, i) returns bit i of |a| (0-indexed from least significant)
    @test bit(ZZ(5), 0) == 1    # 5 = 101 in binary, bit 0 = 1
    @test bit(ZZ(5), 1) == 0    # bit 1 = 0
    @test bit(ZZ(5), 2) == 1    # bit 2 = 1
    @test bit(ZZ(5), 3) == 0    # bit 3 = 0 (beyond number)

    # Works with larger numbers
    @test bit(ZZ(256), 8) == 1  # 256 = 2^8
    @test bit(ZZ(256), 7) == 0

    # Works with negative numbers (returns bit of |a|)
    @test bit(ZZ(-5), 0) == 1
    @test bit(ZZ(-5), 2) == 1
end

@testset "RandomBnd" begin
    # RandomBnd(n) returns random in [0, n-1]
    n = ZZ(100)
    for _ in 1:100
        r = RandomBnd(n)
        @test r >= ZZ(0)
        @test r < n
    end

    # Error: bound must be > 0
    @test_throws DomainError RandomBnd(ZZ(0))
    @test_throws DomainError RandomBnd(ZZ(-1))
end

@testset "RandomBits" begin
    # RandomBits(n) returns random n-bit number
    r = RandomBits(100)
    @test numbits(r) <= 100

    # Edge case: 0 bits
    @test RandomBits(0) == ZZ(0)

    # Error: negative bits
    @test_throws DomainError RandomBits(-1)
end

@testset "ProbPrime" begin
    # Known primes
    @test ProbPrime(ZZ(2)) == true
    @test ProbPrime(ZZ(3)) == true
    @test ProbPrime(ZZ(5)) == true
    @test ProbPrime(ZZ(7)) == true
    @test ProbPrime(ZZ(11)) == true
    @test ProbPrime(ZZ(1000000007)) == true  # Large prime

    # Known composites
    @test ProbPrime(ZZ(4)) == false
    @test ProbPrime(ZZ(9)) == false
    @test ProbPrime(ZZ(15)) == false
    @test ProbPrime(ZZ(1000000011)) == false  # 1000000011 = 3 * 333333337

    # Edge cases
    @test ProbPrime(ZZ(0)) == false
    @test ProbPrime(ZZ(1)) == false
    @test ProbPrime(ZZ(-5)) == false  # Negative numbers not prime

    # With num_trials parameter
    @test ProbPrime(ZZ(1000000007), 20) == true
end

@testset "PrimeSeq" begin
    # First few primes
    ps = PrimeSeq()
    @test next!(ps) == 2
    @test next!(ps) == 3
    @test next!(ps) == 5
    @test next!(ps) == 7
    @test next!(ps) == 11

    # Reset and iterate again
    reset!(ps, 1)
    @test next!(ps) == 2

    # Start from a higher value
    reset!(ps, 20)
    @test next!(ps) == 23

    # Iterator interface
    ps2 = PrimeSeq()
    primes = Int[]
    for p in ps2
        p > 30 && break
        push!(primes, p)
    end
    @test primes == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
end
