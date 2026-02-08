using Documenter
using LibNTL

makedocs(
    sitename = "LibNTL.jl",
    modules = [LibNTL],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://s-celles.github.io/LibNTL.jl"
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
