using CairoMakie
using Makie
import Makie.Linestyle
using TimeseriesTools
using TimeseriesMakie
using Normalization

using ProgressLogging
using Term
using Dagger
using MoreMaps

using Documenter
using Documenter: Documenter
using Documenter.MarkdownAST
using Documenter.MarkdownAST: @ast
using DocumenterVitepress
using Markdown

ENV["UNITFUL_FANCY_EXPONENTS"] = true

include("docs_blocks.jl")

format = DocumenterVitepress.MarkdownVitepress(;
                                               repo = "github.com/brendanjohnharris/TimeseriesDocs.jl",
                                               devbranch = "main",
                                               devurl = "dev")

timeseriestools = [
    "Introduction" => "TimeseriesTools/index.md",
    "Types" => "TimeseriesTools/types.md",
    "Utils" => "TimeseriesTools/utils.md",
    "Others" => "TimeseriesTools/others.md"
]

timeseriesmakie = ["Introduction" => "TimeseriesMakie/index.md",
    "Recipes" => "TimeseriesMakie/recipes.md",
    "Reference" => "TimeseriesMakie/reference.md"]

normalization = ["Introduction" => "Normalization/index.md",
    "Reference" => "Normalization/reference.md"]

cartographer = ["Introduction" => "MoreMaps/index.md",
    "Backends" => "MoreMaps/backends.md",
    "Progress" => "MoreMaps/progress.md",
    "Leaves" => "MoreMaps/leaf.md",
    "Expansion" => "MoreMaps/expansion.md",
    "Reference" => "MoreMaps/reference.md"]

pages = ["Home" => "index.md",
    "Quick start" => "quickstart.md",
    "TimeseriesTools" => timeseriestools,
    "TimeseriesMakie" => timeseriesmakie,
    "Normalization" => normalization,
    "MoreMaps" => cartographer
]

modules = [TimeseriesTools,
    TimeseriesMakie,
    Normalization,
    MoreMaps,
    Base.get_extension(MoreMaps, :DaggerExt),
    Base.get_extension(MoreMaps, :TermExt),
    Base.get_extension(MoreMaps, :ProgressLoggingExt)]

makedocs(;
         authors = "brendanjohnharris <brendanjohnharris@gmail.com> and contributors",
         sitename = "TimeseriesTools",
         format,
         doctest = false,
         warnonly = [:cross_references],
         modules,
         pages)

DocumenterVitepress.deploydocs(;
                               repo = "github.com/brendanjohnharris/TimeseriesDocs.jl",
                               target = "build", # this is where Vitepress stores its output
                               branch = "gh-pages",
                               devbranch = "main",
                               push_preview = true)
