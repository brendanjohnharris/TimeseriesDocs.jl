```@meta
CurrentModule = TimeseriesTools
```

# Spike trains

A [`SpikeTrain`](@ref) is a point-process series whose lookup is the vector of spike
times and whose values are all `true`: the spike times carry all of the information, and
[`spiketimes`](@ref) returns them. A `MultivariateSpikeTrain` is a `Bool` matrix over time
and neuron.

[`spiketrain`](@ref) builds one from a vector of times. With `Distributions` loaded,
[`gammarenewal`](@ref) simulates a renewal process whose inter-spike intervals are gamma
distributed, and [`pointprocess!`](@ref) does the same for any distribution of intervals.

```@example spike
using TimeseriesTools, Distributions, Random, Statistics
Random.seed!(0)
st = gammarenewal(400, 2.0, 0.025)   # 400 spikes; shape 2, scale 25 ms, so a mean interval of 50 ms
```

```@example spike
spiketimes(st)[1:5], length(st) / duration(st)   # the first spike times, and the mean rate
```

## Spike spectra

[`powerspectrum`](@ref) and [`energyspectrum`](@ref) accept a spike train, given the
frequency range to evaluate. By default the spectrum is the Fourier transform of the spike
train's autocovariance, estimated with the [`stoic`](@ref) kernel; `method = :schild` instead
evaluates the Fourier transform of the point process directly (Schild, 1982). A gamma renewal
process with shape 2 is more regular than a Poisson process, which shows as a dip in power at
low frequency:

```@example spike
using CairoMakie, TimeseriesMakie
S = powerspectrum(st, 0:0.5:60; method = :schild)
plot(S; axis = (; xlabel = "Frequency (Hz)", ylabel = "Power"))
```

## Variability

[`fano_factor`](@ref) is the variance-to-mean ratio of the spike counts in bins of a given
width; `1` is Poisson-like, and a renewal process with a regular interval falls below it.
Given no bin widths it evaluates a hundred of them, logarithmically spaced, and returns a
series indexed by bin width:

```@example spike
F = fano_factor(st)
lines(F; axis = (; xscale = log10, xlabel = "Bin width (s)", ylabel = "Fano factor"))
```

[`convolve`](@ref) smooths a spike train with a kernel, returning a function of time that
evaluates the resulting rate estimate. (`Distributions` also exports a `convolve`, so with
both loaded write `TimeseriesTools.convolve`.)

## Pairwise similarity

Two measures of how closely two spike trains follow each other. [`sttc`](@ref) is the
spike-time tiling coefficient (Cutts & Eglen, 2014): the fraction of spikes in each train
that fall within `Δt` of a spike in the other, corrected for the fraction of time the
windows tile. [`stoic`](@ref) is the overlap-integral coefficient (Schreiber et al., 2003):
the normalised inner product of the two trains after convolution with a Gaussian of width
`σ`. Both accept spike trains or plain vectors of sorted times, and given a vector of trains
return the pairwise matrix.

```@example spike
jittered = spiketrain(spiketimes(st) .+ 0.003 .* randn(length(st)))   # the same train, shifted by ~3 ms
independent = gammarenewal(400, 2.0, 0.025)
(sttc(st, jittered; Δt = 0.01), sttc(st, independent; Δt = 0.01)),
(stoic(st, jittered; σ = 0.01), stoic(st, independent; σ = 0.01))
```

`sttc` is corrected for chance, so independent trains score near zero. `stoic` is an inner
product of smoothed, non-negative rates, so two independent trains at the same rate score
well above zero; judge it against surrogates (see [Surrogates](surrogates.md)) rather than
against zero.

[`closeneighbours`](@ref) is the building block behind both: a sparse matrix of the time
differences between every pair of spikes closer than `Δt`.

## Surrogates

Spike-train surrogate methods (`RandomJitter`, `GammaRenewal`) live in the separate
[TimeseriesToolsSurrogates.jl](https://github.com/brendanjohnharris/TimeseriesToolsSurrogates.jl)
package; see [Surrogates](surrogates.md).

## Reference

```@docs
SpikeTrain
spiketrain
spiketimes
gammarenewal
gammarenewal!
pointprocess!
sttc
stoic
closeneighbours
convolve
fano_factor
```

`UnivariateSpikeTrain` and `MultivariateSpikeTrain` are the one- and two-dimensional
versions of `SpikeTrain`.
