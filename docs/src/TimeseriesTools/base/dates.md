```@meta
CurrentModule = TimeseriesBase
```

# Dates

Time lookups can be `Date`/`DateTime` values rather than numbers, in which case the
series is a [`DateTimeseries`](@ref). [`samplingperiod`](@ref) returns a `Period`,
[`duration`](@ref) returns a `Period`.

```@example dates
using TimeseriesTools, Dates
t = DateTime(2024):Day(1):DateTime(2025)
y = Timeseries(1:length(t), t)
y isa RegularTimeseries, samplingperiod(y)
```

## Reference

```@docs
DateIndex
DateTimeIndex
DateTimeseries
```
