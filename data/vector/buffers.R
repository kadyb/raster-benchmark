library(sf)

set.seed(1)

points = read_sf("data/vector/points.gpkg")
idx = sample(nrow(points), 2000)
points = points[idx, ]

buff_size = sample(seq(50, 500, 50), nrow(points), replace = TRUE)
buffers = st_buffer(points, buff_size)
buffers = st_union(buffers)
buffers = st_cast(buffers, "POLYGON")

write_sf(buffers, "data/vector/buffers.gpkg")
