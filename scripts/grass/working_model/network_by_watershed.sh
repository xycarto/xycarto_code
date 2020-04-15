#!/bin/bash

#network by watershed

inTiff=/home/ireese/testing/hydrotesting/raster/raster_processed_gdal/warpCut_original.tif
inRiver=/home/ireese/testing/hydrotesting/shapes/vector_raw/clip_rivers_test_ni.shp
outDir=/home/ireese/testing/hydrotesting/TEMPHOLD
outFinal=/home/ireese/testing/hydrotesting/shapes/vector_processed_grass

baseName=$(basename $inTiff | sed 's/\.tif//')

cutLine=/home/ireese/testing/hydrotesting/shapes/vector_watersheds/mergedWatershed_buff.shp

layerName=/home/ireese/testing/hydrotesting/shapes/vector_watersheds/mergedWatershed_buff.shp
idList=$( ogrinfo -geom=NO -q -sql "SELECT id FROM mergedWatershed_buff" $layerName | grep 'id (Integer)' | sed s/'id (Integer) =//' )

for i in $idList
do
    #TODO: fix
    echo $i
    fileNum=$(basename $i | sed 's/\.tif//')
    fileName=${baseName}${fileNum}

    #GDAL clip rivers by watershed
    echo "GDAL clip rivers by watershed"
    outRiverClipped=$outDir/${fileName}_id_${i}_clipRiver.shp
    ogr2ogr -clipsrc $cutLine -clipsrcsql "SELECT * FROM mergedWatershed_buff where id=${i}" $outRiverClipped $inRiver 

    #GDAL clip DEM by watershed
    echo "GDAL clip DEM by watershed"
    outTiffClipped=$outDir/${fileName}_id_${i}.tif
    gdalwarp -of GTiff -cutline $cutLine -csql "SELECT * FROM mergedWatershed_buff where id=${i}" -crop_to_cutline -tr 8.0 -8.0 $inTiff $outTiffClipped

    #import vector rivers
    echo "import vector rivers"
    #v.import [-flo] input=string [layer=string[,string,...]] [output=name] [extent=string] [encoding=string] [snap=float] [epsg=integer] [datum_trans=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui]
    outRiversVect=${fileName}_riverVect
    v.in.ogr input=$outRiverClipped output=$outRiversVect type=line --overwrite

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
    #outfile=${outFinal}/${fileName}_id_${i}_check.tif
    #r.out.gdal input=$outRiversRast output=$outfile format=GTiff type=Float32 --overwrite

    #fill DEM
    echo "fill dem"
    #r.fill.dir [-f] input=name output=name direction=name [areas=name] [format=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    #TODO: depression=depression map of real depressions
    #filldem=${fileName}_filldem
    #directionDEM=${fileName}_directiondem
    #r.fill.dir input=$outRiversRast output=$filldem direction=$directionDEM --overwrite

    #carve in rivers
    echo "LINZ rivers carve"
    #r.carve [-n] raster=name vector=name output=name [points=name] [width=float] [depth=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    carve=${fileName}_carve
    r.carve -n raster=$outRiversRast vector=$outRiversVect output=$carve depth=1 width=8 --overwrite

    #create hydro DEM
    echo "create hydro corrected dem"
    #r.hydrodem [-afc] input=name [depression=name] [memory=integer] output=name mod=integer size=integer [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    hydrodem=${fileName}_hydrodem
    r.hydrodem input=$carve memory=3000 output=$hydrodem mod=4 size=4 --overwrite

    #create watersheds
    #TODO: check input watershed threshold value
    echo "create watersheds"
    #r.watershed [-s4mab] elevation=name [depression=name] [flow=name] [disturbed_land=name] [blocking=name] [retention=name] [threshold=integer] [max_slope_length=float] [accumulation=name] [tci=name] [spi=name] [drainage=name] [basin=name] [stream=name] [half_basin=name] [length_slope=name] [slope_steepness=name] [convergence=integer] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    accumulation=${fileName}_accumulation
    drainage=${fileName}_drainage
    stream=${fileName}_stream
    r.watershed elevation=$hydrodem threshold=20 accumulation=$accumulation drainage=$drainage stream=$stream memory=3000 --overwrite

    #stream order
    echo "stream order"
    #r.stream.order [-zma] stream_rast=name direction=name [elevation=name] [accumulation=name] [stream_vect=name] [strahler=name] [horton=name] [shreve=name] [hack=name] [topo=name] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    searchTerm=stream_vect
    stream_vect=${fileName}_${searchTerm}
    strahler=${fileName}_strahler
    r.stream.order stream_rast=$stream direction=$drainage elevation=$hydrodem accumulation=$accumulation stream_vect=$stream_vect strahler=$strahler memory=3000 --overwrite

    #fix geometries
    #v.build [-e] map=name [error=name] option=string[,string,...] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    v.build -e map=$stream_vect

    #drop offending columns
    echo "drop offending columns"
    #v.db.dropcolumn map=name [layer=string] columns=name[,name,...] [--help] [--verbose] [--quiet] [--ui]
    v.db.dropcolumn map=$stream_vect columns=prev_str01,prev_str02,prev_str03,prev_str04,prev_str05

    #export stream vector
    echo "export stream order"
    streamOut=${outFinal}/${fileName}_stream_vector.gpkg
    v.out.ogr input=$stream_vect output=$streamOut type=line format=GPKG --overwrite

done

mergeList=$(g.list type=vector pattern=*_${searchTerm} separator=comma)

#inputList=$(echo $mergeList | sed "s/ /,/g")

#v.patch [-nzeab] input=name[,name,...] output=name [bbox=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
v.patch -e input=$mergeList output=merged_vector --overwrite

outRiversMerged=${outFinal}/merged_rivers.gpkg
v.out.ogr input=merged_vector output=$outRiversMerged type=line format=GPKG --overwrite

