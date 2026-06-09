using ResettableStacks
using Test
using JET
using ExplicitImports

# JET static analysis tests
@testset "JET static analysis" begin
    # Test type stability of core operations
    @testset "push!" begin
        S = ResettableStack{}(Float64)
        @test_opt target_modules = (ResettableStacks,) push!(S, 1.0)
    end

    @testset "pop!" begin
        S = ResettableStack{}(Float64)
        push!(S, 1.0)
        @test_opt target_modules = (ResettableStacks,) pop!(S)
    end

    @testset "reset!" begin
        S = ResettableStack{}(Float64)
        push!(S, 1.0)
        @test_opt target_modules = (ResettableStacks,) reset!(S)
    end

    @testset "iterate" begin
        S = ResettableStack{}(Float64)
        push!(S, 1.0)
        @test_opt target_modules = (ResettableStacks,) iterate(S)
    end

    @testset "isempty" begin
        S = ResettableStack{}(Float64)
        @test_opt target_modules = (ResettableStacks,) isempty(S)
    end

    @testset "length" begin
        S = ResettableStack{}(Float64)
        @test_opt target_modules = (ResettableStacks,) length(S)
    end

    @testset "copyat_or_push! (iip=true)" begin
        S = ResettableStack{true}(Tuple{Float64, Vector{Float64}, Vector{Float64}})
        tuple = (1.0, [1.0, 2.0], [3.0, 4.0])
        @test_opt target_modules = (ResettableStacks,) ResettableStacks.copyat_or_push!(S, tuple)
    end

    @testset "copyat_or_push! (iip=false)" begin
        S = ResettableStack{false}(Tuple{Float64, Vector{Float64}, Vector{Float64}})
        tuple = (1.0, [1.0, 2.0], [3.0, 4.0])
        @test_opt target_modules = (ResettableStacks,) ResettableStacks.copyat_or_push!(S, tuple)
    end
end

# ExplicitImports tests
@testset "ExplicitImports" begin
    @test check_no_implicit_imports(ResettableStacks) === nothing
    @test check_no_stale_explicit_imports(ResettableStacks) === nothing
end
