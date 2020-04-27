#!/bin/bash

#UNFINISHED

#set input environment

#merged watershed vector 
watershed=$1
#input DEM at original resolution
inRast=$2
#output location for clipped DEM
outDir=$3

watershedLayerName=$(basename $watershed | sed 's/.shp//')
watershedList=$(ogrinfo $watershed )

getBaseName=$(basename $inRast | sed 's/.tif//')

#clip raster by watershed
for i in $watershedList
do
    fileName=${getBaseName}_${i}
    gdalwarp -of GTiff -dstnodata -9999 -cutline $watershed -csql "SELECT * FROM $watershedLayerName where id='$i'" -clip_to_cutline $inRast $outDir/{fileName}.tif
done



