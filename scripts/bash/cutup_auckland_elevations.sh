#!bin/bash

# The purpose of this script is to process the Auckland 1m DEM and DSM elevation
# data into more manageable pieces for easier viewing in QGIS  
# elevation tile downloads from LDS contain 6423 individual tiles. The
# downloaded elevation tiles are reworked into tiffs the same size as the NZ
# LINZ Topo50 Map Sheets 
#(https://data.linz.govt.nz/layer/50295-nz-linz-map-sheets-topo-150k/).  In
# this case, the original data contains an identifier, like 'AZ31', within 
# the tile name that associates it with Topo50 Map Sheets.  This script 
# extracts that identifier, makes a list of the files containing the identifier
# name, makes a vrt of the items in the list, creates hillshades from that vrt,
# then formats for quicker viewing in QGIS.

# All data is downloaded in EPSG:2193 and in GeoTiff format
# Auckland DEM here: https://data.linz.govt.nz/layer/53405-auckland-lidar-1m-dem-2013/
# Auckland DSM here: https://data.linz.govt.nz/layer/53406-auckland-lidar-1m-dsm-2013/

# Place ZIPPED files in directory of choice

# Set root directory for project. PLACE YOUR OWN DIRECTORY HERE.
BASEDIR=[PLACE/YOUR/OWN/BASE/DIRECTORY/FILEPATH/HERE]


# Create supporting variables
dSm_dir=$BASEDIR/dSm_elevation
dEm_dir=$BASEDIR/dEm_elevation
dSm_list_dir=$BASEDIR/lists/dSmlist
dEm_list_dir=$BASEDIR/lists/dEmlist


# Create file structure
mkdir $BASEDIR/lists
mkdir $dSm_dir
mkdir $dEm_dir
mkdir $dSm_list_dir
mkdir $dEm_list_dir

# Extract data
unzip $BASEDIR/lds-auckland-lidar-1m-dsm-2013-GTiff.zip -d $dSm_dir
unzip $BASEDIR/lds-auckland-lidar-1m-dem-2013-GTiff.zip -d $dEm_dir

# Delete zipped files
# rm -rf $BASEDIR/lds-auckland-lidar-1m-dsm-2013-GTiff.zip
# rm -rf $BASEDIR/lds-auckland-lidar-1m-dem-2013-GTiff.zip

# Loop to process both DEM and DSM data
demdsm="dEm dSm"
for opt in $demdsm
do
# Variables, dEm and dSm, are created for naming purposes and moving data to
# the correct directories 
tempvar=""$opt"_dir"
tempvar_list=""$opt"_list_dir"
capvar="${opt^^}_"

	# Identify associated Topo50 map sheet name.  Make it as a list held as a variable
	unique=$( find ${!tempvar} -name "*.tif" | sed "s#.*$capvar##" | sed 's#_.*##' | sort | uniq )

	# from the 'unique' variable, create a list of files with similar Topo50 idenifier
	for i in $unique
	do
		# List all available tiffs in directory 
		namelist=$( find ${!tempvar} -name "*.tif" -maxdepth 1 )
		# Compare unique name to identifier in available tiffs name.  If 
		# there is a match between the unique name and identifier in the 
		# tiff name, the name is recorded in a list.
		for j in $namelist
		do
			namecompare=$( echo $j  | sed "s#.*$capvar##" | sed 's#_.*##' )
			echo $namecompare
			if [ $i = $namecompare ]
			then
				echo $j	>> ${!tempvar_list}/$i.txt	
			fi
		done
	done

	# Create list of available .txt file 
	listsnames=$( find ${!tempvar_list} -name "*.txt" )

	for k in $listsnames
	do
		# list contents of .txt file into variable
		formerge=$( cat $k )
		# prepare file name to use as vrt name
		filename=$( basename $k | sed 's#.txt##' )
		#echo $filename
		#echo $formerge
		# Build VRT of elevation files in same size as Topo50 grid 
		gdalbuildvrt ${!tempvar}/$filename.vrt $formerge 
	done

	# Change directory to 'Merged DEMs'
	cd ${!tempvar}

	# Make directory to store hillshade files
	mkdir hs

	# Clean out overviews
	find -name "*.vrt" | xargs -P 4 -n4 -t -I % gdaladdo % -clean

	# Create hillshade from VRTs
	find -name "*.vrt"  | xargs -P 4 -n4 -t -I % gdaldem hillshade -multidirectional -compute_edges % hs/%.tif

	# Create external overviews of VRTs
	find -name "*.vrt" | xargs -P 4 -n4 -t -I % gdaladdo -ro % 2 4 8 16 32 64 128

	# Create vrt of elevation VRTs
	gdalbuildvrt $opt.vrt *.vrt

	# change directory to hillshade directory
	cd ${!tempvar}/hs

	rename s#.vrt## *.tif

	# Clean out old overviews
	find -name "*.tif" | xargs -P 4 -n4 -t -I % gdaladdo % -clean

	# Create external overviews of HS tiffs
	find -name "*.tif" | xargs -P 4 -n4 -t -I % gdaladdo -ro % 2 4 8 16 32 64 128

	# Create vrt of Hillshade tiffs
	gdalbuildvrt "$opt"_hs.vrt *.tif

done