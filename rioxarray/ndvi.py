# -*- coding: utf-8 -*-
import os
import timeit
import xarray
import rioxarray
import pandas as pd


wd = os.getcwd()
catalog = os.path.join('data', 'LC08_L1TP_190024_20200418_20200822_02_T1')
rasters = os.listdir(catalog)
rasters = [r for r in rasters if r.endswith(('.TIF'))]
rasters = [os.path.join(wd, catalog, r) for r in rasters]


### raster stack
band_names = ["B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9"]

ras = []
for i, path in enumerate(rasters):
    ras.append(rioxarray.open_rasterio(path, masked = True).squeeze())

ras = xarray.concat(ras, "band")
ras.coords["band"] = band_names


### NDVI

nir = ras[6,:,:] # "B5" - idx 6 from 0
red = ras[5,:,:] # "B4" - idx 5 from 0

t_list = [None] * 10
for i in range(10):
    tic = timeit.default_timer()
    
    ndvi = (nir - red) / (nir + red)
    
    toc = timeit.default_timer()
    t_list[i] = round(toc - tic, 2)


df = {'task': ['ndvi'] * 10, 'package': ['rioxarray'] * 10, 'time': t_list}
df = pd.DataFrame.from_dict(df)
if not os.path.isdir('results'): os.mkdir('results')
savepath = os.path.join('results', 'ndvi-rioxarray.csv')
df.to_csv(savepath, index = False, decimal = ',', sep = ';')
