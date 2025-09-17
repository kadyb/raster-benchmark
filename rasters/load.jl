using Rasters, ArchGDAL, GeoDataFrames
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join=true))

Rasters.checkmem!(false) # make sure that Rasters does not error because it thinks there isn't enough memory
# do something
benchmark = @be RasterStack($raster_files) seconds=10

write_benchmark_as_csv(benchmark; task="load")
