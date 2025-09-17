using Rasters, ArchGDAL, GeoDataFrames
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join=true))
# TODO: replace_missing will not be needed in the next Rasters version
red = replace_missing(Raster(raster_files[5]))
nir = replace_missing(Raster(raster_files[6]))

# do something
get_ndvi(red, nir) = (nir .- red) ./ (nir .+ red)

benchmark = @be get_ndvi($red, $nir) seconds=15

write_benchmark_as_csv(benchmark; task = "ndvi")
