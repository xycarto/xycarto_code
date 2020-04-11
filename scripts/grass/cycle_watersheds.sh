#!/bin/bash

#cycle through watersheds

layerName=/home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp
idList=$( ogrinfo -geom=NO -q -sql "SELECT id FROM merged" $layerName | grep 'id (Integer)' | sed s/'id (Integer) =//' )

for i in $idList
do
    echo $i
done