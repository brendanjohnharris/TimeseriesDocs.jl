```@meta
CurrentModule = TimeseriesBase
```

# Utilities

Helpers for sampling metadata, windowing, embedding, regularisation, derivatives, and
circular statistics. All operate on the core types from
[Time series](timeseries.md).

## Sampling metadata

```@docs
times
step
samplingrate
samplingperiod
duration
```

## Windowing and reshaping

[`coarsegrain`](@ref) downsamples by averaging within blocks; [`buffer`](@ref) returns
non-overlapping windows as columns; [`window`](@ref) returns sliding windows;
[`delayembed`](@ref) builds a delay-coordinate embedding.

```@example utils
using TimeseriesTools
x = Timeseries(sin.(0.0:0.01:9.99), 0.0:0.01:9.99)
b = buffer(x, 100)               # 100-sample non-overlapping windows
size(b)
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

[`rectify`](@ref) and [`regularize`](@ref) repair float jitter in nominally regular
lookups; [`matchdim`](@ref) and [`align`](@ref) bring multiple series onto a common axis.

```@docs
rectify
rectifytime
regularize
matchdim
align
```

## Derivatives

Three finite-difference flavours: left, right, and centred. In-place (`!`) and
allocating forms.

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

```@docs
spiketrain
spiketimes
```
