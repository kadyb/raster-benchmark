library(terra)

# xmin, xmax, ymin, ymax
area = ext(598500, 727500, 5682100, 5781000)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = rast(rasters)
ras = ras * 1 # explicitly load into memory

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
names(ras) = ras_names

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(crop(ras, area))
  t_vec[i] = t[["elapsed"]]

}

output = data.frame(task = "crop", package = "terra", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/crop-terra.csv", row.names = FALSE)
