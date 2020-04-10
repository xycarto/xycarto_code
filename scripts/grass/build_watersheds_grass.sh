#!/bin/bash

#develop watersheds

BJ_coastClip_basinVect_500000
BJ_coastClip_basinVect_250000
BJ_coastClip_basinVect_100000
BJ_coastClip_basinVect_50000
BJ_coastClip_basinVect_25000
BJ_coastClip_basinVect_5000

ainput=BJ_coastClip_basinVect_250000
binput=BJ_coastClip_basinVect_500000



v.out.ogr input=notouch_b output=/home/ireese/testing/hydrotesting/bj_test_GRASS/grasscollect/notouch_b.shp type=area format=ESRI_Shapefile --overwrite

v.overlay [-t] ainput=name [alayer=string] [atype=string[,string,...]] binput=name [blayer=string] [btype=string[,string,...]] operator=string output=name [olayer=string[,string,...]] [snap=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 

v.overlay ainput=$ainput atype=area binput=$binput btype=area output=notouch_b operator=not --overwrite