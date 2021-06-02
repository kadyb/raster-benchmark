library(stars)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(read_stars(rasters, along = 3, proxy = FALSE))
  t_vec[i] = t[["elapsed"]]

}

output = data.frame(task = "load", package = "stars", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/load-stars.csv", row.names = FALSE)
