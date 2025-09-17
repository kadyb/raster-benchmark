#!/bin/bash

R_packages=(exactextractr raster stars terra)
Python_packages=(rasterio rasterstats rioxarray)
Julia_packages=(rasters_jl)

mkdir results

# run R benchmarks
for i in ${R_packages[*]}
do
  for path in "${i}"/*
  do
    echo "$path"
    pixi run --environment="r-$i" Rscript $path
  done
done

# run Python benchmarks
for i in ${Python_packages[*]}
do
  for path in "${i}"/*
  do
    echo "$path"
    pixi run --environment="py-$i" python3 $path
  done
done


# run Julia benchmarks
for i in ${Julia_packages[*]}
do
  # install julia packages first,
  # since pixi doesn't handle those
  pixi run --environment=julia-rasters julia --threads=auto --project=${i} -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
  # now the main loop
  for path in "${i}"/*.jl
  do
    echo "$path"
    pixi run --environment=julia-rasters BENCHMARKING=true julia --threads=auto --project=${i} "$path"
  done
done
