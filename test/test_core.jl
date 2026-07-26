using ResettableStacks
using Test

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

@testset "Base collection interface" begin
    stack = ResettableStack(Int)
    for value in 1:3
        push!(stack, value)
    end

    @test eltype(stack) === Int
    @test length(stack) == 3
    @test !isempty(stack)
    @test collect(stack) == [3, 2, 1]
    @test pop!(stack) == 3
    reset!(stack)
    @test isempty(stack)
    @test length(stack) == 0
end
