#!/bin/bash

#create watershed boundaries 

inDir=/home/ireese/testing/hydrotesting
outDirRast=${inDir}/raster/raster_processed_grass
outDirVect=${inDir}/shapes/vector_watersheds

#rasters=$(find ${inDir}/raster -name '*.tif')
#accept raster from imput stream
rasters=$1
echo $rasters

fileName=$(basename $rasters | sed 's/\.tif//')
echo "Filename: $fileName"

#import raster elevation
echo "Running raster import"
#r.in.gdal [-ojeflakcrp] input=name output=name [band=integer[,integer,...]] [memory=integer] [target=name] [title=phrase] [offset=integer] [num_digits=integer] [map_names_file=name] [location=name] [table=file] [gdal_config=string] [gdal_doo=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
r.in.gdal --overwrite input=$rasters output=${fileName}
echo "set workspace region"
g.region rast=${fileName} -p
    
echo "raster input info"
#r.info [-grseh] map=name [--help] [--verbose] [--quiet] [--ui] 
r.info map=${fileName}

#create hydro DEM
#pay attemtion to 'size' and 'mod'.  Size will be a place where depression of a certain can be overlooked
echo "create hydro corrected dem"
#r.hydrodem [-afc] input=name [depression=name] [memory=integer] output=name mod=integer size=integer [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
hydrodem=${fileName}_hydrodem
r.hydrodem input=$fileName memory=3000 output=$hydrodem mod=4 size=4 --overwrite

echo "hydrodem info"
r.info map=$hydrodem

#set watershed sizes
#order is important
watershedSteps=$(echo 3000000 1000000 750000 500000 250000 100000 50000 25000 10000)

for w in $watershedSteps
do
    echo "Running raster watershed"
    #r.watershed [-s4mab] elevation=name [depression=name] [flow=name] [disturbed_land=name] [blocking=name] [retention=name] [threshold=integer] [max_slope_length=float] [accumulation=name] [tci=name] [spi=name] [drainage=name] [basin=name] [stream=name] [half_basin=name] [length_slope=name] [slope_steepness=name] [convergence=integer] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    threshold=$w
    accumulation=${fileName}_accumulation_${threshold}
    drainage=${fileName}_drainage_${threshold}
    stream=${fileName}_stream_${threshold}
    basin=${fileName}_basin_${threshold}
    #run watershed command
    r.watershed elevation=$hydrodem threshold=$threshold accumulation=$accumulation drainage=$drainage stream=$stream basin=$basin memory=4000 --overwrite

    #basin raster to vector
    echo "Running basin raster to vector"
    #r.to.vect [-svzbt] input=name output=name type=string [column=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    basinVect=${fileName}_basinVect_${threshold}
    #vectorize basin raster
    r.to.vect input=$basin output=$basinVect type=area column=bnum --overwrite

    #create list of vectors for processing later
    echo $basinVect >> ${outDirVect}/watershedList.txt
    cat ${outDirVect}/watershedList.txt

    echo "export basin vector to shp"
    #export basin vector
    basinVectOut=${outDirVect}/${fileName}_basinVectOut_${threshold}.gpkg
    v.out.ogr input=$basinVect output=$basinVectOut type=area format=GPKG --overwrite

    echo "done"
done

