```@meta
CurrentModule = TimeseriesBase
```

# Input/output

Save and load time series to disk. The default backend is JLD2; passing a `.tsv` path
writes a tab-separated representation instead (regular series only).

```julia
savetimeseries("x.jld2", x)
y = loadtimeseries("x.jld2")
```

`savets`/`loadts` are short aliases.

## Reference

```@docs
savetimeseries
savets
loadtimeseries
loadts
```
