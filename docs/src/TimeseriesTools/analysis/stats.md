```@meta
CurrentModule = TimeseriesTools
```

# Statistics

Statistical helpers for time series. Spike-train statistics (`fano_factor`, `sttc`,
`stoic`) are on the [Spike trains](spiketrains.md) page.

## Variability and dispersion

[`madev`](@ref) is the mean absolute deviation of `x` at a set of lags; unlike the
mean-squared displacement, it remains finite for heavy-tailed processes (e.g. Lévy
flights with α < 2). [`msdist`](@ref) (loaded with `Autocorrelations`) is the
mean-squared displacement. For a regular series both take lags in time units and return a
series indexed by lag.

```@example stats
using TimeseriesTools, Random
Random.seed!(0)
x = Timeseries(cumsum(randn(10000)), 0.0:0.001:9.999)   # a random walk
d = madev(x, 0.001:0.001:0.1)
d[[1, 10, 100]]
```

```@docs
madev
msdist
```

With `Autocorrelations` loaded, its `fftacf` and `dotacf` also accept a `RegularTimeseries`
and return the autocorrelation as a series indexed by lag.

## Bootstrap

Block-bootstrap helpers for time series, loaded with [`Bootstrap`](https://github.com/juliangehring/Bootstrap.jl).

```@docs
bootstrapaverage
bootstrapmean
bootstrapmedian
```

## Complexity measures

Loading [`ComplexityMeasures`](https://github.com/JuliaDynamics/ComplexityMeasures.jl)
lets its `StateSpaceSet` be built from a `ToolsArray`, so the estimators of that package
can be applied to the package's arrays after that conversion.

## Other

```@docs
timescale
```
