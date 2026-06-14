using ResettableStacks
using Test
using JLArrays

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
