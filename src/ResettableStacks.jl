__precompile__()

module ResettableStacks

  const FULL_RESET_COUNT = 10000

  import Base: isempty, length, push!, pop!, start, next, done
  type ResettableStack{T}
    data::Vector{T}
    cur::Int
    numResets::Int
  end

  ResettableStack{T}(ty::Type{T}) = ResettableStack{T}(Vector{T}(),0,0)

  isempty(S::ResettableStack) = S.cur==0
  length(S::ResettableStack)  = S.cur

  function push!(S::ResettableStack,x)
    if S.cur==length(S.data)
      S.cur+=1
      push!(S.data,x)
    else
      S.cur+=1
      S.data[S.cur]=x
    end
    nothing
  end

  function pop!(S::ResettableStack)
    if S.cur==length(S.data)
      S.cur-=1
      pop!(S.data)
    else
      S.cur-=1
      S.data[S.cur+1]
    end
  end

  start(S::ResettableStack) = S.cur
  function next(S::ResettableStack,s)
    s -= 1
    (S.data[s+1],s)
  end
  done(S::ResettableStack,s) = s==0

  function reset!(S::ResettableStack)
    S.numResets += 1
    S.cur = 0
    if S.numResets%FULL_RESET_COUNT==0
      S.data = Vector{eltype(S.data)}()
    end
    nothing
  end

  export ResettableStack, reset!
end # module
