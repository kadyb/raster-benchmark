library(raster)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(readAll(stack(rasters)))
  t_vec[i] = t[["elapsed"]]

}

output = data.frame(task = "load", package = "raster", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/load-raster.csv", row.names = FALSE)
