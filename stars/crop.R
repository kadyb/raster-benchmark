library(sf)
library(stars)

area = st_bbox(c(xmin = 598500, xmax = 727500,
                 ymin = 5682100, ymax = 5781000),
               crs = st_crs(32633))

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = read_stars(rasters, proxy = FALSE)
ras = st_redimension(ras)

ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
ras = st_set_dimensions(ras, 3, values = ras_names, names = "band")

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time(st_as_stars(st_crop(ras, area)))
  t = unname(t["elapsed"])
  t_vec[i] = t

}

output = data.frame(task = "crop", package = "stars", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/crop-stars.csv", row.names = FALSE)
