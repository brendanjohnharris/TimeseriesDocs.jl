```@meta
CurrentModule = TimeseriesTools
```

# Tutorial

A walkthrough covering the most common operations: construct a series, compute a
spectrum, resample, filter, plot. Most steps need only `TimeseriesTools`; the spectrum
plot uses [`TimeseriesMakie`](../TimeseriesMakie/index.md) and a Makie backend, and
filtering/resampling load their respective extensions on demand.

## Construct a time series

```@example tutorial
using TimeseriesTools, Unitful

t = range(0, 10; step = 0.01) * u"s"
x = Timeseries(sin.(2π * 5 * ustrip.(t)) .+ 0.3randn(length(t)), t) * u"V"
```

The result is a [`UnivariateTimeseries`](@ref) with a [`𝑡`](@ref) (time) dimension. Units
flow through naturally: `unit(eltype(x))` is `V`, `unit(eltype(lookup(x, 𝑡)))` is `s`.

```@example tutorial
samplingrate(x), duration(x)
```

## Compute and plot a power spectrum

```@example tutorial
using CairoMakie, TimeseriesMakie

S = powerspectrum(x, 0.5)         # second argument: minimum frequency to resolve
fig = Figure()
ax = Axis(fig[1, 1])
plotspectrum!(ax, S)
fig
```

See [Spectra and spectrograms](analysis/spectra.md) for `powerspectrum`/`energyspectrum`
options and the wavelet path.

## Resample, upsample, downsample

`resample` evaluates an interpolant onto any target grid. `upsample` is the dense-target
sugar; `downsample` (filter-then-decimate) is the *only* safe way to reduce a sampling rate.

```@example tutorial
using DataInterpolations    # enables interpolation/resampling

y_dense = upsample(x, 4)            # 4× the sampling density
y_grid  = resample(x, 0.05u"s")     # explicit period
```

```@example tutorial
using DSP                           # enables downsample
y_slow  = downsample(x, 5)          # anti-alias filter, then decimate by 5
samplingrate(y_slow)
```

See [Data wrangling: imputation, interpolation, and resampling](analysis/interpolation.md) for the full table,
including `impute` (NaN/missing fill) and N-dimensional joint fits.

## Filter

```@example tutorial
xb = bandpass(x, [4u"Hz", 6u"Hz"])  # extracts the 5 Hz tone
```

See [Filtering and analytic signals](analysis/filtering.md) for `bandpass`/`highpass`/
`lowpass`, the Hilbert transform, instantaneous frequency/phase/amplitude, and
[`phasestitch`](@ref).

## Next steps

- [Arrays and dimensions](base/arrays.md): the `ToolsArray`/`ToolsDimension` data model.
- [Utilities](base/utils.md): `coarsegrain`, `buffer`, `window`, `delayembed`, derivatives, circular statistics.
- [Spike trains](analysis/spiketrains.md): point-process types, spike spectra, [`stoic`](@ref).
- [Extensions reference](extensions.md): which `using` enables which capability.
