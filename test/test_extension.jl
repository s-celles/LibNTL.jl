# Tests for ZZ_pE and ZZ_pEX (extension fields)
using Test
using LibNTL

@testset "ZZ_pE Type" begin
    @testset "Basic GF(3²)" begin
        ZZ_p_init!(ZZ(3))

        # x² + 1 is irreducible over GF(3)
        P = ZZ_pX()
        setcoeff!(P, 0, ZZ_p(1))
        setcoeff!(P, 2, ZZ_p(1))

        ZZ_pE_init!(P)
        @test ZZ_pE_degree() == 2

        # α = x (root of P)
        alpha = ZZ_pE(ZZ_pX([ZZ_p(0), ZZ_p(1)]))
        @test !iszero(alpha)

        # α² should be -1 = 2 in GF(3)
        alpha_sq = alpha * alpha
        @test rep(alpha_sq) == ZZ_pX([ZZ_p(2)])

        # α² + 1 = 0
        one_e = ZZ_pE(ZZ_p(1))
        @test iszero(alpha_sq + one_e)
    end

    @testset "Arithmetic" begin
        ZZ_p_init!(ZZ(5))

        P = ZZ_pX()
        setcoeff!(P, 0, ZZ_p(2))
        setcoeff!(P, 1, ZZ_p(1))
        setcoeff!(P, 2, ZZ_p(1))  # x² + x + 2

        ZZ_pE_init!(P)

        a = ZZ_pE(ZZ_p(3))
        b = ZZ_pE(ZZ_p(4))

        # Addition
        c = a + b
        @test rep(c) == ZZ_pX([ZZ_p(2)])  # 3 + 4 = 7 ≡ 2 mod 5

        # Multiplication of constants
        d = a * b
        @test rep(d) == ZZ_pX([ZZ_p(2)])  # 3 * 4 = 12 ≡ 2 mod 5
    end

    @testset "Inverse" begin
        ZZ_p_init!(ZZ(3))

        P = ZZ_pX()
        setcoeff!(P, 0, ZZ_p(1))
        setcoeff!(P, 2, ZZ_p(1))

        ZZ_pE_init!(P)

        a = ZZ_pE(ZZ_p(2))  # Constant element
        @test !iszero(a)

        a_inv = inv(a)
        prod = a * a_inv
        @test isone(prod)

        # Test inverse of non-constant element
        alpha = ZZ_pE(ZZ_pX([ZZ_p(0), ZZ_p(1)]))  # α
        alpha_inv = inv(alpha)
        prod2 = alpha * alpha_inv
        @test isone(prod2)
    end

    @testset "Power" begin
        ZZ_p_init!(ZZ(2))

        # x² + x + 1 is irreducible over GF(2)
        P = ZZ_pX()
        setcoeff!(P, 0, ZZ_p(1))
        setcoeff!(P, 1, ZZ_p(1))
        setcoeff!(P, 2, ZZ_p(1))

        ZZ_pE_init!(P)

        alpha = ZZ_pE(ZZ_pX([ZZ_p(0), ZZ_p(1)]))

        # In GF(4), α has order 3
        @test isone(alpha^3)
        @test !isone(alpha^1)
        @test !isone(alpha^2)
    end

    @testset "Context Management" begin
        ZZ_p_init!(ZZ(5))

        P1 = ZZ_pX()
        setcoeff!(P1, 0, ZZ_p(2))
        setcoeff!(P1, 2, ZZ_p(1))

        ZZ_pE_init!(P1)
        @test ZZ_pE_degree() == 2

        # Save and switch
        ctx = ZZ_pEContext()
        save!(ctx)

        P2 = ZZ_pX()
        setcoeff!(P2, 0, ZZ_p(1))
        setcoeff!(P2, 3, ZZ_p(1))

        ZZ_pE_init!(P2)
        @test ZZ_pE_degree() == 3

        # Restore
        restore!(ctx)
        @test ZZ_pE_degree() == 2
    end
end

@testset "ZZ_pEX Type" begin
    @testset "Basic Operations" begin
        ZZ_p_init!(ZZ(3))

        P = ZZ_pX()
        setcoeff!(P, 0, ZZ_p(1))
        setcoeff!(P, 2, ZZ_p(1))

        ZZ_pE_init!(P)

        # Create polynomial f = 1 + y
        f = ZZ_pEX()
        setcoeff!(f, 0, ZZ_pE(ZZ_p(1)))
        setcoeff!(f, 1, ZZ_pE(ZZ_p(1)))

        @test degree(f) == 1
        @test isone(constant(f))
        @test isone(leading(f))
    end

    @testset "Polynomial Arithmetic" begin
        ZZ_p_init!(ZZ(5))

        P = ZZ_pX()
        setcoeff!(P, 0, ZZ_p(2))
        setcoeff!(P, 2, ZZ_p(1))

        ZZ_pE_init!(P)

        # f = y + 1
        f = ZZ_pEX()
        setcoeff!(f, 0, ZZ_pE(ZZ_p(1)))
        setcoeff!(f, 1, ZZ_pE(ZZ_p(1)))

        # g = y + 1
        g = copy(f)

        # f + g = 2y + 2
        h = f + g
        @test degree(h) == 1

        # f * g = y² + 2y + 1
        p = f * g
        @test degree(p) == 2
    end
end
