#!/bin/bash

#UNFINISHED

#set input environment

#merged watershed vector 
watershed=$1
echo $watershed
#input DEM at original resolution
inRast=$2
echo $inRast
#output location for clipped DEM
outDir=$3
echo $outDir

watershedLayerName=$(basename $watershed | sed 's/.shp//')
echo $watershedLayerName
watershedList=$( ogrinfo -geom=NO -q -sql "SELECT id FROM $watershedLayerName" $watershed | grep 'id (Integer)' | sed s/'id (Integer) =//' )

getBaseName=$(basename $inRast | sed 's/.tif//')

#clip raster by watershed
for i in $watershedList
do
    fileName=${getBaseName}_${i}
    echo $fileName
    #gdalwarp -of GTiff -dstnodata -9999 -cutline $watershed -csql "SELECT * FROM $watershedLayerName where id='$i'" -clip_to_cutline $inRast $outDir/{fileName}.tif
done



