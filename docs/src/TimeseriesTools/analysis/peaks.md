```@meta
CurrentModule = TimeseriesTools
```

# Peaks and spectral fitting

[`findpeaks`](@ref) and [`maskpeaks`](@ref) wrap [`Peaks.jl`](https://github.com/halleysfifthinc/Peaks.jl)
for time series and spectra; they handle multivariate input and return peaks with
heights, prominences, and widths.

[`MAPPLE`](@ref) (Adaptive Peaks and Power-Law Exponents) is a parametric spectral model
combining multiple piecewise power-law components with Gaussian peaks. Fitting is in two
stages: an initial peak-finding + linear-regression pass (`fit(MAPPLE, S)`), then a
refinement with [`Optim`](https://github.com/JuliaNLSolvers/Optim.jl) (`fit!(m, S)`),
provided by `OptimExt` (loaded with `using Optim`).

```julia
using TimeseriesTools, Optim
m  = fit(MAPPLE, S)        # rough fit on a power spectrum
fit!(m, S)                 # refine
ŝ  = predict(m, freqs(S))
```

## Reference

```@docs
findpeaks
maskpeaks
MAPPLE
mapple
fit_mapple
```

```@autodocs
Modules = [Base.get_extension(TimeseriesTools, :OptimExt)]
```
