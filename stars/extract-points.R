library(sf)
library(stars)

points = read_sf("data/vector/points.gpkg")
rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = read_stars(rasters, along = 3, proxy = FALSE)
ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
ras = st_set_dimensions(ras, 3, values = ras_names, names = "band")

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(st_drop_geometry(st_as_sf(st_extract(ras, points))))
  t_vec[i] = t[["elapsed"]]

}

output = data.frame(task = "extract-points", package = "stars", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/extract-points-stars.csv", row.names = FALSE)
