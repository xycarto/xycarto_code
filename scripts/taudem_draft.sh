#!bin/bash

#Rough sketch for building river centerlines. Rasters have been clipped prior

BASEPATH=/dir/path/to/base

raster_list=$( find $BASEPATH -name "*.tif" )

taudem_outputs=/dir/path/to/outputs

reso=resolution_number

for i in $raster_list
do

	INPUT_RASTER=$i

	file_name=$( basename $i )

	strip_input_extension=$( echo $file_name | sed 's/.tif//' )

	reso_name=$taudem_outputs/${strip_input_extension}_${reso}res

	gdal_translate -tr $reso $reso -of GTiff $i $reso_name.tif

	fel=${reso_name}_fel.tif
	p=${reso_name}_p.tif
	sd8=${reso_name}_sd8.tif
	ad8=${reso_name}_ad8.tif
	ang=${reso_name}_ang.tif
	slp=${reso_name}_slp.tif
	sca=${reso_name}_sca.tif
	sa=${reso_name}_sa.tif
	ssa=${reso_name}_ssa.tif
	src=${reso_name}_src.tif

	ord=${reso_name}_strahlerorder.tif 
	tree=${reso_name}_tree.dat
	coord=${reso_name}_coord.dat
	net=${reso_name}_network.shp
	w=${reso_name}_watershed.tif 

	processed_input_file=$reso_name.tif

	#TauDEM Commands
	mpiexec -n 8 pitremove -z $processed_input_file -fel $fel

	mpiexec -n 8 d8flowdir -fel $fel -p $p -sd8 $sd8 

	mpiexec -n 8 aread8 -p $p -ad8 $ad8 -nc

	mpiexec -n 8 dinfflowdir -fel $fel -ang $ang -slp $slp

	mpiexec -n 8 areadinf -ang $ang -sca $sca -nc

	mpiexec -n 8 slopearea -slp $slp -sca $sca -sa $sa

	mpiexec -n 8 d8flowpathextremeup -p $p -sa $sa -ssa $ssa -nc

	mpiexec -n 8 threshold -ssa $ssa -src $src

	mpiexec -n 8 streamnet -fel $fel -p $p -ad8 $ad8 -src $src -ord $ord -tree $tree -coord $coord -net $net -w $w

done
