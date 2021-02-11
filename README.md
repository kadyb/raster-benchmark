# Raster benchmarks
This repository contains a collection of raster processing benchmarks for Python and R packages.
The tests cover the most common operations such as extracting values by points, downsampling, calculating NDVI, writing multilayer, cropping by extent and calcualting zonal statictics.
The results are available at https://kadyb.github.io/raster-benchmark/report.html.

### Software
**Python**:
- [rasterio](https://github.com/mapbox/rasterio)
- [rasterstats](https://github.com/perrygeo/python-rasterstats)

**R**:
- [stars](https://github.com/r-spatial/stars)
- [terra](https://github.com/rspatial/terra)
- [raster](https://github.com/rspatial/raster)
- [exactextractr](https://github.com/isciences/exactextractr)

### Reproduction
1. Download raster data (851 MB) from [Google Drive](https://drive.google.com/uc?id=1lzglfQJqlQh9OWT_-czc5L0hQ1AhoR8M&export=download) or [Earth Explorer](https://earthexplorer.usgs.gov/) (original source, registration required) and then unzip to `data/`. 

### Dataset
Landsat 8 satellite scene (10 bands with a resolution of 30 m) was used for tests.

Scene ID: *LC08_L1TP_190024_20200418_20200822_02_T1*

### Hardware configuration

### Acknowledgment
Landsat-8 image courtesy of the U.S. Geological Survey, https://earthexplorer.usgs.gov/
