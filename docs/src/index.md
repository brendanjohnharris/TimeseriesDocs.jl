```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "TimeseriesTools"
  text: "Time-series analysis in Julia"
  tagline: "A suite of tools for regular, irregular, and multivariate time series: wrangle, analyze, and visualize."
  image:
    src: /logo.png
    alt: TimeseriesTools logo.
  actions:
    - theme: brand
      text: Get started
      link: /quickstart
    - theme: alt
      text: Tutorial
      link: /TimeseriesTools/tutorial
    - theme: alt
      text: Gallery
      link: "#gallery"
    - theme: alt
      text: View on Github
      link: https://github.com/brendanjohnharris/TimeseriesTools.jl

features:
  - icon: 🧰
    title: TimeseriesTools
    details: The core data model plus spectra, spike trains, filtering, resampling, and imputation.
    link: /TimeseriesTools/index
  - icon: 📈
    title: TimeseriesMakie
    details: Makie recipes for series, spectra, spike rasters, and trajectories.
    link: /TimeseriesMakie/index
  - icon: ⚖️
    title: Normalization
    details: Composable, invertible normalization methods for array data.
    link: /Normalization/index
  - icon: 🗺️
    title: MoreMaps
    details: Flexible parallel map configurations for abstract and nested arrays.
    link: /MoreMaps/index
---
```

```@raw html
<p style="margin-bottom:2cm"></p>

<div class="vp-doc" style="width:80%; margin:auto">
```

## Gallery

One figure from each part of the family, drawn at build time by the current packages. Each
caption links to the page that explains it.

```@setup gallery
using TimeseriesTools, TimeseriesMakie, TimeseriesToolsSurrogates, Normalization
using CairoMakie, Foresight, Unitful, Random, Statistics
using DSP, DataInterpolations, Distributions, ContinuousWavelets, Optim
import TimeseriesMakie: kinetic, kinetic!, trajectory, trajectory!
Makie.set_theme!(Foresight.foresight())
Random.seed!(1)
```

```@raw html
<div class="gallery">
```

```@raw html
<figure>
```

```@example gallery
t = range(0, 20; step = 0.005) * u"s" # hide
x = colorednoise(t; α = 2.0) * u"V" # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]) # hide
plot!(ax, x) # hide
fig # hide
```

**[A labelled series](TimeseriesTools/base/timeseries.md)**. Brown noise with a time axis in seconds and values in volts; `plot` reads both from the array.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
pink = colorednoise(0.0:0.001:100.0; α = 1.0) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10) # hide
plotspectrum!(ax, powerspectrum(pink, 0.1)) # hide
fig # hide
```

**[Power spectrum](TimeseriesTools/analysis/spectra.md)**. `plotspectrum` of pink noise: log axes, labels and units come from the data.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
tw = 0:0.002:4 # hide
xw = Timeseries(sin.(2π * 5 .* tw) .+ (tw .> 2) .* sin.(2π * 20 .* tw), tw) # hide
W = waveletspectrogram(xw; pass = 40) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xlabel = "Time (s)", ylabel = "Frequency (Hz)") # hide
heatmap!(ax, times(W), freqs(W), parent(abs.(W))) # hide
fig # hide
```

**[Wavelet spectrogram](TimeseriesTools/analysis/spectra.md#Wavelet-spectrograms)**. A 5 Hz tone joined by a 20 Hz tone at two seconds, resolved in time and frequency.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
tf = 0:0.001:5 # hide
xf = Timeseries((1 .+ 0.5 .* sin.(2π * 0.5 .* tf)) .* sin.(2π * 10 .* tf) .+ 0.5 .* randn(length(tf)), tf) # hide
xb = bandpass(xf, [8, 12]) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xlabel = "Time (s)") # hide
lines!(ax, xf; color = (:gray, 0.5)) # hide
lines!(ax, xb) # hide
lines!(ax, analyticamplitude(xb); color = :black, linewidth = 2) # hide
fig # hide
```

**[Band-pass filter and envelope](TimeseriesTools/analysis/filtering.md)**. A noisy amplitude-modulated 10 Hz tone, its 8–12 Hz band, and the analytic amplitude.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
td = 0:0.001:4 # hide
xd = Timeseries(sin.(2π * 3 .* td) .+ sin.(2π * 130 .* td), td) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xlabel = "Frequency (Hz)", ylabel = "Power", yscale = log10) # hide
lines!(ax, powerspectrum(downsample(xd, 10), 1.0); label = "antialias = true") # hide
lines!(ax, powerspectrum(downsample(xd, 10; antialias = false), 1.0); linestyle = :dash, label = "antialias = false") # hide
axislegend(ax) # hide
fig # hide
```

