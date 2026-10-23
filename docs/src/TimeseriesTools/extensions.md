```@meta
CurrentModule = TimeseriesTools
```

# Extensions

`TimeseriesTools` exposes most of its analysis surface as package extensions. The
function stubs live in core, but each method is only loaded when you `using` the
corresponding package. This keeps the base load light and prevents the package from
pulling unwanted heavy dependencies (`CUDA`, `Makie`, `DSP`, …) into every project.

## TimeseriesTools

| Extension | Loaded by | Provides |
|---|---|---|
| `DSPExt` | `using DSP` | [`bandpass`](@ref), [`highpass`](@ref), [`lowpass`](@ref), `DSP.hilbert` on time series, [`analyticphase`](@ref), [`analyticamplitude`](@ref), [`instantaneousfreq`](@ref), [`isoamplitude`](@ref), [`phasestitch`](@ref), [`downsample`](@ref) |
| `DataInterpolationsExt` | `using DataInterpolations` | [`interpolate`](@ref), [`upsample`](@ref), [`resample`](@ref), [`impute`](@ref) (1-D, per axis) |
| `DataInterpolationsNDExt` | `using DataInterpolationsND` | [`interpolate`](@ref), [`upsample`](@ref), [`resample`](@ref) (joint fit over several axes) |
| `NaturalNeighboursExt` | `using NaturalNeighbours` | [`interpolate`](@ref) for a 2-D array by natural-neighbour (Sibson) interpolation |
| `ContinuousWaveletsExt` | `using ContinuousWavelets` | [`waveletspectrogram`](@ref) |
| `CUDAExt` | `using CUDA` | `CuArray(x::AbstractTimeseries)`, which moves the data to the GPU and keeps the dimensions. `waveletspectrogram` of such an array stays on the device |
| `DistributionsExt` | `using Distributions` | [`pointprocess!`](@ref), [`gammarenewal`](@ref), [`gammarenewal!`](@ref) |
| `AutocorrelationsExt` | `using Autocorrelations` | `fftacf`, `dotacf` (and their `!` forms) on time series, returning a series indexed by lag, and [`msdist`](@ref) |
| `BootstrapExt` | `using Bootstrap` | [`bootstrapmean`](@ref), [`bootstrapmedian`](@ref), [`bootstrapaverage`](@ref) |
| `ComplexityMeasuresExt` | `using ComplexityMeasures` | `StateSpaceSet(x::AbstractToolsArray)`, so ComplexityMeasures' estimators accept the package's arrays |
| `GeneralizedPhaseExt` | `using GeneralizedPhase` | `GeneralizedPhase.generalized_phase` on a `RegularTimeseries`, column by column |
| `OptimExt` | `using Optim, ForwardDiff` | MAPPLE refinement ([`fit!`](@ref)) and uncertainties ([`vcov`](@ref), [`stderror`](@ref)) |

Loading an extension package does not change the way you call these functions: `downsample(x, 4)`
is written the same way whether or not `DSP` is loaded, but it only has a method once it is.

## TimeseriesBase

Re-exported by `TimeseriesTools`, with two extensions of its own.

| Extension | Loaded by | Provides |
|---|---|---|
| `JLD2Ext` | `using JLD2` | [`loadtoolsarray`](@ref) and [`toolsarray_typemap`](@ref), which load a stored array whose custom dimension types are not defined in the current session. `JLD2` is also the default backend of [`savetimeseries`](@ref) |
| `SciMLBaseExt` | `using SciMLBase` (or a solver package such as `OrdinaryDiffEq`) | `Timeseries(sol)` for an ODE solution, and for an `EnsembleSolution`. See [Time series](base/timeseries.md#From-differential-equation-solutions) |

## Other packages in the family

| Package | Extension | Loaded by | Provides |
|---|---|---|---|
| `TimeseriesMakie` | `TimeseriesToolsExt` | `using TimeseriesTools` | `plot` of a `ToolsArray` picks `lines`, `heatmap` or `volume`; the spike recipes and [`spectrumplot`](@ref TimeseriesMakie.spectrumplot) accept labelled arrays. See [TimeseriesMakie](../TimeseriesMakie/index.md) |
| `TimeseriesToolsSurrogates` | `TimeseriesToolsExt` | `using TimeseriesTools` | `surrogenerator` on a `SpikeTrain` or `ToolsArray` returns the same type. See [Surrogates](analysis/surrogates.md) |
| `Normalization` | `DimensionalDataExt` | `using DimensionalData` | `UnitEnergy` accounts for the grid spacing of a regularly sampled array |
| `Normalization` | `UnitfulExt` | `using Unitful` | Fitting and normalizing arrays of `Quantity` values |
| `Normalization` | `DataFramesExt` | `using DataFrames` | `fit`, `normalize!` and `denormalize!` on a `DataFrame` |
| `MoreMaps` | `DaggerExt`, `OhMyThreadsExt`, `PolyesterExt` | `using Dagger` / `OhMyThreads` / `Polyester` | The `Daggermap`, `OhMyThreaded` and `Polyestered` backends. See [Backends](../MoreMaps/backends.md) |
| `MoreMaps` | `ProgressLoggingExt`, `TermExt` | `using ProgressLogging` / `Term` | The `ProgressLogger` and `TermLogger` progress loggers. See [Progress](../MoreMaps/progress.md) |
| `MoreMaps` | `DimensionalDataExt` | `using DimensionalData` | `map` over `Dimension` arguments. See [Expansions](../MoreMaps/expansion.md#Dimension-sweeps) |

## Why extensions?

- **Faster cold start**: no precompile-time cost for capabilities you don't use.
- **No version churn**: heavy deps (CUDA, Makie, DSP) move quickly; a weak dep means
  TimeseriesTools doesn't force a particular version on the rest of your project.
- **A clear failure mode**: calling an extension method before loading its package throws a
  `MethodError`, and `TimeseriesTools` adds a hint naming the package to load:

```julia-repl
julia> using TimeseriesTools

julia> impute(Timeseries(randn(100), 0.0:0.01:0.99))
ERROR: MethodError: no method matching impute(::ToolsArray{Float64, 1, …})
The function `impute` exists, but no method is defined for this combination of argument types.

Hint: calling `impute` requires the DataInterpolationsExt extension. Run `using DataInterpolations` to enable it.
```

The single-argument forms of `bandpass`, `highpass` and `lowpass` are the one exception:
`bandpass(x)` returns `x` unchanged, so an optional filtering step in a pipeline stays valid
without `DSP`.
