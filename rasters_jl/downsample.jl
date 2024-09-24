using Rasters, ArchGDAL, NCDatasets, GeoDataFrames
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join = true))
band_names = (:B1, :B10, :B11, :B2, :B3, :B4, :B5, :B6, :B7, :B9)

# Faster to resample a raster with bands than a RasterStack
raster = Raster(RasterStack(raster_files; name=band_names))

# Downsample from 30m to 90m (1/3 of the original resolution)
benchmark = @be Rasters.resample($raster; res=90) seconds=30

write_benchmark_as_csv(benchmark; task = "downsample")
