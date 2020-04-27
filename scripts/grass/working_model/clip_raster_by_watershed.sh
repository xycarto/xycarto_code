#!/bin/bash

#UNFINISHED

#set input environment
inDir=$1
outDir=

inRast=$2
outRast=$3

watershed=${outDir}/mergedWatershed_buff.shp

watershedList=$(ogrinfo )

#clip raster by watershed
for i in $watershedList
do
    gdalwarp
done

