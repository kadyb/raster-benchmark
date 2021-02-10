library(terra)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = rast(rasters)

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
names(ras) = ras_names

###############################################
### calc NDVI using function

calc_ndvi = function(img, nir, red) {

  nir = img[[nir]]
  red = img[[red]]
  ndvi = (nir - red) / (nir + red)
  return(ndvi)

}

t_vec_1 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(calc_ndvi(ras, "B5", "B4"))
  t = unname(t["elapsed"])
  t_vec_1[i] = t

}

###############################################
### calc NDVI using lapp

calc_ndvi = function(nir, red) (nir - red) / (nir + red)

t_vec_2 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(lapp(c(ras[["B5"]], ras[["B4"]]), fun = calc_ndvi))
  t = unname(t["elapsed"])
  t_vec_2[i] = t

}


output = rbind(data.frame(task = "ndvi", package = "terra-fun", time = t_vec_1),
               data.frame(task = "ndvi", package = "terra-lapp", time = t_vec_2))
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/ndvi-terra.csv", row.names = FALSE)
