library(sf)
library(terra)
library(raster)
library(exactextractr)

buffers = read_sf("data/vector/buffers.gpkg")
rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)
ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")

### {raster} as back-end
ras = stack(rasters)
ras = readAll(ras)
names(ras) = ras_names

t_vec_1 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(exact_extract(ras, buffers, fun = "mean", progress = FALSE))
  t_vec_1[i] = t[["elapsed"]]

}

### {terra} as back-end
ras = rast(rasters)
ras = ras * 1 # explicitly load into memory

t_vec_2 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(exact_extract(ras, buffers, fun = "mean", progress = FALSE))
  t_vec_2[i] = t[["elapsed"]]

}


output = rbind(
  data.frame(task = "zonal", package = "exactextractr-raster", time = t_vec_1),
  data.frame(task = "zonal", package = "exactextractr-terra", time = t_vec_2)
  )
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/zonal-exactextractr.csv", row.names = FALSE)
