```@meta
CurrentModule = TimeseriesBase
```

# Unitful integration

Time lookups and values can carry [`Unitful`](https://github.com/PainterQubits/Unitful.jl)
units. Units propagate through most operations; helpers below extract or strip them.

```@example unit
using TimeseriesTools, Unitful
t = (0.0:0.01:1.0) * u"s"
x = Timeseries(sin.(ustrip.(t)), t) * u"V"
timeunit(x), unit(eltype(x)), dimunit(x, 𝑡)
```

[`ustripall`](@ref) recursively strips units from values *and* lookups, returning a plain
`ToolsArray`. Use it when handing data to a unit-unaware backend, then re-attach with
`* u`.

## Reference

```@docs
dimunit
timeunit
frequnit
unit
UnitfulIndex
UnitfulTimeseries
UnitfulSpectrum
ustripall
```
