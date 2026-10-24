# Registering MoreMaps v0.4.0: what has to happen first

Checked on 2026-10-24 against MoreMaps `main` (commit `cfe125c`, fourteen commits after the
`v0.3.0` tag) and the General registry as of the same day.

## Where things stand

Nothing in the registry's rules blocks the release today. The automatic checks that
JuliaRegistries' AutoMerge runs on a new version all pass on the current `main`:

| Check | State |
|---|---|
| Version number | `Project.toml` already says `0.4.0`; 0.3.0 is the newest registered version, so 0.4.0 is a valid next step (a minor bump, which is the breaking bump for a 0.x package, and the changelog lists a breaking change to justify it) |
| Compat entries | Every dependency and weak dependency has one, each with an upper bound: Dagger `0.19`, DimensionalData `0.26 - 0.30`, OhMyThreads `0.7, 0.8`, Polyester `0.7`, ProgressLogging `0.1`, Term `2`, the four standard libraries and `julia` at `1.10` |
| Repository | URL matches the registry entry; MIT `LICENSE` present; the `v0.3.0` tag's tree matches what the registry recorded, so TagBot worked last time |
| Package loads | `using MoreMaps` with only its hard dependencies (three standard libraries) is exercised by every docs build |

Verified locally on Julia 1.13.2 with four threads:

- The full test suite passes: 2534 tests in five minutes, including Aqua, JET, the main-module
  doctests, and the Sequential, Threaded, Distributed, Daggermap, Asyncmap, OhMyThreaded and
  Polyestered backends. (The checkout carried the docstring-only patch from
  `upstream-patches/MoreMaps-doctests.patch`; no code differs from `main`.)
- The Runic formatting check (`runic --check src ext test`, Runic 1.13) reports nothing, so the
  Runic workflow will be green.

## What to fix before tagging

Listed in the order worth doing them.

### 1. Widen the Dagger compat bound

`Project.toml` allows only `Dagger = "0.19"`. The registry now has Dagger 0.22.7, three minor
versions on, and the local environment resolves to 0.19.4 because of this bound. Anyone with
a current Dagger cannot install MoreMaps alongside it, and CompatHelper (which runs nightly in
this repository) will have been opening pull requests for 0.20, 0.21 and 0.22.

Checked: with the bound widened to `Dagger = "0.19 - 0.22"`, a fresh environment resolved
Dagger 0.22.7, and the `Daggermap` test item passed all twelve of its tests there (batching,
pinning tasks to one worker, a `LogLogger` over Dagger, and the speed comparison) in about a
minute on Julia 1.13.2. The `single` option still works in 0.22.7, with the same deprecation
warning as before. So widen the bound to `0.19 - 0.22` (CompatHelper's pull request, if one
is open, does exactly this), and let CI confirm it on the other Julia versions.

### 2. Repair the changelog footer and date

`CHANGELOG.md` ends with link definitions for a `v0.5.0` that does not exist, and
`[Unreleased]` compares against it (issue B8 in `../UPSTREAM_ISSUES.md`). TagBot takes the
release notes from the `## [0.4.0]` section of this file, so also change its date
(`2026-07-08`, when the section was written) to the day of the release.

### 3. Apply the extension-docstring patch

Four doctests in the extension modules fail against current Term, Dagger and
ProgressLogging (issue D7). The package's own tests never see them, because
`doctest(MoreMaps; manual = false)` covers the main module only, but they are the usage
examples for `TermLogger`, `Daggermap` and `ProgressLogger`. `upstream-patches/MoreMaps-doctests.patch`
fixes all four and was verified with the docs build. Optionally extend the `Doctest` test item
to the extension modules so they stay fixed:

```julia
@testitem "Doctest" begin
    using Documenter, ProgressLogging, Dagger, Term, OhMyThreads, Polyester
    exts = [Base.get_extension(MoreMaps, e) for e in (:TermExt, :DaggerExt, :ProgressLoggingExt)]
    doctest(nothing, [MoreMaps, exts...])
end
```

### 4. Stop using Dagger's deprecated `single` option

`test/Backends.jl` pins tasks with `Daggermap(; single = w, batchsize = 2)`, and the unpatched
`Daggermap` docstring shows `single = 1`. Dagger deprecates `single` in favour of scopes, so
the test log fills with deprecation warnings. Use `scope = Dagger.scope(worker = w)` in both
places (the docstring half is already in the patch above).

### 5. Decide what to do about the README recordings

The README embeds four terminal recordings from
`https://github.com/brendanjohnharris/MoreMaps.jl/releases/download/v0.3.0/output_N_@cast.gif`.
Those files exist (the four URLs answer 200), so the README works as it is, but the recordings
show 0.3.0. The `Asciicast` test item regenerates the GIFs and rewrites the README links to the
most recent tag, so the first local test run after tagging `v0.4.0` will point the README at
assets that are not there yet. Either upload the regenerated GIFs to the v0.4.0 release that
TagBot creates, or leave the links on v0.3.0 and do not commit the rewritten README.

## Downstream packages

- **TimeseriesFeatures** 0.7.x already declares `MoreMaps = "0.2 - 0.4"`, so it picks up 0.4.0
  with no change.
- **PyHCTSA** 0.1.0 declares `MoreMaps = "0.2 - 0.3"`; it needs a compat bump and a release of
  its own before it can use 0.4.0.
- **TimeseriesDocs**: the `stable` build described in `STABLE_DEV_BUILDS.md` resolves the
  registered versions, so it waits on this release.

## The release itself

1. Merge the fixes above into `main` and wait for CI to be green on Julia 1.10 to 1.13.
2. In the repository's Actions tab run **Register Package** with the version `0.4.0`. The
   action rewrites the version field (to the value it already has), commits
   "Set version to 0.4.0", and comments `@JuliaRegistrator register` on that commit. Commenting
   that line by hand on the merge commit does the same thing.
3. Registrator opens a pull request against General. AutoMerge runs the checks in the table
   above and merges after its waiting period for new versions of existing packages.
4. TagBot, triggered by Registrator's comment, creates the `v0.4.0` tag and a GitHub release
   whose notes are the changelog section.
5. Afterwards: upload the GIFs if you chose that route in step 5 above, bump PyHCTSA's compat,
   and tag TimeseriesDocs to publish the first `stable` build.
