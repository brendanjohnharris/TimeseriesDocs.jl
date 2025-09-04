
```@meta
CurrentModule = MoreMaps
```

```@setup MoreMaps
using MoreMaps
using Dagger  # Need to load Dagger to trigger the extension
```

# Progress


`MoreMaps.jl` provides multiple options for tracking the progress of long-running map operations.


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

== NoProgress

```@docs; canonical=false
MoreMaps.NoProgress
```

:::
