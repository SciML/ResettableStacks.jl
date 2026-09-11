using ResettableStacks, BenchmarkTools

const SUITE = BenchmarkGroup()

function filled_stack(n)
    s = ResettableStack(Float64)
    for i in 1:n
        push!(s, Float64(i))
    end
    return s
end

# =============================================================================
# ResettableStack operations
# =============================================================================

SUITE["stack"] = BenchmarkGroup()

SUITE["stack"]["push!"] = @benchmarkable push!(s, 1.5) setup = (
    s = ResettableStack(
        Float64
    )
)
SUITE["stack"]["pop!"] = @benchmarkable pop!(s) setup = (s = filled_stack(1000))
SUITE["stack"]["push_pop"] = @benchmarkable begin
    s = ResettableStack(Float64)
    for i in 1:1000
        push!(s, i * 1.0)
    end
    for _ in 1:500
        pop!(s)
    end
end

SUITE["stack"]["reset!"] = @benchmarkable reset!(s) setup = (
    s = filled_stack(1000)
)
SUITE["stack"]["copyat_or_push!"] = @benchmarkable copyat_or_push!(s, 5.0) setup = (
    s = filled_stack(10)
)
