using Pkg

using SafeTestsets
using Test

const GROUP = get(ENV, "GROUP", "All")

if GROUP == "QA"
    Pkg.activate(joinpath(@__DIR__, "qa"))
    Pkg.develop(path = joinpath(@__DIR__, ".."))
    Pkg.instantiate()
    include(joinpath(@__DIR__, "qa", "qa.jl"))
end

if GROUP in ("All", "Core")
    @safetestset "Core" include("test_core.jl")
    @safetestset "Iterator" include("test_iterator.jl")
    @safetestset "eltype" include("test_eltype.jl")
    @safetestset "BigFloat support" include("test_bigfloat.jl")
    @safetestset "JLArray support" include("test_jlarray.jl")
    @safetestset "copyat_or_push! interface" include("test_copyat_or_push.jl")
    @safetestset "ArrayInterface compatibility" include("test_arrayinterface.jl")
end
