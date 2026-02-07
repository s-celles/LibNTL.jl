# Tests for RR (arbitrary precision floating point)
using Test
using LibNTL

@testset "RR Type" begin
    @testset "Precision Settings" begin
        RR_SetPrecision!(150)
        @test RR_precision() == 150

        RR_SetPrecision!(500)
        @test RR_precision() == 500

        RR_SetOutputPrecision!(20)
        @test RR_OutputPrecision() == 20
    end

    @testset "Constructors" begin
        RR_SetPrecision!(200)

        a = RR(3.14)
        @test !iszero(a)

        b = RR(0)
        @test iszero(b)

        c = RR(1)
        @test isone(c)

        d = RR("0.1")
        @test !iszero(d)
    end

    @testset "Arithmetic" begin
        RR_SetPrecision!(200)

        a = RR(3.0)
        b = RR(2.0)

        # Addition
        c = a + b
        @test c == RR(5.0)

        # Subtraction
        d = a - b
        @test d == RR(1.0)

        # Multiplication
        e = a * b
        @test e == RR(6.0)

        # Division
        f = a / b
        @test f == RR(1.5)

        # Negation
        g = -a
        @test g == RR(-3.0)
    end

    @testset "Mathematical Functions" begin
        RR_SetPrecision!(200)

        # Square root
        @test sqrt(RR(4.0)) == RR(2.0)
        @test sqrt(RR(1.0)) == RR(1.0)

        # Exponential and logarithm
        @test abs(log(exp(RR(1.0))) - RR(1.0)) < RR(1e-10)

        # Trigonometric
        pi_val = RR_pi()
        @test abs(sin(pi_val)) < RR(1e-10)  # sin(π) ≈ 0
        @test abs(cos(pi_val) + RR(1.0)) < RR(1e-10)  # cos(π) ≈ -1
    end

    @testset "Power" begin
        RR_SetPrecision!(200)

        a = RR(2.0)
        @test a^2 == RR(4.0)
        @test a^3 == RR(8.0)
        @test a^0 == RR(1.0)
    end

    @testset "Comparison" begin
        RR_SetPrecision!(200)

        @test RR(1.0) < RR(2.0)
        @test RR(2.0) > RR(1.0)
        @test RR(1.0) <= RR(1.0)
        @test RR(2.0) >= RR(1.0)
        @test RR(1.0) == RR(1.0)
    end

    @testset "Pi Constant" begin
        RR_SetPrecision!(500)

        pi_val = RR_pi()
        # Check that π is approximately correct
        @test pi_val > RR(3.14)
        @test pi_val < RR(3.15)

        # sin²(π/4) + cos²(π/4) = 1
        angle = pi_val / RR(4.0)
        identity = sin(angle)^2 + cos(angle)^2
        @test abs(identity - RR(1.0)) < RR(1e-20)
    end

    @testset "High Precision" begin
        RR_SetPrecision!(1000)

        # Test that high precision computation doesn't lose accuracy
        a = RR("1.0000000000000000000000000000001")
        b = RR("0.0000000000000000000000000000001")

        # a - 1 should equal b
        diff = a - RR(1.0)
        @test abs(diff - b) < RR(1e-40)
    end

    @testset "Domain Errors" begin
        @test_throws DomainError sqrt(RR(-1.0))
        @test_throws DomainError log(RR(0.0))
        @test_throws DomainError log(RR(-1.0))
        @test_throws DomainError RR(1.0) / RR(0.0)
    end
end
