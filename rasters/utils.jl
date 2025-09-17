import DelimitedFiles, Chairmarks

"""
    write_benchmark_as_csv(benchmark::Chairmarks.Benchmark; package = "geometryops", task = "distance")

Write the results of a Chairmarks benchmark to a CSV file. The CSV file will be written to the
"""
function write_benchmark_as_csv(benchmark::Chairmarks.Benchmark; package = "rasters", task = "distance", digits = 4)
    # Extract the time results from the Chairmarks benchmark.
    # These are in the form of `Chairmarks.Sample` objects which have various
    # properties like `time`, `memory`, etc.
    times = getproperty.(benchmark.samples, :time)
    # Now, we generate each row of the CSV file as a vector of strings.
    time_rows = map(times) do time
        [task, package, replace(string(round(time; digits)), "." => ",")]
    end
    # Write the results to a CSV file
    header_vec = ["task", "package", "time"]

    DelimitedFiles.writedlm(
        joinpath(dirname(@__DIR__), "results", "$task-$package.csv"),
        permutedims(hcat(header_vec, time_rows...)),
        ';'
    )
end
