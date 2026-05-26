```@meta
CurrentModule = TimeseriesTools
```

# Filtering and analytic signals

`bandpass`/`highpass`/`lowpass` apply zero-phase Butterworth filters (default order 4)
when [`DSP`](https://github.com/JuliaDSP/DSP.jl) is loaded. Without `DSP`, these are
identity functions and warn. Per-column operation on multivariate series.

```julia
using TimeseriesTools, DSP, Unitful
xb = bandpass(x, [4u"Hz", 6u"Hz"])
xl = lowpass(x, 50u"Hz")
```

## Analytic signal

The Hilbert transform yields the analytic signal; from it,
[`analyticphase`](@ref)/[`analyticamplitude`](@ref)/[`instantaneousfreq`](@ref) follow
trivially. `analyticphase` returns the unwrapped phase; `instantaneousfreq` (alias
`instantfreq`) returns its time derivative in Hz.

```julia
ϕ = analyticphase(xb)
A = analyticamplitude(xb)
f = instantaneousfreq(xb)
```

[`phasestitch`](@ref) concatenates multiple time series at phase-matched points,
suppressing edge transients. [`generalizedphase`](@ref) (loaded with
`GeneralizedPhase`) is a multi-channel phase estimator robust to broadband signals.

## Reference

```@docs
bandpass
highpass
lowpass
hilbert
analyticphase
analyticamplitude
instantaneousfreq
instantfreq
phasestitch
isoamplitude
```
