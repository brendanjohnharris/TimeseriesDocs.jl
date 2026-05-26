```@meta
CurrentModule = TimeseriesBase
```

# Spectra

Spectrum types mirror the time-series hierarchy: an [`AbstractSpectrum`](@ref) is the
frequency-domain counterpart of a time series, with a frequency dimension ([`𝑓`](@ref) or
[`Log𝑓`](@ref)/[`Log10𝑓`](@ref) for logarithmically spaced spectra) replacing time.
Spectrograms ([`AbstractSpectrogram`](@ref)) carry both a time and a frequency dimension.

```@example spec
using TimeseriesTools, Random
Random.seed!(0)
x = Timeseries(randn(2000), 0.0:0.01:19.99)
S = powerspectrum(x, 0.1)        # see Spectra and spectrograms
S isa UnivariateSpectrum, dims(S)
```

[`Spectrum`](@ref) is the constructor for assembling a spectrum directly from values and
a frequency lookup; in practice spectra are most often produced by
[`powerspectrum`](../analysis/spectra.md)/`energyspectrum`/`waveletspectrogram`.

## Reference

```@docs
AbstractSpectrum
RegularSpectrum
UnivariateSpectrum
MultivariateSpectrum
Spectrum
freqs
AbstractSpectrogram
MultivariateSpectrogram
RegularSpectrogram
```
