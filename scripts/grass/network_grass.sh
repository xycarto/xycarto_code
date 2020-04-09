#!/bin/bash

#testing for using GRASS gis to burn vectors into an elevation 
#raster and create a rivers network.  The goal is to make rivers
#follow pre-existing rivers drawn from aerial imagery.  Testing 
#is first completed using LINZ 8m DEM and LINZ hydro lines 

#TODO: Clean up script for more universal use

#script for testing 

inDir=~/testing/hydrotesting
outDir=~/hydrotesting/bj_test_GRASS/grasscollect

#rasters=$(find ${inDir}/raster -name '*.tif')
rasters=~/testing/hydrotesting/raster/BJ.tif
echo $rasters

rivers_v_in=~/testing/hydrotesting/shapes/clipped/rivers_BJ_oneatt.shp
rivers_v=bj_rivers

#GRASS setup for hydrology

g.remove -f type=vector name=$rivers_v

#import vector rivers
#v.import [-flo] input=string [layer=string[,string,...]] [output=name] [extent=string] [encoding=string] [snap=float] [epsg=integer] [datum_trans=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
v.in.ogr input=$rivers_v_in output=$rivers_v 
#v.out.ogr input=$rivers_v output=/home/ireese/testing/hydrotesting/bj_test_GRASS/grasscollect/bj_rivers.shp format=ESRI_Shapefile

#import raster elevation
for i in $rasters
do
    filename=$(basename $i | sed 's/\.tif//')
    #r.in.gdal [-ojeflakcrp] input=name output=name [band=integer[,integer,...]] [memory=integer] [target=name] [title=phrase] [offset=integer] [num_digits=integer] [map_names_file=name] [location=name] [table=file] [gdal_config=string] [gdal_doo=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    r.in.gdal --overwrite input=$i output=$filename
    g.region rast=$filename -p

    outfile=${outDir}/${filename}_original.tif
    r.out.gdal input=$filename@PERMANENT output=$outfile format=GTiff type=Float32 --overwrite
    #r.info [-grseh] map=name [--help] [--verbose] [--quiet] [--ui] 
    r.info map=$filename

    #r.fill.dir [-f] input=name output=name direction=name [areas=name] [format=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    #TODO: depression=depression map of real depressions
    filldem=${filename}_filldem
    directionDEM=${filename}_directiondem
    r.fill.dir input=$filename output=$filldem direction=$directionDEM --overwrite

    r.info map=$filldem

    #r.out.gdal [-lcmtf] input=name output=name format=string [type=string] [createopt=string[,string,...]] [metaopt=string[,string,...]] [nodata=float] [overviews=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    fillOut=${outDir}/${filename}_fill.tif
    dirOut=${outDir}/${filename}_direction.tif
    #r.out.gdal input=$filldem output=$fillOut format=GTiff
    #r.out.gdal input=$directionDEM output=$dirOut format=GTiff

    #r.carve [-n] raster=name vector=name output=name [points=name] [width=float] [depth=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    carve=${filename}_carve
    r.carve -n raster=$filldem vector=$rivers_v output=$carve depth=2 width=10 --overwrite

    #r.terraflow [-s] elevation=name [filled=name] [direction=name] [swatershed=name] [accumulation=name] [tci=name] [d8cut=float] [memory=integer] [directory=string] [stats=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    filled=${filename}_filled
    direction=${filename}_direction
    swatershed=${filename}_swatershed
    accumulation=${filename}_accumulation
    
    filledOut=${outDir}/${filename}_filled.tif
    directionOut=${outDir}/${filename}_direction.tif
    swatershedOut=${outDir}/${filename}_swatershed.tif
    accumulationOut=${outDir}/${filename}_accumulation.tif
    #r.terraflow elevation=$filename filled=$filled direction=$direction swatershed=$swatershed accumulation=$accumulation memory=3000 directory=/media/ireese/linz_data_BackUp_disk1/temp --overwrite
    #r.out.gdal input=$filled output=$filledOut format=GTiff
    #r.out.gdal input=$direction output=$directionOut format=GTiff
    #r.out.gdal input=$swatershed output=$swatershedOut format=GTiff
    #r.out.gdal input=$accumulation output=$accumulationOut format=GTiff

    #r.hydrodem [-afc] input=name [depression=name] [memory=integer] output=name mod=integer size=integer [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    hydrodem=${filename}_hydrodem
    r.hydrodem input=$carve memory=3000 output=$hydrodem mod=4 size=4 --overwrite

    #r.watershed [-s4mab] elevation=name [depression=name] [flow=name] [disturbed_land=name] [blocking=name] [retention=name] [threshold=integer] [max_slope_length=float] [accumulation=name] [tci=name] [spi=name] [drainage=name] [basin=name] [stream=name] [half_basin=name] [length_slope=name] [slope_steepness=name] [convergence=integer] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    accumulation=${filename}_accumulation
    drainage=${filename}_drainage
    stream=${filename}_stream
    r.watershed elevation=$hydrodem threshold=20 accumulation=$accumulation drainage=$drainage stream=$stream memory=3000 --overwrite

    #r.stream.order [-zma] stream_rast=name direction=name [elevation=name] [accumulation=name] [stream_vect=name] [strahler=name] [horton=name] [shreve=name] [hack=name] [topo=name] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    stream_vect=${filename}_stream_vect
    strahler=${filename}_strahler
    r.stream.order stream_rast=$stream direction=$drainage elevation=$hydrodem accumulation=$accumulation stream_vect=$stream_vect strahler=$strahler memory=3000 --overwrite
    streamOut=${outDir}/${filename}_stream_vector_iii.gpkg
    v.out.ogr input=$stream_vect output=$streamOut format=GPKG --overwrite

    #r.stream.extract elevation=name [accumulation=name] [depression=name] threshold=float [d8cut=float] [mexp=float] [stream_length=integer] [memory=integer] [stream_raster=name] [stream_vector=name] [direction=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui]
    stream_vector=${filename}_stream_vector
    streamOut=${outDir}/${filename}_stream_vector.shp
    #r.stream.extract elevation=$filldem threshold=1 stream_vector=$stream_vector --overwrite
    #v.out.ogr input=$stream_vector output=$streamOut format=ESRI_Shapefile

done
