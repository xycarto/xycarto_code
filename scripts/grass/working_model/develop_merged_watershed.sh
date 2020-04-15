#!/bin/bash

#develop watersheds

outDir=/home/ireese/testing/hydrotesting/shapes/vector_watersheds

watershedList=$1
#watershedList=/home/ireese/testing/hydrotesting/shapes/vector_watersheds/watershedList.txt

#list=$( echo demClipped_at_coast_basinVect_7500000 demClipped_at_coast_basinVect_5000000 demClipped_at_coast_basinVect_2500000 demClipped_at_coast_basinVect_1000000 demClipped_at_coast_basinVect_500000 demClipped_at_coast_basinVect_250000 demClipped_at_coast_basinVect_10000)
initVect=$(head -1 $watershedList)
initVectForMerge=$(head -1 $watershedList) #need for later patch
list=$(cat $watershedList | grep -v $initVect)

echo $list

for i in $list
do
    ainput=$i
    binput=$initVect

    fileName=${binput}_overlay
    shpOut=$outDir/$fileName.gpkg

    echo $ainput
    echo $binput
    echo $fileName
    echo $shpOut

    echo "running overlay"
    #v.overlay [-t] ainput=name [alayer=string] [atype=string[,string,...]] binput=name [blayer=string] [btype=string[,string,...]] operator=string output=name [olayer=string[,string,...]] [snap=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    v.overlay ainput=$ainput atype=area binput=$binput btype=area output=$fileName operator=not --overwrite

    #echo "output overlays to gpkg"
    #v.out.ogr input=${fileName} output=$shpOut type=area format=GPKG --overwrite

    initVect=$i

done

mergeList=$(g.list type=vector pattern=*_overlay)

inputList=$(echo $mergeList | sed "s/ /,/g")

echo "running patch"
#v.patch [-nzeab] input=name[,name,...] output=name [bbox=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui]
mergedWatershed=mergedWatershed
v.patch input=$inputList,$initVectForMerge output=$mergedWatershed --overwrite

echo "output merged watershed to file"
outMergedWatershed=${outDir}/${mergedWatershed}.shp
v.out.ogr input=$mergedWatershed output=$outMergedWatershed type=area format=ESRI_Shapefile --overwrite

#add id column
echo "add id column and populate"
ogrinfo $outMergedWatershed -sql "ALTER TABLE mergedWatershed ADD COLUMN id integer" 
ogrinfo $outMergedWatershed -dialect SQLite -sql "UPDATE mergedWatershed set id = rowid+1"

#clean up geometries
echo "running buffer"
ogr2ogr -f "ESRI Shapefile" ${outDir}/mergedWatershed_buff.shp $outMergedWatershed -dialect sqlite -sql "select id, ST_buffer(Geometry,0) as geom from mergedWatershed" -overwrite

g.remove -f type=vector pattern="*_overlay"
