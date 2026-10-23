```@meta
CurrentModule = MoreMaps
```

# Extending MoreMaps

`MoreMaps` is extensible: you can add new backends or progress loggers by implementing a small set of methods. The internal scaffolding (`MoreMaps._run_map`) handles preallocation, logger lifecycle, and the per-element closure, so your implementation only needs to describe how work is dispatched and how results are written back.

## Backend interface

A backend is a subtype of `MoreMaps.Backend`. To add a new backend `MyBackend`:

1. Define the type and a `Chart` alias:

   ```julia
   struct MyBackend <: MoreMaps.Backend end
   const MyChart = Chart{L, B} where {L, B <: MyBackend}
   ```

2. Implement `MoreMaps._map(f, C::MyChart, itrs...)`. The recommended pattern is to delegate to `MoreMaps._run_map` and supply only the kernel:

   ```julia
   function MoreMaps._map(f, C::MyChart, itrs...)
       return MoreMaps._run_map(f, C, itrs) do g, ys, idxs, xs
           # Drive `g` over eachindex(idxs); write results into ys[i][].
           for i in eachindex(idxs)
               @inbounds ys[i][] = g(i, map(Base.Fix2(getindex, i), xs)...)
           end
       end
   end
   ```

   The kernel receives:

   - `g(i, x...)`: calls the user function and emits a progress log. Always call this rather than `f` directly.
   - `ys`: a vector of zero-dimensional views into the preallocated output. Assign with `ys[i][] = value`.
   - `idxs`: the iteration indices (length is the total work count).
   - `xs`: leaf views over each input iterable.

   The logger lifecycle (`init_log!` / `close_log!`) and exception safety are handled by `_run_map`.

Here is the whole thing, for a backend that runs every other element on a second task:

```@example interface
using MoreMaps

struct Halves <: MoreMaps.Backend end
const HalvesChart = Chart{L, B} where {L, B <: Halves}

function MoreMaps._map(f, C::HalvesChart, itrs...)
    return MoreMaps._run_map(f, C, itrs) do g, ys, idxs, xs
        go(range) = for i in range
            @inbounds ys[i][] = g(i, map(Base.Fix2(getindex, i), xs)...)
        end
        t = Threads.@spawn go(1:2:length(idxs))
        go(2:2:length(idxs))
        wait(t)
    end
end

map(x -> x^2, Chart(Halves()), 1:6)
```

## Progress logger interface

A progress logger is a subtype of `MoreMaps.Progress`. To add a new logger `MyLogger`:

1. Define the type. If it owns a `RemoteChannel` and consumer `Task`, type those fields concretely (or as `Union{Nothing, ...}` if construction precedes initialization, but assert concretely at use sites):

   ```julia
   mutable struct MyLogger <: MoreMaps.Progress
       # ...your fields...
   end
   ```

2. Implement three methods:

   ```julia
   MoreMaps.init_log!(P::MyLogger, total::Int)  # called once before mapping
   MoreMaps.log_log!(P::MyLogger, i::Int)       # called per element
   MoreMaps.close_log!(P::MyLogger)             # called once after mapping (in a finally block)
   ```

   Optional extensions:

   - `MoreMaps.log_log!(P::MyLogger, i::Int, y)`: receive the produced value (e.g. for `QualityLogger`-style scoring). The default forwards to the two-argument form.
   - `MoreMaps.init_log!(P::MyLogger, total::Int, C::Chart)`: receive the Chart for richer summaries. The default forwards to the two-argument form.

3. If the logger ships events over a `RemoteChannel` to a driver-side consumer `Task`, subtype `MoreMaps.ChannelProgress` instead of `MoreMaps.Progress` and name the fields `channel` and `consumer`: this provides `MoreMaps._open_channel!(P, T)`, `MoreMaps._close_consumer!(P, sentinel)`, and a `Serialization.serialize` method that nulls the consumer so the logger can cross worker boundaries (see `LogLogger.jl` or `CallbackLogger.jl` in the MoreMaps source for the pattern).

A minimal logger that counts how many elements were mapped:

```@example interface
mutable struct Counter <: MoreMaps.Progress
    n::Int
end
Counter() = Counter(0)

MoreMaps.init_log!(P::Counter, total::Int) = (P.n = 0)
MoreMaps.log_log!(P::Counter, i::Int) = (P.n += 1)
MoreMaps.close_log!(P::Counter) = nothing

P = Counter()
map(sqrt, Chart(P), 1:25);
P.n
```

For a sink that receives each result as it completes, `CallbackLogger` already does this and
is safe under distributed backends; write a logger of your own when you need to control the
reporting itself.

## Shared helpers

Useful utilities for logger implementations:

- `MoreMaps._progress_every(total, nlogs)`: compute update granularity.
- `MoreMaps._format_human_time(seconds)`: pretty-print a duration.
- `MoreMaps._run_map(kernel!, f, C, itrs)`: the scaffolding described above.

```@docs
MoreMaps._run_map
```
