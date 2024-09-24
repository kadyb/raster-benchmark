using Rasters, ArchGDAL, NCDatasets, GeoDataFrames
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join = true))
rasters = Rasters.Raster.(raster_files; lazy = true)

band_names = ["B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9"]

rstack = Rasters.RasterStack(rasters...; name = band_names)

# Downsample from 30m to 90m (1/3 of the original resolution)

xmin, ymin, xmax, ymax = (598500, 5682100, 727500, 5781000)
ext = Rasters.Extents.Extent(X = (xmin, ymin), Y = (xmax, ymax))

# You could do it like this:
benchmark = @be $(rstack)[X(xmin..xmax), Y(ymin..ymax)] seconds=15

# or index directly via Extent
# benchmark = @be $(rstack)[ext] seconds=15
# It looks like indexing by extent materializes the raster, so this is 2x slower than the first method 
# Why?

write_benchmark_as_csv(benchmark; task = "crop")
