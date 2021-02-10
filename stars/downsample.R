library(sf)
library(stars)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = read_stars(rasters, proxy = FALSE)
ras = st_redimension(ras)

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
ras = st_set_dimensions(ras, 3, values = ras_names, names = "band")

dest = st_as_stars(st_bbox(ras), dx = 90, values = 0L)
dest = c(dest, dest, dest, dest, dest, dest, dest, dest, dest, dest)
dest = merge(dest)

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(st_warp(ras, dest, method = "average", use_gdal = TRUE))
  t = unname(t["elapsed"])
  t_vec[i] = t

}

output = data.frame(task = "downsample", package = "stars", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/downsample-stars.csv", row.names = FALSE)
