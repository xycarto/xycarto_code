#!/bin/bash

#extracting and formatting input geotiffs bounding box coordinate information
#for use in gdal_translate -a_ullr function

FILE_IN=$1

file_name=$( basename $FILE_IN | sed 's/.tif//' )

function gdal_extent_gdalwarp_te() {
    EXTENT=$(gdalinfo "$1" |\
        grep "Lower Left\|Upper Right" |\
        sed "s/Lower Left  //g;s/Upper Right //g;s/).*//g" |\
        #tr "\n" " " |\
        sed 's/ *$/ /g' |\
        tr -d "\n[(]'"|\
        sed 's/,/ /g')
    echo -n "$EXTENT"
}

#echo $FILE_IN

ExtractedExtent=$(gdal_extent_gdalwarp_te "${FILE_IN}")
#echo $ExtractedExtent

set -- $ExtractedExtent
#echo "flip extent (ulx uly lrx lry) = "$1 $4 $3 $2

ulx=$1
uly=$4
lrx=$3
lry=$2

echo "$ulx"
echo "$uly"
echo "$lrx"
echo "$lry"
