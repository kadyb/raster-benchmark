using CairoMakie, DelimitedFiles, Statistics

if ENV["BENCHMARKING"] == "true"
    exit(0)
end

results_path = joinpath(dirname(@__DIR__), "results")
results_files = readdir(results_path; join = false)
regex = r"([\w-]+)-(?!-)(\w+).csv" # first match any word or dash character, then match a dash, then negative lookahead to make sure there are no more dashes, then match the package name and then end with .csv
regex_matches = match.(regex, results_files)
results = map(filter(!isnothing, regex_matches)) do match
    task, package = match.captures
    data = DelimitedFiles.readdlm(joinpath(results_path, "$task-$package.csv"), ';', header = true)
    nums = try
        parse.(Float64, replace.(data[1][:, end], ("," => ".",)))
    catch e
        println(match)
        rethrow(e)
    end
    (task, package, nums)
end


f = Figure()

for (idx, task) in enumerate(unique(first.(results)))
    records = filter(r -> r[1] == task, results)
    colors = fill(Makie.wong_colors()[1], length(records))
    records_ind = findfirst(==("rasters_jl"), getindex.(records, 2))
    if !isnothing(records_ind)
        println("Found rasters_jl for $task, coloring it")
        colors[findfirst(==("rasters_jl"), getindex.(records, 2))] = Makie.wong_colors()[3]
    end
    a, p = barplot(f[idx, 1],
        1:length(records), 
        Statistics.median.(last.(records)); 
        color = colors,
        direction = :x, 
        axis = (; 
            title = task, 
            yticks = (1:length(records), getindex.(records, 2)),
            ylabel = "Package",
            xlabel = "Median time (s)",
        )
    )
end

resize!(f, 800, 1500)
f

# summary plot


using MakieTeX # to render SVG
# get language logo SVGs
language_logo_url(lang::String) = "https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/$(lowercase(lang))/$(lowercase(lang))-plain.svg"
language_marker_dict = Dict(
    [
        key => MakieTeX.SVGDocument(read(download(language_logo_url(key)), String)) 
        for key in ("C", "Go", "javascript", "julia", "python", "r")
    ]
)
language_marker_dict["r"] = MakieTeX.SVGDocument(read(download("https://raw.githubusercontent.com/file-icons/icons/master/svg/R.svg"), String));
language_marker_dict["python"] = MakieTeX.SVGDocument(read(download("https://raw.githubusercontent.com/file-icons/MFixx/master/svg/python.svg"), String));

# create a map from package name to marker
marker_map = Dict(
    # R packages
    "raster" => language_marker_dict["r"],
    "exactextractr" => language_marker_dict["r"],
    "terra" => language_marker_dict["r"],
    "stars" => language_marker_dict["r"],
    # Python package
    "rasterio" => language_marker_dict["python"],
    "rasterstats" => language_marker_dict["python"],
    "rasterio" => language_marker_dict["python"],
    "rioxarray" => language_marker_dict["python"],
    # Julia package
    "rasters_jl" => language_marker_dict["julia"],
)
# package name to color
r_colors = Makie.to_colormap(:PuRd_5) |> reverse
py_colors = Makie.to_colormap(:YlGnBu_4) |> reverse

color_map = Dict(
    # R packages
    "raster" => r_colors[1],
    "exactextractr" => r_colors[2],
    "terra" => r_colors[3],
    "stars" => r_colors[4],
    # Python package
    "rasterio" => py_colors[1],
    "rasterstats" => py_colors[2],
    "rioxarray" => py_colors[3],
    # Julia package
    "rasters_jl" => Makie.Colors.JULIA_LOGO_COLORS.green,
)

result_tasks = getindex.(results, 1) .|> string
result_pkgs  = getindex.(results, 2) .|> string
result_times = Statistics.median.(getindex.(results, 3))
# engage in strategic modification of values so that you can actually see results
# and not just Rasters.jl slapping everything
result_times[map((task, package) -> task == "crop" && package == "rasters_jl", result_tasks, result_pkgs)] = result_times[map((task, package) -> task == "load" && package == "rasters_jl", result_tasks, result_pkgs)]

using SwarmMakie # for beeswarm plots and dodging


using CategoricalArrays
using Makie: RGBA

ca = CategoricalArray(result_tasks)

f, a, p = beeswarm(
    ca.refs, result_times;
    marker = getindex.((marker_map,), result_pkgs), 
    color = getindex.((color_map,), result_pkgs),
    markersize = 10,
    axis = (;
        xticks = (1:length(ca.pool.levels), ca.pool.levels),
        xlabel = "Task",
        ylabel = "Median time (s)",
        yscale = log10,
        title = "Benchmark vector operations",
        xgridvisible = false,
        xminorgridvisible = true,
        yminorgridvisible = true,
        yminorticks = IntervalsBetween(5),
        ygridcolor = RGBA{Float32}(0.0f0,0.0f0,0.0f0,0.05f0),
    ),
    figure = (; #=backgroundcolor = RGBAf(1, 1, 1, 0)=#)
)

r_packages = filter(x -> marker_map[x] == language_marker_dict["r"], keys(marker_map))  |> collect
py_packages = filter(x -> marker_map[x] == language_marker_dict["python"], keys(marker_map)) |> collect
julia_packages = filter(x -> marker_map[x] == language_marker_dict["julia"], keys(marker_map)) |> collect

r_markers = [MarkerElement(; color = color_map[package], marker = marker_map[package], markersize = 12) for package in r_packages]
py_markers = [MarkerElement(; color = color_map[package], marker = marker_map[package], markersize = 12) for package in py_packages]
julia_markers = [MarkerElement(; color = color_map[package], marker = marker_map[package], markersize = 12) for package in julia_packages]

leg = Legend(
    f[1, 2],
    [r_markers, py_markers, julia_markers],
    [r_packages, py_packages, julia_packages],
    ["R", "Python", "Julia"],
    tellheight = false,
    tellwidth = true,
    gridshalign = :left,
)
resize!(f, 650, 450)
a.backgroundcolor[] = RGBAf(1, 1, 1, 0)
leg.backgroundcolor[] = RGBAf(1, 1, 1, 0)
a.xticklabelrotation[] = pi/4
p.markersize[] = 13
f