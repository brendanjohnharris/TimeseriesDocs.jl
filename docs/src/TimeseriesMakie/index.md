```@meta
CurrentModule = TimeseriesMakie
```

# [TimeseriesMakie](https://www.github.com/brendanjohnharris/TimeseriesMakie.jl)

[TimeseriesMakie.jl](https://github.com/brendanjohnharris/TimeseriesMakie.jl) provides plotting recipes and visualization tools for time series data, using [Makie.jl](https://github.com/MakieOrg/Makie.jl).

## Installation

```julia
using Pkg
Pkg.add("TimeseriesMakie")
Pkg.add("CairoMakie") # Choose a Makie backend (CairoMakie, GLMakie, WGLMakie, etc.)
using TimeseriesMakie, CairoMakie
```

To improve the display of unitful exponents, you can enable fancy exponents with:
```julia
ENV["UNITFUL_FANCY_EXPONENTS"] = true
```

## What's in the box?

| Recipe | Draws |
|---|---|
| [`trajectory`](@ref) | a 2-D or 3-D path, coloured by speed, time, or your own values |
| [`shadows`](@ref) | projections of a 3-D path onto the enclosing axis panes |
| [`traces`](@ref) | the columns of a matrix, stacked or offset along `y` |
| [`trail`](@ref) | a path that fades into the past, for animation |
| [`kinetic`](@ref) | a path whose width follows the data |
| [`spikeraster`](@ref) | one marker per spike, over (time, neuron) |
| [`psth`](@ref) | a peri-stimulus time histogram of pooled spike times |
| [`ratemap`](@ref) | per-neuron firing rate as a heatmap |
| [`spectrumplot`](@ref) | a power spectrum, with its peaks optionally marked |

The [Recipes](recipes.md) page has an example of each; [Reference](reference.md) lists every
attribute.

With `TimeseriesTools` loaded, the spike recipes and `spectrumplot` also accept labelled
`ToolsArray` inputs and read their time and frequency axes from the lookups. Plotting a
`ToolsArray` directly picks a sensible plot type too: `lines` for a series, `heatmap` for a
matrix, and `volume` for a three-dimensional array.