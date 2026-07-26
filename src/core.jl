"""
    ResettableStack{inplace}(::Type{T})
    ResettableStack(::Type{T})

A reusable last-in, first-out stack whose storage survives [`reset!`](@ref).

`ResettableStack` keeps elements in an internal buffer and changes only its active length when it
is reset. This avoids allocating a new buffer for each reuse. A periodic reset, or an explicit
forced reset, can shrink a buffer that has grown substantially.

# Type Parameters
- `T`: Element type stored by the stack.
- `inplace`: Whether the internal helper `copyat_or_push!` reuses mutable tuple components. The
  public constructors default to `true`; use `ResettableStack{false}(T)` when the helper should
  replace a stored element instead.

# Fields
- `data::Vector{T}`: Backing storage. Only indices `1:length(stack)` are active stack entries.
- `cur::Int`: Number of active entries.
- `numResets::Int`: Number of calls to [`reset!`](@ref).

# Constructors
```julia
ResettableStack(T)           # uses inplace = true
ResettableStack{false}(T)    # replaces entries in copyat_or_push!
```

# Interface

A `ResettableStack` supports the standard `Base` collection operations `push!`, `pop!`,
`length`, `isempty`, `eltype`, and iteration. Iteration and `pop!` both visit active elements in
last-in, first-out order. `pop!` must only be called when the stack is nonempty. After `reset!`,
the stack is empty while its backing storage remains available for later pushes.

# Examples
```jldoctest
julia> stack = ResettableStack(Float64);

julia> push!(stack, 1.0); push!(stack, 2.0);

julia> pop!(stack)
2.0

julia> collect(stack)
1-element Vector{Float64}:
 1.0

julia> reset!(stack); isempty(stack)
true
```

See also: [`reset!`](@ref), `push!`, `pop!`
"""
mutable struct ResettableStack{T, iip}
    data::Vector{T}
    cur::Int
    numResets::Int
    ResettableStack(ty::Type{T}) where {T} = new{T, true}(Vector{T}(), 0, 0)
    ResettableStack{iip}(ty::Type{T}) where {T, iip} = new{T, iip}(Vector{T}(), 0, 0)
    function ResettableStack{T, iip}(data::Vector{T}, cur, numResets) where {T, iip}
        return new{T, iip}(data, cur, numResets)
    end
end

isinplace(::ResettableStack{T, iip}) where {T, iip} = iip

isempty(S::ResettableStack) = S.cur == 0
length(S::ResettableStack) = S.cur
eltype(::Type{ResettableStack{T, iip}}) where {T, iip} = T

function push!(S::ResettableStack, x)
    if S.cur == length(S.data)
        S.cur += 1
        push!(S.data, x)
    else
        S.cur += 1
        S.data[S.cur] = x
    end
    return nothing
end

safecopy(x) = copy(x)
safecopy(x::Union{Number, StaticArray}) = x
safecopy(x::Nothing) = nothing

# For DiffEqNoiseProcess S₂ fast updates
function copyat_or_push!(S::ResettableStack, x)
    if S.cur == length(S.data)
        S.cur += 1
        push!(S.data, safecopy.(x))
    else
        S.cur += 1
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
    return nothing
end

function pop!(S::ResettableStack)
    S.cur -= 1
    return S.data[S.cur + 1]
end

function iterate(S::ResettableStack, state = S.cur)
    if state == 0
        return nothing
    end

    state -= 1
    return (S.data[state + 1], state)
end

"""
    reset!(stack::ResettableStack, force_reset = false)

Reset `stack` to an empty state while preserving its backing storage for reuse.

The next `push!` overwrites a previously stored entry when possible. Every
`FULL_RESET_COUNT` calls, or when `force_reset` is `true`, a backing buffer larger than five
entries is reduced to at most half its size. The operation returns `nothing`.

# Arguments
- `stack::ResettableStack`: Stack to empty.
- `force_reset::Bool = false`: Whether to consider shrinking the backing buffer immediately.

# Examples
```jldoctest
julia> stack = ResettableStack(Int); push!(stack, 1); push!(stack, 2);

julia> reset!(stack); (isempty(stack), length(stack))
(true, 0)

julia> push!(stack, 3); pop!(stack)
3
```
"""
function reset!(S::ResettableStack, force_reset = false)
    S.numResets += 1
    S.cur = 0
    if length(S.data) > 5 && (S.numResets % FULL_RESET_COUNT == 0 || force_reset)
        resize!(S.data, max(length(S.data) ÷ 2, 5))
    end
    return nothing
end
