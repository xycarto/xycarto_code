# GDAL Tools List for BASH

There are a number of geospatial operations used repeatably throughout projects for moving, translating, formatting, and reading metadata. It is helpful to have these base operations in one location for the duration of this project. The following is a list of basic GDAL commandline operations for use within BASH shell.

_Note: Evolving list_

## Raster Commands

### Read raster metadata

```gdalinfo input.tif```

### Read raster SRS information (better format in output)

```gdalsrsinfo -o proj4 input.tif```

or

```gdalsrsinfo -o epsg input.tif```

### Get raster bounding box
#### Basic method

```gdalinfo input.tif | grep -e 'Upper Left' -e 'Lower Left' -e 'Upper Right' -e 'Lower Right'```

#### Get Extent

See gdal_extent.sh

```
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
	echo export -n "$EXTENT"
}
```

run `source ./gdal_extent.sh input.tif`

### Reproject Raster

```gdalwarp -s_srs EPSG:#### -t_srs EPSG:#### input.tif output.tif```

### Change raster format

```gdal_translate -of "GTiff" input.grd output.tif```

-of: File type output like geoTIFF, ascii etc

-ot: Change band types to Byte, UInt16, Float32, etc.

### Create VRT (virtual mosaic)

```gdalbuildvrt output.vrt *.tif```

List of inputs can be substituted using:

```-input_file_list my_list.txt```

### Create full mosaic

```gdal_translate -of "GTiff" input.vrt output.tif```

or

```gdalwarp input.vrt output.tif```

* other methods available via gdalwarp

or

```gdal_merge.py -o out.tif in1.tif in2.tif```


### Mask (Clip) raster
#### by Bounding Box

```gdalwarp -te <x_min> <y_min> <x_max> <y_max> input.tif clipped_output.tif```

#### by Input Shapefile (raster resized to input shape size)

```gdalwarp -cutline cropper.shp -crop_to_cutline input.tif cropped_output.tif```

### Raster calc basic operation

* Uses numpy library for calcs

```gdal_calc.py -A input1.tif -B input2.tif --outfile=result.tif --calc="A+B"```

### Add/Remove overviews of raster (pyramids)
#### External overviews with automatic computation of over levels

```gdaladdo -ro -r bilinear input.tif```

#### External overviews with levels input

```gdaladdo -ro -r bilinear input.tif 2 4 8 16 32 64 128```

### Polygonize

```gdal_polygonize.py input.tif output.shp fieldName```

### Compare two raster of same size

```gdalcompare.py golden_file new_file```

### Get Individual Pixel Information

```gdallocationinfo input.tif x y```

### Build Tile Index

```gdaltindex output_index.shp ./*.tif```


## Vector Commands

### Read vector metadata
#### Basic info

```ogrinfo /store/nz_coast_outline/coastline_NZTM.shp```

#### All Data Including each Feature

```ogrinfo -al /store/nz_coast_outline/coastline_NZTM.shp```

#### Just Geometry Information

```ogrinfo -al -so /store/nz_coast_outline/coastline_NZTM.shp```

### Read vector SRS information (better format in output)

```gdalsrsinfo -o proj4 input.shp```

or

```gdalsrsinfo -o epsg input.shp```

### Using OGR with SQL queries

```ogrinfo -geom=NO -q -sql "SELECT id FROM input" ./input.shp```

### CSV Points (with Lat/Long) to Shape

```ogr2ogr -oo X_POSSIBLE_NAMES=$xname* -oo Y_POSSIBLE_NAMES=$yname*  -f "ESRI Shapefile" $output.shp input.csv```

### Reproject Vector

```ogr2ogr -s_srs EPSG:4326 -t_srs EPSG:2193 -f "ESRI Shapefile" output.shp input.shp```

### Change vector format

```ogr2ogr -f GPKG output.gpkg input.shp```

### Get vector bounding box
#### Get Basic Extent

```ogrinfo -al -so /store/nz_coast_outline/coastline_NZTM.shp | grep 'Extent:'```

#### Output Extent in Machine Readable Format

```
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
```

### Clip Vector
#### with Bounding Box

```ogr2ogr -clipsrc -13.931 34.886 46.23 74.12 -f "ESRI Shapefile" output.gpkg output.shp```

#### with Another Vector

```ogr2ogr -skipfailures -clipsrc inputClippingShape.shp output.shp inputShapeToBeClipped.shp```

### Upload/Download to PostGIS Database

_Will need to install these functions with PostGIS installation_

#### Upload Vector to Database

```shp2pgsql -s 2193 input.shp public.input | psql -h <yourHost> -d <yourDatabaseHere> -U <youUserNameHere>```

#### Extract Vector from Database

```pgsql2shp -f "./output" -h ost> -u <yourUserName>  databaseName "SELECT * FROM outputTable"```

### Rasterize

```gdal_rasterize -a attributeName -l input input.shp output.tif```


TODO:

## General
### Read from Internet Link
## Basic Examples



