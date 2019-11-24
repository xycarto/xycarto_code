#!/bin/bash

#Basic sketch for interpolation of wellington harbour bathymetric points.
#The SAGA GIS processes can only iinterpolat small regions, so it is necessary to break
#the full collection of depth point into managable bits.  This will cause lines to appear between
#the iterpolated regions when brought together.  Those lies are unnoticable at
#large scale zooms. This process is to be refined in the future, but for now the 
#basic logic is being recorded.  The processes is not limited to one region, but can 
#be used for any interpolation needed over a large area with a large number of points.
#The process is a bit specific to the project at the time. Many refinements are needed
   
#Two files need to be processed first for this particular process.
#	1. CSV depth points need to be transformed to a shapefile
#	2. The extent of that shapefile is gridded to create smaller individual 
#	regions for interpolation.


#input dir
BASEPATH=

#set resolution for output
reso=

# grid file developed from shapefie extent using QGIS. QGIS builds a dbf structure of the grid
#necessary for the process
inputgridfile=

#If conversion is needed from CSV
#ogr2ogr -s_srs EPSG:4167 -t_srs EPSG:4167 -oo X_POSSIBLE_NAMES=$xname* -oo Y_POSSIBLE_NAMES=$yname*  -f "ESRI Shapefile" $outputshapepath/$basenme.shp $input.csv
#Input points for this process should be shapefile
inputpoints=

inputcsvpath=$BASEPATH/csv
outputshapepath=$BASEPATH/shape
rasteroutput=$BASEPATH/raster/TESTING

#create list of each grid cell for interpolation
idlist=$( ogrinfo -geom=NO -q -sql "SELECT id FROM contour_extent_grid" $inputgridfile | grep 'Integer64' | sed s/'id (Integer64) =//' )


for i in $idlist
do
	
	#get bounding box of grid cell
	xmin=$( ogrinfo -geom=NO -q -sql "SELECT xmin FROM contour_extent_grid where id=$i" $inputgridfile | grep 'xmin' | sed s/'  xmin (Real) = //' )
	xmax=$( ogrinfo -geom=NO -q -sql "SELECT xmax FROM contour_extent_grid where id=$i" $inputgridfile | grep 'xmax' | sed s/'  xmax (Real) = //' ) 
	ymin=$( ogrinfo -geom=NO -q -sql "SELECT ymin FROM contour_extent_grid where id=$i" $inputgridfile | grep 'ymin' | sed s/'  ymin (Real) = //' )
	ymax=$( ogrinfo -geom=NO -q -sql "SELECT ymax FROM contour_extent_grid where id=$i" $inputgridfile | grep 'ymax' | sed s/'  ymax (Real) = //' )

	echo "ID: " $i
	echo "XMIN: "$xmin
	echo "XMAX: "$xmax
	echo "YMIN: "$ymin
	echo "YMAX: "$ymax

	#interpolate surface using SAGA b-spline method
	saga_cmd grid_spline "Multilevel B-Spline Interpolation" -TARGET_DEFINITION 0 -SHAPES "$inputpoints" -FIELD "depth" -METHOD 0 -EPSILON 0.0001 -TARGET_USER_XMIN $xmin -TARGET_USER_XMAX $xmax -TARGET_USER_YMIN $ymin -TARGET_USER_YMAX $ymax -TARGET_USER_SIZE $reso -TARGET_USER_FITS 0 -TARGET_OUT_GRID "$rasteroutput/sdat/spline_${i}"

	#transform SAGA output format to geotiff	
	gdal_translate "$rasteroutput/sdat/IDW_${i}.sdat" "$rasteroutput/tif/IDW_${i}.tif"

	#hillshade of surface	
	gdaldem hillshade -multidirectional -compute_edges "$rasteroutput/tif/IDW_${i}.tif" "$rasteroutput/hs/IDW_${i}.tif"

	#build overviews for faster viewing	
	gdaladdo -ro "$rasteroutput/tif/IDW_${i}.tif" 2 4 8 16 32 64 128
	gdaladdo -ro "$rasteroutput/hs/IDW_${i}.tif" 2 4 8 16 32 64 128

done

