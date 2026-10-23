```@meta
CurrentModule = TimeseriesTools
```

# Quick start

## Installation

`TimeseriesTools` holds the data model and the analysis routines. `TimeseriesMakie` adds the
plotting recipes used below, and needs a Makie backend such as `CairoMakie`:

```julia
using Pkg
Pkg.add(["TimeseriesTools", "TimeseriesMakie", "CairoMakie"])
```

## A first time series

The constructor is [`Timeseries`](@ref): the values come first, then the time points.

```@example quickstart
using TimeseriesTools, TimeseriesMakie, CairoMakie

t = 0:0.01:1
x = Timeseries(sin.(2π .* t), t)
```

The result is a labelled vector whose one dimension is time, [`𝑡`](@ref). Its time points
come back with [`times`](@ref), and the sampling rate with [`samplingrate`](@ref):

```@example quickstart
times(x)[1:3], samplingrate(x)
```

With `TimeseriesMakie` loaded, `plot` knows what to draw: `lines` for a series, `heatmap` for
a matrix.

```@example quickstart
plot(x)
```

## A power spectrum

Units are optional, but once attached they flow through every step. Here `colorednoise`
generates brown noise (power falling as ``1/f^2``) with a time axis in seconds and values in
volts, and [`powerspectrum`](@ref) returns a spectrum in ``\mathrm{V^2/Hz}``:

```@example quickstart
using Unitful

t = range(0, 100; step = 0.005) * u"s"   # 100 s at 200 Hz
x = colorednoise(t; α = 2.0) * u"V"
plot(x[1:2000])
```

```@example quickstart
S = powerspectrum(x, 0.1)   # second argument: the lowest frequency to resolve
plotspectrum(S)
```

`plotspectrum` is a `TimeseriesMakie` helper that sets log axes and reads the labels from the
units. The spectrum itself is another labelled array, indexed by frequency:

```@example quickstart
freqs(S)[1:3], unit(eltype(S))
```

## Where next

- The [Tutorial](TimeseriesTools/tutorial.md) continues from here: resampling, filtering, and
  the analytic signal.
- [Time series](TimeseriesTools/base/timeseries.md) explains the type hierarchy that the
  analysis functions dispatch on.
- [Recipes](TimeseriesMakie/recipes.md) shows every `TimeseriesMakie` plot with an example.
