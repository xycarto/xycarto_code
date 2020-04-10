#testing for using saga gis to burn vectors into an elevation 
#raster and create a rivers network.  The goal is to make rivers
#follow pre-existing rivers drawn from aerial imagery.  Testing 
#is first completed using LINZ 8m DEM and LINZ hydro lines 

rasters=~/testing/hydrotesting/raster/BJ.tif 

r.in.gdal --overwrite input=~/testing/hydrotesting/raster/BJ.tif output=bj

r.info map=bj

g.region rast=bj -p

r.out.gdal input=bj output=~/testing/hydrotesting/bj_test_GRASS/grasscollect/test.tif  nodata=-9999

time grass /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/PERMANENT --exec sh /home/ireese/testing/hydrotesting/network_sortbyWatershed_grass.sh

v.db.select [-rcvf] map=name [layer=string] [columns=name[,name,...]] [where=sql_query] [group=string] [separator=character] [vertical_separator=character] [null_value=string] [file=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
vectorList=$( v.db.select name=${filename}_basinVect_${threshold} columns=dbnum )
for j in $vectorList
do
    r.mask raster=$filename vector=${filename}_basinVect_${threshold} where bnum=$j
done

layername=
idlist=$( ogrinfo -geom=NO -q -sql "SELECT bnum FROM ${filename}_basinVect_${threshold}" ${filename}_basinVect_${threshold} | grep 'Integer64' | sed s/'id (Integer64) =//' )

gdalwarp -of GTiff -cutline $basinVectOut -cl area_of_interest  -crop_to_cutline DATA/PCE_in_gw.asc  data_masked7.tiff 

grass -c epsg:2193 /home/ireese/testing/hydrotesting/bj_test_GRASS/clippedtest/PERMANENT

grass /home/ireese/testing/hydrotesting/bj_test_GRASS/clippedtest/PERMANENT 

time grass /home/ireese/testing/hydrotesting/bj_test_GRASS/clippedtest/PERMANENT --exec sh /home/ireese/xycarto_code/scripts/grass/network_grass.sh