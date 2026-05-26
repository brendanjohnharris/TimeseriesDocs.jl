```@meta
CurrentModule = TimeseriesTools
```

# Extensions

`TimeseriesTools` exposes most of its analysis surface as package extensions. The
function stubs live in core, but each method is only loaded when you `using` the
corresponding package. This keeps the base load light and prevents the package from
pulling unwanted heavy dependencies (`CUDA`, `Makie`, `DSP`, …) into every project.

| Extension | Loaded by | Provides |
|---|---|---|
| `DSPExt` | `using DSP` | [`bandpass`](@ref), [`highpass`](@ref), [`lowpass`](@ref), [`hilbert`](@ref), [`analyticphase`](@ref), [`analyticamplitude`](@ref), [`instantaneousfreq`](@ref), [`phasestitch`](@ref), [`downsample`](@ref) |
| `DataInterpolationsExt` | `using DataInterpolations` | [`interpolate`](@ref), [`upsample`](@ref), [`resample`](@ref), [`impute`](@ref) (1-D / per-axis) |
| `DataInterpolationsNDExt` | `using DataInterpolationsND` | [`interpolate`](@ref), [`upsample`](@ref), [`resample`](@ref) (joint multi-axis) |
| `ContinuousWaveletsExt` | `using ContinuousWavelets` | [`waveletspectrogram`](@ref) |
| `CUDAExt` | `using CUDA, ContinuousWavelets` | GPU-accelerated wavelet transform |
| `AutocorrelationsExt` | `using Autocorrelations` | `fftacf`, `dotacf`, [`msdist`](@ref) |
| `ComplexityMeasuresExt` | `using ComplexityMeasures` | apply estimators directly to `AbstractTimeseries` |
| `GeneralizedPhaseExt` | `using GeneralizedPhase` | `generalizedphase` |
| `NaturalNeighboursExt` | `using NaturalNeighbours` | 2-D scattered interpolation |
| `SignalDecompositionExt` | `using SignalDecomposition` | trend/oscillation decomposition |
| `OptimExt` | `using Optim` | MAPPLE refinement ([`fit!`](@ref)) |
| `BootstrapExt` | `using Bootstrap` | [`bootstrapmean`](@ref), [`bootstrapmedian`](@ref), [`bootstrapaverage`](@ref) |

## Why extensions?

- **Faster cold start**: no precompile-time cost for capabilities you don't use.
- **No version churn**: heavy deps (CUDA, Makie, DSP) move quickly; a weak dep means
  TimeseriesTools doesn't force a particular version on the rest of your project.
- **Discoverable failure mode**: calling `bandpass(x)` without `using DSP` returns `x`
  unchanged (the stub) rather than throwing a `MethodError`. (See the warning at the top
  of each function's docstring.)
