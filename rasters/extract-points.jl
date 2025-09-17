using Rasters, ArchGDAL, GeoDataFrames
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join = true))
band_names = (:B1, :B10, :B11, :B2, :B3, :B4, :B5, :B6, :B7, :B9)
# Extraction makes more sense from a stack than a raster,
# as you get separate layers by name in the result
rstack = RasterStack(raster_files; name=band_names)

benchmark = @be extract($rstack, $points_df) seconds=60

write_benchmark_as_csv(benchmark; task = "extract-points")
