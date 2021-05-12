library(stars)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = read_stars(rasters, along = 3, proxy = FALSE)
ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
ras = st_set_dimensions(ras, 3, values = ras_names, names = "band")

### define NDVI formula
ndvi = function(red, nir) {
  (nir - red) / (nir + red)
}

###############################################
### calc NDVI using function

red = adrop(ras[,,,6])
nir = adrop(ras[,,,7])

t_vec_1 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(ndvi(red, nir))
  t = unname(t["elapsed"])
  t_vec_1[i] = t

}

###############################################
### calc NDVI using st_apply

t_vec_2 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(st_apply(ras[,,,6:7], c("x", "y"), ndvi))
  t = unname(t["elapsed"])
  t_vec_2[i] = t

}

output = rbind(data.frame(task = "ndvi", package = "stars-fun", time = t_vec_1),
               data.frame(task = "ndvi", package = "stars-st_apply", time = t_vec_2))
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/ndvi-stars.csv", row.names = FALSE)
