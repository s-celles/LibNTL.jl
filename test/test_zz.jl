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
