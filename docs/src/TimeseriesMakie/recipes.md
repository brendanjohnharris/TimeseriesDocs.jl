```@meta
CurrentModule = TimeseriesMakie
```

```@setup TimeseriesMakie
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using Foresight
using TimeseriesMakie
using TimeseriesTools
using Statistics
using Random
import Makie.Linestyle
import TimeseriesMakie: kinetic, kinetic!, trajectory, trajectory!
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
Makie.set_theme!(Foresight.foresight())
```

# Recipes


## Trajectory


```@shortdocs; canonical=false
trajectory
```

```@example TimeseriesMakie
f = Figure(size = (600, 600))

ϕ = 0:0.1:(8π) |> reverse
x = ϕ .* exp.(ϕ .* im)
y = imag.(x)
x = real.(x)

# * Default
ax = Axis(f[1, 1], title = "Default")
trajectory!(ax, x, y)

# * Speed
ax = Axis(f[1, 2], title = "Speed")
trajectory!(ax, x, y; color = :speed)

# * Alpha
ax = Axis(f[2, 1], title = "Time")
trajectory!(ax, x, y; color = :time)

# * 3D
ax = Axis3(f[2, 2], title = "3D")
trajectory!(ax, x, y, x .* y; color = :speed)

f
```

## Shadows

```@shortdocs; canonical=false
shadows
```

```@example TimeseriesMakie
 f = Figure(size = (500, 500))

ϕ = 0:0.1:(8π) |> reverse
x = ϕ .* exp.(ϕ .* im)
y = imag.(x)
x = real.(x)
z = x .* y

limits = (extrema(x), extrema(y), extrema(z))
ax = Axis3(f[1, 1]; title = "Shadows", limits)
lines!(ax, x, y, z)
shadows!(ax, x, y, z; limits, linewidth = 0.5)

f
```

## Traces

```@shortdocs; canonical=false
traces
```

```@example TimeseriesMakie
f = Figure(size = (900, 300))

x = 0:0.1:10
y = range(0, π, length = 5)
Z = [sin.(x .+ i) for i in y]
Z = stack(Z)

ax = Axis(f[1, 1]; title = "Unstacked")
p = traces!(ax, x, y, Z)
Colorbar(f[1, 2], p)

ax = Axis(f[1, 3]; title = "Even")
p = traces!(ax, x, y, Z; spacing = :even, offset = 1.5)
Colorbar(f[1, 4], p)

ax = Axis(f[1, 5]; title = "Close")
p = traces!(ax, x, y, Z; spacing = :close, offset = 1.5)
Colorbar(f[1, 6], p)

f
```

## Trail

```@shortdocs; canonical=false
trail
```

```@example TimeseriesMakie
f = Figure(size = (600, 600))

ϕ = 0:0.1:(8π) |> reverse
x = ϕ .* exp.(ϕ .* im)
y = imag.(x)
x = real.(x)

# * Default
ax = Axis(f[1, 1], title = "Default")
trail!(ax, x, y)

# * Colormap
ax = Axis(f[1, 2], title = "Colormap")
trail!(ax, x, y; color = 1:500)

# * Alpha
ax = Axis(f[2, 1], title = "Alpha^3")
trail!(ax, x, y; alpha = Base.Fix2(^, 3))

# * Shorter trail
ax = Axis(f[2, 2], title = "Shorter trail")
trail!(ax, x, y; n_points = 100)

linkaxes!(contents(f.layout))
hidedecorations!.(contents(f.layout))
f
```

You can animate a trail with:
```julia
f = Figure(size = (300, 300))
r = 50 # Set the limits so the axis doesn't resize during the animation
ax = Axis(f[1, 1], limits = ((-r, r), (-r, r)))
xy = Observable([Point2f(first.([x, y]))])
p = trail!(ax, xy, n_points = 100)
hidedecorations!(ax)

record(f, "trail_animation.mp4", zip(x, y)) do _xy
    xy[] = push!(xy[], Point2f(_xy))
end
```


## Kinetic

```@shortdocs; canonical=false
kinetic
```

```@example TimeseriesMakie
x = -π:0.1:π
kinetic(x, sin.(x))
```

### Width profiles

`linewidth` chooses what the width follows, one value per point, scaled by `linewidthscale`.
`:x` and `:y` follow that coordinate, mapped onto `widthrange`; a number holds the width
constant; and `:curv`, the default, draws as wide as the curve has room for.

```@example TimeseriesMakie
x = range(-2π, 2π, length = 400)
y = sin.(5x) .* exp.(-abs.(x) ./ 6)

f = Figure(size = (860, 220))
for (j, lw) in enumerate([:curv, :x, :y, 4])
    local ax = Axis(f[1, j]; title = lw isa Symbol ? ":$lw" : "$lw")
    hidedecorations!(ax)
    kinetic!(ax, x, y; linewidth = lw)
end
f
```

