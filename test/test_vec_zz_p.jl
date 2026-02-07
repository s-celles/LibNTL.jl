# Tests for VecZZ_p - Vectors over Z/pZ

@testset "VecZZ_p Construction" begin
    with_modulus(ZZ(17)) do
        # Empty vector
        v0 = VecZZ_p()
        @test length(v0) == 0
        @test isempty(v0)

        # Vector with size
        v1 = VecZZ_p(5)
        @test length(v1) == 5
        @test all(iszero(v1[i]) for i in 1:5)

        # From ZZ_p array
        v2 = VecZZ_p([ZZ_p(1), ZZ_p(2), ZZ_p(3)])
        @test length(v2) == 3
        @test rep(v2[1]) == ZZ(1)
        @test rep(v2[2]) == ZZ(2)
        @test rep(v2[3]) == ZZ(3)

        # From integer array
        v3 = VecZZ_p([1, 2, 3])
        @test length(v3) == 3
        @test rep(v3[1]) == ZZ(1)
    end
end

@testset "VecZZ_p Indexing" begin
    with_modulus(ZZ(17)) do
        v = VecZZ_p([ZZ_p(5), ZZ_p(10), ZZ_p(15)])

        # 1-indexed access
        @test rep(v[1]) == ZZ(5)
        @test rep(v[2]) == ZZ(10)
        @test rep(v[3]) == ZZ(15)

        # 0-indexed access via callable
        @test rep(v(0)) == ZZ(5)
        @test rep(v(1)) == ZZ(10)
        @test rep(v(2)) == ZZ(15)

        # Set element
        v[2] = ZZ_p(7)
        @test rep(v[2]) == ZZ(7)

        # Set from integer
        v[3] = 20  # 20 mod 17 = 3
        @test rep(v[3]) == ZZ(3)
    end
end

@testset "VecZZ_p Arithmetic" begin
    with_modulus(ZZ(17)) do
        a = VecZZ_p([ZZ_p(5), ZZ_p(10), ZZ_p(15)])
        b = VecZZ_p([ZZ_p(3), ZZ_p(8), ZZ_p(12)])

        # Addition
        c = a + b
        @test rep(c[1]) == ZZ(8)   # 5 + 3 = 8
        @test rep(c[2]) == ZZ(1)   # 10 + 8 = 18 ≡ 1 (mod 17)
        @test rep(c[3]) == ZZ(10)  # 15 + 12 = 27 ≡ 10 (mod 17)

        # Subtraction
        d = a - b
        @test rep(d[1]) == ZZ(2)   # 5 - 3 = 2
        @test rep(d[2]) == ZZ(2)   # 10 - 8 = 2
        @test rep(d[3]) == ZZ(3)   # 15 - 12 = 3

        # Negation
        e = -a
        @test rep(e[1]) == ZZ(12)  # -5 ≡ 12 (mod 17)
        @test rep(e[2]) == ZZ(7)   # -10 ≡ 7 (mod 17)
        @test rep(e[3]) == ZZ(2)   # -15 ≡ 2 (mod 17)

        # Scalar multiplication
        f = ZZ_p(3) * a
        @test rep(f[1]) == ZZ(15)  # 3 * 5 = 15
        @test rep(f[2]) == ZZ(13)  # 3 * 10 = 30 ≡ 13 (mod 17)
        @test rep(f[3]) == ZZ(11)  # 3 * 15 = 45 ≡ 11 (mod 17)

        # Integer scalar multiplication
        g = 2 * a
        @test rep(g[1]) == ZZ(10)  # 2 * 5 = 10
    end
end

@testset "VecZZ_p Inner Product" begin
    with_modulus(ZZ(17)) do
        a = VecZZ_p([ZZ_p(2), ZZ_p(3), ZZ_p(4)])
        b = VecZZ_p([ZZ_p(5), ZZ_p(6), ZZ_p(7)])

        # Inner product: 2*5 + 3*6 + 4*7 = 10 + 18 + 28 = 56 ≡ 5 (mod 17)
        ip = inner_product(a, b)
        @test rep(ip) == ZZ(5)

        # Optimized version should give same result
        ip_zz = inner_product_zz(a, b)
        @test rep(ip_zz) == ZZ(5)
    end
end

@testset "VecZZ_p Mutation" begin
    with_modulus(ZZ(17)) do
        v = VecZZ_p([ZZ_p(1), ZZ_p(2)])

        # Push
        push!(v, ZZ_p(3))
        @test length(v) == 3
        @test rep(v[3]) == ZZ(3)

        push!(v, 4)  # Integer
        @test length(v) == 4
        @test rep(v[4]) == ZZ(4)

        # Resize larger
        resize!(v, 6)
        @test length(v) == 6
        @test iszero(v[5])
        @test iszero(v[6])

        # Resize smaller
        resize!(v, 2)
        @test length(v) == 2
    end
end

@testset "VecZZ_p Iteration" begin
    with_modulus(ZZ(17)) do
        v = VecZZ_p([ZZ_p(1), ZZ_p(2), ZZ_p(3)])

        # For loop
        sum_val = ZZ_p(0)
        for x in v
            sum_val = sum_val + x
        end
        @test rep(sum_val) == ZZ(6)

        # Collect
        collected = collect(v)
        @test length(collected) == 3
    end
end

@testset "VecZZ_p Display" begin
    with_modulus(ZZ(17)) do
        v = VecZZ_p([ZZ_p(1), ZZ_p(2), ZZ_p(3)])
        s = string(v)
        @test s == "[1 2 3]"

        # Empty
        v0 = VecZZ_p()
        @test string(v0) == "[]"
    end
end

@testset "VecZZ_p Copy and Equality" begin
    with_modulus(ZZ(17)) do
        v1 = VecZZ_p([ZZ_p(1), ZZ_p(2), ZZ_p(3)])
        v2 = copy(v1)

        @test v1 == v2

        v2[1] = ZZ_p(10)
        @test v1 != v2
        @test rep(v1[1]) == ZZ(1)  # Original unchanged
    end
end
