```@meta
CurrentModule = TimeseriesBase
```

# Operators

Lag (`ℬ`), lead (`ℒ`), and shift-time (`𝒯`) operators in the time-series tradition. The
shape characters are exported; `ℬ!`/`ℒ!` are in-place forms.

```@example ops
using TimeseriesTools
x = Timeseries(1:5, 0.0:0.1:0.4)
ℬ(x)         # one-step lag
```

## Reference

```@docs
ℬ
ℬ!
ℒ
ℒ!
𝒯
```
