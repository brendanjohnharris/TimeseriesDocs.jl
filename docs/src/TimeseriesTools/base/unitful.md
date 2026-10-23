```@meta
CurrentModule = TimeseriesBase
```

# Unitful integration

Time lookups and values can carry [`Unitful`](https://github.com/PainterQubits/Unitful.jl)
units. Units propagate through most operations: the sampling rate of a series sampled in
seconds is in `s^-1`, the power spectrum of a series in volts is in `V^2/Hz`, and a
derivative divides the value units by the time units. The helpers below extract or strip
them.

```@example unit
using TimeseriesTools, Unitful
t = (0.0:0.01:1.0) * u"s"
x = Timeseries(sin.(ustrip.(t)), t) * u"V"
timeunit(x), unit(x), dimunit(x, 𝑡), samplingrate(x)
```

A series whose *time* lookup is unitful is a [`UnitfulTimeseries`](@ref); the values may or
may not carry units of their own. [`unit`](@ref) returns the unit of the values (`NoUnits`
when there is none), [`timeunit`](@ref) that of the time axis, and [`dimunit`](@ref) that of
any dimension.

[`ustripall`](@ref) recursively strips units from values *and* lookups, returning a plain
`ToolsArray`. Use it when handing data to a unit-unaware backend, then re-attach with
`* u`.

```@example unit
y = ustripall(x)
timeunit(y), unit(y)
```

Selectors take quantities too, so `x[𝑡 = 0.25u"s" .. 0.5u"s"]` selects by time in the
lookup's own units.

## Reference

```@docs
UnitfulTimeseries
UnitfulSpectrum
UnitfulIndex
TimeseriesBase.UnitfulTools.UnitfulTimeIndex
unit(::Union{<:AbstractTimeseries, AbstractSpectrum})
dimunit
timeunit
frequnit
ustripall
```
