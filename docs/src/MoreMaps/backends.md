
```@meta
CurrentModule = MoreMaps
```

```@setup MoreMaps
using MoreMaps
using Dagger  # Need to load Dagger to trigger the extension
```

# Execution Backends

`MoreMaps.jl` provides multiple execution backends to suit different computational needs, from simple sequential execution to distributed computing across multiple machines.


:::tabs

== Sequential

```@docs; canonical=false
MoreMaps.Sequential
```


== Threaded

```@docs; canonical=false
MoreMaps.Threaded
```

== Pmap

```@docs; canonical=false
MoreMaps.Pmap
```


== Daggermap


```@docs; canonical=false
MoreMaps.Daggermap
```


:::