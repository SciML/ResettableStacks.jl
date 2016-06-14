using ResettableStacks
using Base.Test

S = ResettableStack{}(Tuple{Float64,Float64,Float64})

push!(S,(0.5,0.4,0.3))
push!(S,(0.5,0.4,0.4))
reset!(S)
push!(S,(0.5,0.4,0.3))
