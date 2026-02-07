# Tests for ZZX (Polynomials over Z)

@testset "ZZX Construction" begin
    # Default constructor (zero polynomial)
    @test iszero(ZZX())

    # From integer (constant polynomial)
    @test degree(ZZX(0)) == -1  # Zero polynomial has degree -1
    @test degree(ZZX(5)) == 0
    @test constant(ZZX(5)) == ZZ(5)

    # From ZZ
    @test constant(ZZX(ZZ(42))) == ZZ(42)

    # From coefficient vector
    f = ZZX([ZZ(1), ZZ(2), ZZ(3)])  # 1 + 2x + 3x^2
    @test degree(f) == 2
    @test coeff(f, 0) == ZZ(1)
    @test coeff(f, 1) == ZZ(2)
    @test coeff(f, 2) == ZZ(3)
end

@testset "ZZX Coefficient Access" begin
    f = ZZX([ZZ(1), ZZ(2), ZZ(3), ZZ(4)])  # 1 + 2x + 3x^2 + 4x^3

    # degree
    @test degree(f) == 3

    # coeff
    @test coeff(f, 0) == ZZ(1)
    @test coeff(f, 1) == ZZ(2)
    @test coeff(f, 2) == ZZ(3)
    @test coeff(f, 3) == ZZ(4)
    @test coeff(f, 4) == ZZ(0)  # Beyond degree returns 0
    @test coeff(f, 100) == ZZ(0)

    # leading coefficient
    @test leading(f) == ZZ(4)

    # constant term
    @test constant(f) == ZZ(1)

    # getindex syntax
    @test f[0] == ZZ(1)
    @test f[3] == ZZ(4)

    # setcoeff!
    g = ZZX([ZZ(1), ZZ(2)])
    setcoeff!(g, 1, ZZ(10))
    @test coeff(g, 1) == ZZ(10)

    setcoeff!(g, 5, ZZ(7))  # Extend polynomial
    @test degree(g) == 5
    @test coeff(g, 5) == ZZ(7)
end

@testset "ZZX Arithmetic" begin
    f = ZZX([ZZ(1), ZZ(2)])  # 1 + 2x
    g = ZZX([ZZ(3), ZZ(4)])  # 3 + 4x

    # Addition
    h = f + g
    @test coeff(h, 0) == ZZ(4)  # 1 + 3
    @test coeff(h, 1) == ZZ(6)  # 2 + 4

    # Subtraction
    h = f - g
    @test coeff(h, 0) == ZZ(-2)  # 1 - 3
    @test coeff(h, 1) == ZZ(-2)  # 2 - 4

    # Multiplication
    # (1 + 2x)(3 + 4x) = 3 + 4x + 6x + 8x^2 = 3 + 10x + 8x^2
    h = f * g
    @test coeff(h, 0) == ZZ(3)
    @test coeff(h, 1) == ZZ(10)
    @test coeff(h, 2) == ZZ(8)

    # Scalar multiplication
    h = ZZ(3) * f
    @test coeff(h, 0) == ZZ(3)
    @test coeff(h, 1) == ZZ(6)

    # Negation
    h = -f
    @test coeff(h, 0) == ZZ(-1)
    @test coeff(h, 1) == ZZ(-2)
end

@testset "ZZX Division" begin
    # (x^2 + 3x + 2) = (x + 1)(x + 2)
    f = ZZX([ZZ(2), ZZ(3), ZZ(1)])  # 2 + 3x + x^2
    g = ZZX([ZZ(1), ZZ(1)])  # 1 + x

    # Division
    q = div(f, g)
    @test coeff(q, 0) == ZZ(2)  # x + 2
    @test coeff(q, 1) == ZZ(1)

    # Remainder
    r = rem(f, g)
    @test iszero(r)

    # divrem
    q2, r2 = divrem(f, g)
    @test q2 == q
    @test iszero(r2)

    # Division by zero polynomial
    @test_throws DomainError div(f, ZZX())
    @test_throws DomainError rem(f, ZZX())
end

@testset "ZZX GCD" begin
    # gcd(x^2 - 1, x - 1) = x - 1
    f = ZZX([ZZ(-1), ZZ(0), ZZ(1)])  # -1 + x^2
    g = ZZX([ZZ(-1), ZZ(1)])  # -1 + x

    h = gcd(f, g)
    # GCD should be a scalar multiple of (x - 1)
    @test degree(h) == 1

    # gcd of zero with f is f (up to sign)
    @test abs(leading(gcd(ZZX(), f))) == abs(leading(f)) || iszero(gcd(ZZX(), f) - f) || iszero(gcd(ZZX(), f) + f)
end

@testset "ZZX Evaluation and Derivative" begin
    # f(x) = 1 + 2x + 3x^2
    f = ZZX([ZZ(1), ZZ(2), ZZ(3)])

    # Evaluation
    @test f(ZZ(0)) == ZZ(1)
    @test f(ZZ(1)) == ZZ(6)  # 1 + 2 + 3
    @test f(ZZ(2)) == ZZ(17)  # 1 + 4 + 12

    # Derivative: f'(x) = 2 + 6x
    df = derivative(f)
    @test degree(df) == 1
    @test coeff(df, 0) == ZZ(2)
    @test coeff(df, 1) == ZZ(6)

    # Derivative of constant is zero
    @test iszero(derivative(ZZX(5)))
end

