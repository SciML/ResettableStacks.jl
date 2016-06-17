using ResettableStacks
using Base.Test

S = ResettableStack{}(Tuple{Float64,Float64,Float64})

push!(S,(0.5,0.4,0.3))
push!(S,(0.5,0.4,0.4))
reset!(S)
push!(S,(0.5,0.4,0.3))
@test S.data[1] == (0.5,0.4,0.3)

S = ResettableStack{}(Float64)
for i=1:10
  push!(S,i)
end
@test pop!(S) == 10
