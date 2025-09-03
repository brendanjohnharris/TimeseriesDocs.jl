```@meta
CurrentModule = MoreMaps
```

```@setup MoreMaps
using MoreMaps
using Dagger  # Need to load Dagger to trigger the extension
using Test
```

# Nested Array Handling

MoreMaps.jl can map over nested array structures, applying functions at specific levels of nesting.

## Leaf Types

The `leaf` parameter of a `Chart` determines which types are treated as non-iterable units (leaves) during mapping.

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