@testset "ZZX Content and Primitive Part" begin
    # f(x) = 6 + 12x + 18x^2 = 6(1 + 2x + 3x^2)
    f = ZZX([ZZ(6), ZZ(12), ZZ(18)])

    # Content
    c = content(f)
    @test c == ZZ(6)

    # Primitive part
    pp = primpart(f)
    @test coeff(pp, 0) == ZZ(1)
    @test coeff(pp, 1) == ZZ(2)
    @test coeff(pp, 2) == ZZ(3)

    # content(primpart(f)) = 1
    @test content(pp) == ZZ(1)
end

@testset "ZZX Predicates" begin
    @test iszero(ZZX())
    @test iszero(ZZX(0))
    @test !iszero(ZZX(1))
    @test !iszero(ZZX([ZZ(0), ZZ(1)]))  # x is not zero
end

@testset "ZZX Display" begin
    f = ZZX([ZZ(1), ZZ(2), ZZ(3)])

    buf = IOBuffer()
    show(buf, f)
    output = String(take!(buf))
    # NTL uses [c0 c1 c2 ...] format
    @test occursin("1", output)
    @test occursin("2", output)
    @test occursin("3", output)
end

@testset "ZZX Hash and Collections" begin
    f = ZZX([ZZ(1), ZZ(2)])
    g = ZZX([ZZ(1), ZZ(2)])

    # Hash consistency
    @test hash(f) == hash(g)

    # Dict support
    d = Dict{ZZX, String}()
    d[f] = "linear"
    @test d[g] == "linear"
end

@testset "ZZX Copy" begin
    f = ZZX([ZZ(1), ZZ(2), ZZ(3)])
    g = copy(f)

    @test f == g
    @test f !== g  # Different objects
end

@testset "ZZX Iteration" begin
    f = ZZX([ZZ(1), ZZ(2), ZZ(3)])  # degree 2, so 3 coefficients

    # length should be degree + 1
    @test length(f) == 3

    # Collect coefficients
    coeffs = collect(f)
    @test coeffs == [ZZ(1), ZZ(2), ZZ(3)]

    # eltype - check that it returns a ZZ-compatible type
    @test eltype(f) == typeof(ZZ(0))
end

@testset "ZZX Factorization" begin
    # factor(x^2 - 1) = (x - 1)(x + 1)
    f = ZZX([ZZ(-1), ZZ(0), ZZ(1)])  # -1 + x^2 = x^2 - 1
    c, factors = factor(f)
    @test c == ZZ(1)  # content is 1
    @test length(factors) == 2  # Two distinct factors

    # Verify product of factors equals original
    product = ZZX([c])
    for (p, e) in factors
        for _ in 1:e
            product = product * p
        end
    end
    @test product == f

    # factor(x^3 - x) = x(x-1)(x+1)
    g = ZZX([ZZ(0), ZZ(-1), ZZ(0), ZZ(1)])  # -x + x^3 = x^3 - x
    c2, factors2 = factor(g)
    @test c2 == ZZ(1)
    @test length(factors2) == 3  # x, (x-1), (x+1)

    # Verify product
    product2 = ZZX([c2])
    for (p, e) in factors2
        for _ in 1:e
            product2 = product2 * p
        end
    end
    @test product2 == g

    # factor of constant polynomial
    c3, factors3 = factor(ZZX(ZZ(6)))
    @test c3 == ZZ(6)
    @test isempty(factors3)

    # factor with multiplicity: (x + 1)^2 = x^2 + 2x + 1
    h = ZZX([ZZ(1), ZZ(2), ZZ(1)])
    c4, factors4 = factor(h)
    @test c4 == ZZ(1)
    @test length(factors4) == 1  # Single factor (x + 1) with multiplicity 2
    p, e = factors4[1]
    @test e == 2
    @test degree(p) == 1
end

@testset "ZZX Cyclotomic" begin
    # Φ₁(x) = x - 1
    phi1 = cyclotomic(1)
    @test degree(phi1) == 1
    @test coeff(phi1, 0) == ZZ(-1)
    @test coeff(phi1, 1) == ZZ(1)

    # Φ₂(x) = x + 1
    phi2 = cyclotomic(2)
    @test degree(phi2) == 1
    @test coeff(phi2, 0) == ZZ(1)
    @test coeff(phi2, 1) == ZZ(1)

    # Φ₃(x) = x^2 + x + 1
    phi3 = cyclotomic(3)
    @test degree(phi3) == 2
    @test coeff(phi3, 0) == ZZ(1)
    @test coeff(phi3, 1) == ZZ(1)
    @test coeff(phi3, 2) == ZZ(1)

    # Φ₄(x) = x^2 + 1
    phi4 = cyclotomic(4)
    @test degree(phi4) == 2
    @test coeff(phi4, 0) == ZZ(1)
    @test coeff(phi4, 1) == ZZ(0)
    @test coeff(phi4, 2) == ZZ(1)

    # Φ₆(x) = x^2 - x + 1
    phi6 = cyclotomic(6)
    @test degree(phi6) == 2
    @test coeff(phi6, 0) == ZZ(1)
    @test coeff(phi6, 1) == ZZ(-1)
    @test coeff(phi6, 2) == ZZ(1)

    # Φ₁₂(x) = x^4 - x^2 + 1 (degree = φ(12) = 4)
    phi12 = cyclotomic(12)
    @test degree(phi12) == 4

    # x^n - 1 = product of Φ_d(x) for all d | n
    # Verify: x^6 - 1 = Φ₁(x)Φ₂(x)Φ₃(x)Φ₆(x)
    xn_minus_1 = ZZX([ZZ(-1), ZZ(0), ZZ(0), ZZ(0), ZZ(0), ZZ(0), ZZ(1)])  # x^6 - 1
    product = cyclotomic(1) * cyclotomic(2) * cyclotomic(3) * cyclotomic(6)
    @test product == xn_minus_1
end
