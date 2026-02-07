using LibNTL
using Test

@testset "LibNTL.jl" begin
    @testset "ZZ - Arbitrary Precision Integers" begin
        include("test_zz.jl")
    end

    @testset "ZZ Conversions" begin
        include("test_conversions.jl")
    end

    @testset "ZZ_p - Modular Integers" begin
        include("test_zz_p.jl")
    end

    @testset "ZZX - Polynomials" begin
        include("test_zzx.jl")
    end

    @testset "ZZ_pX - Modular Polynomials" begin
        include("test_zz_px.jl")
    end

    @testset "VecZZ - Integer Vectors" begin
        include("test_vec.jl")
    end

    @testset "VecZZ_p - Modular Vectors" begin
        include("test_vec_zz_p.jl")
    end

    @testset "MatZZ - Integer Matrices" begin
        include("test_mat.jl")
    end

    @testset "GF2 - Binary Field Types" begin
        include("test_gf2.jl")
    end

    @testset "zz_p/zz_pX - Small Prime Types" begin
        include("test_zz_p_small.jl")
    end

    @testset "ZZ_pE/ZZ_pEX - Extension Fields" begin
        include("test_extension.jl")
    end

    @testset "RR - Arbitrary Precision Floats" begin
        include("test_rr.jl")
    end

    @testset "Docstrings" begin
        # Verify key functions have docstrings
        @test !isempty(string(@doc ZZ))
        @test !isempty(string(@doc ZZ_p))
        @test !isempty(string(@doc ZZX))
        @test !isempty(string(@doc InvModError))
        @test !isempty(string(@doc numbits))
        @test !isempty(string(@doc numbytes))
        @test !isempty(string(@doc ZZ_p_init!))
        @test !isempty(string(@doc with_modulus))
        @test !isempty(string(@doc degree))
        @test !isempty(string(@doc coeff))
        @test !isempty(string(@doc derivative))
        # New number theory function docstrings
        @test !isempty(string(@doc PowerMod))
        @test !isempty(string(@doc ProbPrime))
        @test !isempty(string(@doc PrimeSeq))
        @test !isempty(string(@doc RandomBnd))
        @test !isempty(string(@doc RandomBits))
    end

    # Examples as integration tests (only run if examples directory exists)
    examples_dir = joinpath(@__DIR__, "..", "examples")
    if isdir(examples_dir)
        include("test_examples.jl")
    end
end
