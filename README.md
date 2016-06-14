# ResettableStacks

A ResettableStack is a stack implementation which has a `reset!` function which
will "reset" the stack, allowing it to write over its previous data. This
allows you to reset the stack while avoiding garbage collection which can greatly
improve performance in certain use cases. Every `FULL_RESET_COUNT` resets, it
does a full reset, which is useful if the stack got very large for some reason
and it no longer needs to be that large (while minimizing garbage control costs).

## Installation

```
Pkg.clone()
```

## Usage

```
S = ResettableStack{}(Tuple{Float64,Float64,Float64})

push!(S,(0.5,0.4,0.3))
push!(S,(0.5,0.4,0.4))
reset!(S)
push!(S,(0.5,0.4,0.3))
tup = pop!(S)
```
