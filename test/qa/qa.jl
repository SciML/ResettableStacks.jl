using SciMLTesting, ResettableStacks, JET, Test

include("public_docs.jl")

run_qa(ResettableStacks; explicit_imports = true)
