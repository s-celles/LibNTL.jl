# Tests for GF2, GF2X, VecGF2, MatGF2

@testset "GF2 - Binary Field Element" begin
    @testset "Construction" begin
        @test iszero(GF2())
        @test iszero(GF2(0))
        @test isone(GF2(1))
        @test iszero(GF2(2))  # 2 mod 2 = 0
        @test isone(GF2(3))   # 3 mod 2 = 1
        @test iszero(GF2(false))
        @test isone(GF2(true))
    end

    @testset "Arithmetic" begin
        z = GF2(0)
        o = GF2(1)

        # Addition (XOR)
        @test z + z == z
        @test z + o == o
        @test o + z == o
        @test o + o == z

        # Subtraction (same as addition in GF(2))
        @test o - o == z
        @test o - z == o

        # Multiplication (AND)
        @test z * z == z
        @test z * o == z
        @test o * z == z
        @test o * o == o

        # Negation (identity)
        @test -z == z
        @test -o == o
    end

    @testset "Division and Power" begin
        o = GF2(1)
        @test inv(o) == o
        @test o / o == o
        @test_throws DomainError inv(GF2(0))

        @test o^0 == o
        @test o^1 == o
        @test o^10 == o
    end
end

@testset "GF2X - Polynomials over GF(2)" begin
    @testset "Construction" begin
        f0 = GF2X()
        @test degree(f0) == -1
        @test iszero(f0)

        f1 = GF2X([1, 0, 1])  # 1 + x^2
        @test degree(f1) == 2
        @test isone(coeff(f1, 0))
        @test iszero(coeff(f1, 1))
        @test isone(coeff(f1, 2))
    end

    @testset "Arithmetic" begin
        # f = 1 + x, g = 1 + x + x^2
        f = GF2X([1, 1])
        g = GF2X([1, 1, 1])

        # Addition
        h = f + g  # x^2
        @test degree(h) == 2
        @test iszero(coeff(h, 0))
        @test iszero(coeff(h, 1))
        @test isone(coeff(h, 2))

        # Multiplication: (1+x)(1+x+x^2) = 1 + x^3
        p = f * g
        @test degree(p) == 3
        @test isone(coeff(p, 0))
        @test iszero(coeff(p, 1))
        @test iszero(coeff(p, 2))
        @test isone(coeff(p, 3))
    end

    @testset "Division" begin
        # x^3 + 1 divided by x + 1
        f = GF2X([1, 0, 0, 1])  # 1 + x^3
        g = GF2X([1, 1])        # 1 + x

        q, r = divrem(f, g)
        @test f == g * q + r
    end

    @testset "GCD" begin
        # gcd(x^2 + 1, x + 1) over GF(2)
        # x^2 + 1 = (x+1)^2 in GF(2)
        f = GF2X([1, 0, 1])  # x^2 + 1
        g = GF2X([1, 1])     # x + 1

        h = gcd(f, g)
        @test degree(h) == 1  # Should be x + 1
    end

    @testset "Irreducibility" begin
        # x^2 + x + 1 is irreducible over GF(2)
        f = GF2X([1, 1, 1])
        @test is_irreducible(f)

        # x^2 + 1 = (x+1)^2 is reducible
        g = GF2X([1, 0, 1])
        @test !is_irreducible(g)

        # x^3 + x + 1 is irreducible
        h = GF2X([1, 1, 0, 1])
        @test is_irreducible(h)

        # x^3 + x^2 + 1 is irreducible
        k = GF2X([1, 0, 1, 1])
        @test is_irreducible(k)
    end

    @testset "Evaluation" begin
        f = GF2X([1, 1, 1])  # 1 + x + x^2
        @test f(GF2(0)) == GF2(1)  # 1 + 0 + 0 = 1
        @test f(GF2(1)) == GF2(1)  # 1 + 1 + 1 = 1
    end
end

@testset "VecGF2 - Vectors over GF(2)" begin
    @testset "Construction" begin
        v0 = VecGF2()
        @test length(v0) == 0

        v1 = VecGF2(5)
        @test length(v1) == 5
        @test all(iszero(v1[i]) for i in 1:5)

        v2 = VecGF2([1, 0, 1, 1, 0])
        @test length(v2) == 5
        @test isone(v2[1])
        @test iszero(v2[2])
    end

    @testset "Arithmetic" begin
        a = VecGF2([1, 0, 1])
        b = VecGF2([1, 1, 0])

        c = a + b
        @test iszero(c[1])  # 1 + 1 = 0
        @test isone(c[2])   # 0 + 1 = 1
        @test isone(c[3])   # 1 + 0 = 1

        # Inner product
        ip = inner_product(a, b)
        @test ip == GF2(1)  # 1*1 + 0*1 + 1*0 = 1
    end

    @testset "Display" begin
        v = VecGF2([1, 0, 1])
        @test string(v) == "[1 0 1]"
    end
end

@testset "MatGF2 - Matrices over GF(2)" begin
    @testset "Construction" begin
        m0 = MatGF2(2, 3)
        @test nrows(m0) == 2
        @test ncols(m0) == 3

        m1 = MatGF2([1 0; 0 1])
        @test m1[1, 1] == GF2(1)
        @test m1[1, 2] == GF2(0)
    end

    @testset "Arithmetic" begin
        A = MatGF2([1 0; 1 1])
        B = MatGF2([1 1; 0 1])

        C = A * B
        @test C[1, 1] == GF2(1)  # 1*1 + 0*0 = 1
        @test C[1, 2] == GF2(1)  # 1*1 + 0*1 = 1
        @test C[2, 1] == GF2(1)  # 1*1 + 1*0 = 1
        @test C[2, 2] == GF2(0)  # 1*1 + 1*1 = 0
    end

    @testset "Gaussian Elimination" begin
        # Full rank 3x3 matrix (identity)
        I3 = eye_gf2(3)
        I3_copy = copy(I3)
        r1 = gauss!(I3_copy)
        @test r1 == 3

        # Rank-deficient matrix: row 3 = row 1 + row 2, so rank = 2
        m2 = MatGF2([1 0 1; 0 1 1; 1 1 0])
        m2_copy = copy(m2)
        r2 = gauss!(m2_copy)
        @test r2 == 2

        # Even more rank-deficient
        m3 = MatGF2([1 1; 1 1])  # rank 1
        m3_copy = copy(m3)
        r3 = gauss!(m3_copy)
        @test r3 == 1

        # Test matrix_rank function
        @test matrix_rank(I3) == 3
        @test matrix_rank(m2) == 2
        @test matrix_rank(m3) == 1
    end

    @testset "Matrix-Vector Multiplication" begin
        A = MatGF2([1 0; 0 1; 1 1])  # 3x2
        v = VecGF2([1, 1])           # 2x1

        w = A * v
        @test length(w) == 3
        @test w[1] == GF2(1)  # 1*1 + 0*1 = 1
        @test w[2] == GF2(1)  # 0*1 + 1*1 = 1
        @test w[3] == GF2(0)  # 1*1 + 1*1 = 0
    end
end
