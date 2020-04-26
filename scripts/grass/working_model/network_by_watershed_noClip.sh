#!/bin/bash

#network by watershed

inTiff=/home/ireese/testing/wellington_hydro/dem_orig_bigCatchment_5.tif
inCarve=/home/ireese/testing/wellington_hydro/vectorRaw/riverSegmentsBuff.shp
outDir=/home/ireese/testing/wellington_hydro/TEMP_forDelete
outFinal=/home/ireese/testing/wellington_hydro/vectorRivers

memory=9000

baseName=$(basename $inTiff | sed 's/\.tif//')

idList=${inTiff}

for i in $idList
do
    #TODO: fix
    echo $i
    fileNum=$(basename $i | sed 's/\.tif//')
    fileName=${baseName}${fileNum}

    #import vector rivers
    echo "import carve vector"
    #v.import [-flo] input=string [layer=string[,string,...]] [output=name] [extent=string] [encoding=string] [snap=float] [epsg=integer] [datum_trans=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui]
    outCarveVect=${fileName}_carveVect
    v.in.ogr input=$inCarve output=$outCarveVect type=line --overwrite

    #import raster watershed
    echo "import raster watershed"
    #r.in.gdal [-ojeflakcrp] input=name output=name [band=integer[,integer,...]] [memory=integer] [target=name] [title=phrase] [offset=integer] [num_digits=integer] [map_names_file=name] [location=name] [table=file] [gdal_config=string] [gdal_doo=string] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    outRiversRast=${fileName}_watershedRast
    #r.in.gdal input=$inTiff output=$outRiversRast --overwrite 

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
    fillDEM=${fileName}_filldem
    directionDEM=${fileName}_directiondem
    areasDEM=${fileName}_areasDEM
    #r.fill.dir input=$outRiversRast output=$fillDEM direction=$directionDEM areas=$areasDEM --overwrite

    #r.out.gdal [-lcmtf] input=name output=name format=string [type=string] [createopt=string[,string,...]] [metaopt=string[,string,...]] [nodata=float] [overviews=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui]
    areaOut=${outDir}/${fileName}.tif
    #r.out.gdal input=${areasDEM} output=${areaOut}

    #carve in rivers
    echo "LINZ rivers carve"
    #r.# [-n] raster=name vector=name output=name [points=name] [width=float] [depth=float] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    carve=${fileName}_carve
    r.carve -n raster=$fillDEM vector=$outCarveVect output=$carve depth=2 width=10 --overwrite

    #create hydro DEM
    echo "create hydro corrected dem"
    #r.hydrodem [-afc] input=name [depression=name] [memory=integer] output=name mod=integer size=integer [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    hydrodem=${fileName}_hydrodem
    #r.hydrodem input=$outCarveVect memory=$memory output=$hydrodem --overwrite

    #create watersheds
    #TODO: check input watershed threshold value
    echo "create watersheds"
    #r.watershed [-s4mab] elevation=name [depression=name] [flow=name] [disturbed_land=name] [blocking=name] [retention=name] [threshold=integer] [max_slope_length=float] [accumulation=name] [tci=name] [spi=name] [drainage=name] [basin=name] [stream=name] [half_basin=name] [length_slope=name] [slope_steepness=name] [convergence=integer] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    accumulation=${fileName}_accumulation
    drainage=${fileName}_drainage
    stream=${fileName}_stream
    r.watershed elevation=$carve threshold=500 accumulation=$accumulation drainage=$drainage stream=$stream memory=$memory --overwrite

    #stream order
    echo "stream order"
    #r.stream.order [-zma] stream_rast=name direction=name [elevation=name] [accumulation=name] [stream_vect=name] [strahler=name] [horton=name] [shreve=name] [hack=name] [topo=name] [memory=integer] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
    searchTerm=stream_vect
    stream_vect=${fileName}_${searchTerm}
    strahler=${fileName}_strahler
    r.stream.order stream_rast=$stream direction=$drainage elevation=$carve accumulation=$accumulation stream_vect=$stream_vect strahler=$strahler memory=$memory --overwrite

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

#mergeList=$(g.list type=vector pattern=*_${searchTerm} separator=comma)

#inputList=$(echo $mergeList | sed "s/ /,/g")

#v.patch [-nzeab] input=name[,name,...] output=name [bbox=name] [--overwrite] [--help] [--verbose] [--quiet] [--ui] 
#v.patch -e input=$mergeList output=merged_vector --overwrite

outRiversMerged=${outFinal}/merged_rivers.gpkg
#v.out.ogr input=merged_vector output=$outRiversMerged type=line format=GPKG --overwrite

