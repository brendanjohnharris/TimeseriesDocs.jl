
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

All progress loggers are subtypes of `MoreMaps.Progress` and are passed to a `Chart` (or directly to `map`). `LogLogger` and `QualityLogger` ship with `MoreMaps`; `ProgressLogger` and `TermLogger` are provided by package extensions and become available once `ProgressLogging.jl` or `Term.jl` is loaded, respectively.

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


== NoProgress

```@docs; canonical=false
MoreMaps.NoProgress
```

:::
