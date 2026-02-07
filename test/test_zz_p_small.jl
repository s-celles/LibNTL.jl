# Tests for zz_p and zz_pX (single-precision small prime types).
using Test
using LibNTL

@testset "zz_p Type" begin
    @testset "Basic Arithmetic" begin
        zz_p_init!(17)

        x = zz_p(5)
        y = zz_p(10)

        @test rep(x) == 5
        @test rep(y) == 10

        # Addition
        @test rep(x + y) == 15
        @test rep(y + x) == 15

        # Subtraction
        @test rep(x - y) == 12  # 5 - 10 ≡ -5 ≡ 12 (mod 17)
        @test rep(y - x) == 5

        # Multiplication
        @test rep(x * y) == 16  # 5 * 10 = 50 ≡ 16 (mod 17)

        # Negation
        @test rep(-x) == 12  # -5 ≡ 12 (mod 17)

        # Power
        @test rep(x^2) == 8   # 5^2 = 25 ≡ 8 (mod 17)
        @test rep(x^3) == 6   # 5^3 = 125 ≡ 6 (mod 17)
    end

    @testset "Inverse and Division" begin
        zz_p_init!(17)

        x = zz_p(5)
        x_inv = inv(x)

        # 5 * 7 = 35 ≡ 1 (mod 17)
        @test rep(x_inv) == 7
        @test rep(x * x_inv) == 1

        # Division
        y = zz_p(10)
        @test rep(y / x) == rep(y * x_inv)

        # Inverse of zero should throw
        @test_throws DomainError inv(zz_p(0))
    end

    @testset "FFT Primes" begin
        # Test FFT prime initialization
        zz_p_FFTInit!(0)
        p = zz_p_modulus()
        @test p == 7681

        zz_p_FFTInit!(1)
        p = zz_p_modulus()
        @test p == 65537
    end

    @testset "Context Management" begin
        zz_p_init!(17)
        x = zz_p(5)
        @test rep(x) == 5

        # Save context and switch
        with_small_modulus(23) do
            y = zz_p(5)
            @test rep(y) == 5
            @test zz_p_modulus() == 23

            # 5 * 5 = 25 ≡ 2 (mod 23)
            @test rep(y * y) == 2
        end

        # Should be restored
        @test zz_p_modulus() == 17
        # 5 * 5 = 25 ≡ 8 (mod 17)
        @test rep(zz_p(5) * zz_p(5)) == 8
    end

    @testset "Predicates" begin
        zz_p_init!(17)

        @test iszero(zz_p(0))
        @test !iszero(zz_p(5))
        @test isone(zz_p(1))
        @test !isone(zz_p(5))

        # Zero and one constants
        @test iszero(zero(zz_p))
        @test isone(one(zz_p))
    end

    @testset "Equality and Comparison" begin
        zz_p_init!(17)

        @test zz_p(5) == zz_p(5)
        @test zz_p(22) == zz_p(5)  # 22 ≡ 5 (mod 17)
        @test zz_p(5) != zz_p(10)
    end
end

@testset "zz_pX Type" begin
    @testset "Basic Operations" begin
        zz_p_init!(17)

        # Create polynomial: 1 + 2x + 3x²
        f = zz_pX()
        setcoeff!(f, 0, 1)
        setcoeff!(f, 1, 2)
        setcoeff!(f, 2, 3)

        @test degree(f) == 2
        @test rep(coeff(f, 0)) == 1
        @test rep(coeff(f, 1)) == 2
        @test rep(coeff(f, 2)) == 3
        @test rep(leading(f)) == 3
        @test rep(constant(f)) == 1
    end

    @testset "Polynomial Arithmetic" begin
        zz_p_init!(17)

        # f = 1 + x
        f = zz_pX()
        setcoeff!(f, 0, 1)
        setcoeff!(f, 1, 1)

        # g = 1 + x
        g = zz_pX()
        setcoeff!(g, 0, 1)
        setcoeff!(g, 1, 1)

        # f + g = 2 + 2x
        h = f + g
        @test rep(coeff(h, 0)) == 2
        @test rep(coeff(h, 1)) == 2

        # f * g = (1 + x)² = 1 + 2x + x²
        p = f * g
        @test degree(p) == 2
        @test rep(coeff(p, 0)) == 1
        @test rep(coeff(p, 1)) == 2
        @test rep(coeff(p, 2)) == 1
    end

    @testset "Division" begin
        zz_p_init!(17)

        # f = x² - 1 = (x-1)(x+1)
        f = zz_pX()
        setcoeff!(f, 0, -1)  # -1 ≡ 16 (mod 17)
        setcoeff!(f, 2, 1)

        # g = x + 1
        g = zz_pX()
        setcoeff!(g, 0, 1)
        setcoeff!(g, 1, 1)

        # f / g should be x - 1
        q, r = divrem(f, g)
        @test iszero(r)
        @test degree(q) == 1
        @test rep(coeff(q, 0)) == 16  # -1 ≡ 16 (mod 17)
        @test rep(coeff(q, 1)) == 1
    end

    @testset "GCD" begin
        zz_p_init!(17)

        # f = x² - 1 = (x-1)(x+1)
        f = zz_pX()
        setcoeff!(f, 0, -1)
        setcoeff!(f, 2, 1)

        # g = (x-1)² = x² - 2x + 1
        g = zz_pX()
        setcoeff!(g, 0, 1)
        setcoeff!(g, 1, -2)
        setcoeff!(g, 2, 1)

        # gcd should be (x - 1) (monic)
        h = gcd(f, g)
        @test degree(h) == 1
        @test rep(leading(h)) == 1  # Should be monic
    end

    @testset "Evaluation" begin
        zz_p_init!(17)

        # f = 1 + 2x + x²
        f = zz_pX()
        setcoeff!(f, 0, 1)
        setcoeff!(f, 1, 2)
        setcoeff!(f, 2, 1)

        # f(0) = 1
        @test rep(f(zz_p(0))) == 1

        # f(1) = 1 + 2 + 1 = 4
        @test rep(f(zz_p(1))) == 4

        # f(2) = 1 + 4 + 4 = 9
        @test rep(f(zz_p(2))) == 9
    end

    @testset "Irreducibility" begin
        zz_p_init!(3)

        # x² + 1 over GF(3) is irreducible (no roots: 0²+1=1, 1²+1=2, 2²+1=2)
        f = zz_pX()
        setcoeff!(f, 0, 1)
        setcoeff!(f, 2, 1)
        @test is_irreducible(f)

        # x² - 1 over GF(3) is reducible (roots at 1 and 2)
        g = zz_pX()
        setcoeff!(g, 0, -1)
        setcoeff!(g, 2, 1)
        @test !is_irreducible(g)
    end
end
