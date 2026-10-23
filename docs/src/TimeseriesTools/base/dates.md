```@meta
CurrentModule = TimeseriesBase
```

# Dates

Time lookups can be `Date`/`DateTime` values (instants) or `Period`s (durations) rather than
numbers, in which case the series is a [`DateTimeseries`](@ref). A lookup built from a
`Dates` range is regular, so the series is also a [`RegularTimeseries`](@ref) and every
regular-series function applies.

```@example dates
using TimeseriesTools, Dates, Statistics
t = DateTime(2024, 1, 1):Hour(6):DateTime(2024, 12, 31)
y = Timeseries(sin.(2π .* (1:length(t)) ./ 4) .+ 0.1 .* randn(length(t)), t)
y isa DateTimeseries, y isa RegularTimeseries
```

## Sampling metadata

[`samplingperiod`](@ref) and [`duration`](@ref) return `Period`s. A rate needs a fixed
duration to divide into, so [`samplingrate`](@ref) and [`nyquist`](@ref) return a `Unitful`
quantity (a `Hour(6)` step gives `1/21600 s^-1`), and throw for a calendar period (`Year`,
`Month`, `Quarter`), which has no fixed length.

```@example dates
samplingperiod(y), Day(duration(y)), samplingrate(y)
```

## Windowing and grid repair

[`buffer`](@ref), [`window`](@ref), [`delayembed`](@ref) and [`coarsegrain`](@ref) work on a
`Dates` lookup; each window is labelled with the mean of its own time values, computed on
integer offsets since instants do not add.

```@example dates
daily = buffer(y, 4)      # 4 samples of 6 h: one buffer per day
times(daily)[1:3]
```

[`regularize`](@ref) repairs a nominally regular lookup that has drifted. On a `Dates`
lookup the fit runs on exact integer offsets, `atol` may be given as a `Period`, and the
default tolerance is exact, since a `Dates` lookup carries no float jitter. (The older
`rectify`, `rectifytime` and `matchdim` reject a `Dates` lookup and point here.)

```@example dates
jitter = Millisecond.(rand(-200:200, length(t)))
z = Timeseries(parent(y), collect(t) .+ jitter)   # irregular: every stamp is off by up to 0.2 s
z isa RegularTimeseries
```

```@example dates
r = regularize(z; atol = Second(1))
r isa RegularTimeseries, times(r)[1:2]
```

The grid is fitted by least squares over all the stamps, so it need not pass through the
first one; here it starts a few milliseconds before midnight.

## Calendar operations

Because the lookup is a calendar, DimensionalData's grouping works directly: here the
monthly mean.

```@example dates
monthly = mean.(groupby(y, 𝑡 => month))
```

`stitch` preserves an instant axis, continuing the calendar from the first series'
own start; a numeric or `Period` index restarts from the origin instead.
`regularize(...; zero = true)` deliberately returns a `Period` axis, since elapsed time is a
duration rather than an instant.

Saving to `.tsv` writes instants as ISO 8601 and periods as bare counts, recording the type in
the header so that [`loadtimeseries`](@ref) restores it; see [IO](io.md).

`Dates.Time` (a time of day) and lookups mixing several `Period` types are rejected with an
error rather than failing deep in the arithmetic.

## Reference

```@docs
DateTimeseries
```

`DateIndex` and `DateTimeIndex` are the corresponding lookup and dimension-tuple aliases, in
the pattern of [`TimeIndex`](@ref) and [`RegularTimeIndex`](@ref).
