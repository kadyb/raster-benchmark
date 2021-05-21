library(terra)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(rast(rasters) * 1)
  t = unname(t["elapsed"])
  t_vec[i] = t

}

output = data.frame(task = "load", package = "terra", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/load-terra.csv", row.names = FALSE)
