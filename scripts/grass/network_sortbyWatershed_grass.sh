#!/bin/bash

#testing for using GRASS gis to burn vectors into an elevation 
#raster and create a rivers network.  The goal is to make rivers
#follow pre-existing rivers drawn from aerial imagery.  Testing 
#is first completed using LINZ 8m DEM and LINZ hydro lines 

#TODO: Clean up script for more universal use

#script for testing 

inDir=/home/ireese/testing/hydrotesting
outDir=/home/ireese/testing/hydrotesting/bj_test_GRASS/grasscollect

#rasters=$(find ${inDir}/raster -name '*.tif')
rasters=/home/ireese/testing/hydrotesting/raster/BJ_coastClip.tif
echo $rasters



#import raster elevation
for i in $rasters
do
    filename=$(basename $i | sed 's/\.tif//')
    echo "Running raster import"
    #r.in.gdal [-ojeflakcrp] input=name output=name [band=integer[,integer,...]] [memory=integer] [target=name] [title=phrase] [offset=integer] [num_digits=integer] [map_names_file=name] [location=name] [table=file] [gdal_config=string] [gdal_doo=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    r.in.gdal --overwrite input=$i output=$filename
    g.region rast=$filename -p
    outfile=${outDir}/${filename}_original.tif
    r.out.gdal input=$filename output=$outfile format=GTiff type=Float32 --overwrite
    
    #r.info [-grseh] map=name [--help] [--verbose] [--quiet] [--ui] 
    r.info map=$filename

    echo "Running raster filldem"
    #r.fill.dir [-f] input=name output=name direction=name [areas=name] [format=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    #TODO: depression=depression map of real depressions
    filldem=${filename}_filldem
    directionDEM=${filename}_directiondem
    r.fill.dir input=$filename output=$filldem direction=$directionDEM --overwrite

    r.info map=$filldem

    #r.carve [-n] raster=name vector=name output=name [points=name] [width=float] [depth=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    #carve=${filename}_carve
    #r.carve -n raster=$filldem vector=$rivers_v output=$carve depth=2 width=10 --overwrite

    echo "Running raster hydrodem"
    #r.hydrodem [-afc] input=name [depression=name] [memory=integer] output=name mod=integer size=integer [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    #hydrodem=${filename}_hydrodem
    #r.hydrodem input=$filldem memory=3000 output=$hydrodem mod=4 size=4 --overwrite

    echo "Running raster watershed"
    #r.watershed [-s4mab] elevation=name [depression=name] [flow=name] [disturbed_land=name] [blocking=name] [retention=name] [threshold=integer] [max_slope_length=float] [accumulation=name] [tci=name] [spi=name] [drainage=name] [basin=name] [stream=name] [half_basin=name] [length_slope=name] [slope_steepness=name] [convergence=integer] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    threshold=5000
    accumulation=${filename}_accumulation
    drainage=${filename}_drainage
    stream=${filename}_stream
    basin=${filename}_basin_${threshold}
    #run watershed command
    #r.watershed elevation=$hydrodem threshold=$threshold accumulation=$accumulation drainage=$drainage stream=$stream basin=$basin  memory=3000 --overwrite
    r.watershed elevation=$filldem threshold=$threshold accumulation=$accumulation drainage=$drainage stream=$stream basin=$basin memory=3000 --overwrite
    #export watershed outputs
    basinOut=${outDir}/${filename}_basin_${threshold}.tif
    r.out.gdal input=$basin output=$basinOut format=GTiff type=Float32 --overwrite

    echo "Running basin raster to vector"
    #r.to.vect [-svzbt] input=name output=name type=string [column=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    basinVect=${filename}_basinVect_${threshold}
    #vectorize basin raster
    r.to.vect input=$basin output=$basinVect type=area column=bnum --overwrite
    #export basin vector
    basinVectOut=${outDir}/${filename}_basinVectOut_${threshold}.shp
    v.out.ogr input=$basinVect output=$basinVectOut type=area format=ESRI_Shapefile --overwrite


    #r.stream.order [-zma] stream_rast=name direction=name [elevation=name] [accumulation=name] [stream_vect=name] [strahler=name] [horton=name] [shreve=name] [hack=name] [topo=name] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    #stream_vect=${filename}_stream_vect
    #strahler=${filename}_strahler
    #r.stream.order stream_rast=$stream direction=$drainage elevation=$hydrodem accumulation=$accumulation stream_vect=$stream_vect strahler=$strahler memory=3000 --overwrite
    #streamOut=${outDir}/${filename}_stream_vector.shp
    #v.out.ogr input=$stream_vect output=$streamOut format=ESRI_Shapefile type=area --overwrite

done
