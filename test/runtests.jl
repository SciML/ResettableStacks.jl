using ResettableStacks
using Test
using Random
using JLArrays
using ArrayInterface

S = ResettableStack{}(Tuple{Float64, Float64, Float64})

push!(S, (0.5, 0.4, 0.3))
push!(S, (0.5, 0.4, 0.4))
reset!(S)
push!(S, (0.5, 0.4, 0.3))
@test S.data[1] == (0.5, 0.4, 0.3)

S = ResettableStack{}(Float64)
for i in 1:10
    push!(S, i)
end
@test pop!(S) == 10

### Iterator tests
s = ResettableStacks.ResettableStack{}(Float64)
Random.seed!(100)
expected_values = Float64[]
for i in 1:6
    v = rand()
    push!(expected_values, v)
    push!(s, v)
end
# Iterator returns values in reverse (LIFO) order
reversed_expected = reverse(expected_values)
for (i, c) in enumerate(s)
    @test c == reversed_expected[i]
end
@test length(collect(s)) == 6
reset!(s)
new_val = rand()
push!(s, new_val)
for c in s
    @test c == new_val
end
@test length(collect(s)) == 1

### Interface tests

# eltype tests
@testset "eltype" begin
    S = ResettableStack{}(Float64)
    push!(S, 1.0)
    @test eltype(S) == Float64
    @test typeof(collect(S)) == Vector{Float64}

    S2 = ResettableStack{}(BigFloat)
    push!(S2, BigFloat(1.0))
    @test eltype(S2) == BigFloat
    @test typeof(collect(S2)) == Vector{BigFloat}

    S3 = ResettableStack{}(Vector{Int})
    push!(S3, [1, 2, 3])
    @test eltype(S3) == Vector{Int}
    @test typeof(collect(S3)) == Vector{Vector{Int}}
end

# BigFloat support tests
@testset "BigFloat support" begin
    S = ResettableStack{}(BigFloat)
    push!(S, BigFloat("3.14159265358979323846264338327950288419716939937510"))
    push!(S, BigFloat("2.71828182845904523536028747135266249775724709369995"))
    @test pop!(S) == BigFloat("2.71828182845904523536028747135266249775724709369995")
    @test length(S) == 1

    # Test iteration
    for item in S
        @test item isa BigFloat
    end

    # Test reset
    reset!(S)
    @test isempty(S)
end

# JLArrays support tests (GPU-like arrays)
@testset "JLArray support" begin
    # Store JLArrays in a stack
    S = ResettableStack{}(JLArray{Float64, 1})
    x1 = JLArray([1.0, 2.0, 3.0])
    x2 = JLArray([4.0, 5.0, 6.0])

    push!(S, x1)
    push!(S, x2)
    @test length(S) == 2

    result = pop!(S)
    @test result isa JLArray{Float64, 1}

    # Test iteration
    for item in S
        @test item isa JLArray{Float64, 1}
    end

    # Test reset
    reset!(S)
    @test isempty(S)
end

# copyat_or_push! tests with various types
@testset "copyat_or_push! interface" begin
    # Test with BigFloat arrays (in-place mode)
    S = ResettableStack{true}(Tuple{BigFloat, Vector{BigFloat}, Vector{BigFloat}})
    tuple1 = (BigFloat(1.0), BigFloat[1.0, 2.0, 3.0], BigFloat[4.0, 5.0, 6.0])
    tuple2 = (BigFloat(2.0), BigFloat[7.0, 8.0, 9.0], BigFloat[10.0, 11.0, 12.0])

    ResettableStacks.copyat_or_push!(S, tuple1)
    ResettableStacks.copyat_or_push!(S, tuple2)
    @test S.cur == 2

    # Test with JLArrays (non-in-place mode)
    S2 = ResettableStack{false}(Tuple{Float64, JLArray{Float64, 1}, JLArray{Float64, 1}})
    t1 = (1.0, JLArray([1.0, 2.0, 3.0]), JLArray([4.0, 5.0, 6.0]))
    t2 = (2.0, JLArray([7.0, 8.0, 9.0]), JLArray([10.0, 11.0, 12.0]))

    ResettableStacks.copyat_or_push!(S2, t1)
    ResettableStacks.copyat_or_push!(S2, t2)
    @test S2.cur == 2
    @test S2.data[1][2] isa JLArray
end

# ArrayInterface compatibility tests
@testset "ArrayInterface compatibility" begin
    S = ResettableStack{}(Float64)
    for i in 1:5
        push!(S, Float64(i))
    end

    # The internal data vector should work with ArrayInterface
    @test ArrayInterface.can_setindex(S.data)
    @test ArrayInterface.fast_scalar_indexing(S.data)
end
