# -*- coding: utf-8 -*-
import os
import timeit
import pandas as pd
from rasterstats import zonal_stats


wd = os.getcwd()
catalog = os.path.join('data', 'LC08_L1TP_190024_20200418_20200822_02_T1')
rasters = os.listdir(catalog)
rasters = [r for r in rasters if r.endswith(('.TIF'))]
rasters = [os.path.join(wd, catalog, r) for r in rasters]
band_names = ["B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9"]

buffers = os.path.join('data', 'vector', 'buffers.gpkg')

### zonal

t_list = [None] * 10
for i in range(10):
    tic = timeit.default_timer()
    data = []
    for ras in rasters:
        zonal = zonal_stats(buffers, ras, stats = 'mean')
        zonal = [z['mean'] for z in zonal]
        data.append(zonal)
    
    data = pd.DataFrame(data).transpose()
    data.columns = band_names
    
    toc = timeit.default_timer()
    t_list[i] = round(toc - tic, 2)
    

df = {'task': ['zonal'] * 10, 'package': ['rasterstats'] * 10, 'time': t_list}
df = pd.DataFrame.from_dict(df)
if not os.path.isdir('results'): os.mkdir('results')
savepath = os.path.join('results', 'zonal-rasterstats.csv')
df.to_csv(savepath, index = False, decimal = ',', sep = ';')
