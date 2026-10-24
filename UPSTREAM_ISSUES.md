# Issues found in the Timeseries packages during the documentation review

Review date: 2026-10-23/24. Packages reviewed at the `main` commits that the docs track:
TimeseriesTools v0.9.0 (`b469ef9`), TimeseriesBase v0.3.0 (`e2838bc`), TimeseriesMakie
v0.3.0 (`c864629`), Normalization v0.9.3 (`9017077`), MoreMaps v0.4.0 (`cfe125c`),
TimeseriesToolsSurrogates v0.1.0 (`9dd29fa`).

How they were found: reading every source file against the docs, building the site locally
on Julia 1.13.2, and running the behavioural checks in Julia. Items marked **verified** were
reproduced by running code; the rest were confirmed by reading the source.

None of these are fixed by the documentation changes in this repository; each needs a change
in the package named. The documentation works around them where it can.

## Summary

| ID | Package | Severity | Issue |
|---|---|---|---|
| B1 | TimeseriesBase / TimeseriesTools | Bug | In-place derivatives and `instantaneousfreq` throw on a unitful time axis |
| B2 | TimeseriesTools | Bug | `ComplexityMeasuresExt` calls `TimeseriesTools.decompose`, which does not exist |
| B3 | TimeseriesTools, TimeseriesToolsSurrogates | Usability | Both packages export `pointprocess!` |
| B4 | TimeseriesTools | Usability | `convolve` collides with `Distributions.convolve` |
| B5 | TimeseriesTools | Minor | `timescale` is an exported stub that always throws |
| B6 | Normalization | Typo | Unbalanced backtick in the `AbstractNormalization` docstring and README |
| B7 | TimeseriesBase | Typo | `TimeseriesBase.Uniful.convertconst` in a docstring |
| B8 | MoreMaps | Typo | Changelog footer links to a v0.5.0 that does not exist |
| B9 | TimeseriesTools | Bug | `:schild` spike spectra return the periodogram squared, and the estimator mutates its input |
| D1 | TimeseriesBase | Docstring | The `stitch` docstring is attached to `_stitchstart` |
| D2 | TimeseriesBase, TimeseriesTools | Docstring | 16 docstring examples use `@example 1` fences with `julia>` prompts and never run |
| D3 | TimeseriesBase | Docstring | `frequnit` example calls `fft(ts)` and `frequnits`, neither of which exists |
| D4 | TimeseriesBase, TimeseriesTools | Docstring | Cross-references that cannot resolve from the module they are written in |
| D5 | TimeseriesBase, TimeseriesTools | Docstring | Exported aliases and `spikefft` have no docstring |
| D6 | TimeseriesMakie | Docstring | Attribute docs inherited from Makie reference `Makie.Linestyle` |
| D7 | MoreMaps | Docstring | Four extension doctests fail, and the test suite never runs them |

## Bugs

### B1. In-place derivatives fail on a unitful time axis (verified)

`TimeseriesBase/src/Utils.jl:1113`, in `_deriv!`:

```julia
f!(x; dims, kwargs...)
x ./= dt
```

When the time lookup carries units, `dt` is a `Quantity` (for example `0.001 s`) while the
array holds plain `Float64`s, so the in-place division tries to store `s^-1` values in a
`Float64` array. Every in-place derivative inherits this: `centralderiv!`, `leftderiv!`,
`rightderiv!`. `TimeseriesTools.instantaneousfreq` (`ext/DSPExt.jl:17`) calls
`centralderiv!` on the unwrapped phase, so it fails for the same input. The out-of-place
`centralderiv` handles units correctly.

```julia
using TimeseriesTools, DSP, Unitful
t = (0:0.001:2) * u"s"
x = Timeseries(sin.(2π * 10 .* ustrip.(t)), t)
instantaneousfreq(x)   # DimensionError:  and s^-1 are not dimensionally compatible
centralderiv!(copy(x)) # same error
centralderiv(x)        # works: eltype Quantity{Float64, 𝐓^-1, ...}
```

With unitful values too (`x * u"V"`) the message is `DimensionError: V and 62.67 V s^-1 are
not dimensionally compatible`.

