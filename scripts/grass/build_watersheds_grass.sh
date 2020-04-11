#!/bin/bash

#develop watersheds

outDir=/home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP

list=$( echo BJ_coastClip_basinVect_500000 BJ_coastClip_basinVect_250000 BJ_coastClip_basinVect_100000 BJ_coastClip_basinVect_50000 BJ_coastClip_basinVect_25000 BJ_coastClip_basinVect_5000)

echo $list

initVect=BJ_coastClip_basinVect_1000000

for i in $list
do
    ainput=$i
    binput=$initVect

    fileName=${binput}_overlay
    shpOut=$outDir/$fileName.shp

    echo $ainput
    echo $binput
    echo $fileName
    echo $shpOut

    echo "running overlay"
    #v.overlay [-t] ainput=name [alayer=string] [atype=string[,string,...]] binput=name [blayer=string] [btype=string[,string,...]] operator=string output=name [olayer=string[,string,...]] [snap=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    v.overlay ainput=$ainput atype=area binput=$binput btype=area output=$fileName operator=not --overwrite

    v.out.ogr input=${fileName} output=$shpOut type=area format=ESRI_Shapefile --overwrite

    initVect=$i

done

mergeList=$(g.list type=vector pattern=*_overlay)

inputList=$(echo $mergeList | sed "s/ /,/g")

echo "running patch"
#v.patch [-nzeab] input=name[,name,...] output=name [bbox=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
v.patch input=$inputList,BJ_coastClip_basinVect_1000000 output=merged --overwrite

v.out.ogr input=merged output=/home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp type=area format=ESRI_Shapefile --overwrite

#add id column
echo "add id column and populate"
ogrinfo /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp -sql "ALTER TABLE merged ADD COLUMN id integer" 
ogrinfo /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp -dialect SQLite -sql "UPDATE merged set id = rowid+1"

#clean up geometries
echo "running buffer"
ogr2ogr -f "ESRI Shapefile" /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/mergedBuff.shp /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp -dialect sqlite -sql "select id, ST_buffer(Geometry,0) as geom from merged"


