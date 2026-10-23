
```@meta
CurrentModule = MoreMaps
```

```@setup MoreMaps
using MoreMaps
using Dagger             # Need to load Dagger to trigger the extension
using ProgressLogging    # Need to load ProgressLogging to trigger the extension
using Term               # Need to load Term to trigger the extension
```

# Progress

`MoreMaps.jl` provides multiple options for tracking the progress of long-running map operations.

All progress loggers are subtypes of `MoreMaps.Progress` and are passed to a `Chart` (or directly to `map`). `LogLogger`, `QualityLogger`, `CallbackLogger`, `CompositeLogger` and `Monitor` ship with `MoreMaps`; `ProgressLogger` and `TermLogger` are provided by package extensions and become available once `ProgressLogging.jl` or `Term.jl` is loaded, respectively.

| Logger | Output |
|---|---|
| `LogLogger` | periodic `@info` messages with an elapsed/remaining estimate |
| `ProgressLogger` | `ProgressLogging.jl` events, for VS Code, Pluto and `TerminalLoggers` |
| `TermLogger` | a `Term.jl` progress bar |
| `QualityLogger` | a grid of coloured blocks, one per element, coloured by a quality score of its result (for example the fraction of `NaN`s) |
| `CallbackLogger` | calls your function once per completed element, with its index and value |
| `CompositeLogger` | forwards every event to several of the above |
| `Monitor` | records wall time, allocations and GC time for the whole map, at no per-element cost |
| `NoProgress` | nothing; the default |

Every logger except `NoProgress` and `Monitor` yields when it reports, so the `Polyestered` backend accepts only those two.

:::tabs

== LogLogger

```@docs; canonical=false
MoreMaps.LogLogger
```

== ProgressLogger

```@docs; canonical=false
MoreMaps.ProgressLogger
```

== TermLogger

```@docs; canonical=false
MoreMaps.TermLogger
```

== QualityLogger

```@docs; canonical=false
MoreMaps.QualityLogger
```

== CallbackLogger

```@docs; canonical=false
MoreMaps.CallbackLogger
```

== CompositeLogger

```@docs; canonical=false
MoreMaps.CompositeLogger
```

== NoProgress

```@docs; canonical=false
MoreMaps.NoProgress
```

:::

## Monitoring resource usage

`Monitor` occupies the progress slot and cheaply records each job: two clock and GC snapshots, nothing per element. Combine it with a real logger via `CompositeLogger`.

```@example MoreMaps
M = Monitor()
map(x -> sum(sin, 1:x), Chart(Threaded(), CompositeLogger(M, LogLogger(2))), 1:2000);
M
```

```@example MoreMaps
M.time, M.n, M.backend
```

For distributed backends the allocation counters cover the driver process only.

```@docs; canonical=false
MoreMaps.Monitor
```