Suggested fix: `_deriv!` cannot change the element type, so either divide by `ustrip(dt)` and
document that the in-place form drops the time unit, or throw an `ArgumentError` naming the
out-of-place form (as the method already does for a `Dates.Period` step). `instantaneousfreq`
should call the out-of-place `centralderiv`, which costs one allocation and works for every
input.

The docs page on filtering uses a unitless time axis because of this.

### B2. `ComplexityMeasuresExt` references an undefined function

`TimeseriesTools/ext/ComplexityMeasuresExt.jl:9`:

```julia
function allprobabilities_and_outcomes(x::AbstractToolsArray, args...; kwargs...)
    return allprobabilities_and_outcomes(TimeseriesTools.decompose(x)..., args...; kwargs...)
end
```

`decompose` is not defined anywhere in TimeseriesTools (`isdefined(TimeseriesTools,
:decompose)` is `false`). The only `decompose` for these arrays is
`Makie.GeometryBasics.decompose` in TimeseriesMakie's extension, which is a different
binding. Calling this method throws `UndefVarError: decompose`. The `StateSpaceSet`
method in the same file is fine.

Suggested fix: define `decompose(x::AbstractToolsArray) = (map(parent, lookup(x))...,
parent(x))` in TimeseriesTools itself and have the TimeseriesMakie extension reuse it. The
extension has no tests, which is how this went unnoticed.

The docs describe the extension as providing only the `StateSpaceSet` conversion.

### B3. Two packages export `pointprocess!`

`TimeseriesTools/src/SpikeTrains.jl:3` and
`TimeseriesToolsSurrogates/src/TimeseriesToolsSurrogates.jl:15` both export a
`pointprocess!` with the same signature and meaning. After `using TimeseriesTools,
TimeseriesToolsSurrogates`, which the surrogates README recommends, an unqualified call is
an error (`UndefVarError: pointprocess! not defined` with a note that both packages export
it). Suggested fix: TimeseriesToolsSurrogates already has a TimeseriesTools extension; either
stop exporting its copy, or move the function to TimeseriesBase so both can share it.

### B4. `convolve` collides with Distributions

`TimeseriesTools` exports `convolve` (`src/SpikeTrains.jl:3`). `Distributions` also exports
`convolve`, and TimeseriesTools' own `DistributionsExt` requires users to load Distributions
to use `gammarenewal` and `pointprocess!`. With both loaded, `convolve(st, 0.01)` is
ambiguous. Suggested fix: rename to something like `spikedensity`, or do not export it.

### B5. `timescale` is an exported stub that always throws

`TimeseriesTools/src/TimeseriesTools.jl:62`. The function dispatches to
`timescale(x, Val{method}())`, for which no method exists, so every call is a `MethodError`.
The docstring says so. Either implement `:ac_crossing` or do not export the stub.

### B6. Unbalanced backtick in Normalization

