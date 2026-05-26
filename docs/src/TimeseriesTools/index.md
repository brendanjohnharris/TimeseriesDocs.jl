```@meta
CurrentModule = TimeseriesTools
```

# [TimeseriesTools.jl](https://www.github.com/brendanjohnharris/TimeseriesTools.jl)

`TimeseriesTools.jl` is the top-level package of the `Timeseries*` family. It bundles a
core data model with a collection of analysis routines, and re-exports both
[`TimeseriesBase.jl`](https://github.com/brendanjohnharris/TimeseriesBase.jl) (the type
hierarchy, IO, and basic utilities) and [`Normalization.jl`](https://github.com/brendanjohnharris/Normalization.jl).
Heavier analysis lives behind package extensions, so the core load stays light.

## Installation

```julia
using Pkg
Pkg.add("TimeseriesTools")
```

## Package map

| Layer | Source | What it provides |
|---|---|---|
| Core types and utilities | [`TimeseriesBase`](base/timeseries.md) (re-exported) | `Timeseries`, `Spectrum`, custom dimensions, `times`/`samplingrate`, `coarsegrain`/`buffer`/`window`, derivatives, IO |
| Tools (this package) | [`TimeseriesTools`](analysis/spectra.md) | Spectra, spike trains, MAPPLE spectral fitting, and a thin dispatch layer for the extensions below |
| Optional extensions | Loaded by `using X` | DSP filtering, wavelets, interpolation/resampling, complexity, … see [Extensions](extensions.md) |
| Plotting | [`TimeseriesMakie`](../TimeseriesMakie/index.md) | Makie recipes for series, spectra, spike rasters, trajectories |

## Sections

- [Tutorial](tutorial.md): build a time series, take a spectrum, resample, plot.
- **Core types and utilities** (re-exported from `TimeseriesBase`):
  - [Arrays and dimensions](base/arrays.md), [Time series](base/timeseries.md), [Spectra](base/spectra.md)
  - [Unitful integration](base/unitful.md), [Dates](base/dates.md)
  - [Utilities](base/utils.md), [Operators](base/operators.md), [IO](base/io.md)
- **Analysis** (provided by `TimeseriesTools` and its extensions):
  - [Spectra and spectrograms](analysis/spectra.md), [Filtering and analytic signals](analysis/filtering.md)
  - [Data wrangling: imputation, interpolation, and resampling](analysis/interpolation.md)
  - [Spike trains](analysis/spiketrains.md), [Surrogates](analysis/surrogates.md) (separate package)
  - [Peaks and spectral fitting](analysis/peaks.md), [Statistics](analysis/stats.md)
- [Extensions reference](extensions.md): which `using` enables which capability.

## Where to next?

[TimeseriesMakie](../TimeseriesMakie/index.md) provides Makie recipes for time series,
spectra, spike rasters, and trajectories. See the [Tutorial](tutorial.md) for an
end-to-end walkthrough.
