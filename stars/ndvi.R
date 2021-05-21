library(stars)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

red = read_stars(rasters[6], proxy = FALSE)
nir = read_stars(rasters[7], proxy = FALSE)

### define NDVI formula
ndvi = function(red, nir) {
  (nir - red) / (nir + red)
}

###############################################
### calc NDVI using function

t_vec_1 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(ndvi(red, nir))
  t = unname(t["elapsed"])
  t_vec_1[i] = t

}

###############################################
### calc NDVI using st_apply

ras = merge(c(red, nir))

t_vec_2 = numeric(10)
for (i in seq_len(10)) {

  t = system.time(st_apply(ras, c("x", "y"), ndvi))
  t = unname(t["elapsed"])
  t_vec_2[i] = t

}

output = rbind(data.frame(task = "ndvi", package = "stars-fun", time = t_vec_1),
               data.frame(task = "ndvi", package = "stars-st_apply", time = t_vec_2))
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/ndvi-stars.csv", row.names = FALSE)
