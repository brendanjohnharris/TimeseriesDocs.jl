@testset "DimArrays" begin
    x = ToolsArray(randn(10), (𝑡(1:10),))
    @test x isa ToolsArray
    @test !(x isa DimensionalData.DimArray)
    @test x isa DimensionalData.AbstractDimArray

    using DimensionalData
    import DimensionalData: ForwardOrdered, Regular, Points, Sampled, Metadata, order,
                            sampling, layerdims, index, locus, Intervals, intervalbounds
    a = [1 2; 3 4]
    a2 = [1 2 3 4
          3 4 5 6
          4 5 6 7]
    xmeta = Metadata(:meta => "X")
    ymeta = Metadata(:meta => "Y")
    tmeta = Metadata(:meta => "T")
    ameta = Metadata(:meta => "da")
    dimz = (X(Sampled(143.0:2.0:145.0; order = ForwardOrdered(), metadata = xmeta)),
            Y(Sampled(-38.0:2.0:-36.0; order = ForwardOrdered(), metadata = ymeta)))
    dimz2 = (Dim{:row}(10:10:30), Dim{:column}(-20:10:10))

    refdimz = (𝑡(1:1; metadata = tmeta),)
    da = @test_nowarn ToolsArray(a, dimz; refdims = refdimz, name = :test, metadata = ameta)
    val(dims(da, 1)) |> typeof
    da2 = ToolsArray(a2, dimz2; refdims = refdimz, name = :test2)
    lx = Sampled(143.0:2.0:145.0, ForwardOrdered(), Regular(2.0), Points(), xmeta)
    ly = Sampled(-38.0:2.0:-36.0, ForwardOrdered(), Regular(2.0), Points(), ymeta)
    db = DimArray(da)
    @test db isa DimArray
    @test dims(da) == dims(db)
    @test dims(db, X) == dims(da, X)
    @test refdims(db) == refdims(da)
    @test name(db) == name(da)
    @test metadata(db) == metadata(da)
    @test lookup(db) == lookup(da)
    @test order(db) == order(da)
    @test sampling(db) == sampling(da)
    @test span(db) == span(da)
    @test locus(db) == locus(da)
    @test bounds(db) == bounds(da)
    @test layerdims(db) == layerdims(da)
    @test index(db, Y) == index(da, Y)
    da_intervals = set(da, X => Intervals, Y => Intervals)
    db_intervals = set(db, X => Intervals, Y => Intervals)
    @test intervalbounds(da_intervals) == intervalbounds(db_intervals)
end

@testset "TimeseriesTools.jl" begin
    ts = 1:100
    x = @test_nowarn TimeSeries(ts, randn(100))
    @test x isa AbstractTimeSeries
    @test x isa RegularTimeSeries
    @test x isa UnivariateTimeSeries

    @test step(x) == step(ts)
    @test samplingrate(x) == 1 / step(ts)
    @test times(x) == ts
    @test duration(x) == -first(-(extrema(ts)...))
    @test Interval(x) == first(extrema(ts)) .. last(extrema(ts))
    @test x[𝑡(1 .. 10)] == x[1:10]
    @test all(x[𝑡(At(1:10))] .== x[1:10])
    # @test x[ 𝑡(At(1:10))] != x[1:10]
end

@testset "Dim queries" begin
    ts = 1:100
    cs = 1:10
    X = TimeSeries(ts, Dim{:channel}(cs), randn(100, 10))
    @test dims(X) == (𝑡(ts), Dim{:channel}(cs))
    @test dims(X, 1) == 𝑡(ts)
    @test dims(X, 𝑡) == 𝑡(ts)
    @test dims(X, Dim{:channel}) == Dim{:channel}(cs)
    @test dims(X, :channel) == Dim{:channel}(cs)

    DimensionalData.@dim U ToolsDim "U"
    @test U <: ToolsDimension

    x = ToolsArray(randn(10), (𝑥(1:10),))
    @test all(x[At(dims(x, 1))] .== x)
    @test lookup(x[At(dims(x, 1))]) != lookup(x) # One is Regular, one is Irregular
    @test all(lookup(x[At(dims(x, 1))]) .== lookup(x[At(1:10)])) # But same elements
end
@testset "Multivariate time series" begin
    ts = 1:100
    x = @test_nowarn TimeSeries(ts, 1:5, randn(100, 5))
    @test x isa AbstractTimeSeries
    @test x isa RegularTimeSeries
    @test x isa MultivariateTimeSeries

    @test step(x) == step(ts)
    @test samplingrate(x) == 1 / step(ts)
    @test times(x) == ts
    @test duration(x) == -first(-(extrema(ts)...))
    @test Interval(x) == first(extrema(ts)) .. last(extrema(ts))
    @test x[𝑡(1 .. 10)] == x[1:10, :]
end

@testset "Multidimensional time series" begin
    x = @test_nowarn TimeSeries(𝑡(1:100), X(1:10), randn(100, 10))
    @test x isa AbstractTimeSeries
    @test x isa RegularTimeSeries
    @test x isa MultidimensionalTimeSeries

    x = @test_nowarn TimeSeries(𝑡(1:100), X(1:10), Y(1:10), randn(100, 10, 10))
    @test x isa AbstractTimeSeries
    @test x isa RegularTimeSeries
    @test x isa MultidimensionalTimeSeries
    @test_nowarn x[𝑡(Near(4:10))]

    x = @test_nowarn TimeSeries(𝑡(1:100), X(randn(10) |> sort), Y(1:10),
                                randn(100, 10, 10))
    @test x isa AbstractTimeSeries
    @test x isa RegularTimeSeries
    @test !(x isa MultidimensionalTimeSeries)

    x = @test_nowarn TimeSeries(𝑡(sort(randn(100))), randn(100))
    @test x isa AbstractTimeSeries
    @test !(x isa RegularTimeSeries)
    @test !(x isa MultidimensionalTimeSeries)
end
