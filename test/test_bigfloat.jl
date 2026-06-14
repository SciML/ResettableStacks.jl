using ResettableStacks
using Test

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
