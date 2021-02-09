library(sf)

set.seed(1)

a = c(551660, 5657470)
b = c(736590, 5611760)
c = c(783160, 5802030)
d = c(597620, 5846610)

mat = matrix(c(a, b, c, d, a), ncol = 2, byrow = TRUE)

poly = st_sfc(st_polygon(list(mat)), crs = st_crs(32633))

n_smp = 100000
x_smp = sample(seq(st_bbox(poly)["xmin"], st_bbox(poly)["xmax"], 30),
               n_smp, replace = TRUE)
y_smp = sample(seq(st_bbox(poly)["ymin"], st_bbox(poly)["ymax"], 30),
               n_smp, replace = TRUE)


pts = data.frame(x = x_smp, y = y_smp)
pts = st_as_sf(pts, coords = c("x", "y"), crs = st_crs(32633))
pts = st_intersection(pts, poly)
write_sf(pts, "data/vector/points.gpkg")
