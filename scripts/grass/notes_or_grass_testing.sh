rasters=/home/ireese/testing/hydrotesting/raster/BJ.tif 

r.in.gdal --overwrite input=/home/ireese/testing/hydrotesting/raster/BJ.tif output=bj

r.info map=bj

g.region rast=bj -p

r.out.gdal input=bj output=/home/ireese/testing/hydrotesting/bj_test_GRASS/grasscollect/test.tif  nodata=-9999