using Rasters, ArchGDAL, GeoDataFrames

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join = true))
rasters = Rasters.Raster.(raster_files; lazy = true)

# do something

red = read(rasters[5])
nir = read(rasters[6])

function get_ndvi(red, nir)
    return @. (nir - red) / (nir + red)
end

benchmark = @be get_ndvi($red, $nir) seconds=15 gc=false

write_benchmark_as_csv(benchmark; task = "ndvi")
