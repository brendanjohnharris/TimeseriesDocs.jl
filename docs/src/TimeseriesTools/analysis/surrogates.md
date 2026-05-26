```@meta
CurrentModule = TimeseriesTools
```

# Surrogates

!!! note "Now a separate package"
    Surrogate-data methods are no longer part of `TimeseriesTools`. They live in
    [TimeseriesToolsSurrogates.jl](https://github.com/brendanjohnharris/TimeseriesToolsSurrogates.jl),
    which depends on the (relatively heavy) [TimeseriesSurrogates.jl](https://github.com/JuliaDynamics/TimeseriesSurrogates.jl).
    Keeping it out of the core package means `using TimeseriesTools` stays lightweight.

`TimeseriesToolsSurrogates` re-exports `TimeseriesSurrogates`, so a single import gives
both the standard methods (FT, AAFT, IAAFT, …) and the additional spike-train,
multivariate, and N-dimensional methods (`RandomJitter`, `GammaRenewal`, `NDFT`,
`NDAAFT`, `NDIAAFT`, `MVFT`). When `TimeseriesTools` is also loaded, its extension makes
the methods dispatch directly on `SpikeTrain` and `ToolsArray`, returning the same type.

```julia
using TimeseriesToolsSurrogates    # re-exports TimeseriesSurrogates
using TimeseriesTools              # enables the typed methods via an extension

x = Timeseries(randn(101, 101), 𝑡(1:101), Var(1:101))
s = surrogenerator(x, NDAAFT())()  # returns a ToolsArray with the same dimensions
```

See the [TimeseriesToolsSurrogates documentation](https://github.com/brendanjohnharris/TimeseriesToolsSurrogates.jl)
for the full method list.
