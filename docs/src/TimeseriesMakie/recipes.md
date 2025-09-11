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
using Statistics
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
  f = Figure(size = (400, 400))

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

