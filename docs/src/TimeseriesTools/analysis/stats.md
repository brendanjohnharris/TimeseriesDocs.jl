```@meta
CurrentModule = TimeseriesTools
```

# Statistics

A grab-bag of statistical helpers for time series.

## Variability and dispersion

[`madev`](@ref) is the mean absolute deviation of `x` at a set of lags; unlike the
mean-squared displacement, it remains finite for heavy-tailed processes (e.g. Lévy
flights with α < 2). [`msdist`](@ref) (loaded with `Autocorrelations`) is the
mean-squared displacement.

```@docs
madev
msdist
```

## Bootstrap

Block-bootstrap helpers for time series, loaded with [`Bootstrap`](https://github.com/juliangehring/Bootstrap.jl).

```@docs
bootstrapaverage
bootstrapmean
bootstrapmedian
```

## Complexity measures

Loaded with [`ComplexityMeasures`](https://github.com/JuliaDynamics/ComplexityMeasures.jl).
Each `ProbabilitiesEstimator`/`InformationMeasure` from that package can be applied to
an `AbstractTimeseries` directly.

## Other

```@docs
fanofactor
timescale
```
