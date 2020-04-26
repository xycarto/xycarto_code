#!/bin/bash

inRast=/home/ireese/testing/hydrotesting/raster/raster_raw
outRast=/home/ireese/testing/hydrotesting/raster/raster_processed_gdal

coastline=/home/ireese/testing/hydrotesting/shapes/vector_raw/coastline_NZTM.shp

rasterList=$(find $inRast -name '*.tif')

for i in $rasterList
do
    gdaladdo -clean $i
done

cd $inRast

gdalbuildvrt rast.vrt *.tif

cd

gdalwarp -of GTiff -cutline $coastline -csql "SELECT * FROM coastline_NZTM where NAME='North Island or Te Ika-a-Māui'" -multi -wo NUM_THREADS=ALL_CPUS  $inRast/rast.vrt $outRast/warpCut_original.tif

gdalwarp -of GTiff -tr 20 -20 -cutline $coastline -csql "SELECT * FROM coastline_NZTM where NAME='North Island or Te Ika-a-Māui'" -multi -wo NUM_THREADS=ALL_CPUS $inRast/rast.vrt $outRast/warpCut_20.tif

gdalwarp -of GTiff -dstnodata -9999 -cutline /home/ireese/testing/wellington_hydro/vectorCatchments/dem_orig_25_clipped_basinVectOut_2000000.gpkg -crop_to_cutline -multi -wo NUM_THREADS=ALL_CPUS /home/ireese/testing/wellington_hydro/dem_orig.tif /home/ireese/testing/wellington_hydro/dem_orig_bigCatchment.tif

gdal_translate -tr 5.0 -5.0 /home/ireese/testing/wellington_hydro/dem_orig_bigCatchment.tif /home/ireese/testing/wellington_hydro/dem_orig_bigCatchmen_5.tif