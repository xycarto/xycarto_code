### Set test environment
inDir=

mkdir ${inDir}/raster
mkdir ${inDir}/raster/raster_raw
mkdir ${inDir}/raster/raster_processed_gdal

mkdir ${inDir}/vector
mkdir ${inDir}/vector/watersheds
mkdir ${inDir}/vector/riversProcessed

mkdir mkdir ${inDir}/TEMP

inRast=${inDir}/raster/raster_raw
outRast=${inDir}/raster/raster_processed_gdal

### create grass environment
grass -c epsg:2193 -e ${inDir}/GRASS_ENV

### launch grass interactive environment (for testing)

grass ${inDir}/GRASS_ENV/PERMANENT

### clip raster data by coastline
### downsample raster for watershed creation

time bash -v ${inDir}/scripts/prep_raster.sh

### create watershed from downsampled raster

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${inDir}/scripts/create_watershed_boundaries.sh ${outRast}/rast_50.tif

### merge vectors into one clean watershed

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${inDir}/scripts/develop_merged_watershed.sh /home/ireese/testing/hydrotesting/shapes/vector_watersheds/watershedList.txt

### clip original raster mosaic by watershed boundaries


### Run river creation process

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${inDir}/scripts/network_by_watershed.sh

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${inDir}/scripts/network_by_watershed_noClip.sh

	

