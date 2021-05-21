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

red = rioxarray.open_rasterio(rasters[5], masked = True)
nir = rioxarray.open_rasterio(rasters[6], masked = True)

### NDVI

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