**[Anti-aliased downsampling](TimeseriesTools/analysis/interpolation.md#downsample)**. A 130 Hz tone sampled at 1 kHz, downsampled to 100 Hz: filtered away, or folded back to 30 Hz.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
vi = sin.(0.0:0.1:9.9); vi[30:38] .= NaN; vi[60:63] .= NaN # hide
g = Timeseries(vi, 0.0:0.1:9.9) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]) # hide
lines!(ax, impute(g); color = :crimson, label = "impute") # hide
scatter!(ax, g; markersize = 7, label = "data") # hide
axislegend(ax) # hide
fig # hide
```

**[Imputation](TimeseriesTools/analysis/interpolation.md#impute)**. Gaps flagged as `NaN`, filled by an Akima interpolant through the surviving samples.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
tm = 0:0.001:300 # hide
ϕ = 2π .* (10 .* tm .+ (0.5 / (2π * 0.05)) .* (1 .- cos.(2π * 0.05 .* tm))) # hide
xm = colorednoise(tm; α = 1.5) .+ 0.5 .* sin.(ϕ) # hide
Sm = logsample(powerspectrum(xm, 0.05)[𝑓 = 1 .. 200]) # hide
m = fit(MAPPLE, Sm; peaks = 1) # hide
fm = collect(lookup(Sm, 𝑓)) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10, xlabel = "Frequency (Hz)", ylabel = "Power") # hide
scatter!(ax, fm, collect(parent(Sm)); markersize = 6) # hide
lines!(ax, fm, predict(m, fm); color = :crimson, linewidth = 2) # hide
fig # hide
```

**[MAPPLE spectral fit](TimeseriesTools/analysis/peaks.md)**. A power law with a rhythm at 10 Hz, log-sampled and fitted by a broken power law plus Gaussian peaks.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
st = gammarenewal(400, 2.0, 0.025) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xlabel = "Frequency (Hz)", ylabel = "Power") # hide
lines!(ax, powerspectrum(st, 0:0.5:60; method = :schild)) # hide
ax2 = Axis(fig[1, 2]; xscale = log10, xlabel = "Bin width (s)", ylabel = "Fano factor") # hide
lines!(ax2, fano_factor(st)) # hide
fig # hide
```

**[Spike spectrum and Fano factor](TimeseriesTools/analysis/spiketrains.md)**. A gamma renewal spike train: its power spectrum, and the Fano factor of its counts across bin widths.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
rates = shuffle(range(2, 20, length = 40)) # hide
spikes = [cumsum(randexp(300) ./ r) for r in rates] # hide
spikes = [s[s .< 10] for s in spikes] # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xlabel = "Time (s)", ylabel = "Neuron") # hide
spikeraster!(ax, spikes; sortby = :rate) # hide
fig # hide
```

**[Spike raster](TimeseriesMakie/recipes.md#Spike-raster)**. Forty neurons with different rates, rows sorted by rate.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xlabel = "Time (s)", ylabel = "Spikes / s") # hide
psth!(ax, reduce(vcat, spikes); binwidth = 0.25) # hide
fig # hide
```

**[Peri-stimulus time histogram](TimeseriesMakie/recipes.md#PSTH)**. The pooled spike times of the same population, binned.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
φ = 0:0.05:(8π) |> reverse # hide
zc = φ .* exp.(φ .* im) # hide
xs, ys = real.(zc), imag.(zc) # hide
zs = xs .* ys ./ 10 # hide
limits = (extrema(xs), extrema(ys), extrema(zs)) # hide
fig = Figure(size = (520, 400)) # hide
ax = Axis3(fig[1, 1]; limits) # hide
trajectory!(ax, xs, ys, zs; color = :speed, linewidth = 2) # hide
shadows!(ax, xs, ys, zs; limits, color = (:gray, 0.6), linewidth = 0.7) # hide
fig # hide
```

**[Trajectory with shadows](TimeseriesMakie/recipes.md#Trajectory)**. A spiral in three dimensions coloured by speed, with its projections on the axis panes.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
xt = 0:0.1:10 # hide
yt = range(0, π, length = 6) # hide
Z = stack([sin.(xt .+ i) for i in yt]) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]) # hide
p = traces!(ax, xt, yt, Z; spacing = :even, offset = 1.5) # hide
Colorbar(fig[1, 2], p) # hide
fig # hide
```

**[Traces](TimeseriesMakie/recipes.md#Traces)**. The columns of a matrix, offset so each trace has its own lane.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
tk = range(0, 1, length = 3000) # hide
chirp = sin.(2π .* (1 .+ 12 .* tk) .* tk) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]) # hide
hidedecorations!(ax) # hide
kinetic!(ax, tk, chirp) # hide
fig # hide
```

