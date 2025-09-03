# Progress


`MoreMaps.jl` provides multiple options for tracking the progress of long-running map operations.


### NoProgress

The default option that provides no progress output:

```@example MoreMaps
using MoreMaps
C = Chart(Sequential(), NoProgress())
x = randn(100)
y = map(x -> x^2, C, x)
```

### InfoProgress

.............

```@example MoreMaps
using MoreMaps
# Log 10 progress updates
C = Chart(Sequential(), InfoProgress(10))
x = randn(100)

# Capture logs for demonstration
using Logging
logs = with_logger(ConsoleLogger(stderr, Logging.Info)) do
    map(x -> (sleep(0.01); x^2), C, x)
end
```

The parameter specifies how many log messages to emit during execution.

### ProgressLogger

Integrates with ProgressLogging.jl:

```julia
using ProgressLogging

C = Chart(Sequential(), ProgressLogger(; name="Computation"))
x = randn(1000)
y = map(x -> (sleep(0.001); x^2), C, x)
```

Best with:
- VSCode's progress indicator
- Jupyter notebooks
- Pluto.jl notebooks
- [TerminalLoggers.jl](https://github.com/JuliaLogging/TerminalLoggers.jl)

### TermLogger

Provides rich terminal progress bars using Term.jl:

```julia
using Term

# Basic usage
C = Chart(Sequential(), TermLogger())

# With custom configuration
C = Chart(Sequential(), TermLogger(10; width=80, transient=false))

x = randn(1000)
y = map(x -> (sleep(0.001); x^2), C, x)
```