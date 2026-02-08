using Documenter
using LibNTL

makedocs(
    sitename = "LibNTL.jl",
    modules = [LibNTL],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://github.com/s-celles/LibNTL.jl"
    ),
    pages = [
        "Home" => "index.md",
        "Types" => "types.md",
        "Tutorial" => "tutorial.md",
        "Examples" => "examples.md",
    ],
    checkdocs = :exports,
    warnonly = false
)

deploydocs(
    repo = "github.com/s-celles/LibNTL.jl.git",
    devbranch = "main",
    push_preview = true
)
