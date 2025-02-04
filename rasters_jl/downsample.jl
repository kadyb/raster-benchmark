using Rasters, ArchGDAL, NCDatasets, GeoDataFrames, Statistics
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join = true))
band_names = (:B1, :B10, :B11, :B2, :B3, :B4, :B5, :B6, :B7, :B9)

Rasters.checkmem!(false) # Avoid memory check bug on some machines
raster = Raster(RasterStack(raster_files; name=band_names))
# Downsample from 30m to 90m (1/3 of the original resolution)
benchmark = @be Rasters.aggregate($mean, $raster, $(3)) seconds=60

# The other way to do this (via GDAL) is:
# benchmark = @be Rasters.resample($raster; res=90) seconds=60

write_benchmark_as_csv(benchmark; task = "downsample")
