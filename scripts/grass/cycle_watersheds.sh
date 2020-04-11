#!/bin/bash

#cycle through watersheds

inTiff=/home/ireese/testing/hydrotesting/raster/BJ.tif
outDir=/home/ireese/testing/hydrotesting/raster/wshedClip

layerName=/home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp
idList=$( ogrinfo -geom=NO -q -sql "SELECT id FROM merged" $layerName | grep 'id (Integer)' | sed s/'id (Integer) =//' )

for i in $idList
do
    echo $i
    fileName=$(basename $i | sed 's/\.tif//')
    gdalwarp -of GTiff -cutline /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp -csql "SELECT * FROM merged where id=${i}" -crop_to_cutline -tr 8.0 -8.0 $inTiff $outDir/${fileName}_id_${i}.tif
done