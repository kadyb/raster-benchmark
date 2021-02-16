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

### raster stack

band_names = ["B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9"]

with rasterio.open(rasters[0]) as ras:
    meta = ras.meta

meta.update(count = len(rasters))

stack_file = 'stack.TIF'
with rasterio.open(stack_file, 'w', **meta) as dst:
    for id, layer in enumerate(rasters, start = 1):
        with rasterio.open(layer) as stack:
            dst.write_band(id, stack.read(1))
            dst.set_band_description(id, band_names[id - 1])

ras = rasterio.open('stack.TIF')
ras_arr = ras.read(masked=True)

ras.close() # stack_file is opened by ras
os.remove(stack_file)

### NDVI

nodata = ras.nodata

nir = ras_arr[6,:,:].astype(float) # "B5" - idx 6 from 0
red = ras_arr[5,:,:].astype(float) # "B4" - idx 5 from 0

t_list = [None] * 10
for i in range(10):
    tic = timeit.default_timer()
    
    ndvi = (nir-red)/(nir+red)
    mask = ndvi.mask.copy()
    ndvi[mask] = nodata
    
    toc = timeit.default_timer()
    t_list[i] = round(toc - tic, 2)


df = {'task': ['ndvi'] * 10, 'package': ['rasterio'] * 10, 'time': t_list}
df = pd.DataFrame.from_dict(df)
if not os.path.isdir('results'): os.mkdir('results')
savepath = os.path.join('results', 'zonal-rasterstats.csv')
df.to_csv(savepath, index = False, decimal = ',', sep = ';')
