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
    end
end
