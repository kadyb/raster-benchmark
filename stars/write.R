library(stars)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = read_stars(rasters, proxy = FALSE)
ras = st_redimension(ras)

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
ras = st_set_dimensions(ras, 3, values = ras_names, names = "band")

t_vec = numeric(10)
for (i in seq_len(10)) {

  tmp = tempfile(fileext = ".tif")

  # input rasters are 'UInt16'
  t = system.time(write_stars(ras, tmp, options = "COMPRESS=LZW", type = "UInt16",
                              NA_value = 0))
  t = unname(t["elapsed"])
  t_vec[i] = t

  unlink(tmp)

}

output = data.frame(task = "write", package = "stars", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/write-stars.csv", row.names = FALSE)
