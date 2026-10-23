```@meta
CurrentModule = TimeseriesTools
```

# Spectra and spectrograms

[`powerspectrum`](@ref) and [`energyspectrum`](@ref) compute one-sided spectra of regular
time series via Welch's method: the series is cut into overlapping Hann-windowed segments,
each is Fourier transformed, and the segment spectra are averaged. The result is an
[`AbstractSpectrum`](@ref) whose lookup is frequency. Units carry through: a `V`-valued
series sampled in `s` returns `V^2/Hz` for the power spectrum.

```@example spec
using TimeseriesTools, Random, Statistics
Random.seed!(0)
t = 0.0:0.001:9.999
x = Timeseries(sin.(2π * 5 .* t) .+ 0.2randn(length(t)), t)
S = powerspectrum(x, 0.1)
```

The second argument is the lowest frequency to resolve: it sets the segment length to
`samplingrate / f_min` samples, so a lower `f_min` means longer segments, finer frequency
spacing, and fewer segments to average over. The default resolves down to
`samplingrate(x) / min(length(x) ÷ 4, 1000)`.

```@example spec
freqs(S)[2] - freqs(S)[1]      # the frequency spacing equals f_min
```

The power spectrum is the energy spectrum divided by the duration of each segment, so it
measures power per unit frequency rather than the total energy. `spectrum` is an alias for
`powerspectrum`.

## Multivariate series

When the input is multivariate, each column is analysed independently and the result keeps
the other dimensions, giving a [`MultivariateSpectrum`](@ref):

```@example spec
m = Timeseries(randn(10000, 3), t, Var([:a, :b, :c]))
Sm = powerspectrum(m, 0.5)
dims(Sm)
```

## Windowed spectra

[`_energyspectrum`](@ref) and [`_powerspectrum`](@ref) return the spectrum of every segment
before averaging, with the segments along a second `window` dimension. Use them to inspect
the spread across segments, or to average with something other than the mean.

```@example spec
W = _powerspectrum(x, 0.1)
size(W)
```

## Test signals

[`colorednoise`](@ref) generates a power-law noise with a specified exponent on a given time
range, and is used throughout these pages as a test signal:

```@example spec
using CairoMakie, TimeseriesMakie
pink = colorednoise(0.0:0.001:100.0; α = 1.0)   # power ∝ 1/f
plotspectrum(powerspectrum(pink, 0.1))
```

## Log-frequency sampling

A linear-frequency spectrum packs most of its samples into the high-frequency decades,
where periodogram noise is also largest. [`logsample`](@ref) bins the spectrum into equal
widths in log frequency and averages within each bin, equalising the sample density across
decades and averaging down the noise; [`logbin`](@ref) does the binning without the
reduction. The bin width is the spacing of the first two frequencies in log space, so the
lower edge of the input decides how fine the result is: start the spectrum a few steps above
its resolution rather than at the very first bin.

```@example spec
P = powerspectrum(pink, 0.1)
L = logsample(P[𝑓 = 1 .. 500])
length(P), length(L)
```

```@example spec
fig = Figure()
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10, xlabel = "Frequency (Hz)", ylabel = "Power")
lines!(ax, collect(freqs(P))[2:end], collect(parent(P))[2:end]; color = (:gray, 0.5), label = "linear")
scatter!(ax, collect(lookup(L, 𝑓)), collect(parent(L)); label = "logsample")
axislegend(ax)
fig
```

This is the recommended preprocessing before fitting a [`MAPPLE`](@ref) model; see
[Peaks and spectral fitting](peaks.md).

## Wavelet spectrograms

[`waveletspectrogram`](@ref) (enabled by `using ContinuousWavelets`) computes a continuous
wavelet transform and returns a spectrogram with both time and frequency dimensions. The
coefficients are complex; take `abs` for the amplitude envelope at each frequency. A
`MultivariateTimeseries` is transformed in one batch, giving a time × frequency × variable
array, and data held on a GPU (as a `CuArray`) stays there.

```@example wavelet
using TimeseriesTools, ContinuousWavelets, CairoMakie
t = 0:0.002:4
x = Timeseries(sin.(2π * 5 .* t) .+ (t .> 2) .* sin.(2π * 20 .* t), t)   # 20 Hz joins at 2 s
W = waveletspectrogram(x; pass = 40)   # keep frequencies up to 40 Hz
dims(W)
```

```@example wavelet
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = "Time (s)", ylabel = "Frequency (Hz)")
heatmap!(ax, times(W), freqs(W), parent(abs.(W)))
fig
```

`moth` selects the mother wavelet (default `Morlet(2π)`), `Q` the number of voices per octave,
and `β` the spacing of the scales.

## Reference

```@docs
powerspectrum
energyspectrum
_powerspectrum
_energyspectrum
colorednoise
logsample
logbin
waveletspectrogram
```
