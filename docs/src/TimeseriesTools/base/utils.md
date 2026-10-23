```@meta
CurrentModule = TimeseriesBase
```

# Utilities

Helpers for sampling metadata, windowing, embedding, regularisation, derivatives, and
circular statistics. All operate on the core types from
[Time series](timeseries.md).

## Sampling metadata

```@example utils
using TimeseriesTools
x = Timeseries(sin.(0.0:0.01:9.99), 0.0:0.01:9.99)
samplingrate(x), samplingperiod(x), nyquist(x), duration(x)
```

```@docs
times
step(::RegularTimeseries)
samplingrate
samplingperiod
nyquist
duration
Interval(::AbstractTimeseries)
```

## Windowing and reshaping

[`buffer`](@ref) cuts a series into consecutive windows, [`window`](@ref) into sliding ones,
and [`delayembed`](@ref) builds a delay-coordinate embedding. Each returns a vector of
sub-series indexed by the time at which each window is centred (or, for `delayembed`, a
matrix whose rows are the embedded vectors). [`coarsegrain`](@ref) pairs up neighbouring
samples along a dimension. `stitch(x, y, ...)` joins regular series end to end on a
continuous time axis (the sampling periods must match); a numeric time axis restarts one step
from the origin, while a `DateTime` axis continues the calendar of the first series.

```@example utils
b = buffer(x, 100)               # 100-sample non-overlapping windows
length(b), size(b[1]), times(b)[1:3]
```

```@example utils
w = window(x, 100, 50)           # 100-sample windows sliding by 50
length(w)
```

```@docs
coarsegrain
buffer
window
delayembed
interlace
Dropdims
```

## Regularising time axes

[`regularize`](@ref) repairs float jitter in a nominally regular lookup, fitting the grid by
least squares and throwing if any point deviates by more than `atol`. Given several arrays,
it crops them to their common range and puts them on one shared grid. It supersedes
[`rectify`](@ref), [`rectifytime`](@ref) and [`matchdim`](@ref), which remain for existing
code. [`align`](@ref) cuts windows around a set of event times.

```@example utils
t = collect(0.0:0.1:9.9) .+ 1e-9 .* randn(100)   # jittered stamps
j = Timeseries(randn(100), t)
j isa RegularTimeseries, regularize(j) isa RegularTimeseries
```

```@docs
regularize
rectify
rectifytime
matchdim
align
```

## Derivatives

Three finite-difference flavours: left, right, and centred. The `diff` forms difference
neighbouring samples; the `deriv` forms divide by the sampling period. Each has an in-place
(`!`) and an allocating form, and a `grad` keyword to swap in another difference operator
(see [`phasegrad`](@ref) for angles).

```@example utils
dx = centralderiv(x)
dx[1:3]
```

```@docs
centraldiff
centraldiff!
centralderiv
centralderiv!
leftdiff
leftdiff!
leftderiv
leftderiv!
rightdiff
rightdiff!
rightderiv
rightderiv!
```

## Circular statistics

For phase series and other angular data.

```@docs
resultant
resultantlength
circularmean
circularvar
circularstd
phasegrad
```

## Metadata helpers

```@docs
addrefdim
addmetadata
```

## Spike-train helpers

Documented in full on [Spike trains](../analysis/spiketrains.md).

```@docs; canonical=false
spiketrain
spiketimes
```