The other three modes fill this one in, because nothing stops them asking for a width the
oscillation has no room for; `:curv` is the only one that leaves the signal readable.

### Crowding

`:curv` measures, at each point, the radius of the largest disc tangent to the curve that holds
no other part of it. For a circle of radius `R` that radius is `R`, and for two strands `d`
apart it is `d/2`, so a tight turn and a near miss are one quantity: how much room there is.
The stroke then has only to fit inside it, which is what keeps a fast passage legible beside a
slow one.

```@example TimeseriesMakie
t = range(0, 1, length = 3000)
chirp = sin.(2π .* (1 .+ 12 .* t) .* t)                  # 1 Hz sweeping to 25 Hz
burst = sin.(2π .* 1.5 .* t) .+
        0.45 .* sin.(2π .* 45 .* t) .* exp.(-((t .- 0.5) ./ 0.04) .^ 2)

f = Figure(size = (860, 420))
for (i, (name, y)) in enumerate([("Chirp", chirp), ("Slow carrier, fast burst", burst)])
    local ax = Axis(f[i, 1]; title = name)
    hidedecorations!(ax)
    kinetic!(ax, t, y)
end
f
```

`crowding` sets the fraction of that room the stroke fills: `1` lets two neighbouring strands
just touch, leaving no visible gap. `taper` sets the largest relative change in width per pixel
travelled along the curve, which also decides how far a narrow spot spreads into its
surroundings. Those two cannot be separated, so lower `taper` to flatten the width across an
oscillation and raise it to keep an isolated thin loop at its full width.

```@example TimeseriesMakie
f = Figure(size = (860, 560))
for (i, (label, kw)) in enumerate([("crowding = 0.2", (crowding = 0.2,)),
                                   ("crowding = 1", (crowding = 1,)),
                                   ("taper = 0.005", (taper = 0.005,)),
                                   ("taper = 0.2", (taper = 0.2,))])
    local ax = Axis(f[cld(i, 2), mod1(i, 2)]; title = label)
    hidedecorations!(ax)
    kinetic!(ax, t, burst; kw...)
end
f
```

Because the room is measured in pixels, the widths follow the axis rather than the data: zoom
into a dense passage and the stroke fattens as its structure becomes resolvable.

### Geometries

`geometry` chooses how the stroke is drawn. It is read once when the plot is built, so
changing it afterwards has no effect.

`:mesh` builds a triangle strip in pixel space, tapering each interval linearly between its
end widths and rounding the joins and caps. `:segments` draws one `linesegments` per
interval, each at a single width, with the joints left to `linecap`.

```@example TimeseriesMakie
smooth_x = range(-2π, 2π, length = 200)
smooth_y = sin.(smooth_x) .* exp.(-abs.(smooth_x) ./ 6)

sharp_x = 0:8
sharp_y = Float64[0, 1, 0, 1, 0, 1, 0, 1, 0]

ϕ = range(0.6, 4π, length = 250)
loop_x = ϕ .* cos.(ϕ)
loop_y = ϕ .* sin.(ϕ)

cases = [("Smooth", smooth_x, smooth_y, (linewidth = :curv,)),
         ("Sharp", sharp_x, sharp_y, (linewidth = :y, linewidthscale = 1.2)),
         ("Overlapping", loop_x, loop_y, (linewidth = :curv, linewidthscale = 0.7,
                                          alpha = 0.5))]

f = Figure(size = (740, 620))
for (j, g) in enumerate([:mesh, :segments]),
    (i, (name, x, y, kw)) in enumerate(cases)

    local ax = Axis(f[i, j])
    hidedecorations!(ax)
    kinetic!(ax, x, y; geometry = g, kw...)
end
for (j, g) in enumerate([:mesh, :segments])
    Label(f[0, j], ":$g", font = :bold, tellwidth = false, padding = (0, 0, 4, 0))
end
for (i, case) in enumerate(cases)
    Label(f[i, 0], case[1], font = :bold, rotation = π / 2, tellheight = false,
          padding = (0, 4, 0, 0))
end
colgap!(f.layout, 10); rowgap!(f.layout, 10)
f
```

Under `:segments` the width steps from one interval to the next, which shows as a beaded
edge on a smooth curve, and each joint is drawn twice, so a translucent stroke darkens at
every point and a sharp turn leaves a visible lattice. `:mesh` tapers continuously and
composites as a single surface, holding the alpha uniform along the stroke.

