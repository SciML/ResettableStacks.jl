using ResettableStacks
using Test
using JLArrays

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
