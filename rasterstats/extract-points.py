# -*- coding: utf-8 -*-

# skip this test because one band proccesing takes more than 6 min
if False:

    import os
    from rasterstats import point_query
    
    
    wd = os.getcwd()
    catalog = os.path.join('data', 'LC08_L1TP_190024_20200418_20200822_02_T1')
    rasters = os.listdir(catalog)
    rasters = [r for r in rasters if r.endswith(('.TIF'))]
    rasters = [os.path.join(wd, catalog, r) for r in rasters]
    band_names = ["B1", "B10", "B11", "B2", "B3", "B4", "B5", "B6", "B7", "B9"]
    
    points = os.path.join('data', 'vector', 'points.gpkg')
    
    ### extract

    data = []
    for ras in rasters:
        vals = point_query(points, ras, interpolate = 'nearest')
        data.append(vals)
