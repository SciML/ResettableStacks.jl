"""
    ResettableStack{T, iip}

A stack data structure that can be efficiently reset without triggering garbage collection.

The stack maintains an internal buffer that is reused across resets, avoiding memory allocations
and garbage collection overhead. Every `FULL_RESET_COUNT` resets, the internal buffer is resized
if it has grown significantly larger than needed.

# Type Parameters
- `T`: The element type stored in the stack
- `iip`: Boolean flag indicating if elements should be treated as in-place (true) or out-of-place (false)

# Fields
- `data::Vector{T}`: Internal buffer storing stack elements
- `cur::Int`: Current position in the stack (number of elements)
- `numResets::Int`: Counter tracking the number of times `reset!` has been called

# Constructors
```julia
ResettableStack(::Type{T})          # Creates a stack with iip=true
ResettableStack{iip}(::Type{T})     # Creates a stack with specified iip flag
```

# Example
```julia
S = ResettableStack{true}(Float64)
push!(S, 1.0)
push!(S, 2.0)
val = pop!(S)  # returns 2.0
reset!(S)      # efficiently resets the stack
```

See also: [`reset!`](@ref), [`push!`](@ref), [`pop!`](@ref)
"""
mutable struct ResettableStack{T, iip}
    data::Vector{T}
    cur::Int
    numResets::Int
    ResettableStack(ty::Type{T}) where {T} = new{T, true}(Vector{T}(), 0, 0)
    ResettableStack{iip}(ty::Type{T}) where {T, iip} = new{T, iip}(Vector{T}(), 0, 0)
    function ResettableStack{T, iip}(data::Vector{T}, cur, numResets) where {T, iip}
        new{T, iip}(data, cur, numResets)
    end
end

isinplace(::ResettableStack{T, iip}) where {T, iip} = iip

isempty(S::ResettableStack) = S.cur==0
length(S::ResettableStack) = S.cur

function push!(S::ResettableStack, x)
    if S.cur==length(S.data)
        S.cur+=1
        push!(S.data, x)
    else
        S.cur+=1
        S.data[S.cur]=x
    end
    nothing
end

safecopy(x) = copy(x)
safecopy(x::Union{Number, StaticArray}) = x
safecopy(x::Nothing) = nothing

# For DiffEqNoiseProcess S₂ fast updates
function copyat_or_push!(S::ResettableStack, x)
    if S.cur==length(S.data)
        S.cur+=1
        push!(S.data, safecopy.(x))
    else
        S.cur+=1
        curx = S.data[S.cur]
        if !isinplace(S)
            S.data[S.cur] = x
        else
            curx[2] .= x[2]
            if x[3] != nothing
                curx[3] .= x[3]
            end
            S.data[S.cur] = (x[1], curx[2], curx[3])
        end
    end
    nothing
end

function pop!(S::ResettableStack)
    S.cur-=1
    S.data[S.cur + 1]
end

function iterate(S::ResettableStack, state = S.cur)
    if state == 0
        return nothing
    end

    state -= 1
    (S.data[state + 1], state)
end

"""
    reset!(S::ResettableStack, force_reset=false)

Reset the stack to an empty state without deallocating the internal buffer.

This allows the stack to be reused efficiently by overwriting previous data instead of
allocating new memory. Every `FULL_RESET_COUNT` resets (default: 10000), or when
`force_reset=true`, the internal buffer is resized to half its current size if it has
grown larger than 5 elements, preventing unbounded memory growth.

# Arguments
- `S::ResettableStack`: The stack to reset
- `force_reset::Bool=false`: If true, forces a buffer resize regardless of reset count

# Example
```julia
S = ResettableStack{true}(Float64)
push!(S, 1.0)
push!(S, 2.0)
reset!(S)  # Stack is now empty but buffer is preserved
push!(S, 3.0)  # Reuses existing buffer
```
"""
function reset!(S::ResettableStack, force_reset = false)
    S.numResets += 1
    S.cur = 0
    if length(S.data) > 5 && (S.numResets%FULL_RESET_COUNT==0 || force_reset)
        resize!(S.data, max(length(S.data)÷2, 5))
    end
    nothing
end
