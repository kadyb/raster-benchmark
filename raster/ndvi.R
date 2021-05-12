library(raster)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = stack(rasters)
ras = readAll(ras)

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
names(ras) = ras_names

### define NDVI formula
ndvi = function(red, nir) {
  (nir - red) / (nir + red)
}

###############################################
### calc NDVI using function

red = ras[["B4"]]
nir = ras[["B5"]]

t_vec_1 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(ndvi(red, nir))
  t = unname(t["elapsed"])
  t_vec_1[i] = t

}

###############################################
### calc NDVI using overlay

t_vec_2 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(overlay(ras[["B4"]], ras[["B5"]], fun = ndvi))
  t = unname(t["elapsed"])
  t_vec_2[i] = t

}


output = rbind(data.frame(task = "ndvi", package = "raster-fun", time = t_vec_1),
               data.frame(task = "ndvi", package = "raster-overlay", time = t_vec_2))
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/ndvi-raster.csv", row.names = FALSE)
