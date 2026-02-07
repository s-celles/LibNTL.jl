# Tests for MatZZ - Matrix of arbitrary-precision integers

@testset "MatZZ Construction" begin
    # Default constructor (empty matrix)
    m = MatZZ()
    @test size(m) == (0, 0)

    # Constructor with dimensions
    m = MatZZ(3, 4)
    @test size(m) == (3, 4)
    @test nrows(m) == 3
    @test ncols(m) == 4

    # Constructor from 2D Julia array
    m = MatZZ([ZZ(1) ZZ(2); ZZ(3) ZZ(4)])
    @test size(m) == (2, 2)
    @test m[1, 1] == ZZ(1)
    @test m[1, 2] == ZZ(2)
    @test m[2, 1] == ZZ(3)
    @test m[2, 2] == ZZ(4)

    # Constructor from integers (automatic conversion)
    m = MatZZ([1 2 3; 4 5 6])
    @test size(m) == (2, 3)
end

@testset "MatZZ Indexing" begin
    m = MatZZ([ZZ(1) ZZ(2); ZZ(3) ZZ(4)])

    # getindex (1-based indexing)
    @test m[1, 1] == ZZ(1)
    @test m[1, 2] == ZZ(2)
    @test m[2, 1] == ZZ(3)
    @test m[2, 2] == ZZ(4)

    # setindex!
    m[1, 2] = ZZ(10)
    @test m[1, 2] == ZZ(10)

    # Bounds checking
    @test_throws BoundsError m[0, 1]
    @test_throws BoundsError m[1, 0]
    @test_throws BoundsError m[3, 1]
    @test_throws BoundsError m[1, 3]
end

@testset "MatZZ Size Functions" begin
    m = MatZZ(3, 4)

    @test size(m) == (3, 4)
    @test size(m, 1) == 3
    @test size(m, 2) == 4
    @test nrows(m) == 3
    @test ncols(m) == 4
    @test length(m) == 12
end

@testset "MatZZ Arithmetic" begin
    m1 = MatZZ([ZZ(1) ZZ(2); ZZ(3) ZZ(4)])
    m2 = MatZZ([ZZ(5) ZZ(6); ZZ(7) ZZ(8)])

    # Matrix addition
    m3 = m1 + m2
    @test m3[1, 1] == ZZ(6)
    @test m3[1, 2] == ZZ(8)
    @test m3[2, 1] == ZZ(10)
    @test m3[2, 2] == ZZ(12)

    # Matrix subtraction
    m4 = m2 - m1
    @test m4[1, 1] == ZZ(4)
    @test m4[1, 2] == ZZ(4)
    @test m4[2, 1] == ZZ(4)
    @test m4[2, 2] == ZZ(4)

    # Matrix multiplication
    # [1 2]   [5 6]   [1*5+2*7  1*6+2*8]   [19 22]
    # [3 4] * [7 8] = [3*5+4*7  3*6+4*8] = [43 50]
    m5 = m1 * m2
    @test m5[1, 1] == ZZ(19)
    @test m5[1, 2] == ZZ(22)
    @test m5[2, 1] == ZZ(43)
    @test m5[2, 2] == ZZ(50)

    # Scalar multiplication
    m6 = m1 * ZZ(2)
    @test m6[1, 1] == ZZ(2)
    @test m6[2, 2] == ZZ(8)

    m7 = ZZ(3) * m1
    @test m7[1, 1] == ZZ(3)
    @test m7[2, 2] == ZZ(12)
end

@testset "MatZZ Negation" begin
    m = MatZZ([ZZ(1) ZZ(2); ZZ(3) ZZ(4)])

    mn = -m
    @test mn[1, 1] == ZZ(-1)
    @test mn[1, 2] == ZZ(-2)
    @test mn[2, 1] == ZZ(-3)
    @test mn[2, 2] == ZZ(-4)
end

@testset "MatZZ mul!" begin
    m1 = MatZZ([ZZ(1) ZZ(2); ZZ(3) ZZ(4)])
    m2 = MatZZ([ZZ(5) ZZ(6); ZZ(7) ZZ(8)])
    result = MatZZ(2, 2)

    mul!(result, m1, m2)
    @test result[1, 1] == ZZ(19)
    @test result[1, 2] == ZZ(22)
    @test result[2, 1] == ZZ(43)
    @test result[2, 2] == ZZ(50)
end

@testset "MatZZ Display" begin
    m = MatZZ([ZZ(1) ZZ(2); ZZ(3) ZZ(4)])
    s = string(m)
    # Should contain the elements
    @test occursin("1", s)
    @test occursin("2", s)
    @test occursin("3", s)
    @test occursin("4", s)
end

@testset "MatZZ Copy" begin
    m1 = MatZZ([ZZ(1) ZZ(2); ZZ(3) ZZ(4)])
    m2 = copy(m1)

    # Copies should be equal
    @test m1 == m2

    # Modification of copy shouldn't affect original
    m2[1, 1] = ZZ(100)
    @test m1[1, 1] == ZZ(1)
    @test m2[1, 1] == ZZ(100)
end

@testset "MatZZ Identity and Zero" begin
    # Identity matrix
    I3 = MatZZ(3, 3)
    for i in 1:3
        I3[i, i] = ZZ(1)
    end
    @test I3[1, 1] == ZZ(1)
    @test I3[2, 2] == ZZ(1)
    @test I3[3, 3] == ZZ(1)
    @test I3[1, 2] == ZZ(0)

    # Zero matrix
    Z = MatZZ(2, 3)
    for i in 1:2, j in 1:3
        @test Z[i, j] == ZZ(0)
    end
end
