__precompile__()

module ResettableStacks

const FULL_RESET_COUNT = 10000

using StaticArrays

import Base: isempty, length, push!, pop!, iterate, eltype

include("core.jl")

export ResettableStack, reset!
end # module
