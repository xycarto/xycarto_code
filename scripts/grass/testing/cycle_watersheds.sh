#!/bin/bash

#cycle through watersheds

inTiff=/home/ireese/testing/hydrotesting/raster/BJ.tif
inRiver=/home/ireese/testing/hydrotesting/shapes/clipped/rivers_BJ.shp
outDir=/home/ireese/testing/hydrotesting/raster/wshedClip

cutLine=/home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp

layerName=/home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp
idList=$( ogrinfo -geom=NO -q -sql "SELECT id FROM merged" $layerName | grep 'id (Integer)' | sed s/'id (Integer) =//' )

for i in $idList
do
    echo $i
    fileName=$(basename $i | sed 's/\.tif//')

    ogr2ogr -clipsrc $cutLine -clipsrcsql "select * from merged where id=${i}" $outDir/${fileName}_id_${i}_clipRiver.shp $inRiver 

    gdalwarp -of GTiff -cutline $cutLine -csql "SELECT * FROM merged where id=${i}" -crop_to_cutline -tr 8.0 -8.0 $inTiff $outDir/${fileName}_id_${i}.tif
done