__precompile__()

module ResettableStacks

    const FULL_RESET_COUNT = 10000

    using StaticArrays: StaticArray

    import Base: isempty, length, push!, pop!, iterate, eltype

    include("core.jl")

    export ResettableStack, copyat_or_push!, reset!
end # module
