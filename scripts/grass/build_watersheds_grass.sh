#!/bin/bash

#develop watersheds

outDir=/home/ireese/testing/hydrotesting/bj_test_GRASS/largetest

list=$( echo demClipped_at_coast_basinVect_7500000 demClipped_at_coast_basinVect_5000000 demClipped_at_coast_basinVect_2500000 demClipped_at_coast_basinVect_1000000 demClipped_at_coast_basinVect_500000 demClipped_at_coast_basinVect_250000 demClipped_at_coast_basinVect_10000)
#list=$(cat ${outDir}/watershedList.txt)

echo $list

initVect=demClipped_at_coast_basinVect_10000000

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

mergeList=$(g.list type=vector pattern=demClipped_at_coast*_overlay)

inputList=$(echo $mergeList | sed "s/ /,/g")

echo "running patch"
#v.patch [-nzeab] input=name[,name,...] output=name [bbox=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
v.patch input=$inputList,demClipped_at_coast_basinVect_10000000 output=merged --overwrite

v.out.ogr input=merged output=${outDir}/merged.shp type=area format=ESRI_Shapefile --overwrite

#add id column
echo "add id column and populate"
ogrinfo ${outDir}/merged.shp -sql "ALTER TABLE merged ADD COLUMN id integer" 
ogrinfo ${outDir}/merged.shp -dialect SQLite -sql "UPDATE merged set id = rowid+1"

#clean up geometries
echo "running buffer"
ogr2ogr -f "ESRI Shapefile" ${outDir}/mergedBuff.shp ${outDir}/merged.shp -dialect sqlite -sql "select id, ST_buffer(Geometry,0) as geom from merged"


