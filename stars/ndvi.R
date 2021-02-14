library(stars)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = read_stars(rasters, proxy = FALSE)
ras = st_redimension(ras)

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
ras = st_set_dimensions(ras, 3, values = ras_names, names = "band")

calc_ndvi = function(x) (x[7] - x[6]) / (x[7] + x[6])

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(st_apply(ras, c("x", "y"), calc_ndvi))
  t = unname(t["elapsed"])
  t_vec[i] = t

}

output = data.frame(task = "ndvi", package = "stars", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/ndvi-stars.csv", row.names = FALSE)
