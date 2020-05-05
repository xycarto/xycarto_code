#!/bin/bash

# set base path
outDir=grass_test

# Set raster as variable
raster=${outDir}/lds-tile-jm-GTiff/JM.tif

# Set a base name for the data. This is used to demonstrate that normal
# BASH commands can be used in this process, along side GRASS
rasterName=$( basename $raster | sed 's/.tif//g' )

# Import raster data
r.in.gdal input=$raster output=$rasterName --overwrite

# Set region. His region is set for the duration of the following commands
g.region rast=$rasterName

# Fill sinks
fillDEM=${rasterName}_filldem
directionDEM=${rasterName}_directiondem
areasDEM=${rasterName}_areasDEM
r.fill.dir input=$rasterName output=$fillDEM direction=$directionDEM areas=$areasDEM --overwrite

# Exprot a raster for viewing
areaOut=${outDir}/${rasterName}_areas.tif
r.out.gdal input=$areasDEM output=$areaOut

list=$(echo 2000000 1000000 500000)

for i in $list
do
    # Run watershed operation on fill sink raster
    threshold=$i
    accumulation=${rasterName}_accumulation_${i}
    drainage=${rasterName}_drainage_${i}
    stream=${rasterName}_stream_${i}
    basin=${rasterName}_basin_${i}
    r.watershed elevation=$fillDEM threshold=$threshold accumulation=$accumulation drainage=$drainage stream=$stream basin=$basin --overwrite

    # Convert Basin (watershed) to vector format
    basinVect=${rasterName}_basinVect_${i}
    r.to.vect input=$basin output=$basinVect type=area column=bnum --overwrite

    # Export catchment to vector format
    basinVectOut=${outDir}/${rasterName}_basinVectOut_${i}.shp
    v.out.ogr input=$basinVect output=$basinVectOut type=area format=ESRI_Shapefile --overwrite
done
