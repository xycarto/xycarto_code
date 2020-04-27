#!/bin/bash

#set input environment
inDir=

inRast=${inDir}/raster/raster_raw
outRast=${inDir}/raster/raster_processed_gdal

coastline=${inDir}/vector/coastline_NZTM.shp

rasterList=$(find $inRast -name '*.tif')

#clean overviews
for i in $rasterList
do
    gdaladdo -clean $i
done

#clip coastline from rasters
#process by number of processors for speed
cd ${inRast}
numP=$(nproc)
find -name '*.tif' | sed 's/.\///g' | xargs -n${numP} -P ${numP} -t -I % gdalwarp -of GTiff -dstnodata -9999 -cutline $coastline -csql "SELECT * FROM coastline_NZTM where NAME='North Island or Te Ika-a-Māui'" % ${outDir}/%

cd ${outRast}
gdalbuildvrt rast.vrt *.tif

cd

#original resolution raster merge
gdal_translate ${outRast}/rast.vrt ${outRast}/rast.tif

#downsample for watershed creation
gdal_translate -tr 50.0 -50.0 ${outRast}/rast.tif ${outRast}/rast_50.tif
