```@meta
CurrentModule = TimeseriesBase
```

# Time series

The core type hierarchy. Every concrete time-series type is a subtype of
[`AbstractTimeseries`](@ref), specialised by regularity (regular vs irregular sampling)
and dimensionality (univariate vs multivariate). The names below are type *aliases* for a
[`ToolsArray`](@ref) with a particular kind of time lookup, so a value can belong to several
of them at once: a regularly sampled vector is a `UnivariateTimeseries`, a
`RegularTimeseries` and a `UnivariateRegular`.

```
AbstractTimeseries                 any array whose first dimension is 𝑡
├── UnivariateTimeseries           1-D
├── MultivariateTimeseries         2-D, time on the first dimension
├── RegularTimeseries              time lookup is an AbstractRange
│   ├── UnivariateRegular
│   ├── MultivariateRegular
│   └── MultidimensionalTimeseries every dimension is regularly sampled
├── IrregularTimeseries            time lookup is any sorted vector
├── UnitfulTimeseries              time lookup carries Unitful units (see Unitful integration)
├── DateTimeseries                 time lookup holds Dates values (see Dates)
└── SpikeTrain                     Bool values: the lookup holds the spike times
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

## From differential-equation solutions

With `SciMLBase` loaded (it comes with any solver package, such as `OrdinaryDiffEq`),
`Timeseries` accepts a solution object directly. The time points become the lookup, each
state variable a column, and the solver metadata (`alg`, `retcode`) is stored in the array's
metadata. Duplicate time steps, as produced by a `SavingCallback`, are split off and kept
under `:callback_values`. An `EnsembleSolution` becomes a vector of time series over an
[`Obs`](@ref) dimension.

```julia
using OrdinaryDiffEq, TimeseriesTools
f(u, p, t) = [u[2], -u[1]]
sol = solve(ODEProblem(f, [1.0, 0.0], (0.0, 10.0)), Tsit5(); saveat = 0.01)
x = Timeseries(sol)            # a MultivariateTimeseries with Var(1:2)
metadata(x)[:retcode]
```

## Reference

```@docs
AbstractTimeseries
UnivariateTimeseries
MultivariateTimeseries
RegularTimeseries
IrregularTimeseries
MultidimensionalTimeseries
TimeIndex
RegularIndex
RegularTimeIndex
IrregularIndex
IrregularTimeIndex
Timeseries
```

```@docs; canonical=false
SpikeTrain
```

The remaining aliases are intersections of the above and have no docstring of their own:
`UnivariateRegular` and `MultivariateRegular` combine `RegularTimeseries` with the two
dimensionalities; `UnivariateSpikeTrain` and `MultivariateSpikeTrain` do the same for
`SpikeTrain`; and `MultidimensionalIndex` is the dimension tuple behind
`MultidimensionalTimeseries`.
