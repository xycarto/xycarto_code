#!/bin/bash

inDir=/home/ireese/testing/hydrotesting
outDir=/home/ireese/testing/hydrotesting/bj_test

#rasters=$(find ${inDir}/raster -name '*.tif')
rasters=/home/ireese/testing/hydrotesting/raster/BJ.tif

for i in $rasters
do
    filename=$(basename $i | sed 's/\.tif//')
    #filename=/home/ireese/testing/hydrotesting/raster/BJ.tif
    echo $filename
    echo $i

    inRiverVector=/home/ireese/testing/hydrotesting/shapes/clipped/rivers_BJ.shp
    outRiverVector=${outDir}/${filename}_riverLINZNetwork.shp

    #TODO:develop method to get raster reso(-tr) and bbox(-te)
    #Rasterize stream network. Must be in same reso as burn raster
    #gdal_rasterize -l rivers_BJ -burn 1.0 -tr 8.0 -8.0 -a_nodata -9999.0 -te 1638400.0 6094848.0 1703936.0 6160384.0 -ot Float32 -of GTiff /home/ireese/testing/hydrotesting/shapes/clipped/rivers_BJ.shp /home/ireese/testing/hydrotesting/raster/BJ_linz_rivers.tif

    #convert to SDAT format
    ELEV=$outDir/${filename}.sdat
    gdal_translate $i $ELEV

    #fill sink pre-process (Wang & Lu)
    #saga_cmd ta_preprocessor 4 -ELEV <str> [-FILLED <str>] [-FDIR <str>] [-WSHED <str>] [-MINSLOPE <str>]
    FILLED=$outDir/${filename}_FILLED.sdat
    FDIR=$outDir/${filename}_FDIR.sdat
    WSHED=$outDir/${filename}_WSHED.sdat
    saga_cmd ta_preprocessor 4 -ELEV $ELEV -FILLED $FILLED -FDIR $FDIR -WSHED $WSHED -MINSLOPE 0.0001

    #burn rivers
    #saga_cmd ta_preprocessor 6 [-DEM <str>] [-BURN <str>] [-STREAM <str>] [-FLOWDIR <str>] [-METHOD <str>] [-EPSILON <str>]
    BURN=$outDir/${filename}_BURN.sdat
    STREAM=/home/ireese/testing/hydrotesting/raster/BJ_linz_rivers.tif   
    saga_cmd ta_preprocessor 6 -DEM $FILLED -BURN $BURN -STREAM $STREAM -FLOWDIR $FDIR -METHOD 0 -EPSILON 1

    #sink route
    #saga_cmd ta_preprocessor 1 [-ELEVATION <str>] [-SINKROUTE <str>] [-THRESHOLD <str>] [-THRSHEIGHT <str>]
    SINKROUTE=${outDir}/${filename}_SINKROUTE.sdat
    saga_cmd ta_preprocessor 1 -ELEVATION $BURN -SINKROUTE $SINKROUTE

    #fill sink
    #saga_cmd ta_preprocessor 2 -DEM <str> [-SINKROUTE <str>] [-DEM_PREPROC <str>] [-METHOD <str>] [-THRESHOLD <str>] [-THRSHEIGHT <str>]
    DEM_PREPROC=${outDir}/${filename}_DEM_PREPROC.sdat
    saga_cmd ta_preprocessor 2 -DEM $BURN -SINKROUTE $SINKROUTE -DEM_PREPROC $DEM_PREPROC -METHOD 1

    #channel vectors
    #saga_cmd ta_channels 5 -DEM <str> [-DIRECTION <str>] [-CONNECTION <str>] [-ORDER <str>] [-BASIN <str>] [-SEGMENTS <str>] [-BASINS <str>] [-NODES <str>] [-THRESHOLD <num>]
    ORDER=${outDir}/${filename}_ORDER.sdat
    SEGMENTS=${outDir}/${filename}_SEGMENTS.shp
    saga_cmd ta_channels 5 -DEM $DEM_PREPROC  -ORDER $ORDER -SEGMENTS $SEGMENTS 
done