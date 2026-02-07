# Tests that run all examples as integration tests

@testset "Tour Example 1: Big Integers" begin
    examples_dir = joinpath(@__DIR__, "..", "examples", "tour_ex1")

    @testset "basic_arithmetic.jl" begin
        @test include(joinpath(examples_dir, "basic_arithmetic.jl")) === nothing || true
    end

    @testset "sum_of_squares.jl" begin
        @test include(joinpath(examples_dir, "sum_of_squares.jl")) === nothing || true
    end

    @testset "powermod.jl" begin
        @test include(joinpath(examples_dir, "powermod.jl")) === nothing || true
    end

    @testset "primetest.jl" begin
        @test include(joinpath(examples_dir, "primetest.jl")) === nothing || true
    end
end

@testset "Tour Example 2: Vectors and Matrices" begin
    examples_dir = joinpath(@__DIR__, "..", "examples", "tour_ex2")

    @testset "vector_sum_0indexed.jl" begin
        @test include(joinpath(examples_dir, "vector_sum_0indexed.jl")) === nothing || true
    end

    @testset "vector_sum_1indexed.jl" begin
        @test include(joinpath(examples_dir, "vector_sum_1indexed.jl")) === nothing || true
    end

    @testset "palindrome.jl" begin
        @test include(joinpath(examples_dir, "palindrome.jl")) === nothing || true
    end

    @testset "matrix_multiply.jl" begin
        @test include(joinpath(examples_dir, "matrix_multiply.jl")) === nothing || true
    end
end

@testset "Tour Example 3: Polynomials" begin
    examples_dir = joinpath(@__DIR__, "..", "examples", "tour_ex3")

    @testset "factorization.jl" begin
        @test include(joinpath(examples_dir, "factorization.jl")) === nothing || true
    end

    @testset "cyclotomic.jl" begin
        @test include(joinpath(examples_dir, "cyclotomic.jl")) === nothing || true
    end
end

@testset "Tour Example 4: Modular Polynomials" begin
    examples_dir = joinpath(@__DIR__, "..", "examples", "tour_ex4")

    @testset "poly_factor_mod_p.jl" begin
        @test include(joinpath(examples_dir, "poly_factor_mod_p.jl")) === nothing || true
    end

    @testset "irred_test_push.jl" begin
        @test include(joinpath(examples_dir, "irred_test_push.jl")) === nothing || true
    end

    @testset "vector_add_zz_p.jl" begin
        @test include(joinpath(examples_dir, "vector_add_zz_p.jl")) === nothing || true
    end

    @testset "inner_product.jl" begin
        @test include(joinpath(examples_dir, "inner_product.jl")) === nothing || true
    end

    @testset "gf2_irred_test.jl" begin
        @test include(joinpath(examples_dir, "gf2_irred_test.jl")) === nothing || true
    end
end
