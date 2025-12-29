using ResettableStacks
using Test
using Random

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
