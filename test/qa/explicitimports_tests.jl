using ResettableStacks
using Test
using ExplicitImports

@test check_no_implicit_imports(ResettableStacks) === nothing
@test check_no_stale_explicit_imports(ResettableStacks) === nothing
