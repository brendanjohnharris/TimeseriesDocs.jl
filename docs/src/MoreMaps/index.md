```@meta
CurrentModule = MoreMaps
```

# [MoreMaps.jl](https://www.github.com/brendanjohnharris/MoreMaps.jl)

A flexible mapping framework for Julia that provides different parallel backends, progress tracking, and iteration patterns.

## Features

- **Multiple backends**: Sequential, Threaded, Distributed (`Pmap`), and `Daggermap` execution
- **Progress tracking**: `LogLogger`, `ProgressLogger`, `TermLogger`, and `QualityLogger`
- **Nested array support**: Map over specific leaf types in nested array structures
- **Cartesian (and arbitrary) expansions**: Easy combinatorial iteration over inputs
- **Tuple / NamedTuple inputs**: Map over `Tuple`s and `NamedTuple`s, returning the same shape
- **`DimensionalData` support**: Map directly over `Dimension` arguments

## Quick Start

```@example MoreMaps
using MoreMaps

# Basic usage with default sequential backend
x = rand(100)
C = Chart()
y = map(sqrt, C, x)

# Use threading for parallel execution
C_threaded = Chart(Threaded())
y_threaded = map(sqrt, C_threaded, x)

# Add progress tracking
C_progress = Chart(Threaded(), LogLogger(10))
y_progress = map(sqrt, C_progress, x)
```

You can also pass a `Backend` or `Progress` value (or even the bare type) directly to `map`, and a default `Chart` wrapping it will be constructed for you:

```@example MoreMaps
using MoreMaps
x = rand(10)
map(sqrt, Threaded(), x)        # equivalent to map(sqrt, Chart(Threaded()), x)
map(sqrt, LogLogger(5), x)      # equivalent to map(sqrt, Chart(LogLogger(5)), x)
```

## Basics

The basis of a `MoreMaps` map is the `Chart` type, which configures how mapping operations are executed.

A `Chart` is parameterised by four things:

- `backend`: Specifies the execution backend
- `progress`: Configures the progress logging behavior
- `leaf`: The element type where recursion terminates, used for mapping nested arrays. Stored as a type parameter rather than a field.
- `expansion`: Determines how the input iterables are combined (e.g. Cartesian product). Either `NoExpansion()` or a `Function`.

A chart can be constructed using keywords or arbitrary-order positional arguments. The default `Chart()` reproduces `Base.map()`, and is constructed as:

```julia
C = Chart(backend   = Sequential(),    # No parallel execution; similar to Base.map
          progress  = NoProgress(),    # No progress logging
          leaf      = MoreMaps.All,    # Map over each element of the root array, like Base.map
          expansion = NoExpansion())   # Map over the original input arrays, as for Base.map

# Or, using positional arguments in any order. Each argument is dispatched on its
# type: `Backend` -> backend, `Progress` -> progress, `Type` -> leaf, `Function`
# -> expansion.
C = Chart(Sequential(), NoProgress(), MoreMaps.All, NoExpansion())

# Default behavior
C == Chart()
```

### Mapping

Once you have a Chart, pass it to the standard `Base.map` function:

```@example MoreMaps
using MoreMaps

x = rand(10)
C = Chart()
y = map(sqrt, C, x)
y == map(sqrt, x)
```

`Tuple` and `NamedTuple` inputs are supported and the result is returned with the same shape:

```@example MoreMaps
map(x -> x^2, Chart(), (1, 2, 3))             # -> Tuple
map(x -> x^2, Chart(), (a = 1, b = 2, c = 3)) # -> NamedTuple
```

See the following pages for details on configuring a `Chart`:

- [Backends](backends) - Execution strategies (`Sequential`, `Threaded`, `Pmap`, `Daggermap`)
- [Progress](progress) - Progress tracking options (`LogLogger`, `ProgressLogger`, `TermLogger`, `QualityLogger`, `NoProgress`)
- [Leaves](leaf) - Nested array handling
- [Expansions](expansion) - Cartesian product and custom iterations
