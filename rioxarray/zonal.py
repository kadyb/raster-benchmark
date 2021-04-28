# -*- coding: utf-8 -*-
import os
import numpy
import timeit
import xarray
import rioxarray
import pandas as pd
import geopandas as gpd
from geocube.api.core import make_geocube


wd = os.getcwd()
catalog = os.path.join('data', 'LC08_L1TP_190024_20200418_20200822_02_T1')
rasters = os.listdir(catalog)
rasters = [r for r in rasters if r.endswith(('.TIF'))]
rasters = [os.path.join(wd, catalog, r) for r in rasters]

buff_path = os.path.join('data', 'vector', 'buffers.gpkg')
buffers = gpd.read_file(buff_path)
buffers["ID"] = list(range(len(buffers)))

### raster stack
band_names = ["B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9"]

ras = []
for i, path in enumerate(rasters):
    ras.append(rioxarray.open_rasterio(path, masked = True).squeeze())

ras = xarray.concat(ras, "band")
ras.coords["band"] = band_names

### define zonal function
def zonal(raster, vector):
    
    out_grid = make_geocube(
    vector_data = vector,
    measurements = ["ID"],
    like = raster,
    fill = numpy.nan
    )

    out_grid["ras"] = raster
    zonal = out_grid.drop("spatial_ref").groupby(out_grid.ID)
    zonal_mean = zonal.mean().drop("spatial_ref")
    df = zonal_mean.to_dataframe().unstack()
    df.columns = df.columns.droplevel(0)
    return(df)

### benchmark

t_list = [None] * 10
for i in range(10):
    tic = timeit.default_timer()
    
    df = zonal(ras, buffers)
    
    toc = timeit.default_timer()
    t_list[i] = round(toc - tic, 2)


df = {'task': ['zonal'] * 10, 'package': ['rioxarray'] * 10, 'time': t_list}
df = pd.DataFrame.from_dict(df)
if not os.path.isdir('results'): os.mkdir('results')
savepath = os.path.join('results', 'zonal-rioxarray.csv')
df.to_csv(savepath, index = False, decimal = ',', sep = ';')