**[Kinetic](TimeseriesMakie/recipes.md#Kinetic)**. A chirp drawn as wide as the curve has room for, so dense passages stay legible.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]) # hide
hidedecorations!(ax) # hide
trail!(ax, xs, ys; color = 1:length(xs), n_points = 300) # hide
fig # hide
```

**[Trail](TimeseriesMakie/recipes.md#Trail)**. A path that fades into the past, for animations.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
ts = 0:0.001:20 # hide
xs2 = colorednoise(ts; α = 1.0) .+ sin.(2π * 8 .* ts) # hide
s2 = surrogenerator(xs2, NDAAFT())() # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10, xlabel = "Frequency (Hz)", ylabel = "Power") # hide
lines!(ax, powerspectrum(xs2, 0.1)[2:end]; label = "original") # hide
lines!(ax, powerspectrum(s2, 0.1)[2:end]; linestyle = :dash, label = "surrogate") # hide
axislegend(ax) # hide
fig # hide
```

**[Surrogate data](TimeseriesTools/analysis/surrogates.md)**. An NDAAFT surrogate keeps the power spectrum of the original, 8 Hz peak included.

```@raw html
</figure>
```

```@raw html
<figure>
```

```@example gallery
xn = 1.25 .* randn(300) .+ 1.0 # hide
yn = normalize(xn, fit(Sigmoid, xn)) # hide
fig = Figure(size = (520, 340)) # hide
ax = Axis(fig[1, 1]; xlabel = "Input", ylabel = "Output") # hide
scatter!(ax, xn, yn; markersize = 6, color = (:black, 0.5)) # hide
fig # hide
```

**[Normalization](Normalization/index.md)**. A `Sigmoid` normalization maps the input distribution onto the unit interval.

```@raw html
</figure>
```

```@raw html
</div>
```

```@example gallery
Makie.set_theme!() # hide
nothing # hide
```

## Highlights

- **Consistent data**: built on `DimensionalData.jl`, giving one type that carries values, time points, spatial coordinates, units, and metadata.
- **Leverage dispatch**: distinct types for e.g. regular, irregular, and multivariate series, facilitating generic methods.
- **Unitful**: `Unitful.jl` integration keeps frequency, power, and amplitude dimensionally consistent.
- **Calendar-aware**: `Dates` time axes work across windowing, grid repair, and IO.
- **Analysis**: spectra and spectrograms, filtering and analytic signals, interpolation/resampling/imputation, spike trains, parametric spectral fits, and (in a companion package) surrogate data.
- **Plotting**: `Makie.jl` recipes for series, spectra, spike rasters, and trajectories.
- **Light by default**: extensions implement heavy analysis, and a hint names the package to load when a method is missing.

## Versions described by this build

The pages are built from the packages' `main` branches, and every example is executed at build
time against these versions:

```@example versions
using TimeseriesTools, TimeseriesMakie, Normalization, MoreMaps, TimeseriesToolsSurrogates, Markdown # hide
rows = ["| Package | Version |", "|---|---|"] # hide
for m in (TimeseriesTools, TimeseriesTools.TimeseriesBase, TimeseriesMakie, Normalization, MoreMaps, TimeseriesToolsSurrogates) # hide
    push!(rows, "| [`$(nameof(m))`](https://github.com/brendanjohnharris/$(nameof(m)).jl) | $(pkgversion(m)) |") # hide
end # hide
Markdown.parse(join(rows, "\n")) # hide
```


```@raw html
</div>
```
