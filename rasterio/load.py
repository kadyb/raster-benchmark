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
# source rasters have 'DEFLATE' compression
with rasterio.open(stack_file, 'w', **meta, compress = 'DEFLATE') as dst:
    for id, layer in enumerate(rasters, start = 1):
        with rasterio.open(layer) as stack:
            dst.write_band(id, stack.read(1))
            dst.set_band_description(id, band_names[id - 1])

### load

t_list = [None] * 10
for i in range(10):
    tic = timeit.default_timer()

    ras = rasterio.open('stack.TIF')
    data = ras.read(masked = True)
    ras.close()
    
    toc = timeit.default_timer()
    t_list[i] = round(toc - tic, 2)
    
os.remove(stack_file)


df = {'task': ['load'] * 10, 'package': ['rasterio'] * 10, 'time': t_list}
df = pd.DataFrame.from_dict(df)
if not os.path.isdir('results'): os.mkdir('results')
savepath = os.path.join('results', 'load-rasterio.csv')
df.to_csv(savepath, index = False, decimal = ',', sep = ';')