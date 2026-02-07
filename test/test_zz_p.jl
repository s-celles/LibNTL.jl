# Tests for ZZ_p (Modular Integers)

@testset "ZZ_p Modulus Initialization" begin
    # Initialize with a prime modulus
    ZZ_p_init!(ZZ(17))
    @test ZZ_p_modulus() == ZZ(17)

    # Change modulus
    ZZ_p_init!(ZZ(23))
    @test ZZ_p_modulus() == ZZ(23)

    # Large prime modulus
    large_prime = ZZ("1000000007")
    ZZ_p_init!(large_prime)
    @test ZZ_p_modulus() == large_prime

    # Modulus must be > 1
    @test_throws DomainError ZZ_p_init!(ZZ(1))
    @test_throws DomainError ZZ_p_init!(ZZ(0))
    @test_throws DomainError ZZ_p_init!(ZZ(-5))
end

@testset "ZZ_p Construction" begin
    ZZ_p_init!(ZZ(17))

    # Default constructor (zero)
    @test iszero(ZZ_p())

    # From integer
    @test rep(ZZ_p(5)) == ZZ(5)
    @test rep(ZZ_p(17)) == ZZ(0)  # Reduced mod 17
    @test rep(ZZ_p(20)) == ZZ(3)  # 20 mod 17 = 3

    # From negative integer
    @test rep(ZZ_p(-1)) == ZZ(16)  # -1 mod 17 = 16

    # From ZZ
    @test rep(ZZ_p(ZZ(100))) == ZZ(100 % 17)
end

@testset "ZZ_p Arithmetic" begin
    ZZ_p_init!(ZZ(17))

    a = ZZ_p(5)
    b = ZZ_p(3)

    # Addition
    @test rep(a + b) == ZZ(8)
    @test rep(ZZ_p(15) + ZZ_p(5)) == ZZ(3)  # 20 mod 17 = 3

    # Subtraction
    @test rep(a - b) == ZZ(2)
    @test rep(ZZ_p(3) - ZZ_p(5)) == ZZ(15)  # -2 mod 17 = 15

    # Multiplication
    @test rep(a * b) == ZZ(15)
    @test rep(ZZ_p(5) * ZZ_p(7)) == ZZ(1)  # 35 mod 17 = 1

    # Negation
    @test rep(-a) == ZZ(12)  # -5 mod 17 = 12

    # Power
    @test rep(ZZ_p(2)^3) == ZZ(8)
    @test rep(ZZ_p(2)^4) == ZZ(16)
    @test rep(ZZ_p(2)^5) == ZZ(15)  # 32 mod 17 = 15
end

@testset "ZZ_p Division and Inverse" begin
    ZZ_p_init!(ZZ(17))

    a = ZZ_p(5)

    # Inverse: 5 * 7 = 35 = 1 mod 17
    @test rep(inv(a)) == ZZ(7)
    @test rep(a * inv(a)) == ZZ(1)

    # Division: 10 / 5 = 10 * 7 = 70 = 2 mod 17
    @test rep(ZZ_p(10) / a) == ZZ(2)

    # Inverse of zero should throw
    @test_throws InvModError inv(ZZ_p(0))

    # Division by zero should throw
    @test_throws DomainError ZZ_p(5) / ZZ_p(0)
end

@testset "ZZ_p Predicates" begin
    ZZ_p_init!(ZZ(17))

    @test iszero(ZZ_p(0))
    @test iszero(ZZ_p(17))  # 17 mod 17 = 0
    @test !iszero(ZZ_p(1))

    @test isone(ZZ_p(1))
    @test isone(ZZ_p(18))  # 18 mod 17 = 1
    @test !isone(ZZ_p(0))
    @test !isone(ZZ_p(2))
end

@testset "ZZ_pContext Save/Restore" begin
    # Set initial modulus
    ZZ_p_init!(ZZ(17))
    @test ZZ_p_modulus() == ZZ(17)

    a = ZZ_p(5)
    @test rep(a) == ZZ(5)

    # Save context
    ctx = ZZ_pContext()
    save!(ctx)

    # Change modulus
    ZZ_p_init!(ZZ(23))
    @test ZZ_p_modulus() == ZZ(23)

    b = ZZ_p(5)
    @test rep(b) == ZZ(5)

    # Restore context
    restore!(ctx)
    @test ZZ_p_modulus() == ZZ(17)
end

@testset "with_modulus Convenience Function" begin
    ZZ_p_init!(ZZ(17))
    @test ZZ_p_modulus() == ZZ(17)

    # Execute code with a different modulus
    result = with_modulus(ZZ(23)) do
        @test ZZ_p_modulus() == ZZ(23)
        a = ZZ_p(20)
        rep(a)  # Should be 20 mod 23 = 20
    end
    @test result == ZZ(20)

    # Original modulus should be restored
    @test ZZ_p_modulus() == ZZ(17)

    # Test with exception - modulus should still be restored
    try
        with_modulus(ZZ(31)) do
            @test ZZ_p_modulus() == ZZ(31)
            error("Test exception")
        end
    catch e
        @test isa(e, ErrorException)
    end
    @test ZZ_p_modulus() == ZZ(17)  # Modulus restored even after exception
end

@testset "ZZ_p Display" begin
    ZZ_p_init!(ZZ(17))

    buf = IOBuffer()
    show(buf, ZZ_p(5))
    @test String(take!(buf)) == "5"

    show(buf, ZZ_p(20))
    @test String(take!(buf)) == "3"  # 20 mod 17 = 3
end

@testset "ZZ_p Hash and Collections" begin
    ZZ_p_init!(ZZ(17))

    # Hash consistency
    @test hash(ZZ_p(5)) == hash(ZZ_p(5))
    @test hash(ZZ_p(22)) == hash(ZZ_p(5))  # 22 mod 17 = 5

    # Dict support
    d = Dict{ZZ_p, String}()
    d[ZZ_p(1)] = "one"
    d[ZZ_p(2)] = "two"
    @test d[ZZ_p(1)] == "one"
    @test d[ZZ_p(18)] == "one"  # 18 mod 17 = 1
end

@testset "ZZ_p Copy" begin
    ZZ_p_init!(ZZ(17))

    a = ZZ_p(5)
    b = copy(a)
    @test rep(a) == rep(b)
    @test a !== b  # Different objects
end
