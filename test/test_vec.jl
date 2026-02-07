# Tests for VecZZ - Vector of arbitrary-precision integers

@testset "VecZZ Construction" begin
    # Default constructor (empty vector)
    v = VecZZ()
    @test length(v) == 0
    @test isempty(v)

    # Constructor from Julia array
    v = VecZZ([ZZ(1), ZZ(2), ZZ(3)])
    @test length(v) == 3
    @test !isempty(v)

    # Constructor with size
    v = VecZZ(5)
    @test length(v) == 5

    # Constructor from integers (automatic conversion)
    v = VecZZ([1, 2, 3, 4, 5])
    @test length(v) == 5
end

@testset "VecZZ Indexing" begin
    v = VecZZ([ZZ(10), ZZ(20), ZZ(30)])

    # getindex (1-based indexing)
    @test v[1] == ZZ(10)
    @test v[2] == ZZ(20)
    @test v[3] == ZZ(30)

    # setindex!
    v[2] = ZZ(25)
    @test v[2] == ZZ(25)

    # Bounds checking
    @test_throws BoundsError v[0]
    @test_throws BoundsError v[4]
end

@testset "VecZZ Iteration" begin
    v = VecZZ([ZZ(1), ZZ(2), ZZ(3)])

    # Collect via iteration
    collected = collect(v)
    @test collected == [ZZ(1), ZZ(2), ZZ(3)]

    # Sum via iteration
    total = sum(v)
    @test total == ZZ(6)

    # For loop
    vals = ZZ[]
    for x in v
        push!(vals, x)
    end
    @test vals == [ZZ(1), ZZ(2), ZZ(3)]
end

@testset "VecZZ Mutation" begin
    v = VecZZ()

    # push!
    push!(v, ZZ(1))
    @test length(v) == 1
    @test v[1] == ZZ(1)

    push!(v, ZZ(2))
    push!(v, ZZ(3))
    @test length(v) == 3

    # resize!
    resize!(v, 5)
    @test length(v) == 5
    # First 3 elements preserved
    @test v[1] == ZZ(1)
    @test v[2] == ZZ(2)
    @test v[3] == ZZ(3)

    # Shrink
    resize!(v, 2)
    @test length(v) == 2
    @test v[1] == ZZ(1)
    @test v[2] == ZZ(2)
end

@testset "VecZZ Arithmetic" begin
    v1 = VecZZ([ZZ(1), ZZ(2), ZZ(3)])
    v2 = VecZZ([ZZ(4), ZZ(5), ZZ(6)])

    # Element-wise sum
    s = sum(v1)
    @test s == ZZ(6)

    # Dot product / inner product
    dot = sum(v1[i] * v2[i] for i in 1:length(v1))
    @test dot == ZZ(1*4 + 2*5 + 3*6)  # 32
end

@testset "VecZZ Display" begin
    v = VecZZ([ZZ(1), ZZ(2), ZZ(3)])
    s = string(v)
    # NTL format: [1 2 3]
    @test occursin("1", s)
    @test occursin("2", s)
    @test occursin("3", s)
end

@testset "VecZZ Copy" begin
    v1 = VecZZ([ZZ(1), ZZ(2), ZZ(3)])
    v2 = copy(v1)

    # Copies should be equal
    @test v1 == v2

    # Modification of copy shouldn't affect original
    v2[1] = ZZ(100)
    @test v1[1] == ZZ(1)
    @test v2[1] == ZZ(100)
end
