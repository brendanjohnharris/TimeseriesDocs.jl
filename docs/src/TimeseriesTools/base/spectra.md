```@meta
CurrentModule = TimeseriesBase
```

# Spectra

Spectrum types mirror the time-series hierarchy: an [`AbstractSpectrum`](@ref) is the
frequency-domain counterpart of a time series, with a frequency dimension ([`𝑓`](@ref))
replacing time. Spectrograms carry both a time and a frequency dimension.

```@example spec
using TimeseriesTools, Random
Random.seed!(0)
x = Timeseries(randn(2000), 0.0:0.01:19.99)
S = powerspectrum(x, 0.1)        # see Spectra and spectrograms
S isa UnivariateSpectrum, dims(S)
```

[`Spectrum`](@ref) is the constructor for assembling a spectrum directly from values and
a frequency lookup; in practice spectra are most often produced by
[`powerspectrum`](../analysis/spectra.md), `energyspectrum`, or `waveletspectrogram`.
[`freqs`](@ref) returns the frequency lookup, as [`times`](@ref) does for time.

```@example spec
freqs(S)[1:4]
```

The two logarithmic dimensions, [`Log𝑓`](@ref) and [`Log10𝑓`](@ref), hold `log(f)` and
`log10(f)` rather than `f`. They are not `FrequencyDim`s, so an array indexed by one is not
an `AbstractSpectrum`; they exist for fitting and plotting in log-frequency space (see
[Peaks and spectral fitting](../analysis/peaks.md)).

## Spectrograms

A spectrogram is a `ToolsArray` whose first dimension is time and whose second is frequency.
The aliases follow the same pattern as the spectra, and have no docstrings of their own:

| Alias | Dimensions |
|---|---|
| `AbstractSpectrogram` | `(𝑡, 𝑓, ...)` |
| `RegularSpectrogram` | as above, with a regularly sampled time axis |
| `MultivariateSpectrogram` | `(𝑡, 𝑓, Var)`: one spectrogram per variable |

`waveletspectrogram` returns a `RegularSpectrogram`; see
[Spectra and spectrograms](../analysis/spectra.md#Wavelet-spectrograms).

## Reference

```@docs
AbstractSpectrum
RegularSpectrum
UnivariateSpectrum
MultivariateSpectrum
Spectrum
freqs
```
