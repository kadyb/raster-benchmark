library(raster)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = stack(rasters)

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
names(ras) = ras_names

t_vec = numeric(10)
for (i in seq_len(10)) {

  tmp = tempfile(fileext = ".tif")

  # input rasters are 'UInt16'
  t = system.time(writeRaster(ras, tmp, options = "COMPRESS=LZW",
                              datatype = "INT2U", NAflag = 0))
  t = unname(t["elapsed"])
  t_vec[i] = t

  unlink(tmp)

}

output = data.frame(task = "write", package = "raster", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/write-raster.csv", row.names = FALSE)
