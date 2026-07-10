using Pkg

Pkg.develop(PackageSpec(path = dirname(@__DIR__)))
Pkg.instantiate()

using Documenter
using ResettableStacks

DocMeta.setdocmeta!(ResettableStacks, :DocTestSetup, :(using ResettableStacks); recursive = true)

makedocs(;
    modules = [ResettableStacks],
    authors = "Chris Rackauckas",
    sitename = "ResettableStacks.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true"
    ),
    pages = [
        "Home" => "index.md",
    ],
    checkdocs = :exports
)
