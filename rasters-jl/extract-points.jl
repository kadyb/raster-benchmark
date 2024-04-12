using Rasters, ArchGDAL, NCDatasets, GeoDataFrames
using Chairmarks, CairoMakie

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))
points_df.geom = GeoDataFrames.GeoInterface.convert.((CairoMakie.GeometryBasics,), points_df.geom)

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join = true))
rasters = Rasters.Raster.(raster_files; lazy = true, mappedcrs = false)

band_names = ["B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9"]

stack = Rasters.RasterStack(rasters...; name = band_names)

# TODO: do something

write_benchmark_as_csv(benchmark; task = "extract-points")
