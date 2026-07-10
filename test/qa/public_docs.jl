using ResettableStacks
using Test

@testset "Public API documentation" begin
    package_root = normpath(joinpath(@__DIR__, "..", ".."))
    src_dir = joinpath(package_root, "src")
    docs_src_dir = joinpath(package_root, "docs", "src")

    @test startswith(normpath(pathof(ResettableStacks)), src_dir)

    src_text = join(
        String[
            read(joinpath(root, file), String)
                for (root, _, files) in walkdir(src_dir)
                for file in files if endswith(file, ".jl")
        ],
        "\n"
    )
    docs_text = join(
        String[
            read(joinpath(root, file), String)
                for (root, _, files) in walkdir(docs_src_dir)
                for file in files if endswith(file, ".md")
        ],
        "\n"
    )

    @test !occursin(r"(?m)^\s*public\b", src_text)
    @test !occursin(r"@public\b", src_text)
    @test !occursin(r"SciMLPublic", src_text)

    exported_names = setdiff(names(ResettableStacks), [nameof(ResettableStacks)])
    @test sort(exported_names) == [:ResettableStack, :reset!]

    documented_bindings = Set{String}()
    in_docs_block = false
    for line in split(docs_text, '\n')
        stripped = strip(line)
        if startswith(stripped, "```@docs")
            in_docs_block = true
        elseif startswith(stripped, "```")
            in_docs_block = false
        elseif in_docs_block && !isempty(stripped)
            push!(documented_bindings, replace(stripped, "ResettableStacks." => ""))
        end
    end

    @test occursin(
        Regex("(?s)\"\"\"\\s+ResettableStack\\{T, iip\\}.*?\"\"\"\\s+mutable struct ResettableStack"),
        src_text
    )
    @test occursin(
        Regex("(?s)\"\"\"\\s+reset!\\(S::ResettableStack, force_reset = false\\).*?\"\"\"\\s+function reset!"),
        src_text
    )

    for name in exported_names
        @test haskey(Docs.meta(ResettableStacks), Docs.Binding(ResettableStacks, name))
        @test string(name) in documented_bindings
    end
end
