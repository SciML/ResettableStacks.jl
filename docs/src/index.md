# ResettableStacks.jl

## Overview

`ResettableStacks.jl` provides a stack type whose storage can be reused across resets.

## Installation

```julia
using Pkg
Pkg.add("ResettableStacks")
```

## Usage

```julia
using ResettableStacks

S = ResettableStack{true}(Tuple{Float64, Float64, Float64})
push!(S, (0.5, 0.4, 0.3))
push!(S, (0.5, 0.4, 0.4))
reset!(S)
push!(S, (0.5, 0.4, 0.3))
tup = pop!(S)
```

## API

```@docs
ResettableStack
reset!
```
