```@meta
CurrentModule = MoreMaps
```

# [MoreMaps.jl](https://www.github.com/brendanjohnharris/MoreMaps.jl)

A flexible mapping framework for Julia that provides different parallel backends, progress tracking, and iteration patterns.

## Features

- **Multiple backends**: Sequential, Threads, Distributed, and Dagger execution
- **Progress tracking**: Support for various progress-logging backends
- **Nested array support**: Map over specific leaf types in nested array structures
- **Cartesian expansions**: Easy cartesian product iterations

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

## Basics

The basis of a `MoreMaps` map is the `Chart` type, which configures how mapping operations are executed.

A `Chart` has the following fields:
- `backend`: Specifies the execution backend
- `progress`: Configures the progress logging behavior
- `leaf`: Defines the element type where recursion terminates, for mapping nested arrays
- `expansion`: Determines the expansion strategy (e.g. Cartesian product)

A chart can be constructed using keywords or arbitrary-order positional arguments. The default `Chart()` reproduces `Base.map()`, and is constructed as:
```julia
C = Chart(backend=Sequential(),    # No parallel execution; similar to Base.map
          progress=NoProgress(),   # No progress logging
          leaf=MoreMaps.All,                # Map over each element of the root array, like Base.map
          expansion=NoExpansion()) # Map over the original input arrays, as for Base.map

# Or
C = Chart(Sequential(), NoProgress(), MoreMaps.All, NoExpansion()) # In any order

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

See the following pages for details on configuring a `Chart`:
- [Backends](MoreMaps/backends) - Execution strategies (Sequential, Threaded, Distributed, Dagger)
- [Progress](MoreMaps/progress) - Progress tracking options
- [Leaves](MoreMaps/leaf) - Nested array handling
- [Expansions](MoreMaps/expansion) - Cartesian product iterations
