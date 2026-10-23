```@meta
CurrentModule = TimeseriesToolsSurrogates
```

# Surrogates

!!! note "A separate package"
    Surrogate-data methods are not part of `TimeseriesTools`. They live in
    [TimeseriesToolsSurrogates.jl](https://github.com/brendanjohnharris/TimeseriesToolsSurrogates.jl),
    which depends on the (relatively heavy) [TimeseriesSurrogates.jl](https://github.com/JuliaDynamics/TimeseriesSurrogates.jl).
    Keeping it out of the core package means `using TimeseriesTools` stays lightweight.

    ```julia
    using Pkg
    Pkg.add("TimeseriesToolsSurrogates")
    ```

A surrogate is a randomised copy of a data set that preserves some of its properties (its
power spectrum, say, or its distribution of values) while destroying others. Comparing a
statistic on the data with its distribution over surrogates tests whether the data has more
structure than those preserved properties alone can explain.

`TimeseriesToolsSurrogates` re-exports `TimeseriesSurrogates`, so a single import gives both
the standard methods (`RandomShuffle`, `AAFT`, `IAAFT`, …) and the methods added here:

| Method | Input | Preserves |
|---|---|---|
| [`RandomJitter`](@ref) | spike train | the approximate rate |
| [`GammaRenewal`](@ref) | spike train | the mean and variance of the inter-spike intervals |
| [`NDFT`](@ref) | N-dimensional array | the amplitude spectrum |
| [`NDAAFT`](@ref) | N-dimensional array | the amplitude spectrum and the distribution of values |
| [`NDIAAFT`](@ref) | N-dimensional array | both, enforced iteratively |
| [`MVFT`](@ref) | matrix (columns are channels) | each column's spectrum and the cross-spectra between columns |

All use the standard interface: `surrogenerator(x, method)` returns a generator, and calling
it returns a new surrogate each time. When `TimeseriesTools` is also loaded, an extension
makes the methods dispatch directly on `SpikeTrain` and `ToolsArray`, returning the same type
with its dimensions, units and metadata intact.

```@example surr
using TimeseriesTools, TimeseriesToolsSurrogates, Random
Random.seed!(0)
t = 0:0.001:20
x = colorednoise(t; α = 1.0) .+ sin.(2π * 8 .* t)
sg = surrogenerator(x, NDAAFT())
s = sg()                       # a ToolsArray on the same time axis
dims(s) == dims(x)
```

The surrogate shares the power spectrum of the original, 8 Hz peak included, while its
waveform is unrelated:

```@example surr
using CairoMakie, TimeseriesMakie
fig = Figure()
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10, xlabel = "Frequency (Hz)", ylabel = "Power")
lines!(ax, powerspectrum(x, 0.1)[2:end]; label = "original")
lines!(ax, powerspectrum(s, 0.1)[2:end]; label = "NDAAFT surrogate", linestyle = :dash)
axislegend(ax)
fig
```

For spike trains the two methods differ in how much timing they keep. `RandomJitter` moves
each spike by at least `Δt` plus a half-normal displacement of scale `σ`, so a train stays
correlated with its surrogate at coarse resolution; `GammaRenewal` draws an entirely new
train with matched interval statistics.

```@example surr
using Distributions   # enables gammarenewal
st = gammarenewal(400, 2.0, 0.025)
jit = surrogenerator(st, RandomJitter(; Δt = 0.002, σ = 0.005))()
ren = surrogenerator(st, GammaRenewal())()
sttc(st, jit; Δt = 0.02), sttc(st, ren; Δt = 0.02)
```

## Reference

```@docs
RandomJitter
GammaRenewal
NDFT
NDAAFT
NDIAAFT
MVFT
phaserand!
nansubarray
TimeseriesToolsSurrogates.pointprocess!
```

Both `TimeseriesTools` and `TimeseriesToolsSurrogates` export a `pointprocess!`, with the
same meaning; qualify the name if you have both loaded and call it directly.
