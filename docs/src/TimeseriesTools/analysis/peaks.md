```@meta
CurrentModule = TimeseriesTools
```

# Peaks and spectral fitting

## Finding peaks

[`findpeaks`](@ref) wraps [`Peaks.jl`](https://github.com/halleysfifthinc/Peaks.jl) for
labelled arrays: it returns the peak values, their prominences, and the interval each peak
spans at half its prominence, all indexed by the position of the peak along the lookup.
[`maskpeaks`](@ref) labels every sample with the index of the peak it belongs to. Both
handle multivariate input along `dims`.

```@example mapple
using TimeseriesTools, Random
Random.seed!(2)
t = 0:0.001:300                                      # 300 s at 1 kHz
ϕ = 2π .* (10 .* t .+ (0.5 / (2π * 0.05)) .* (1 .- cos.(2π * 0.05 .* t)))
rhythm = sin.(ϕ)                                     # a 10 Hz rhythm that wanders by ±0.5 Hz
x = colorednoise(t; α = 1.5) .+ 0.5 .* rhythm        # on a 1/f^1.5 background
S = powerspectrum(x, 0.05)
pks, proms, widths = findpeaks(S, 20; N = 1)         # the single most prominent peak
lookup(pks, 𝑓), widths
```

## MAPPLE: a parametric spectral model

[`MAPPLE`](@ref) (Adaptive Peaks and Power-Law Exponents) describes a spectrum as a
broken power law, with one exponent per frequency band and smooth transitions between
bands, plus Gaussian peaks on top. Fitting it to a measured spectrum summarises the
spectrum in a handful of interpretable numbers: the exponents, the frequencies at which
they change, and the centre, width and height of each peak.

### Preparing the spectrum

The fit minimises the squared residuals in log-10 power across all samples, so a
linear-frequency spectrum, most of whose samples sit in the noisy high-frequency decades,
should be passed through [`logsample`](@ref) first. The zero-frequency bin has no logarithm
and must be dropped, and the lower edge decides the bin width (see
[Log-frequency sampling](spectra.md#Log-frequency-sampling)): starting at 1 Hz, twenty
steps above the 0.05 Hz resolution, gives bins about 0.02 decades wide.

```@example mapple
Slog = logsample(S[𝑓 = 1 .. 200])
length(S), length(Slog)
```

### Fitting

`fit(MAPPLE, S)` chooses the number of power-law segments by the Bayesian information
criterion over `1:max_components`, detecting peaks on each candidate's detrended residual.
With [`Optim`](https://github.com/JuliaNLSolvers/Optim.jl) loaded (which enables `OptimExt`),
every candidate is refined before the comparison and the returned model is already refined;
without it only the rough initialisation is available and the selection collapses to one
component.

```@example mapple
using Optim
m = fit(MAPPLE, Slog)
```

A single power-law segment was selected, with the exponent of the background and a peak at
10 Hz. The detector also kept a weak bump near 2 Hz at the lower edge of the band; pass
`peaks = 1` to keep only the strongest detection, or raise `peak_threshold`.

The accessors report the parameters in physical units ([`betas`](@ref),
[`breakfrequencies`](@ref), [`peakcentres`](@ref), [`peakbandwidths`](@ref),
[`peakheights`](@ref)) or in the log-10 space the model is parameterised in
([`breakpoints`](@ref), [`peakfreqs`](@ref), [`peaksigmas`](@ref), [`peakamplitudes`](@ref)).
The last component's break frequency is never a transition: it is held at the top of the
fitted band and reports where the fit ends.

```@example mapple
betas(m), breakfrequencies(m), peakcentres(m)
```

[`predict`](@ref) evaluates the fitted model, and [`rsquared`](@ref) and
[`mapple_residuals`](@ref) measure the fit, both in log-10 space:

```@example mapple
using CairoMakie, TimeseriesMakie
f = collect(lookup(Slog, 𝑓))
fig = Figure()
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10, xlabel = "Frequency (Hz)", ylabel = "Power",
          title = "R² = $(round(rsquared(m, Slog); digits = 3))")
scatter!(ax, f, collect(parent(Slog)); label = "spectrum")
lines!(ax, f, predict(m, f); color = :crimson, linewidth = 2, label = "MAPPLE")
axislegend(ax)
fig
```

### Controlling the fit

Pass an integer `components` to fix the segment count; this returns the rough fit, which
[`fit!`](@ref) then refines in place. Keyword arguments steer the peak detection (`peaks`,
`peak_threshold`, `window`) and, through `refine`, the optimiser (`multistart`,
`iterations`). Two refinement options are worth knowing:

- `w = true` weights each sample by the width of the log-frequency cell it owns
  ([`logweights`](@ref)), so a grid that is not uniform in log space cannot bias the fit
  towards its denser end.
- `fix` holds named parameters at given values, for example a slope known on theoretical
  grounds or a break frequency shared across a set of fits. Labels follow
  `ComponentArrays.labels(m.params)`, such as `"components[1].β"`.

```@example mapple
m2 = fit(MAPPLE, Slog; components = 2, peaks = 1)   # rough initialisation only
fit!(m2, Slog; w = true, fix = ["components[1].β" => -1.5])
betas(m2)
```

### Uncertainty

[`stderror`](@ref) and [`vcov`](@ref) give asymptotic standard errors and the covariance
matrix of the fitted parameters from the Hessian at the optimum, assuming independent
residuals. Held parameters report zero error; [`freelabels`](@ref) lists the ones that were
fitted, in the order of the covariance matrix. Read the warnings in their docstrings before
reporting these on an averaged spectrum, whose residuals are strongly correlated.

```@example mapple
se = stderror(m, Slog)
se.log_A, se.components[1].β
```

## Reference

```@docs
findpeaks
maskpeaks
maskpeaks!
```

### Model

```@docs
MAPPLE
mapple
fit(::Type{MAPPLE}, ::DimensionalData.AbstractDimVector)
fit!(::MAPPLE, ::DimensionalData.AbstractDimVector)
fit_mapple
predict(::MAPPLE, ::Any)
logweights
```

### Parameters

```@docs
betas
breakpoints
breakfrequencies
peakfreqs
peaksigmas
peakamplitudes
peakcentres
peakbandwidths
peakheights
peakparams
peakparams_hz
```

### Goodness of fit and uncertainty

```@docs
rsquared
mapple_residuals
mapple_loss
vcov(::MAPPLE, ::DimensionalData.AbstractDimVector)
stderror(::MAPPLE, ::DimensionalData.AbstractDimVector)
freelabels
```
