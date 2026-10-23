```@meta
CurrentModule = TimeseriesBase
```

# Operators

Lag (`ℬ`), lead (`ℒ`), and shift-time (`𝒯`) operators in the time-series tradition. The
shape characters are exported; `ℬ!`/`ℒ!` are in-place forms, so they need an array that can
be written to (a `collect`ed vector rather than a range).

```@example ops
using TimeseriesTools
x = Timeseries(collect(1.0:5.0), 0.0:0.1:0.4)
ℬ(x)         # one-step lag: ℬ(x)[i] == x[i-1], wrapping around
```

```@example ops
ℒ(x)         # one-step lead, the inverse of ℬ
```

`𝒯` moves the time axis rather than the values, and its one-argument form returns a function,
which is convenient for mapping over lags:

```@example ops
times(𝒯(x, 1.0)), times(𝒯(-0.1)(x))
```

## Reference

```@docs
ℬ
ℬ!
ℒ
ℒ!
𝒯
```
