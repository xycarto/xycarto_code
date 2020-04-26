### Set test environment
inDir=

### create grass environment
grass -c epsg:2193 -e ${inDir}/GRASS_ENV

### launch grass interactive environment (for testing)

grass ${inDir}/GRASS_ENV/PERMANENT

### gather raster data
 
### gather rivers data

### clip raster data by coastline
### downsample raster for watershed creation

time bash -v ${inDir}/scripts/prep_raster.sh

### clip rivers by NI and SI

### create watershed from downsampled raster

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${inDir}/scripts/create_watershed_boundaries.sh /home/ireese/testing/wellington_hydro/dem_orig_25_clipped.tif

### merge into one clean watershed
time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${inDir}/scripts/develop_merged_watershed.sh /home/ireese/testing/hydrotesting/shapes/vector_watersheds/watershedList.txt

### clip original raster by watersheds
time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${inDir}/scripts/network_by_watershed.sh

time grass ${inDir}/GRASS_ENV/PERMANENT --exec sh ${inDir}/scripts/network_by_watershed_noClip.sh

### Run river creation process
	

