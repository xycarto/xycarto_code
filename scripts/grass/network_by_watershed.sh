#!/bin/bash

#network by watershed

inTiff=/home/ireese/testing/hydrotesting/raster/BJ.tif
inRiver=/home/ireese/testing/hydrotesting/shapes/clipped/rivers_BJ.shp
outDir=/home/ireese/testing/hydrotesting/raster/wshedClip
outFinal=/home/ireese/testing/hydrotesting/bj_test_GRASS/final

baseName=$(basename $inTiff | sed 's/\.tif//')

cutLine=/home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp

layerName=/home/ireese/testing/hydrotesting/bj_test_GRASS/TEMP/merged.shp
idList=$( ogrinfo -geom=NO -q -sql "SELECT id FROM merged" $layerName | grep 'id (Integer)' | sed s/'id (Integer) =//' )

for i in $idList
do
    echo $i
    fileNum=$(basename $i | sed 's/\.tif//')
    fileName=${baseName}${fileNum}

    #GDAL clip rivers by watershed
    echo "GDAL clip rivers by watershed"
    outRiverClipped=$outDir/${fileName}_id_${i}_clipRiver.shp
    ogr2ogr -clipsrc $cutLine -clipsrcsql "SELECT * FROM merged where id=${i}" $outRiverClipped $inRiver 

    #GDAL clip DEM by watershed
    echo "GDAL clip DEM by watershed"
    outTiffClipped=$outDir/${fileName}_id_${i}.tif
    gdalwarp -of GTiff -cutline $cutLine -csql "SELECT * FROM merged where id=${i}" -crop_to_cutline -tr 8.0 -8.0 $inTiff $outTiffClipped

    #import vector rivers
    echo "import vector rivers"
    #v.import [-flo] input=string [layer=string[,string,...]] [output=name] [extent=string] [encoding=string] [snap=float] [epsg=integer] [datum_trans=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui]
    outRiversVect=${fileName}_riverVect
    v.in.ogr input=$outRiverClipped output=$outRiversVect --overwrite

    #import raster watershed
    echo "import raster watershed"
    #r.in.gdal [-ojeflakcrp] input=name output=name [band=integer[,integer,...]] [memory=integer] [target=name] [title=phrase] [offset=integer] [num_digits=integer] [map_names_file=name] [location=name] [table=file] [gdal_config=string] [gdal_doo=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    outRiversRast=${fileName}_watershedRast
    r.in.gdal input=$outTiffClipped output=$outRiversRast --overwrite 

    #set region
    echo "set region"
    g.region rast=$outRiversRast -p

    #check info
    echo "check info"
    r.info map=$outRiversRast

    #check output
    echo "check output"
    outfile=${outFinal}/${fileName}_id_${i}_check.tif
    r.out.gdal input=$outRiversRast output=$outfile format=GTiff type=Float32 --overwrite

    
done

