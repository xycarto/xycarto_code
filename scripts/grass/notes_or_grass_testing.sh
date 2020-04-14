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


time grass /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/PERMANENT --exec sh /home/ireese/xycarto_code/scripts/grass/build_watersheds_grass.sh

time grass /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/PERMANENT --exec sh /home/ireese/xycarto_code/scripts/grass/network_by_watershed.sh

gdalwarp -s_srs EPSG:2193 -t_srs EPSG:2193 -of GTiff -tr 8.0 -8.0 -tap -cutline /store/nz_coast_outline/coastline_NZTM.shp  /home/ireese/testing/hydrotesting/raster/BJ.tif /home/ireese/testing/hydrotesting/raster/BJ_coastClip.tif

ainput=BJ_coastClip_basinVect_250000
binput=BJ_coastClip_basinVect_500000
v.select [-tcr] ainput=name [alayer=string] [atype=string[,string,...]] binput=name [blayer=string] [btype=string[,string,...]] output=name operator=string [relate=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
v.select ainput=$ainput atype=area binput=$binput btype=area output=notouch_b operator=within --overwrite
v.out.ogr input=notouch_b output=/home/ireese/testing/hydrotesting/bj_test_GRASS/grasscollect/notouch_b.shp type=area format=ESRI_Shapefile --overwrite

v.overlay [-t] ainput=name [alayer=string] [atype=string[,string,...]] binput=name [blayer=string] [btype=string[,string,...]] operator=string output=name [olayer=string[,string,...]] [snap=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 

v.overlay ainput=$ainput atype=area binput=$binput btype=area output=notouch_b operator=not --overwrite

v.build -e map=BJ127_stream_vect

ogr2ogr -f "ESRI Shapefile" /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/mergedBuff.shp /home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp -dialect sqlite -sql "select id, ST_buffer(Geometry,0) as geom from merged"

mergeList=$(g.list type=vector pattern=*_stream_vect exclude=BJ221_stream_vect,BJ127_stream_vect)

for i in $mergeList; 
do 
    echo $i;
    v.db.dropcolumn map=$i columns=prev_str01,prev_str02,prev_str03,prev_str04;
    db.describe -c table=$i; 
done

echo "/home/ireese/testing/hydrotesting/raster/BI.tif /home/ireese/testing/hydrotesting/raster/BJ.tif" > /home/ireese/testing/hydrotesting/raster/list.txt

list=$(echo "/home/ireese/testing/hydrotesting/raster/BI.tif /home/ireese/testing/hydrotesting/raster/BJ.tif")

gdalbuildvrt /home/ireese/testing/hydrotesting/raster/test.vrt -input_file_list /home/ireese/testing/hydrotesting/raster/list.txt -overwrite

gdal_translate /home/ireese/testing/hydrotesting/raster/test.vrt /home/ireese/testing/hydrotesting/raster/demMerge.tif

gdalwarp -s_srs EPSG:2193 -t_srs EPSG:2193 -of GTiff -tr 8.0 -8.0 -cutline /store/nz_coast_outline/coastline_NZTM.shp  -/home/ireese/testing/hydrotesting/raster/test.vrt /home/ireese/testing/hydrotesting/raster/demMerge_cut.tif

NAME="North Island or Te Ika-a-Māui"

gdalwarp -of GTiff -cutline /store/nz_coast_outline/coastline_NZTM.shp -csql "SELECT * FROM coastline_NZTM where NAME='North Island or Te Ika-a-Māui'" /home/ireese/testing/hydrotesting/raster/test.vrt /home/ireese/testing/hydrotesting/raster/demClipped_at_coast.tif

demClipped_at_coast

r.hydrodem input=demClipped_at_coast memory=3000 output=demClipped_at_coast_hydrodem mod=4 size=4 --overwrite