library(terra)
library(data.table)

rasters = list.files("data/LC08_L1TP_190024_20200418_20200822_02_T1/",
                     pattern = "\\.TIF$", full.names = TRUE)

ras = rast(rasters)
ras_names = c("B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9")
names(ras) = ras_names

# convert raster values to data.table
dt = as.data.table(values(ras))

t_vec = numeric(10)
for (i in seq_len(10)) {

  t = system.time((dt$B5 - dt$B4) / (dt$B5 + dt$B4))
  t = unname(t["elapsed"])
  t_vec[i] = t

}

# copy values to raster ('init()' can be used too)
# ndvi = (dt$B5 - dt$B4) / (dt$B5 + dt$B4)
# new = rast(nrows = nrow(ras), ncols = ncol(ras), extent = ext(ras),
#           crs = crs(ras), names = "NDVI")
# values(new) = ndvi

output = data.frame(task = "ndvi", package = "data.table", time = t_vec)
if (!dir.exists("results")) dir.create("results")
write.csv2(output, "results/ndvi-data.table.csv", row.names = FALSE)
