#!/bin/bash

function gdal_extent() {
	if [ -z "$1" ]; then 
		echo "Missing arguments. Syntax:"
		echo "  gdal_extent <input_raster>"
    	return
	fi
	EXTENT=$(gdalinfo $1 |\
		grep "Upper Left\|Lower Right" |\
		sed "s/Upper Left  //g;s/Lower Right //g;s/).*//g" |\
		tr "\n" " " |\
		sed 's/ *$//g' |\
		tr -d "[(,]")
	echo -n "$EXTENT"
}

gdal_extent $1