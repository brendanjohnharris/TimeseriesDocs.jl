```@meta
CurrentModule = TimeseriesBase
```

# Input/output

[`savetimeseries`](@ref) and [`loadtimeseries`](@ref) write and read a time series, choosing
the format from the file extension. `.jld2` is lossless and is the default choice; it needs
[`JLD2`](https://github.com/JuliaIO/JLD2.jl) loaded. `.tsv` writes a plain-text table with a
small header, for anything that is not Julia.

```@example io
using TimeseriesTools, Unitful, JLD2
x = Timeseries(rand(5), (0.0:0.1:0.4) * u"s") * u"V"
dir = mktempdir()
savetimeseries(joinpath(dir, "x.jld2"), x)
y = loadtimeseries(joinpath(dir, "x.jld2"))
y == x
```

`savets`/`loadts` are short aliases.

## Text files

A `.tsv` file has a four-line `#` header (name, metadata, reference dimensions, variable
names) followed by a table whose first column is time. Units are stripped from the cells and
recorded in the metadata header, and a `Dates` time column travels the same way, so both are
restored on load.

```@example io
savetimeseries(joinpath(dir, "x.tsv"), x)
print(read(joinpath(dir, "x.tsv"), String))
```

```@example io
z = loadtimeseries(joinpath(dir, "x.tsv"))
unit(z), timeunit(z), z isa IrregularTimeseries
```

The text format makes concessions: the time lookup comes back as a vector rather than a
range (so the result is an `IrregularTimeseries` even when the original was regular, and
[`regularize`](@ref) restores the range), reference dimensions are written but not read back,
and a series of three or more dimensions is flattened to a table that cannot be reloaded.
Use `.jld2` for those.

## Loading arrays with missing dimension types

JLD2 stores the full type of an array, including the types of its dimensions. If a file holds
a `ToolsArray` whose dimensions were defined with `@dim` in a package that is not loaded
when reading, a plain `JLD2.load` degrades the whole array to an opaque struct.
[`loadtoolsarray`](@ref) reconstructs it instead, replacing each absent dimension type by a
generic `Dim{name}` that carries the same lookup. [`toolsarray_typemap`](@ref) is the
underlying typemap, for use with `jldopen` on multi-key files.

```julia
using JLD2
x = loadtoolsarray("results.jld2", "x")
```

## Reference

```@docs
savetimeseries
savets
loadtimeseries
loadts
loadtoolsarray
toolsarray_typemap
```
