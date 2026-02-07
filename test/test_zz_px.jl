# Tests for ZZ_pX (Polynomials over Z/pZ)

@testset "ZZ_pX Construction" begin
    with_modulus(ZZ(17)) do
        # Default constructor (zero polynomial)
        @test iszero(ZZ_pX())

        # From ZZ_p (constant polynomial)
        @test degree(ZZ_pX(ZZ_p(5))) == 0
        @test constant(ZZ_pX(ZZ_p(5))) == ZZ_p(5)

        # From coefficient vector
        f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(3)])  # 1 + 2x + 3x^2
        @test degree(f) == 2
        @test coeff(f, 0) == ZZ_p(1)
        @test coeff(f, 1) == ZZ_p(2)
        @test coeff(f, 2) == ZZ_p(3)

        # From integers (automatic reduction mod p)
        g = ZZ_pX([1, 2, 20])  # 1 + 2x + 20x^2, but 20 ≡ 3 (mod 17)
        @test coeff(g, 2) == ZZ_p(3)
    end
end

@testset "ZZ_pX Coefficient Access" begin
    with_modulus(ZZ(13)) do
        f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(3), ZZ_p(4)])  # 1 + 2x + 3x^2 + 4x^3

        # degree
        @test degree(f) == 3

        # coeff
        @test coeff(f, 0) == ZZ_p(1)
        @test coeff(f, 1) == ZZ_p(2)
        @test coeff(f, 2) == ZZ_p(3)
        @test coeff(f, 3) == ZZ_p(4)
        @test coeff(f, 4) == ZZ_p(0)  # Beyond degree returns 0

        # leading coefficient
        @test leading(f) == ZZ_p(4)

        # constant term
        @test constant(f) == ZZ_p(1)

        # getindex syntax
        @test f[0] == ZZ_p(1)
        @test f[3] == ZZ_p(4)

        # setcoeff!
        g = ZZ_pX([ZZ_p(1), ZZ_p(2)])
        setcoeff!(g, 1, ZZ_p(10))
        @test coeff(g, 1) == ZZ_p(10)
    end
end

@testset "ZZ_pX Arithmetic" begin
    with_modulus(ZZ(17)) do
        f = ZZ_pX([ZZ_p(1), ZZ_p(2)])  # 1 + 2x
        g = ZZ_pX([ZZ_p(3), ZZ_p(4)])  # 3 + 4x

        # Addition
        h = f + g
        @test coeff(h, 0) == ZZ_p(4)  # 1 + 3
        @test coeff(h, 1) == ZZ_p(6)  # 2 + 4

        # Subtraction
        h = f - g
        @test coeff(h, 0) == ZZ_p(17 - 2)  # 1 - 3 ≡ -2 ≡ 15 (mod 17)
        @test coeff(h, 1) == ZZ_p(17 - 2)  # 2 - 4 ≡ -2 ≡ 15 (mod 17)

        # Multiplication
        # (1 + 2x)(3 + 4x) = 3 + 4x + 6x + 8x^2 = 3 + 10x + 8x^2
        h = f * g
        @test coeff(h, 0) == ZZ_p(3)
        @test coeff(h, 1) == ZZ_p(10)
        @test coeff(h, 2) == ZZ_p(8)

        # Negation
        h = -f
        @test coeff(h, 0) == ZZ_p(16)  # -1 ≡ 16 (mod 17)
        @test coeff(h, 1) == ZZ_p(15)  # -2 ≡ 15 (mod 17)
    end
end

@testset "ZZ_pX Division" begin
    with_modulus(ZZ(17)) do
        # (x^2 - 1) = (x - 1)(x + 1)
        f = ZZ_pX([ZZ_p(16), ZZ_p(0), ZZ_p(1)])  # -1 + x^2 ≡ 16 + x^2 (mod 17)
        g = ZZ_pX([ZZ_p(16), ZZ_p(1)])  # -1 + x ≡ 16 + x (mod 17)

        # Division (should be x + 1)
        q = div(f, g)
        @test degree(q) == 1
        @test coeff(q, 0) == ZZ_p(1)   # constant = 1
        @test coeff(q, 1) == ZZ_p(1)   # x coefficient = 1

        # Remainder should be zero
        r = rem(f, g)
        @test iszero(r)
    end
end

@testset "ZZ_pX GCD" begin
    with_modulus(ZZ(17)) do
        # gcd(x^2 - 1, x - 1) should be a unit times (x - 1)
        f = ZZ_pX([ZZ_p(16), ZZ_p(0), ZZ_p(1)])  # x^2 - 1
        g = ZZ_pX([ZZ_p(16), ZZ_p(1)])  # x - 1

        h = gcd(f, g)
        # GCD should be monic (leading coeff = 1) and of degree 1
        @test degree(h) == 1
        @test leading(h) == ZZ_p(1)
    end
end

@testset "ZZ_pX Derivative" begin
    with_modulus(ZZ(17)) do
        # f(x) = 1 + 2x + 3x^2, f'(x) = 2 + 6x
        f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(3)])
        df = derivative(f)
        @test degree(df) == 1
        @test coeff(df, 0) == ZZ_p(2)
        @test coeff(df, 1) == ZZ_p(6)
    end
end

@testset "ZZ_pX Evaluation" begin
    with_modulus(ZZ(17)) do
        f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(3)])  # 1 + 2x + 3x^2

        # Evaluate at 0
        @test f(ZZ_p(0)) == ZZ_p(1)

        # Evaluate at 1: 1 + 2 + 3 = 6
        @test f(ZZ_p(1)) == ZZ_p(6)

        # Evaluate at 2: 1 + 4 + 12 = 17 ≡ 0 (mod 17)
        @test f(ZZ_p(2)) == ZZ_p(0)
    end
end

@testset "ZZ_pX Irreducibility (DetIrredTest)" begin
    with_modulus(ZZ(2)) do
        # x^2 + x + 1 is irreducible over GF(2)
        f = ZZ_pX([ZZ_p(1), ZZ_p(1), ZZ_p(1)])  # 1 + x + x^2
        @test is_irreducible(f)

        # x^2 + 1 = (x + 1)^2 is reducible over GF(2)
        g = ZZ_pX([ZZ_p(1), ZZ_p(0), ZZ_p(1)])  # 1 + x^2
        @test !is_irreducible(g)
    end

    with_modulus(ZZ(3)) do
        # x^2 + 1 is irreducible over GF(3) (no roots: 0^2+1=1, 1^2+1=2, 2^2+1=5≡2)
        f = ZZ_pX([ZZ_p(1), ZZ_p(0), ZZ_p(1)])
        @test is_irreducible(f)

        # x^2 - 1 = (x-1)(x+1) is reducible
        g = ZZ_pX([ZZ_p(2), ZZ_p(0), ZZ_p(1)])  # -1 + x^2 ≡ 2 + x^2 (mod 3)
        @test !is_irreducible(g)
    end
end

@testset "ZZ_pX Display" begin
    with_modulus(ZZ(17)) do
        f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(3)])
        s = string(f)
        # Should contain coefficient representations
        @test occursin("1", s)
        @test occursin("2", s)
        @test occursin("3", s)
    end
end

@testset "ZZ_pX Copy" begin
    with_modulus(ZZ(17)) do
        f = ZZ_pX([ZZ_p(1), ZZ_p(2), ZZ_p(3)])
        g = copy(f)
        @test f == g
        @test f !== g
    end
end
