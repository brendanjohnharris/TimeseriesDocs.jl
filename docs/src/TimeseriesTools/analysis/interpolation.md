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

```julia
using TimeseriesTools, DataInterpolations
x  = Timeseries(sinc.(-π:0.1:π), -π:0.1:π)
itp = interpolate(x, AkimaInterpolation)    # any DataInterpolations type works
y1  = upsample(x, 4)                        # 4× the sampling density
y2  = resample(x, 0.05)                     # explicit new period
y3  = resample(x, [0.0, 0.5, 1.2])          # arbitrary target points
```

`resample` accepts an `AbstractVector`, a `Dimension`, or a `Number` (interpreted as a
sampling period). Multivariate input is handled per-slice along `dims = 1` (the time
axis); units flow through both the values and the time lookup.

## `downsample`

`downsample` is in [`DSPExt`](../extensions.md) and is the **only spectrally-correct way
to reduce a sampling rate**. It applies a polyphase anti-aliasing FIR filter, then
decimates by an integer factor.

```julia
using DSP
y = downsample(x, 4)                  # antialias = true (default)
z = downsample(x, 4; antialias=false) # plain x[1:4:end], aliases — see below
```

Two distinct intents are supported via the `antialias` keyword:

- `antialias = true` (default): filter then decimate. Use for a faithful low-rate
  **representation** of the kept band — the honest "lower the rate" operation.
- `antialias = false`: plain decimation. Use to **simulate having physically sampled** the
  process at a lower rate (aliasing and all). The fold-back is the real acquisition
  behaviour you're reproducing.

Neither `resample` to a coarser grid nor `x[1:N:end]` includes anti-aliasing: they
silently fold high-frequency content into your kept band.

## `impute`

Fill flagged entries (default `[NaN, Nothing, Missing]`) by interpolation.

```julia
v = sin.(0.0:0.1:9.9); v[10:15] .= NaN
x = Timeseries(v, 0.0:0.1:9.9)
y = impute(x)                                          # NaNs filled by Akima fit
y = impute(x; replace = [NaN, Nothing, Missing, Complex])  # also flag complex values
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

## Reference

```@docs
interpolate
upsample
resample
downsample
impute
```