A third option, `:lines`, passes one width per point to a single `lines` call. GLMakie and
WGLMakie stroke that natively and draw much as `:mesh` does, so `:auto` (the default) picks
`:lines` on those two backends and `:mesh` on every other. CairoMakie cannot vary the width
within one path and throws rather than choosing a single width for the line, so `:lines` is
not drawn above.

Widths are pixel counts under every geometry, so a stroke keeps its thickness as the axis is
zoomed, and only the points set the axis limits.

## Spike raster

```@shortdocs; canonical=false
spikeraster
```

Spikes can be passed as a flat `(times, ids)` pair, as one spike-time vector per neuron, or
as a `Neuron × Time` boolean mask. `sortby` reorders the rows, which is usually what makes
structure visible in a population.

```@example TimeseriesMakie
Random.seed!(42)
rates = shuffle(range(2, 20, length = 40))          # Hz, one per neuron
spikes = [cumsum(randexp(300) ./ r) for r in rates] # exponential inter-spike intervals
spikes = [t[t .< 10] for t in spikes]               # keep the first 10 s

f = Figure(size = (900, 320))

ax = Axis(f[1, 1]; title = "Id order", xlabel = "Time (s)", ylabel = "Neuron")
spikeraster!(ax, spikes)

ax = Axis(f[1, 2]; title = "sortby = :rate", xlabel = "Time (s)")
spikeraster!(ax, spikes; sortby = :rate)

ax = Axis(f[1, 3]; title = "sortby = first", xlabel = "Time (s)")
spikeraster!(ax, spikes; sortby = first)

f
```

With `TimeseriesTools` loaded, a binary `ToolsArray` spike train can be passed directly and
the time axis is read from its `𝑡` lookup.

## PSTH

```@shortdocs; canonical=false
psth
```

```@example TimeseriesMakie
f = Figure(size = (720, 300))

ax = Axis(f[1, 1]; title = "Population rate", xlabel = "Time (s)", ylabel = "Spikes / s")
psth!(ax, reduce(vcat, spikes))

ax = Axis(f[1, 2]; title = "Per neuron, wider bins", xlabel = "Time (s)")
psth!(ax, reduce(vcat, spikes); binwidth = 0.5, nneurons = length(spikes))

f
```

## Rate map

```@shortdocs; canonical=false
ratemap
```

```@example TimeseriesMakie
S = falses(length(spikes), 1000)                    # Neuron × Time, 10 s at 100 Hz
for (i, t) in enumerate(spikes), tᵢ in t
    S[i, clamp(ceil(Int, tᵢ * 100), 1, 1000)] = true
end

f = Figure(size = (760, 300))

ax = Axis(f[1, 1]; title = "Unbinned", xlabel = "Sample", ylabel = "Neuron")
ratemap!(ax, S)

ax = Axis(f[1, 2]; title = "binwidth = 50", xlabel = "Sample")
p = ratemap!(ax, S; binwidth = 50)
Colorbar(f[1, 3], p)

f
```

A raw spike mask is mostly empty, so an unbinned rate map is hard to read; `binwidth` averages
over that many time columns and recovers the per-neuron rate.

## Spectrum

`spectrumplot` is provided by the `TimeseriesTools` extension, so it appears once
`TimeseriesTools` is loaded.

```@docs; canonical=false
spectrumplot
```

```@example TimeseriesMakie
Random.seed!(7)
t = 0.002:0.002:4
oscillations(t) = 3 .* sin.(2π .* 10 .* t) .+ 2 .* sin.(2π .* 40 .* t)

x = colorednoise(t; α = 1.2) .+ oscillations(collect(t))
X = cat([colorednoise(t; α = 1.2) .+ oscillations(collect(t)) for _ in 1:10]...; dims = 2)

f = Figure(size = (860, 320))

ax = Axis(f[1, 1]; xscale = log10, yscale = log10, xlabel = "Frequency (Hz)",
          ylabel = "Spectral density", title = "One trial, peaks marked")
spectrumplot!(ax, spectrum(x); peaks = 2, pwindow = 5, annotate = true)

ax = Axis(f[1, 2]; xscale = log10, yscale = log10, xlabel = "Frequency (Hz)",
          title = "Ten trials, median and IQR")
spectrumplot!(ax, spectrum(X))

f
```

`peaks` ranks candidates by prominence, and a candidate must be maximal over `pwindow`
samples to be considered at all. The default window of 10 is wide enough to miss a peak in a
finely resolved spectrum, as the 10 Hz component is here unless `pwindow` is lowered.

A multivariate spectrum is reduced to a line and a band, by default the median and the
interquartile range across columns; `average` and `width` replace either.

[`plotspectrum`](@ref) wraps the same recipe and sets the log scales, limits and labels
itself, so the axis above can be left to it:

```@example TimeseriesMakie
plotspectrum(spectrum(x); peaks = 2, pwindow = 5)
```
