# Expansions

`MoreMaps.jl` supports automatic expansion of iterators, allowing for efficient combinatorial mapping.

## Basic Expansion

The typical expansion of two inputs `x` and `y` is the Cartesian product Use `Iterators.product(x, y)`:

```@example MoreMaps
x = 1:3
y = 4:6

C = Chart(expansion = Iterators.product)
z = map(tuple, C, x, y)
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


## Custom Expansion Functions

You can provide any custom expansion functions `f(iters...)` that return an iterator of tuples:

```@example MoreMaps
# Custom expansion that zips instead of products
function zip_expansion(iters...)
    return zip(iters...)
end

x = 1:5
y = 6:10

C = Chart(zip_expansion)
z = map(tuple, C, x, y)
```

## Expansion with Nested Arrays

Expansions interact with leaf types:

```@example MoreMaps
x = [[1, 2], [3, 4]]
y = [[5, 6], [7, 8]]

# Expand outer arrays
C_outer = Chart(leaf = MoreMaps.All, expansion = Iterators.product)
result_outer = map((a, b) -> length(a) + length(b), C_outer, x, y)

# Expand at leaf level
C_leaf = Chart(leaf = Vector{Int}, expansion = Iterators.product)
result_leaf = map((a, b) -> a .+ b, C_leaf, x, y)
```

## Practical Applications

### Parameter Sweeps

```@example MoreMaps
# Sweep over parameter combinations
alphas = [0.1, 0.5, 1.0]
betas = [1, 2, 3]

C = Chart(Threaded(), LogLogger(5), MoreMaps.All, Iterators.product)

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

C = Chart(Threaded(), NoProgress(), MoreMaps.All, Iterators.product)

grid = map((x, y) -> x^2 + y^2, C, x_range, y_range)
```


### Dimension sweeps

`Iterators.product` expansions work well with `DimensionalData.jl` dimensions:

```@example MoreMaps
using DimensionalData
x = X(1:3)
y = Y(4:6)
C = Chart(Iterators.product)
z = map(+, C, x, y)
```