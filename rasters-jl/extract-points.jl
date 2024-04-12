using Rasters, ArchGDAL, NCDatasets, GeoDataFrames
import GeoInterface as GI, GeometryOps as GO
using Chairmarks, CairoMakie

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
points_df = GeoDataFrames.read(joinpath(data_dir, "vector", "points.gpkg"))

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join = true))
rasters = Rasters.Raster.(raster_files; lazy = true)

band_names = ["B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9"]

rstack = Rasters.RasterStack(rasters...; name = band_names)

# TODO: do something, this performance is atrocious

function _get_point_from_raster(raster, point)
    return raster[X(Near(GI.x(point))), Y(Near(GI.y(point)))]
end

benchmark = @be _get_point_from_raster.((rstack,), points_df.geom) seconds=60

write_benchmark_as_csv(benchmark; task = "extract-points")