`Normalization/src/Normalization.jl:71` and `README.md:112`:
`- inverse(N::Union{...})` returns ...` has a closing backtick with no opening one, so the
rendered line is garbled.

### B7. `Uniful` typo

`TimeseriesBase/src/UnitfulTools.jl:48`: the `convertconst` docstring header reads
`TimeseriesBase.Uniful.convertconst`.

### B8. MoreMaps changelog footer

`MoreMaps/CHANGELOG.md:105-106` define link references for `v0.5.0` although the latest
section is 0.4.0.

### B9. The `:schild` spike spectrum squares the periodogram twice (verified)

`spikefft(t, Val(:schild))` (`TimeseriesTools/src/Spectra.jl:200-206`) returns

```julia
f -> (sum(cos.(2π * f .* t))^2 + sum(sin.(2π * f .* t))^2) / T
```

which is already the squared magnitude of the transform divided by the duration, that is, a
periodogram. The spike-train `_energyspectrum` (`Spectra.jl:231`) then applies
`abs.(...) .^ 2` to it, so `powerspectrum(st, fs; method = :schild)` returns the periodogram
*squared*. The Parseval normalisation that follows rescales the total but not the shape:
every feature is exaggerated (a dip to half the high-frequency power shows as a dip to a
quarter), and the estimate is much noisier than a periodogram, because the square of an
exponentially distributed value has a relative standard deviation of about 2.2 rather than 1.
Averaging twenty independent trains still leaves a spiky curve; the documentation page now
averages a hundred to show the shape.

The same function also runs `t .-= minimum(t)` on its argument, so it mutates the vector of
spike times it is given.

Reproduction (seed 0, `st = gammarenewal(400, 2.0, 0.025)`, `fs = 0.5:0.5:60`): dividing
`powerspectrum(st, fs; method = :schild)` by a hand-computed periodogram
`[(sum(cos.(2π * f .* t))^2 + sum(sin.(2π * f .* t))^2) / T for f in fs]` gives a ratio that
varies across frequency, while dividing by the periodogram squared gives a constant.

Suggested fix: have `spikefft` return the transform itself, `f -> sum(cis.(-2π * f .* t))`,
and keep the `abs2` in `_energyspectrum` (or drop the `.^ 2` there), and copy `t` before
shifting it.

## Docstring defects

These affect the documentation site directly: the build at
`brendanjohnharris.github.io/TimeseriesDocs.jl` includes these docstrings.

### D1. The `stitch` docstring is attached to the wrong binding

`TimeseriesBase/src/Utils.jl:1356-1370`. A block of comment lines sits between the
docstring that begins `stitch(x, args...)` and the next definition, which is
`_stitchstart(t, dt) = dt`. The parser drops the comments, so the docstring documents
`_stitchstart`; `stitch` has none, and `@docs stitch` fails with "no docs found". Move the
comment above the docstring (the Operators.jl file already notes this hazard). The docs
describe `stitch` in prose for now.

### D2. Docstring examples that never run

Sixteen docstrings contain fenced blocks of the form

    ```@example 1
    julia> using TimeseriesBase, Unitful;
    julia> t = 1:100
    ...
    ```

`@example` is not evaluated inside docstrings, and the `julia>` prompts mean the block is
not valid as a plain example either, so the code is never checked and renders as a code
block with stray prompts. DocumenterVitepress warns about each one. Locations:

- `TimeseriesBase/src/TimeSeries.jl:149, 167` (`Timeseries`, two methods)
- `TimeseriesBase/src/Utils.jl:74, 89, 104, 124, 140, 157, 172` (`times`, `step`,
  `samplingrate`, `samplingperiod`, `nyquist`, `duration`, `Interval`)
- `TimeseriesBase/src/UnitfulTools.jl:53, 92, 149, 165, 183, 200` (`convertconst`,
  `UnitfulTimeseries`, `dimunit`, `timeunit`, `frequnit`, `unit`)
- `TimeseriesTools/src/Spectra.jl:100` (`_energyspectrum`)

Converting them to `jldoctest` blocks makes them run under `Documenter.doctest` in the
package test suites and in this docs build, which now sets `doctest = true`. A ready-made
conversion is in `docs/upstream-patches/` in this repository; see the README there for how
it was verified.

### D3. `frequnit` example references functions that do not exist

`TimeseriesBase/src/UnitfulTools.jl:188-189`: `sp = fft(ts)` and `frequnits(sp) == u"Hz"`.
There is no `fft` method for a time series and no `frequnits`. Replace with
`frequnit(powerspectrum(ts, ...))` or a `Spectrum` built directly.

### D4. Cross-references that cannot resolve

Documenter resolves an `@ref` inside a docstring relative to the module the docstring is
written in. These point at names that module does not have, so they render as plain text
and the build warns:

- `TimeseriesBase/src/ToolsArrays.jl:159, 162, 213, 228`: the `𝑡`, `Log𝑓` and `Log10𝑓`
  docstrings reference `AbstractTimeseries`, `Timeseries`, `times`, `samplingrate` and
  `freqs`, which live in sibling submodules. Qualify them, e.g.
  `[`TimeseriesBase.times`](@ref)`.
- `TimeseriesBase/src/DatesTools.jl:30, 35`: `DateIndex` has no docstring (see D5) and
  `stitch` has none because of D1.
- `TimeseriesBase/src/Utils.jl:222, 227`: `[`AbstractArray`](@ref)` points at `Core`.
  Use plain code formatting.
- `TimeseriesTools/ext/OptimExt.jl:141, 305, 314`: `_held`, `freelabels` and
  `mapple_residuals` are not imported into `OptimExt`, so the references fail even though
  the docstrings exist. Add them to the `import TimeseriesTools: ...` line.
- `TimeseriesTools/src/Mapple.jl:195, 204`: the `_held` docstring references `mapple!` and
  `_bic`, neither of which has a docstring.

### D5. Exported names without a docstring

`@docs` cannot include them, so the site describes them in prose:

- `TimeseriesBase/src/TimeSeries.jl:82, 140, 141, 185, 186`: `MultidimensionalIndex`,
  `UnivariateSpikeTrain`, `MultivariateSpikeTrain`, `UnivariateRegular`,
  `MultivariateRegular`.
- `TimeseriesBase/src/Spectra.jl:107, 111, 113`: `AbstractSpectrogram`,
  `MultivariateSpectrogram`, `RegularSpectrogram`.
- `TimeseriesBase/src/DatesTools.jl:10, 16`: `DateIndex`, `DateTimeIndex`.
- `TimeseriesTools/src/SpikeTrains.jl`: `spikefft` is exported but undocumented.

### D6. `Makie.Linestyle` references in TimeseriesMakie

The recipes inherit Makie's attribute docstrings through `get_drop_attrs`, and Makie's
`linestyle` docstring links to `Makie.Linestyle`, which is not part of this site. Six warnings
per build, harmless. Documenting `Makie.Linestyle` on the reference page, or filtering that
attribute's docstring, would silence them.

### D7. MoreMaps extension doctests fail (verified)

Running the docs build with `doctest = true` found four failures in MoreMaps, all in
extension docstrings that `doctest(MoreMaps; manual = false)` in its test suite does not
cover, since that call doctests the main module only:

- `ext/TermExt.jl:21-44`: the `TermLogger` example draws a progress bar, so the doctest's
  expected empty output never matches the escape codes Term writes.
- `ext/DaggerExt.jl:28-61`: `Daggermap(; single = 1, ...)` uses an option Dagger has
  deprecated, so a three-line warning lands in the output. The surrounding prose also lists
  `single` as an option. Use `scope = Dagger.scope(worker = 1)`.
- `ext/ProgressLoggingExt.jl:25-53`, twice: the expected representation of
  `ProgressLogger(5)` is stale (`LogLogger` now prints all of its fields) and contains the
  logger's UUID, which is random. The block is also marked `output = false`, which has no
  effect on `julia>`-style doctests.

`docs/upstream-patches/MoreMaps-doctests.patch` fixes all three: the `TermLogger` example runs
its `map` inside `redirect_stdout(devnull)` and checks the result, since a progress bar is drawn
for a terminal and cannot be compared as text; the `Daggermap` example passes
`scope = Dagger.scope(worker = 1)`; the `ProgressLogger` example ends the two constructor lines
with `;` so the representations are not compared. Until it lands, this docs build treats a
doctest failure as a warning rather than an error.

## Documentation-repository issues fixed in this review

For completeness, since they were found at the same time:

- `docs/package.json` allowed `@nolebase/vitepress-plugin-enhanced-readabilities` 2.21,
  which requires VitePress 2; `npm install` failed. Pinned to `~2.18.2`.
- The docs environment lacked DSP, DataInterpolations and Distributions, so four tutorial
  and spike-train examples failed to run on the published site.
- The operators example mutated a `UnitRange`.
- The quick start plotted an undefined variable and called `colorednoise(t, u"s")`, which
  builds an invalid multivariate array.
- `hilbert`, `fanofactor` and `generalizedphase` were documented under names that do not
  exist; `stoic` and `sttc` had each other's description; `analyticphase` was described as
  unwrapped.
- 49 exported docstrings were not included on the site.
