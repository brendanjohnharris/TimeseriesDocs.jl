
```@meta
CurrentModule = MoreMaps
```

```@setup MoreMaps
using Dagger  # Need to load Dagger to trigger the extension
using MoreMaps
```

# Execution Backends

`MoreMaps.jl` provides multiple execution backends to suit different computational needs, from simple sequential execution to distributed computing across multiple machines.

All backends are subtypes of `MoreMaps.Backend` and are interchangeable: just pass an instance (or the bare type) to a `Chart`.

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

`Daggermap` is provided by a package extension and becomes available as soon as `Dagger.jl` is loaded.

```@docs; canonical=false
MoreMaps.Daggermap
```

:::
