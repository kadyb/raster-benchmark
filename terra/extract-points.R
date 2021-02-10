library(terra)

points = vect("data/vector/points.gpkg")
rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = rast(rasters)

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
names(ras) = ras_names

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(extract(ras, points, factors = FALSE)[, -1])
  t = unname(t["elapsed"])
  t_vec[i] = t

}

output = data.frame(task = "extract-points", package = "terra", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/extract-points-terra.csv", row.names = FALSE)
