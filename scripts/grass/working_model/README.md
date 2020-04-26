### create grass environment
grass -c epsg:2193 -e /home/ireese/testing/wellington_hydro/GRASS_ENV

### launch grass interactive environment (for testing)

grass /home/ireese/testing/wellington_hydro/GRASS_ENV/PERMANENT

### gather raster data
 
### gather rivers data

### clip raster data by coastline
### downsample raster for watershed creation

time bash -v /home/ireese/testing/hydrotesting/scripts/prep_raster.sh

### clip rivers by NI and SI

### create watershed from downsampled raster

time grass /home/ireese/testing/wellington_hydro/GRASS_ENV/PERMANENT --exec sh /home/ireese/testing/wellington_hydro/scripts/create_watershed_boundaries.sh /home/ireese/testing/wellington_hydro/dem_orig_25_clipped.tif

/home/ireese/testing/wellington_hydro/dem_orig_25_clipped.tif

	hydrodem
	eliminiate overlapping watersheds
	
### merge into one clean watershed
time grass /home/ireese/testing/hydrotesting/GRASS_ENV/PERMANENT --exec sh /home/ireese/testing/hydrotesting/scripts/develop_merged_watershed.sh /home/ireese/testing/hydrotesting/shapes/vector_watersheds/watershedList.txt

### clip original raster by watersheds
time grass /home/ireese/testing/hydrotesting/GRASS_ENV/PERMANENT --exec sh /home/ireese/testing/hydrotesting/scripts/network_by_watershed.sh

time grass /home/ireese/testing/wellington_hydro/GRASS_ENV/PERMANENT --exec sh /home/ireese/testing/wellington_hydro/scripts/network_by_watershed_noClip.sh

### Run river creation process
	do I need a fill?
	hydrodem good enough?
	carve in obsticles or rivers
	run river creation
	clean rivers to remove prev_str column
	merge all streams to master stream file

	select river.geom
from
(select st_subdivide(shape, 8) as geom from nztm.nz_river_name_lines__pilot_) as river,
(select shape as geom from nztm.nz_road_centrelines__topo__1_50k_) as road
where
st_intersects(river.geom, road.geom)


shp2pgsql -I -s 2193 /home/ireese/testing/wellington_hydro/vectorCatchments/wshed_test.shp nztm.wshed_test | psql -h localhost -d nz_data -U postgres

(select geom from nztm.wshed_test) as wshed

(select shape as geom from nztm.nz_road_centrelines__topo__1_50k_) as road

(select shape as geom from nztm.nz_river_name_lines__pilot_) as river

create table nztm.wshedRiver_intersection
as
(
select river.geom
from
(select geom from nztm.wshed_test) as wshed,
(select shape as geom from nztm.nz_river_name_lines__pilot_) as river
where st_intersects(wshed.geom, river.geom)
);

create table nztm.wshedRiverRoad_intersection
as
(
select river.geom
from
(select st_subdivide(geom, 8) as geom from nztm.wshedriver_intersection) as river,
(select geom geom from nztm.wshedroad_intersection) as road
where
st_intersects(river.geom, road.geom)
);

drop table nztm.wshed_riverSegs_roadInt;
create table nztm.wshed_riverSegs_roadInt
as
(
select st_intersection(river.geom, roadbuff.geom) as geom
from
(select geom from nztm.wshedriverroad_intersection) as river,
(select st_buffer(geom,20) as geom from nztm.wshedroad_intersection) as roadbuff
where
st_intersects(river.geom, roadbuff.geom)
);
