using Rasters, ArchGDAL, NCDatasets, GeoDataFrames
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join=true))
band_names = (:B1, :B10, :B11, :B2, :B3, :B4, :B5, :B6, :B7, :B9)

# Stack the rasters
Rasters.checkmem!(false) # avoid a memory size bug on some machines
ras = Raster(RasterStack(raster_files; name=band_names))
stack_file = joinpath(data_dir, "stack.tif")
# note that we use force=true to force overwriting the file,
# and Rasters compresses by Zstd by default, but every other 
# package uses LZW - so for consistency's sake we force the compression
# to LZW as well.
benchmark = @be write($stack_file, $ras; force=$true, options = $(Dict("COMPRESS" => "LZW"))) seconds=60

write_benchmark_as_csv(benchmark; task = "write")
