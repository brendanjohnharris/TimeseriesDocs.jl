```@meta
CurrentModule = TimeseriesTools
```

# Spike trains

A [`SpikeTrain`](@ref) is a point-process series whose lookup is the vector of spike
times and whose values are absent (`Bool` or trivially `true`). Multivariate spike
trains store a vector of trains, one per channel/unit.

```@example spike
using TimeseriesTools, Distributions, Random
Random.seed!(0)
spikes = sort(cumsum(rand(Exponential(0.05), 200)))   # ISI ~ 50 ms
st = spiketrain(spikes)
```

## Spike spectra

A power spectrum of a spike train can be computed via the autocovariance function
(`using Autocorrelations`), giving a frequency-domain summary of rate fluctuations.

## Pairwise similarity

[`stoic`](@ref) computes the spike-time tiling coefficient (Cutts & Eglen, 2014) and
related spike-time covariance measures, pairwise across channels.

## Surrogates

Spike-train surrogate methods (`RandomJitter`, `GammaRenewal`, …) live in the separate
[TimeseriesToolsSurrogates.jl](https://github.com/brendanjohnharris/TimeseriesToolsSurrogates.jl)
package; see [Surrogates](surrogates.md).

## Reference

```@docs
SpikeTrain
UnivariateSpikeTrain
MultivariateSpikeTrain
spiketrain
spiketimes
stoic
pointprocess!
```
