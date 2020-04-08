#testing for using saga gis to burn vectors into an elevation 
#raster and create a rivers network.  The goal is to make rivers
#follow pre-existing rivers drawn from aerial imagery.  Testing 
#is first completed using LINZ 8m DEM and LINZ hydro lines 

rasters=~/testing/hydrotesting/raster/BJ.tif 

r.in.gdal --overwrite input=~/testing/hydrotesting/raster/BJ.tif output=bj

r.info map=bj

g.region rast=bj -p

r.out.gdal input=bj output=~/testing/hydrotesting/bj_test_GRASS/grasscollect/test.tif  nodata=-9999