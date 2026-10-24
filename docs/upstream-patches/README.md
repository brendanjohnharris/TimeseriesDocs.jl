# Upstream patches

Changes to the documented packages that the documentation review produced, kept here until
they are applied upstream. Each file is a `git diff` against the package's `main` branch at
the commit named in `../../UPSTREAM_ISSUES.md`.

| Patch | Package | What it does |
|---|---|---|
| `TimeseriesBase-doctests.patch` | TimeseriesBase.jl | Converts the fifteen `@example 1` docstring blocks (with `julia>` prompts) into `jldoctest` blocks that run; replaces the `frequnit` example that called functions which do not exist; fixes the `Uniful` typo (issues D2, D3, B7) |
| `TimeseriesTools-doctests.patch` | TimeseriesTools.jl | Converts the `_energyspectrum` docstring example into a `jldoctest` block, replacing `RegularTimeseries(x, t)`, which is an alias rather than a constructor, with `Timeseries(x, t)` (issue D2) |
| `MoreMaps-doctests.patch` | MoreMaps.jl | Repairs the four extension doctests that fail: the `TermLogger` example draws its progress bar into `devnull` and checks the result instead of comparing terminal escape codes, the `Daggermap` example uses a `scope` instead of the deprecated `single` option, and the `ProgressLogger` example no longer compares a stale printed representation containing a random UUID (issue D7) |

Apply with `git apply <patch>` from the package root. Each patch was verified by applying it to
the package sources in a local depot and running this repository's doctest-only build
(`DOCS_DOCTEST=only julia --project=docs docs/make.jl` on Julia 1.13.2, against the package
commits listed in `../../UPSTREAM_ISSUES.md`). That build doctests every module the site
documents, extensions included, and reported no failures with all three patches applied.

MoreMaps' test suite runs `doctest(MoreMaps; manual = false)`, which covers the main module
only; the extension docstrings are checked by nothing but this docs build. After applying the
patch, extend the test to the extensions (load `Term`, `Dagger`, `ProgressLogging`,
`OhMyThreads` and `Polyester` in the test environment and pass their modules via
`makedocs(; doctest = :only, modules = [MoreMaps, Base.get_extension.(...)...])`).

Once applied, add to each package's test suite so the examples stay correct:

```julia
using Documenter
DocMeta.setdocmeta!(TimeseriesBase, :DocTestSetup, :(using TimeseriesBase, Unitful); recursive = true)
doctest(TimeseriesBase; manual = false)
```

The documentation build in this repository already runs with `doctest = true`, so the
converted blocks are also checked on every docs build after the patches land.
