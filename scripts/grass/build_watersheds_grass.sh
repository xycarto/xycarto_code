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

    #v.overlay [-t] ainput=name [alayer=string] [atype=string[,string,...]] binput=name [blayer=string] [btype=string[,string,...]] operator=string output=name [olayer=string[,string,...]] [snap=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 

    v.overlay ainput=$ainput atype=area binput=$binput btype=area output=$fileName operator=not --overwrite

    v.out.ogr input=$fileName output=$shpOut type=area format=ESRI_Shapefile --overwrite

    $binput=$i
    
done



