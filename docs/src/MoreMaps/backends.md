
```@meta
CurrentModule = MoreMaps
```

```@setup MoreMaps
using Dagger       # Need to load Dagger to trigger the extension
using OhMyThreads  # Need to load OhMyThreads to trigger the extension
using Polyester    # Need to load Polyester to trigger the extension
using MoreMaps
```

# Execution Backends

`MoreMaps.jl` provides multiple execution backends to suit different computational needs, from simple sequential execution to distributed computing across multiple machines.

All backends are subtypes of `MoreMaps.Backend` and are interchangeable: just pass an instance (or the bare type) to a `Chart`. `Sequential`, `Threaded`, `Asyncmap` and `Pmap` ship with `MoreMaps`; `OhMyThreaded`, `Polyestered` and `Daggermap` are provided by package extensions and become available once `OhMyThreads.jl`, `Polyester.jl` or `Dagger.jl` is loaded, respectively.

## Choosing a backend

| Backend | Requires | Overhead per element\* | Use when |
|----|----|----|----|
| `Sequential` | — | ~0.2 µs | Default; small or fast maps, debugging, deterministic execution order |
| `Threaded` | `julia -t` | ~4 µs | CPU-bound elements on one machine; `Threads.@threads` |
| `OhMyThreaded` | OhMyThreads.jl, `julia -t` | ~0.2 µs | Uneven per-element cost; chunked, load-balanced scheduling. Prefer over `Threaded` |
| `Polyestered` | Polyester.jl, `julia -t` | ~1 µs | Very cheap elements at large N. Supports only `NoProgress` and `Monitor` (Polyester tasks must not yield) |
| `Asyncmap` | — | ~5 µs | IO-bound elements (file loading, network): tasks overlap while waiting. No gain for CPU-bound work |
| `Pmap` | `addprocs` | ~100 µs | Expensive elements (more than ~10 ms each) across processes; below that, serialization dominates |
| `Daggermap` | Dagger.jl, `addprocs` | ~3 µs (batched) | Heterogeneous or multi-node resources; per-task scheduler options (`scope`, `occupancy`) via `Daggermap(; kwargs...)` |

\*Scheduling and writeback floor for a trivial `f`, measured by `benchmark/backend_benchmark.jl` in the MoreMaps repository (Julia 1.12, 20 threads, 4 workers); re-run that script on your own machine for local numbers.

:::tabs

== Sequential

```@docs; canonical=false
MoreMaps.Sequential
```

== Threaded

```@docs; canonical=false
MoreMaps.Threaded
```

== OhMyThreaded

`OhMyThreaded` is provided by a package extension and becomes available as soon as `OhMyThreads.jl` is loaded.

```@docs; canonical=false
MoreMaps.OhMyThreaded
```

== Polyestered

`Polyestered` is provided by a package extension and becomes available as soon as `Polyester.jl` is loaded.

```@docs; canonical=false
MoreMaps.Polyestered
```

== Asyncmap

```@docs; canonical=false
MoreMaps.Asyncmap
```

== Pmap

```@docs; canonical=false
MoreMaps.Pmap
```

== Daggermap

`Daggermap` is provided by a package extension and becomes available as soon as `Dagger.jl` is loaded.

```@docs; canonical=false
MoreMaps.Daggermap
```

:::
