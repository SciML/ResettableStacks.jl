using ResettableStacks
using Test

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
