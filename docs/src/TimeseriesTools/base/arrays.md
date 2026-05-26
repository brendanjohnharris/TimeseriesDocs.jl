```@meta
CurrentModule = TimeseriesBase
```

# Arrays and dimensions

`TimeseriesTools` extends [`DimensionalData.jl`](https://github.com/rafaqz/DimensionalData.jl)
with a custom array type, [`ToolsArray`](@ref), and a set of canonical
[`ToolsDimension`](@ref)s. The motivation is dispatch-friendliness: a `ToolsArray` whose
first or last dimension is a `ToolsDimension` is preserved across operations that would
otherwise drop the `DimArray` wrapper (e.g. `eachcol`, slicing, rebuilding).

```@example arrays
using TimeseriesTools
x = Timeseries(rand(10), 1:10)
x isa AbstractToolsArray, x isa AbstractTimeseries
```

A `ToolsArray` behaves like a `DimensionalData.DimArray` in most respects.

## Canonical dimensions

The exported `ToolsDimension`s are spatial axes ([`𝑥`](@ref), [`𝑦`](@ref), [`𝑧`](@ref)),
time ([`𝑡`](@ref)), frequency ([`𝑓`](@ref), [`Log𝑓`](@ref), [`Log10𝑓`](@ref)),
generic-variable ([`Var`](@ref)), and observation ([`Obs`](@ref)).

```@example arrays
y = Timeseries(rand(10, 3), 𝑡(0.0:0.1:0.9), Var(1:3))
dims(y)
```

To define another `ToolsDimension`:

```julia
using DimensionalData
DimensionalData.@dim NewDim ToolsDim "NameOfNewDim"
```

Functions operating on a `ToolsArray` without a `ToolsDimension` as the first or last
dimension may not return a `ToolsArray`; be careful with the `DimensionalData.Dim{:name}`
syntax in that position.

## Reference

```@docs
AbstractToolsArray
ToolsArray
ToolsDimension
ToolsDim
𝑡
𝑥
𝑦
𝑧
𝑓
Log𝑓
Log10𝑓
Var
Obs
```
