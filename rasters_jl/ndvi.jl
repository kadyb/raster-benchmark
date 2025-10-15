using Rasters, ArchGDAL, GeoDataFrames
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join=true))
red = Raster(raster_files[6]; lazy=false) .* 1.0 # Convert to Float64 for math use without overflow
nir = Raster(raster_files[7]; lazy=false) .* 1.0

# do something
get_ndvi(red, nir) = (nir .- red) ./ (nir .+ red)

benchmark = @be get_ndvi($red, $nir) seconds=15

write_benchmark_as_csv(benchmark; task = "ndvi")
