### create grass environment
grass -c epsg:2193 -e /home/ireese/testing/hydrotesting/GRASS_ENV

### launch grass interactive environment (for testing)

grass /home/ireese/testing/hydrotesting/GRASS_ENV/PERMANENT

### gather raster data
 
### gather rivers data

### clip raster data by coastline
### downsample raster for watershed creation

time bash -v /home/ireese/testing/hydrotesting/scripts/prep_raster.sh

### clip rivers by NI and SI

### create watershed from downsampled raster

time grass /home/ireese/testing/hydrotesting/GRASS_ENV/PERMANENT --exec sh /home/ireese/testing/hydrotesting/scripts/create_watershed_boundaries.sh /home/ireese/testing/hydrotesting/raster/raster_processed_gdal/warpCut_20.tif

	hydrodem
	eliminiate overlapping watersheds
	
### merge into one clean watershed
time grass /home/ireese/testing/hydrotesting/GRASS_ENV/PERMANENT --exec sh /home/ireese/testing/hydrotesting/scripts/develop_merged_watershed.sh /home/ireese/testing/hydrotesting/shapes/vector_watersheds/watershedList.txt

### clip original raster by watersheds
time grass /home/ireese/testing/hydrotesting/GRASS_ENV/PERMANENT --exec sh /home/ireese/testing/hydrotesting/scripts/network_by_watershed.sh

### Run river creation process
	do I need a fill?
	hydrodem good enough?
	carve in obsticles or rivers
	run river creation
	clean rivers to remove prev_str column
	merge all streams to master stream file


