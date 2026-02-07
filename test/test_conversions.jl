# Tests for ZZ <-> BigInt conversions

@testset "ZZ to BigInt" begin
    # Basic conversions
    @test convert(BigInt, ZZ(0)) == big"0"
    @test convert(BigInt, ZZ(42)) == big"42"
    @test convert(BigInt, ZZ(-100)) == big"-100"

    # Large numbers
    large = big"12345678901234567890123456789012345678901234567890"
    @test convert(BigInt, ZZ(string(large))) == large

    # Very large numbers (1000 digits)
    very_large = parse(BigInt, "9" ^ 1000)
    @test convert(BigInt, ZZ("9" ^ 1000)) == very_large
end

@testset "BigInt to ZZ" begin
    # Basic conversions
    @test ZZ(big"0") == ZZ(0)
    @test ZZ(big"42") == ZZ(42)
    @test ZZ(big"-100") == ZZ(-100)

    # Large numbers
    large = big"12345678901234567890123456789012345678901234567890"
    @test string(ZZ(large)) == string(large)

    # Very large numbers
    very_large = parse(BigInt, "9" ^ 1000)
    @test string(ZZ(very_large)) == string(very_large)
end

@testset "Round-trip Conversion" begin
    # Test values that should round-trip exactly
    test_values = [
        big"0",
        big"1",
        big"-1",
        big"42",
        big"-42",
        big"9999999999999999999999999999999999999999",
        big"-9999999999999999999999999999999999999999",
        parse(BigInt, "9" ^ 500),
        -parse(BigInt, "9" ^ 500),
    ]

    for v in test_values
        @test convert(BigInt, ZZ(v)) == v
    end
end

@testset "ZZ to Int64" begin
    # Valid conversions
    @test convert(Int64, ZZ(0)) == 0
    @test convert(Int64, ZZ(42)) == 42
    @test convert(Int64, ZZ(-100)) == -100
    @test convert(Int64, ZZ(typemax(Int64))) == typemax(Int64)
    @test convert(Int64, ZZ(typemin(Int64))) == typemin(Int64)

    # Overflow should throw
    @test_throws InexactError convert(Int64, ZZ(string(big"9" ^ 20)))
    @test_throws InexactError convert(Int64, ZZ(string(-big"9" ^ 20)))
end

@testset "Conversion Operators" begin
    # Test that BigInt(zz) works
    @test BigInt(ZZ(42)) == big"42"

    # Test that convert works both ways
    @test convert(ZZ, big"42") == ZZ(42)
    @test convert(BigInt, ZZ(42)) == big"42"
end
