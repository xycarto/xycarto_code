#!/bin/bash

function ogr_extent() {
	if [ -z "$1" ]; then 
		echo "Missing arguments. Syntax:"
		echo "  ogr_extent <input_vector>"
    	return
	fi
	EXTENT=$(ogrinfo -al -so $1 |\
		grep Extent |\
		sed 's/Extent: //g' |\
		sed 's/(//g' |\
		sed 's/)//g' |\
		sed 's/ - /, /g')
	EXTENT=`echo $EXTENT | awk -F ',' '{print $1 " " $4 " " $3 " " $2}'`
	echo -n "$EXTENT"
}

ogr_extent