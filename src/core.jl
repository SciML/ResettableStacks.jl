mutable struct ResettableStack{T}
  data::Vector{T}
  cur::Int
  numResets::Int
end

ResettableStack(ty::Type{T}) where {T} = ResettableStack{T}(Vector{T}(),0,0)

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

safecopy(x) = copy(x)
safecopy(x::Union{Number,StaticArray}) = x
safecopy(x::Nothing) = nothing

# For DiffEqNoiseProcess S₂ fast updates
function copyat_or_push!(S::ResettableStack,x)
  if S.cur==length(S.data)
    S.cur+=1
    push!(S.data,safecopy.(x))
  else
    S.cur+=1
    curx = S.data[S.cur]
    if typeof(curx[2]) <: Union{Number,SArray}
      S.data[S.cur] = x
    else
      curx[2] .= x[2]
      if x[3] != nothing
        curx[3] .= x[3]
      end
      S.data[S.cur] = (x[1],curx[2],curx[3])
    end
  end
  nothing
end

function pop!(S::ResettableStack)
  S.cur-=1
  S.data[S.cur+1]
end

start(S::ResettableStack) = S.cur
function next(S::ResettableStack,s)
  s -= 1
  (S.data[s+1],s)
end
done(S::ResettableStack,s) = s==0

function reset!(S::ResettableStack,force_reset = false)
  S.numResets += 1
  S.cur = 0
  if length(S.data) > 5 && (S.numResets%FULL_RESET_COUNT==0 || force_reset)
    resize!(S.data,max(length(S.data)÷2,5))
  end
  nothing
end
