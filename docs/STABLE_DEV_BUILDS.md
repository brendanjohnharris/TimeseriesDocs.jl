# Plan: `stable` and `dev` documentation builds

## The problem

The site publishes one build, `dev`, and it is built from the `main` branch of every
package (the `[sources]` section of `docs/Project.toml`). A user who installed the registered
releases reads docs for code they do not have: today that means MoreMaps v0.4.0's backends
and loggers documented while the registered release is v0.3.0.

The goal is two builds side by side, with a version picker to switch:

| Build | Built from | Rebuilt when | URL |
|---|---|---|---|
| `dev` | package `main` branches, as now | every push to `main`, monthly | `.../TimeseriesDocs.jl/dev/` |
| `stable` | the registered releases | every release tag of this repository | `.../TimeseriesDocs.jl/stable/` |

## How the tooling decides what to publish

This is worth spelling out, because the mechanism is not in the Documenter manual.

1. `Documenter.deploy_folder` reads the GitHub Actions event. A push to `main` gives the
   subfolder `dev` (the `devurl`). A push of a tag `vX.Y.Z` on this repository gives the
   subfolder `vX.Y.Z`. A pull request gives `previews/PR<n>`.
2. `DocumenterVitepress.determine_bases` turns a version subfolder into the set of folders
   to build. With the default `keep = :breaking`, `v1.2.3` becomes `stable` (if no higher
   tag exists on the repository) and `v1`. A non-version subfolder such as `dev` stays as it
   is. Each folder is a separate VitePress build, listed in `build/bases.txt`.
3. `DocumenterVitepress.deploydocs` pushes each folder to `gh-pages`. Before pushing, it
   scans the branch for `stable`, `dev` and `v*` folders and writes `versions.js`, which the
   `VersionPicker` component reads, plus a root `index.html` that redirects to `stable` when
   it exists and to `dev` otherwise.
4. `noindex_non_stable = true` (the default) marks every build except `stable` as
   `noindex`, so search engines will index the stable build once there is one.

So `stable` appears the moment this repository has a release tag, and nothing else in the
pipeline needs to change for the folders and the picker to work. What does need deciding is
what a tagged build *contains*.

## Design

### Versioning this repository

Tag TimeseriesDocs with its own semantic versions, starting at `v1.0.0`. Bump the major
version when the package family makes a breaking change that reshapes the docs (the next
TimeseriesTools 0.x release counts, since 0.x minors are breaking in Julia's reading of
SemVer), and the minor version for anything else. Mirroring one package's version number
would be misleading for a site that covers six packages.

With `keep = :breaking`, a tag `v1.3.0` produces the folders `stable` and `v1`; patch and
minor folders are not kept, which keeps `gh-pages` small. Readers always see `stable`, `dev`
and one folder per major version.

### What a tagged build contains

A tagged build must resolve the *registered* package versions, so the `[sources]` section
that pins `main` has to go for that build only. Add a step to the workflow that rewrites
`docs/Project.toml` before `Pkg.instantiate` when the ref is a tag:

```yaml
      - name: Use the registered package versions for a release build
        if: startsWith(github.ref, 'refs/tags/')
        run: |
          julia -e '
            using TOML
            project = TOML.parsefile("docs/Project.toml")
            delete!(project, "sources")
            open(io -> TOML.print(io, project), "docs/Project.toml", "w")'
```

`Pkg.instantiate` then resolves the newest registered releases that are mutually
compatible. The build log records the resolved versions, and the home page shows them in
its "Versions described by this build" table, so readers can tell which release a page
describes.

Two prerequisites before the first tag:

- **Register `TimeseriesToolsSurrogates`.** It is not in General, so a build without
  `[sources]` cannot resolve it. Until it is registered, keep its `[sources]` entry only (the
  step above can delete the other five keys instead of the whole section).
- **Register MoreMaps v0.4.0.** The registered release is v0.3.0, which lacks the backends
  and loggers the pages now document; a `stable` build today would show `@docs` failures
  for `Asyncmap`, `OhMyThreaded`, `Polyestered`, `Monitor`, `CallbackLogger` and
  `CompositeLogger`. More generally, release the packages first and tag the docs second.

### Guarding the stable build

The stable build sees older code than `main`, so a page that documents something unreleased
would fail it. Two cheap guards:

- Run the release build as a dry run first: a `workflow_dispatch` input `channel: stable`
  that performs the same `[sources]` rewrite and runs `makedocs` without deploying.
  Documenter's deploy criteria already refuse to deploy a `workflow_dispatch` run that is
  not on a tag, so the only addition is the input and the `if:` condition on the rewrite
  step.
- Keep `warnonly` as it is: a missing docstring in the stable build is a warning (the page
  still ships, with a gap), a failing example is an error. That is the right asymmetry: a
  stale example misleads, a missing entry does not.

### The version picker

`docs/src/.vitepress/config.mts` already imports the `VersionPicker` component; its entry
in `nav` is commented out. Re-enable it:

```ts
const nav = [
    ...navTemp.nav,
    {
        component: 'VersionPicker'
    }
]
```

It renders from `versions.js`, so it shows nothing until the first deployment after this
change writes that file, and it lists `stable`, `dev` and the `v*` folders in that order.

### Workflow summary

`.github/workflows/Documentation.yml` already triggers on tags. The complete change is the
rewrite step above, the optional `workflow_dispatch` input, and no change to `make.jl`.
The release routine becomes:

1. Release the packages (TagBot and Registrator as usual).
2. Wait for the registry PRs to merge.
3. On this repository: `git tag v1.0.0 && git push origin v1.0.0`.
4. CI builds the tag against the registered versions and publishes `stable` and `v1`;
   `dev` is untouched.

### Later refinements

- Pin exact versions with `[compat]` in a committed `docs/stable.toml` instead of deleting
  `[sources]`, if reproducible stable builds matter more than always tracking the newest
  release. The rewrite step would then copy that file over `docs/Project.toml`.
- A `stable` badge in each package README pointing at `.../TimeseriesDocs.jl/stable/<Package>/`,
  alongside the existing `dev` badge.
- Once `stable` exists, flip `ignoreDeadLinks` in `config.mts` to `false` so a broken
  internal link fails the build rather than shipping.
