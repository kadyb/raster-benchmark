#!/bin/bash

R_packages=(exactextractr raster stars terra)
Python_packages=(rasterio rasterstats)

mkdir results

# run R benchmarks
for i in ${R_packages[*]}
do
  for path in "${i}"/*
  do
    Rscript "$path"
  done
done

# run Python benchmarks
# for i in ${Python_packages[*]}
# do
#   for path in "${i}"/*
#   do
#     echo "$path"
#   done
# done
