using ResettableStacks
using Test
using ArrayInterface

S = ResettableStack{}(Float64)
for i in 1:5
    push!(S, Float64(i))
end

# The internal data vector should work with ArrayInterface
@test ArrayInterface.can_setindex(S.data)
@test ArrayInterface.fast_scalar_indexing(S.data)
