#!/bin/bash

#testing for using GRASS gis to burn vectors into an elevation 
#raster and create a rivers network.  The goal is to make rivers
#follow pre-existing rivers drawn from aerial imagery.  Testing 
#is first completed using LINZ 8m DEM and LINZ hydro lines 

#TODO: Clean up script for more universal use

#script for testing 

inDir=/home/ireese/testing/hydrotesting
outDir=/home/ireese/testing/hydrotesting/bj_test_GRASS/largetest

#rasters=$(find ${inDir}/raster -name '*.tif')
rasters=/home/ireese/testing/hydrotesting/raster/demClipped_at_coast.tif
echo $rasters

#import raster elevation
for i in $rasters
do
    fileName=$(basename $i | sed 's/\.tif//')
    echo "Running raster import"
    #r.in.gdal [-ojeflakcrp] input=name output=name [band=integer[,integer,...]] [memory=integer] [target=name] [title=phrase] [offset=integer] [num_digits=integer] [map_names_file=name] [location=name] [table=file] [gdal_config=string] [gdal_doo=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    r.in.gdal --overwrite input=$i output=$fileName
    g.region rast=$fileName -p
    #outfile=${outDir}/${filename}_original.tif
    #r.out.gdal input=$filename output=$outfile format=GTiff type=Float32 --overwrite
    
    #r.info [-grseh] map=name [--help] [--verbose] [--quiet] [--ui] 
    r.info map=$fileName

    echo "Running raster filldem"
    #r.fill.dir [-f] input=name output=name direction=name [areas=name] [format=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    #TODO: depression=depression map of real depressions
    #filldem=${filename}_filldem
    #directionDEM=${filename}_directiondem
    #r.fill.dir input=$filename output=$filldem direction=$directionDEM --overwrite

    #create hydro DEM
    echo "create hydro corrected dem"
    #r.hydrodem [-afc] input=name [depression=name] [memory=integer] output=name mod=integer size=integer [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    hydrodem=${fileName}_hydrodem
    #r.hydrodem input=$fileName memory=3000 output=$hydrodem mod=4 size=4 --overwrite

    r.info map=$hydrodem

    watershedSteps=$(echo 10000000 7500000 5000000 2500000 1000000 500000 250000 10000)

    for w in $watershedSteps
    do
        echo "Running raster watershed"
        #r.watershed [-s4mab] elevation=name [depression=name] [flow=name] [disturbed_land=name] [blocking=name] [retention=name] [threshold=integer] [max_slope_length=float] [accumulation=name] [tci=name] [spi=name] [drainage=name] [basin=name] [stream=name] [half_basin=name] [length_slope=name] [slope_steepness=name] [convergence=integer] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
        threshold=$w
        accumulation=${fileName}_accumulation
        drainage=${fileName}_drainage
        stream=${fileName}_stream
        basin=${fileName}_basin_${threshold}
        #run watershed command
        #r.watershed elevation=$hydrodem threshold=$threshold accumulation=$accumulation drainage=$drainage stream=$stream basin=$basin  memory=3000 --overwrite
        r.watershed elevation=$hydrodem threshold=$threshold accumulation=$accumulation drainage=$drainage stream=$stream basin=$basin memory=3000 --overwrite
        #export watershed outputs
        basinOut=${outDir}/${fileName}_basin_${threshold}.tif
        r.out.gdal input=$basin output=$basinOut format=GTiff type=Float32 --overwrite

        echo "Running basin raster to vector"
        #r.to.vect [-svzbt] input=name output=name type=string [column=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
        basinVect=${fileName}_basinVect_${threshold}
        #vectorize basin raster
        r.to.vect input=$basin output=$basinVect type=area column=bnum --overwrite
        #export basin vector
        basinVectOut=${outDir}/${fileName}_basinVectOut_${threshold}.shp
        v.out.ogr input=$basinVect output=$basinVectOut type=area format=ESRI_Shapefile --overwrite
    done
done
