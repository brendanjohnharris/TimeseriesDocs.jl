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
C_progress = Chart(Threaded(), InfoProgress(10))
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

---


---

```

## Custom Progress Intervals

Control the frequency of progress updates:

```@example MoreMaps
using MoreMaps
x = randn(1000)

# More frequent updates
C_frequent = Chart(Sequential(), InfoProgress(20))

# Less frequent updates
C_sparse = Chart(Sequential(), InfoProgress(3))

# The number determines how many progress messages are logged
with_logger(NullLogger()) do  # Suppress output for docs
    map(x -> (sleep(0.001); x^2), C_frequent, x)
    map(x -> (sleep(0.001); x^2), C_sparse, x)
end
```

## Performance Considerations

Progress logging has minimal overhead, but for very fast operations on small arrays, consider using `NoProgress`:

```@example MoreMaps
using MoreMaps
x = randn(10)
fast_op = x -> x + 1

# For fast operations, skip progress
C_fast = Chart(Threaded(), NoProgress())
y = map(fast_op, C_fast, x)
```

---

<!-- ## Leaves


# Nested Array Handling

MoreMaps.jl can map over nested array structures, applying functions at specific levels of nesting.

## Leaf Types

The `leaf` parameter of a `Chart` determines which array types are treated as atomic units (leaves) during mapping.

### All (Default)

Treats all arrays as leaves - applies the function to the outermost array:

```@example MoreMaps
x = [1:3, 4:6, 7:9]
C = Chart(leaf = All)
y = map(sum, C, x)
```

### Union{} (Deep Mapping)

Maps over the deepest nested elements:

```@example MoreMaps
x = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
C = Chart(leaf = Union{})
y = map(x -> x^2, C, x)
```

### Specific Types

Specify a concrete type to control the mapping depth:

```@example MoreMaps
# Nested structure: Array of Arrays of Ranges
x = [[1:2, 3:4], [5:6, 7:8]]

# Map over the ranges (innermost)
C_range = Chart(leaf = UnitRange)
y_range = map(sum, C_range, x)

# Map over the inner arrays
C_array = Chart(leaf = Vector)
y_array = map(length, C_array, x)
```

## Type Stability

MoreMaps maintains type stability when possible:

```@example MoreMaps
x = randn(10)

# Type-stable with concrete leaf type
C_stable = Chart(leaf = Float64)
y = @inferred map(sqrt ∘ abs, C_stable, x)

# Type inference with Union{}
x_nested = [[1.0, 2.0], [3.0, 4.0]]
C_nested = Chart(leaf = Union{})
# Note: Union{} may not always be type-stable
y_nested = map(x -> x^2, C_nested, x_nested)
```

## Working with Complex Structures

```@example MoreMaps
# Mixed nested structure
data = [
    [1.0:0.5:3.0, 4.0:0.5:6.0],
    [7.0:0.5:9.0, 10.0:0.5:12.0]
]

# Process at different levels
C_outer = Chart(leaf = All)
result_outer = map(x -> length(x), C_outer, data)

C_ranges = Chart(leaf = StepRangeLen)
result_ranges = map(x -> collect(x), C_ranges, data)

C_deep = Chart(leaf = Union{})
result_deep = map(x -> round(x), C_deep, data)
```

## Multiple Iterator Support

When using multiple iterators, leaf types apply to all inputs:

```@example MoreMaps
x = [[1, 2], [3, 4]]
y = [[5, 6], [7, 8]]

C = Chart(leaf = Vector{Int})
z = map(+, C, x, y)
```

## Performance Tips

1. Use concrete leaf types when possible for better type stability
2. `All` (default) is fastest for non-nested arrays
3. `Union{}` provides maximum flexibility but may sacrifice type stability
4. Specify the most specific leaf type that matches your use case

---

## Expansions


# Cartesian Product Expansions

MoreMaps.jl supports automatic expansion of iterators into cartesian products, enabling efficient multi-dimensional mapping operations.

## Basic Expansion

Use `Iterators.product` as the expansion function to create cartesian products:

```@example MoreMaps
x = 1:3
y = 4:6

C = Chart(expansion = Iterators.product)
z = map(+, C, x, y)
```

## Multi-dimensional Expansions

Works with any number of iterators:

```@example MoreMaps
x = 1:2
y = 3:4
z = 5:6

C = Chart(expansion = Iterators.product)
result = map((a, b, c) -> a + b + c, C, x, y, z)
```

## Combining with Backends

Expansions work with all execution backends:

```@example MoreMaps
x = 1:10
y = 1:10

# Sequential with expansion
C_seq = Chart(Sequential(), NoProgress(), All, Iterators.product)
z_seq = map(*, C_seq, x, y)

# Threaded with expansion
C_thread = Chart(Threaded(), NoProgress(), All, Iterators.product)
z_thread = map(*, C_thread, x, y)
```

## Custom Expansion Functions

You can provide custom expansion functions:

```@example MoreMaps
# Custom expansion that zips instead of products
function zip_expansion(iters...)
    return zip(iters...)
end

x = 1:5
y = 6:10

# Note: This would need proper implementation in the package
# C = Chart(expansion = zip_expansion)
# z = map(+, C, x, y)
```

## Expansion with Nested Arrays

Expansions interact with leaf types:

```@example MoreMaps
x = [[1, 2], [3, 4]]
y = [[5, 6], [7, 8]]

# Expand outer arrays
C_outer = Chart(leaf = All, expansion = Iterators.product)
result_outer = map((a, b) -> length(a) + length(b), C_outer, x, y)

# Expand at leaf level
C_leaf = Chart(leaf = Vector{Int}, expansion = Iterators.product)
result_leaf = map((a, b) -> a .+ b, C_leaf, x, y)
```

## Performance Considerations

```@example MoreMaps
# Small expansions are efficient
x = 1:10
y = 1:10
C = Chart(Threaded(), NoProgress(), All, Iterators.product)
@time z = map(+, C, x, y)

# Be careful with large expansions
# x = 1:1000
# y = 1:1000
# This creates a 1,000,000 element result!
```

## Practical Applications

### Parameter Sweeps

```@example MoreMaps
# Sweep over parameter combinations
alphas = [0.1, 0.5, 1.0]
betas = [1, 2, 3]

C = Chart(Threaded(), InfoProgress(5), All, Iterators.product)

results = map(C, alphas, betas) do α, β
    # Simulate some computation
    sum(α * sin(x) + β * cos(x) for x in 1:100)
end
```

### Grid Computations

```@example MoreMaps
# Create a 2D grid evaluation
x_range = range(-1, 1, length=20)
y_range = range(-1, 1, length=20)

C = Chart(Threaded(), NoProgress(), All, Iterators.product)

grid = map((x, y) -> x^2 + y^2, C, x_range, y_range)
```

## NoExpansion (Default)

The default behavior performs element-wise mapping without expansion:

```@example MoreMaps
x = 1:3
y = 4:6

C = Chart()  # Default: NoExpansion()
z = map(+, C, x, y)  # Element-wise addition
``` -->