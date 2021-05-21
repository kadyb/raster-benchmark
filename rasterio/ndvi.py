# -*- coding: utf-8 -*-
import os
import timeit
import rasterio
import pandas as pd


wd = os.getcwd()
catalog = os.path.join('data', 'LC08_L1TP_190024_20200418_20200822_02_T1')
rasters = os.listdir(catalog)
rasters = [r for r in rasters if r.endswith(('.TIF'))]
rasters = [os.path.join(wd, catalog, r) for r in rasters]

red = rasterio.open(rasters[5])
nir = rasterio.open(rasters[6])
meta = red.meta

red = red.read(masked = True).astype(float)
nir = nir.read(masked = True).astype(float)

### NDVI

t_list = [None] * 10
for i in range(10):
    tic = timeit.default_timer()
    
    ndvi = (nir - red) / (nir + red)
    mask = ndvi.mask.copy()
    ndvi[mask] = meta['nodata']
    
    toc = timeit.default_timer()
    t_list[i] = round(toc - tic, 2)


df = {'task': ['ndvi'] * 10, 'package': ['rasterio'] * 10, 'time': t_list}
df = pd.DataFrame.from_dict(df)
if not os.path.isdir('results'): os.mkdir('results')
savepath = os.path.join('results', 'ndvi-rasterio.csv')
df.to_csv(savepath, index = False, decimal = ',', sep = ';')
