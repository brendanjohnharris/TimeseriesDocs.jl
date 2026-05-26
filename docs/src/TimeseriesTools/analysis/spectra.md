```@meta
CurrentModule = TimeseriesTools
```

# Spectra and spectrograms

[`powerspectrum`](@ref) and [`energyspectrum`](@ref) compute one-sided spectra of regular
time series via the FFT, returning an [`AbstractSpectrum`](@ref) whose lookup is
frequency. Units carry through: a `V`-valued series sampled in `s` returns `V^2/Hz` for
the power spectrum.

```@example spec
using TimeseriesTools, Random
Random.seed!(0)
x = Timeseries(sin.(2π * 5 .* (0.0:0.001:9.999)) .+ 0.2randn(10000), 0.0:0.001:9.999)
S = powerspectrum(x, 0.1)
```

The second argument is the minimum frequency to resolve (lower → longer windows). When
the input is multivariate, each column is spectrally analysed independently and the
result keeps the foreign dimensions.

## Wavelet spectrograms

`waveletspectrogram` (enabled by `using ContinuousWavelets`) returns an
[`AbstractSpectrogram`](@ref) with both time and frequency dimensions. A CUDA backend is
available via `using CUDA, ContinuousWavelets`. See [Extensions](../extensions.md).

```julia
using ContinuousWavelets
W = waveletspectrogram(x; β = 1.0)
```

## Reference

```@docs
powerspectrum
energyspectrum
waveletspectrogram
```
