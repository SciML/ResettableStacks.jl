using SafeTestsets

@safetestset "JET static analysis" include("jet_tests.jl")
@safetestset "ExplicitImports" include("explicitimports_tests.jl")
