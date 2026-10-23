```@meta
CurrentModule = TimeseriesTools
```

# Filtering and analytic signals

[`bandpass`](@ref), [`highpass`](@ref) and [`lowpass`](@ref) apply zero-phase Butterworth
filters (default order 4, forward and backward with `filtfilt`) when
[`DSP`](https://github.com/JuliaDSP/DSP.jl) is loaded. The sampling rate is read from the
time axis of a `RegularTimeseries`, so the corner frequencies are given in the inverse of
the time units: in Hz for a series sampled in seconds. A multivariate series is filtered
column by column.

```@example filt
using TimeseriesTools, DSP, Random, CairoMakie, TimeseriesMakie
Random.seed!(0)
t = 0:0.001:5                                     # 5 s at 1 kHz
carrier = sin.(2π * 10 .* t)                      # a 10 Hz tone...
envelope = 1 .+ 0.5 .* sin.(2π * 0.5 .* t)        # ...whose amplitude is modulated at 0.5 Hz
x = Timeseries(envelope .* carrier .+ 0.5 .* randn(length(t)), t)
xb = bandpass(x, [8, 12])                         # 8–12 Hz
```

The band can be a two-element vector, a tuple, or an interval (`8 .. 12`); for a plain
array, pass the sampling rate as the second argument. Without `DSP` loaded these functions
have no methods, except that the one-argument form `bandpass(x)` returns `x` unchanged so a
pipeline with an optional filtering step stays valid.

## Analytic signal

`DSP.hilbert` gains a method for time series, returning the complex analytic signal with the
array's dimensions and units intact. From it, [`analyticamplitude`](@ref) gives the envelope,
[`analyticphase`](@ref) the instantaneous phase wrapped to `(-π, π]` (use `DSP.unwrap` for a
continuous phase), and [`instantaneousfreq`](@ref) (alias `instantfreq`) the rate of change
of the unwrapped phase in cycles per unit time. All three are only meaningful on a narrowband
signal, so filter first.

```@example filt
A = analyticamplitude(xb)
ϕ = analyticphase(xb)
f = instantaneousfreq(xb)

fig = Figure(size = (700, 500))
ax1 = Axis(fig[1, 1]; ylabel = "Signal")
lines!(ax1, x; color = (:gray, 0.5), label = "raw")
lines!(ax1, xb; label = "8–12 Hz")
lines!(ax1, A; color = :black, linewidth = 2, label = "envelope")
axislegend(ax1; position = :rt)
ax2 = Axis(fig[2, 1]; xlabel = "Time (s)", ylabel = "Instantaneous frequency (Hz)", limits = (nothing, (5, 15)))
lines!(ax2, f)
linkxaxes!(ax1, ax2)
fig
```

[`isoamplitude`](@ref) keeps only the phase of a signal, returning `sin` of the analytic
phase so the result oscillates between `-1` and `1` with the original timing.

## Stitching segments

[`phasestitch`](@ref) concatenates several time series at phase-matched points, so that an
oscillation continues smoothly across each join rather than jumping. It trims a fraction of
each segment at the interfaces (`trim`) to suppress Hilbert edge effects, and matches phases
to within `tol`. Given a passband, the phases are computed on a filtered copy while the raw
segments are what gets stitched.

```@example filt
a = x[𝑡 = 0 .. 1.3]
b = x[𝑡 = 2.0 .. 3.6]
s = phasestitch([a, b], [8, 12])
duration(a) + duration(b), duration(s)
```

`GeneralizedPhase.generalized_phase` (loaded with `GeneralizedPhase`) is a wideband
alternative to the Hilbert phase that gains a method for `RegularTimeseries`, operating
column by column.

## Reference

```@docs
bandpass
highpass
lowpass
analyticphase
analyticamplitude
instantaneousfreq
isoamplitude
phasestitch
```
