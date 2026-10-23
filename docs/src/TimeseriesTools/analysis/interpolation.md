```@meta
CurrentModule = TimeseriesTools
```

# Data wrangling: imputation, interpolation, and resampling

Five functions cover the regridding/cleaning surface. Each is a thin dispatch layer in
core; the implementations live in extensions, so `using` the right backend is mandatory.

| Function | What it does | Loads from | Aliases? |
|---|---|---|---|
| [`interpolate`](@ref) | Fit an interpolant to a series | `DataInterpolations`; or `DataInterpolationsND` for joint multi-axis | n/a |
| [`upsample`](@ref) | Increase sampling density (`factor`) | `DataInterpolations` (thin `resample` wrapper) | never |
| [`resample`](@ref) | Evaluate an interpolant on an arbitrary new grid | `DataInterpolations`; ND variant via `DataInterpolationsND` | only if target is coarser than source |
| [`downsample`](@ref) | Reduce the sampling rate by an integer factor | `DSP` | no, when `antialias = true` (default); yes, when `false` |
| [`impute`](@ref) | Fill NaN/`missing`/flagged entries by interpolation | `DataInterpolations` | n/a |

## 1-D `interpolate`/`upsample`/`resample`

```@example interp
using TimeseriesTools, DataInterpolations
t = 0:0.25:10
x = Timeseries(sinc.(t .- 5), t)
itp = interpolate(x, AkimaInterpolation)    # any DataInterpolations type works
itp(5.1)
```

```@example interp
y1 = upsample(x, 4)                         # 4× the sampling density
y2 = resample(x, 0.1)                       # explicit new period
y3 = resample(x, [0.3, 2.7, 9.9])           # arbitrary target points
samplingperiod(y1), samplingperiod(y2), times(y3)
```

`resample` accepts an `AbstractVector`, a `Dimension`, or a `Number` (interpreted as a
sampling period). Multivariate input is handled per-slice along `dims = 1` (the time
axis); units flow through both the values and the time lookup.

```@example interp
using CairoMakie, TimeseriesMakie
fig = Figure()
ax = Axis(fig[1, 1])
lines!(ax, y1; label = "upsample ×4")
scatter!(ax, x; markersize = 12, label = "samples")
scatter!(ax, y3; marker = :xcross, markersize = 16, label = "resample at points")
axislegend(ax)
fig
```

## `downsample`

`downsample` is in [`DSPExt`](../extensions.md) and is the **only spectrally-correct way
to reduce a sampling rate**. It applies a polyphase anti-aliasing FIR filter, then
decimates by an integer factor.

```@example down
using TimeseriesTools, DSP
t = 0:0.001:4
x = Timeseries(sin.(2π * 3 .* t) .+ sin.(2π * 130 .* t), t)   # 3 Hz and 130 Hz, sampled at 1 kHz
y = downsample(x, 10)                   # antialias = true (default): new rate 100 Hz
z = downsample(x, 10; antialias = false)  # plain x[1:10:end]
samplingrate(y), samplingrate(z)
```

Two distinct intents are supported via the `antialias` keyword:

- `antialias = true` (default): filter then decimate. Use for a faithful low-rate
  **representation** of the kept band — the honest "lower the rate" operation.
- `antialias = false`: plain decimation. Use to **simulate having physically sampled** the
  process at a lower rate (aliasing and all). The fold-back is the real acquisition
  behaviour you're reproducing.

The 130 Hz tone is above the new Nyquist frequency of 50 Hz. The anti-aliasing filter removes
it; plain decimation folds it back to 30 Hz, where it is indistinguishable from a real 30 Hz
component:

```@example down
using CairoMakie, TimeseriesMakie
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = "Frequency (Hz)", ylabel = "Power", yscale = log10)
lines!(ax, powerspectrum(y, 1.0); label = "antialias = true")
lines!(ax, powerspectrum(z, 1.0); label = "antialias = false", linestyle = :dash)
axislegend(ax)
fig
```

Neither `resample` to a coarser grid nor `x[1:N:end]` includes anti-aliasing: they
silently fold high-frequency content into your kept band.

## `impute`

Fill flagged entries (default `[NaN, Nothing, Missing]`) by interpolation.

```@example interp
v = sin.(0.0:0.1:9.9); v[30:35] .= NaN
g = Timeseries(v, 0.0:0.1:9.9)
h = impute(g)                                          # NaNs filled by Akima fit
count(isnan, g), count(isnan, h)
```

```julia
impute(g; replace = [NaN, Nothing, Missing, Complex])  # also flag complex values
```

`replace` accepts sentinel values (matched by `isequal`, with `NaN` matched by `isnan`)
and types (matched by `isa`). The mechanism is mask → `missing` →
`DataInterpolations.munge_data` drops the masked pairs → interpolant fit to survivors →
evaluated at every original time point. For arrays of more than one dimension, each
slice along `dims = 1` is imputed independently.

## Joint N-dimensional interpolation

For *grid* data where you want a single interpolant over multiple axes (rather than
per-axis), load `DataInterpolationsND`:

```julia
using DataInterpolationsND
X   = Timeseries(rand(11, 9), 𝑡(0:0.5:5.0), Var(0:0.5:4.0))
itp = interpolate(X, LinearInterpolationDimension)   # joint over both axes
Y   = upsample(X, 2, LinearInterpolationDimension)   # joint, not separable
```

`LinearInterpolationDimension` and `ConstantInterpolationDimension` pass through the
samples. `BSplineInterpolationDimension` uses the data as B-spline *control points* (not
samples) and so smooths rather than interpolates for `degree > 1` — see the docstring.
The ND path requires a **complete (gap-free) grid**: use `impute` first if needed, then
ND-regrid.

For scattered two-dimensional data, `using NaturalNeighbours` gives `interpolate` a method
for a matrix that fits a natural-neighbour (Sibson) interpolant over both axes.

## Reference

```@docs
interpolate
upsample
resample
downsample
impute
```
