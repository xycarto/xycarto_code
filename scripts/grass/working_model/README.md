### Intro

Process to develop stream order from Wellington 1m DEM.

The goal is to develop a collection of DEMs clipped at watershed boundariee, where the watershed boundaries used for processing are those only draining to the coast.

Basic steps

1. Mosaic DEM
2. Downsample mosic to for watershed creation
3. Create watersheds
4. Merge watersheds into single file, representing only those watershed that drian to the coast.
5. Clip original resolution mosic by watershed boundaries
6. Create stream order from clipped DEM

Note: for large watersheds it may be necesary to slightly downsample the clipped DEM watersheds in order to process.  Testing so far reveals that watersheds >2.5GB are difficult to process in a reasonable amount of time. 

Note: method trys to determine location where rivers may cross barriers like roads and create an outlet for continuous drainage.  

### Requirements

GRASSGIS >= 7.4

GDAL >= 2.3

PostGIS

PostgreSQL

### Set test environment
inDir=

mkdir ${inDir}/scripts

mkdir ${inDir}/raster

mkdir ${inDir}/raster/rawData

mkdir ${inDir}/raster/processedData

mkdir ${inDir}/raster/processedData/indivWatershed


mkdir ${inDir}/vector

mkdir ${inDir}/vector/rawData

mkdir ${inDir}/vector/watersheds

mkdir ${inDir}/vector/riversProcessed

mkdir ${inDir}/TEMP


inRast=${inDir}/raster/raster_raw

outRast=${inDir}/raster/raster_processed_gdal

rastWatersheds=${outRast}/indivWatershed

vectWatershed=${inDir}/vector/watersheds

vectRivers=${inDir}/vector/riversProcessed

scripts=${inDir}/scripts

tempHold=${inDir}/TEMP

### download LINZ data

raster DEM: https://data.linz.govt.nz/layer/53621-wellington-lidar-1m-dem-2013/

coastline: https://data.linz.govt.nz/layer/51153-nz-coastlines-and-islands-polygons-topo-150k/

riverPilot: https://data.linz.govt.nz/layer/103632-nz-river-name-lines-pilot/

roads: https://data.linz.govt.nz/layer/50329-nz-road-centrelines-topo-150k/

### create grass environment
grass -c epsg:2193 -e ${inDir}/GRASS_ENV

### launch grass interactive environment (for testing)

grass ${inDir}/GRASS_ENV/PERMANENT

### downsample raster for watershed creation

time bash -v ${scripts}/prep_raster.sh ${inDir} ${inRast} ${outRast}

### create watershed from downsampled raster

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${scripts}/create_watershed_boundaries.sh ${inDir} ${vectWatershed} ${outRast}/rast_50.tif

### merge vectors into one clean watershed

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${scripts}/develop_merged_watershed.sh ${vectWatershed}

### clip original raster mosaic by watershed boundaries

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${scripts}/clip_raster_by_watershed.sh ${vectWatershed}/mergedWatershed_buff.shp ${outRast}/rast_50.tif ${rastWatersheds}

### Develop carve vector

TODO: add sql process to create carve vector file

### Run river creation process

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${scripts}/scripts/network_by_watershed_noClip.sh ${rastWatersheds} ${vectCarve} ${tempHold} ${vectRivers} 

	

