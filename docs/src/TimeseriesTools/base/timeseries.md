```@meta
CurrentModule = TimeseriesBase
```

# Time series

The core type hierarchy. Every concrete time-series type is a subtype of
[`AbstractTimeseries`](@ref), specialised by regularity (regular vs irregular sampling)
and dimensionality (univariate vs multivariate).

```
AbstractTimeseries
├── UnivariateTimeseries   (1-D)
├── MultivariateTimeseries (N-D, time on first dimension)
├── RegularTimeseries      (lookup is an AbstractRange)
│   ├── UnivariateRegular
│   └── MultivariateRegular
└── IrregularTimeseries    (lookup is any sorted vector)
```

The constructor is [`Timeseries`](@ref): the first argument is the data, the second is
the time lookup (or `𝑡(...)`), and any further arguments are extra dimensions.

```@example types
using TimeseriesTools
x = Timeseries(rand(100),    0.0:0.01:0.99)            # regular, univariate
m = Timeseries(rand(100, 4), 0.0:0.01:0.99, Var(1:4))  # regular, multivariate
i = Timeseries(rand(50),     sort(rand(50)))           # irregular, univariate
x isa RegularTimeseries, m isa MultivariateRegular, i isa IrregularTimeseries
```

Time lookups can be plain numbers (`Float64`), unitful quantities (see [Unitful
integration](unitful.md)), or `DateTime`s (see [Dates](dates.md)).

[`SpikeTrain`](@ref) is a special irregular type whose values are absent: a spike train
is fully specified by its time stamps. See [Spike trains](../analysis/spiketrains.md).

## Reference

```@docs
AbstractTimeseries
UnivariateTimeseries
MultivariateTimeseries
RegularTimeseries
UnivariateRegular
MultivariateRegular
IrregularTimeseries
TimeIndex
RegularIndex
RegularTimeIndex
IrregularIndex
IrregularTimeIndex
Timeseries
MultidimensionalIndex
MultidimensionalTimeseries
SpikeTrain
MultivariateSpikeTrain
UnivariateSpikeTrain
```
