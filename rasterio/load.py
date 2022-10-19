# -*- coding: utf-8 -*-
import os
import timeit
import rasterio
import numpy as np
import pandas as pd


wd = os.getcwd()
catalog = os.path.join('data', 'LC08_L1TP_190024_20200418_20200822_02_T1')
rasters = os.listdir(catalog)
rasters = [r for r in rasters if r.endswith(('.TIF'))]
rasters = [os.path.join(wd, catalog, r) for r in rasters]


t_list = [None] * 10
for i in range(10):
    tic = timeit.default_timer()

    ls = []
    for r in rasters:
        src = rasterio.open(r, "r")
        meta = src.meta
        array = src.read(masked = True).squeeze()
        ls.append(array)
        src.close()
    
    ras = np.ma.asarray(ls, dtype = 'float')
    np.ma.set_fill_value(ras, meta['nodata'])
    meta.update(count = len(rasters))
    
    toc = timeit.default_timer()
    t_list[i] = round(toc - tic, 2)


df = {'task': ['load'] * 10, 'package': ['rasterio'] * 10, 'time': t_list}
df = pd.DataFrame.from_dict(df)
if not os.path.isdir('results'): os.mkdir('results')
savepath = os.path.join('results', 'load-rasterio.csv')
df.to_csv(savepath, index = False, decimal = ',', sep = ';')