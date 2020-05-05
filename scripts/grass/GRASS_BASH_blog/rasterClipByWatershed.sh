#!/bin/bash

# set base path
outDir=grass_test
outDirRast=grass_test/raster_watersheds

# Set raster as variable
raster=${outDir}/lds-tile-jm-GTiff/JM.tif
rasterName=$( basename $raster | sed 's/.tif//g' )

#prep your input vectors
inputVector=/home/ireese/grass_test/JM_basinVectOut_2000000.shp
inputVectorLayerName=$(basename $inputVector | sed 's/.shp//')

#create your watersheds list
watershedList=$(ogrinfo -geom=NO -q -sql "SELECT cat FROM $inputVectorLayerName" $inputVector | grep 'cat (Integer)' | sed s/'cat (Integer) =//')

for i in $watershedList
do
    gdalwarp -of GTiff -dstnodata -9999 -cutline $inputVector -csql "SELECT cat FROM $inputVectorLayerName where cat='$i'" -crop_to_cutline $raster $outDirRast/{$rasterName}_${i}.tif
done