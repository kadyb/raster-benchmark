library(terra)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

red = rast(rasters[6])
red = red * 1 # explicitly load into memory
nir = rast(rasters[7])
nir = nir * 1

### define NDVI formula
ndvi = function(red, nir) {
  (nir - red) / (nir + red)
}

###############################################
### calc NDVI using function

t_vec_1 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(ndvi(red, nir))
  t_vec_1[i] = t[["elapsed"]]

}

###############################################
### calc NDVI using lapp

ras = c(red, nir)

t_vec_2 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(lapp(ras, fun = ndvi))
  t_vec_2[i] = t[["elapsed"]]

}


output = rbind(data.frame(task = "ndvi", package = "terra-fun", time = t_vec_1),
               data.frame(task = "ndvi", package = "terra-lapp", time = t_vec_2))
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/ndvi-terra.csv", row.names = FALSE)
