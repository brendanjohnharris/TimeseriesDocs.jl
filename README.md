# TimeseriesDocs

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://brendanjohnharris.github.io/TimeseriesTools.jl/stable/) -->
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://brendanjohnharris.github.io/TimeseriesDocs.jl/dev/)

Provides documentation for [TimeseriesTools.jl](https://github.com/brendanjohnharris/TimeseriesTools.jl) and related packages.

## Building the documentation locally

The docs track the `main` branch of every package they describe (see `docs/Project.toml`),
so a build always reflects the packages' current state.

```julia
julia --project=docs -e 'using Pkg; Pkg.instantiate()'
julia --project=docs docs/make.jl
```

The first command resolves and precompiles the documentation environment (CairoMakie and the
extension packages included, so it takes a while the first time). The second runs every
example, writes the Markdown to `docs/build/.documenter`, and builds the VitePress site into
`docs/build/1`; deployment is skipped outside GitHub Actions. To preview with live reload
while editing, run `npm run docs:dev` from `docs/` after a build.
