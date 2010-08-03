########################################################
# routines to set up, transform and manage weather tiles
# Thorsten Renk, July 2010
########################################################

# function			purpose
#
# tile_management_loop		to decide if a tile is created, removed or considered current
# generate_tile			to decide on orientation and type and set up all information for tile creation
# remove_tile			to delete a tile by index
# change_active_tile		to change the tile the aircraft is currently in and to generate neighbour info
# copy_entry			to copy tile information from one node to another
# create_neighbour		to set up information for a new neighbouring tile
# create_neighbours		to initialize the 8 neighbours of the initial tile
# calc_geo			to get local Cartesian geometry for latitude conversion
# get_lat			to get latitude from Cartesian coordinates
# get_lon			to get longitude from Cartesian coordinates


###################################
# tile management loop
###################################

var tile_management_loop = func {

var tNode = props.globals.getNode(lw~"tiles", 1).getChildren("tile");
var viewpos = geo.aircraft_position(); # using viewpos here triggers massive tile ops for tower view...
var code = getprop(lw~"tiles/tile[4]/code");
var i = 0;
var d_min = 100000.0;
var i_min = 0;
var distance_to_load = getprop(lw~"config/distance-to-load-tile-m");
var distance_to_remove = getprop(lw~"config/distance-to-remove-tile-m");
var current_heading = getprop("orientation/heading-deg");
var loading_flag = getprop(lw~"tmp/asymmetric-tile-loading-flag");
var this_frame_generated_flag = 0; # use this flag to avoid overlapping tile generation calls

foreach (var t; tNode) {

	var tpos = geo.Coord.new();
	tpos.set_latlon(t.getNode("latitude-deg").getValue(),t.getNode("longitude-deg").getValue(),0.0);
	var d = viewpos.distance_to(tpos);
	if (d < d_min) {d_min = d; i_min = i;}
	var flag = t.getNode("generated-flag").getValue();
	
	var dir = viewpos.course_to(tpos);
	var d_load = distance_to_load;
	var d_remove = distance_to_remove;
	if (loading_flag == 1)
		{
		if ((abs(dir-current_heading) > 135.0) and (abs(dir-current_heading) < 225.0))
			{		
			d_load = 0.7 * d_load;
			d_remove = 0.7 * d_remove;
			} 
		}

	# the tile needs to be generated, unless it already has been
	# and if no other tile has been generated in this loop cycle
	# and the thread and convective system are idle
	# (we want to avoid overlapping tile generation)
	if ((d < distance_to_load) and (flag==0) and (this_frame_generated_flag == 0) and (getprop(lw~"tmp/thread-status") == "idle") and (getprop(lw~"tmp/convective-status") == "idle")) 
		{
		setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);
		print("Building tile unique index ",getprop(lw~"tiles/tile-counter"), " in direction ",i);
		generate_tile(code, tpos.lat(), tpos.lon(),i);

		if (getprop(lw~"config/dynamics-flag") == 1)
			{
			var quadtree = [];
			weather_dynamics.generate_quadtree_structure(0, quadtree);
			append(weather_dynamics.cloudQuadtrees,quadtree);
			}

		t.getNode("generated-flag").setValue(1);
		t.getNode("timestamp-sec").setValue(weather_dynamics.time_lw);
		t.getNode("tile-index",1).setValue(getprop(lw~"tiles/tile-counter"));
		
		this_frame_generated_flag = 1;
		} 

	if ((d > distance_to_remove) and (flag==1)) # the tile needs to be deleted if it exists
		{
		print("Removing tile, unique index ", t.getNode("tile-index").getValue());
		remove_tile(t.getNode("tile-index").getValue());
		t.getNode("generated-flag").setValue(0);
		}
	i = i + 1;
	} # end foreach

	#print("Minimum distance to: ",i_min);

	if (i_min != 4) # we've entered a different tile
		{
		print("Changing active tile to direction ", i_min);
		change_active_tile(i_min);
		}    

	

if (getprop(lw~"tile-loop-flag") ==1) {settimer(tile_management_loop, 5.0);}

}


###################################
# tile generation call
###################################

var generate_tile = func (code, lat, lon, dir_index) {

# make sure the last tile call has finished, otherwise put on hold

#if ((getprop(lw~"tmp/thread-status") != "idle") or (getprop(lw~"tmp/convective-status") != "idle"))
#	{
#	print("Tile generation overlap, delaying...");
#	settimer( func {generate_tile(code, lat, lon, dir_index);}, 1);
#	}

setprop(lw~"tiles/tmp/latitude-deg", lat);
setprop(lw~"tiles/tmp/longitude-deg",lon);
setprop(lw~"tiles/tmp/code",code);


# do windspeed and orientation before presampling check, but test not to do it again

if (((getprop(lw~"tmp/presampling-flag") == 1) and (getprop(lw~"tmp/presampling-status") == "idle")) or (getprop(lw~"tmp/presampling-flag") == 0))
	{

	var alpha = getprop(lw~"tmp/tile-orientation-deg");

	if ((local_weather.wind_model_flag == 2) or (local_weather.wind_model_flag ==4))
		{
		alpha = alpha + 2.0 * (rand()-0.5) * 10.0;

		# account for the systematic spin of weather systems around a low pressure 
		# core dependent on hemisphere
		if (lat >0.0) {alpha = alpha -3.0;}
		else {alpha = alpha +3.0;} 

		setprop(lw~"tmp/tile-orientation-deg",alpha);
	
		# compute the new windspeed

		var windspeed = getprop(lw~"tmp/windspeed-kt");
		windspeed = windspeed + 2.0 * (rand()-0.5) * 2.0;
		if (windspeed < 0) {windspeed = rand();}
		setprop(lw~"tmp/windspeed-kt");

		# store the tile orientation and wind strength in an array for fast processing

		append(weather_dynamics.tile_wind_direction, alpha);
		append(weather_dynamics.tile_wind_speed, windspeed);

		}
	else if (local_weather.wind_model_flag ==5) # alpha and windspeed are calculated
		{
		var res = local_weather.wind_interpolation(lat,lon,0.0);
		
		alpha = res[0];
		setprop(lw~"tmp/tile-orientation-deg",alpha);				

		var windspeed = res[1];
		setprop(lw~"tmp/windspeed-kt",windspeed);

		append(weather_dynamics.tile_wind_direction,res[0]);
		append(weather_dynamics.tile_wind_speed,res[1]);

		}


	props.globals.getNode(lw~"tiles").getChild("tile",dir_index).getNode("orientation-deg").setValue(alpha);
	}




# now see if we need to presample the terrain

if ((getprop(lw~"tmp/presampling-flag") == 1) and (getprop(lw~"tmp/presampling-status") == "idle")) 
	{
	local_weather.terrain_presampling_start(lat, lon, 1000, 40000, getprop(lw~"tmp/tile-orientation-deg")); 
	setprop(lw~"tiles/tmp/dir-index",dir_index);
	return;
	}

print("Current tile type: ", code);

if (getprop(lw~"tmp/tile-management") == "repeat tile")
	{
	if (code == "altocumulus_sky"){weather_tiles.set_altocumulus_tile();}
	else if (code == "broken_layers") {weather_tiles.set_broken_layers_tile();}
	else if (code == "stratus") {weather_tiles.set_overcast_stratus_tile();}
	else if (code == "cumulus_sky") {weather_tiles.set_fair_weather_tile();}
	else if (code == "gliders_sky") {weather_tiles.set_gliders_sky_tile();}
	else if (code == "blue_thermals") {weather_tiles.set_blue_thermals_tile();}
	else if (code == "summer_rain") {weather_tiles.set_summer_rain_tile();}
	else if (code == "high_pressure_core") {weather_tiles.set_high_pressure_core_tile();}
	else if (code == "high_pressure") {weather_tiles.set_high_pressure_tile();}
	else if (code == "high_pressure_border") {weather_tiles.set_high_pressure_border_tile();}
	else if (code == "low_pressure_border") {weather_tiles.set_low_pressure_border_tile();}
	else if (code == "low_pressure") {weather_tiles.set_low_pressure_tile();}
	else if (code == "low_pressure_core") {weather_tiles.set_low_pressure_core_tile();}
	else if (code == "cold_sector") {weather_tiles.set_cold_sector_tile();}
	else if (code == "warm_sector") {weather_tiles.set_warm_sector_tile();}
	else if (code == "tropical_weather") {weather_tiles.set_tropical_weather_tile();}
	else {print("Repeat tile not implemented with this tile type!");}
	}
else if (getprop(lw~"tmp/tile-management") == "realistic weather")
	{
	var rn = rand();
	
	if (code == "low_pressure_core") 
		{
		if (rn > 0.2) {weather_tiles.set_low_pressure_core_tile();}
		else {weather_tiles.set_low_pressure_tile();}
		}
	else if (code == "low_pressure") 
		{
		if (rn > 0.2) {weather_tiles.set_low_pressure_tile();}
		else if (rn > 0.1) {weather_tiles.set_low_pressure_core_tile();}
		else {weather_tiles.set_low_pressure_border_tile();}
		}
	else if (code == "low_pressure_border") 
		{
		if (rn > 0.4) {weather_tiles.set_low_pressure_border_tile();}
		else if (rn > 0.3) {weather_tiles.set_cold_sector_tile();}
		else if (rn > 0.2) {weather_tiles.set_warm_sector_tile();}
		else if (rn > 0.1) {weather_tiles.set_low_pressure_tile();}
		else {weather_tiles.set_high_pressure_border_tile();}
		}
	else if (code == "high_pressure_border") 
		{
		if (rn > 0.4) {weather_tiles.set_high_pressure_border_tile();}
		else if (rn > 0.3) {weather_tiles.set_cold_sector_tile();}
		else if (rn > 0.2) {weather_tiles.set_warm_sector_tile();}
		else if (rn > 0.1) {weather_tiles.set_high_pressure_tile();}
		else {weather_tiles.set_low_pressure_border_tile();}
		}
	else if (code == "high_pressure") 
		{
		if (rn > 0.2) {weather_tiles.set_high_pressure_tile();}
		else if (rn > 0.1) {weather_tiles.set_high_pressure_border_tile();}
		else {weather_tiles.set_high_pressure_core_tile();}
		}
	else if (code == "high_pressure_core") 
		{
		if (rn > 0.2) {weather_tiles.set_high_pressure_core_tile();}
		else {weather_tiles.set_high_pressure_tile();}
		}
	else if (code == "cold_sector") 
		{
		if (rn > 0.3) {weather_tiles.set_cold_sector_tile();}
		else if (rn > 0.2) 
			{
			if ((dir_index ==0) or (dir_index ==1) or (dir_index==2))
				{weather_tiles.set_warmfront1_tile();}
			else if ((dir_index ==3) or (dir_index ==5))
				{weather_tiles.set_cold_sector_tile();}
			else if ((dir_index ==6) or (dir_index ==7) or (dir_index==8))
				{weather_tiles.set_coldfront_tile();}
			}
		else if (rn > 0.1) {weather_tiles.set_low_pressure_border_tile();}
		else {weather_tiles.set_high_pressure_border_tile();}
		}
	else if (code == "warm_sector") 
		{
		if (rn > 0.3) {weather_tiles.set_warm_sector_tile();}
		else if (rn > 0.2) 
			{
			if ((dir_index ==0) or (dir_index ==1) or (dir_index==2))
				{weather_tiles.set_coldfront_tile();}
			else if ((dir_index ==3) or (dir_index ==5))
				{weather_tiles.set_warm_sector_tile();}
			else if ((dir_index ==6) or (dir_index ==7) or (dir_index==8))
				{weather_tiles.set_warmfront4_tile();}
			}
		else if (rn > 0.1) {weather_tiles.set_low_pressure_border_tile();}
		else {weather_tiles.set_high_pressure_border_tile();}
		}
	else if (code == "warmfront1")
		{
		if ((dir_index ==0) or (dir_index ==1) or (dir_index==2))
			{weather_tiles.set_warmfront2_tile();}
		else if ((dir_index ==3) or (dir_index ==5))
			{weather_tiles.set_warmfront1_tile();}
		else if ((dir_index ==6) or (dir_index ==7) or (dir_index==8))
			{weather_tiles.set_cold_sector_tile();}
		}
	else if (code == "warmfront2")
		{
		if ((dir_index ==0) or (dir_index ==1) or (dir_index==2))
			{weather_tiles.set_warmfront3_tile();}
		if ((dir_index ==3) or (dir_index ==5))
			{weather_tiles.set_warmfront2_tile();}
		if ((dir_index ==6) or (dir_index ==7) or (dir_index==8))
			{weather_tiles.set_warmfront1_tile();}
		}
	else if (code == "warmfront3")
		{
		if ((dir_index ==0) or (dir_index ==1) or (dir_index==2))
			{weather_tiles.set_warmfront4_tile();}
		if ((dir_index ==3) or (dir_index ==5))
			{weather_tiles.set_warmfront3_tile();}
		if ((dir_index ==6) or (dir_index ==7) or (dir_index==8))
			{weather_tiles.set_warmfront2_tile();}
		}
	else if (code == "warmfront4")
		{
		if ((dir_index ==0) or (dir_index ==1) or (dir_index==2))
			{weather_tiles.set_warm_sector_tile();}
		if ((dir_index ==3) or (dir_index ==5))
			{weather_tiles.set_warmfront4_tile();}
		if ((dir_index ==6) or (dir_index ==7) or (dir_index==8))
			{weather_tiles.set_warmfront3_tile();}
		}
	else if (code == "coldfront")
		{
		if ((dir_index ==0) or (dir_index ==1) or (dir_index==2))
			{weather_tiles.set_cold_sector_tile();}
		else if ((dir_index ==3) or (dir_index ==5))
			{weather_tiles.set_coldfront_tile();}
		else if ((dir_index ==6) or (dir_index ==7) or (dir_index==8))
			{weather_tiles.set_warm_sector_tile();}
		}
	else
		{
		print("Realistic weather not implemented with this tile type!");
		}

	} # end if mode == realistic weather
}
	

###################################
# tile removal call
###################################

var remove_tile = func (index) {

compat_layer.remove_clouds(index);

var effectNode = props.globals.getNode("local-weather/effect-volumes").getChildren("effect-volume");

var ecount = 0;

foreach (var e; effectNode)
	{
	if (e.getNode("tile-index").getValue() == index) 
		{
		e.remove();
		ecount = ecount + 1;
		}
	}

setprop(lw~"effect-volumes/number",getprop(lw~"effect-volumes/number")- ecount);

# set placement indices to zero to reinitiate search for free positions

setprop(lw~"clouds/placement-index",0);
setprop(lw~"clouds/model-placement-index",0);
setprop(lw~"effect-volumes/effect-placement-index",0);

# remove quadtree structures 

if (getprop(lw~"config/dynamics-flag") ==1)
	{
	setsize(weather_dynamics.cloudQuadtrees[index-1],0);
	}

# rebuild effect volume vector

local_weather.assemble_effect_array(); 

}



###################################
# active tile change and neighbour 
# recomputation
###################################

var change_active_tile = func (index) {

var t = props.globals.getNode(lw~"tiles").getChild("tile",index,0);

var lat = t.getNode("latitude-deg").getValue();
var lon = t.getNode("longitude-deg").getValue();
var alpha = getprop(lw~"tmp/tile-orientation-deg");


if (index == 0)
	{
	copy_entry(4,8);
	copy_entry(3,7);
	copy_entry(1,5);
	copy_entry(0,4);
	create_neighbour(lat,lon,0,alpha);
	create_neighbour(lat,lon,1,alpha);
	create_neighbour(lat,lon,2,alpha);
	create_neighbour(lat,lon,3,alpha);
	create_neighbour(lat,lon,6,alpha);
	}
else if (index == 1)
	{
	copy_entry(3,6);
	copy_entry(4,7);
	copy_entry(5,8);
	copy_entry(0,3);
	copy_entry(1,4); 
	copy_entry(2,5);
	create_neighbour(lat,lon,0,alpha);
	create_neighbour(lat,lon,1,alpha);
	create_neighbour(lat,lon,2,alpha);
	}
else if (index == 2)
	{
	copy_entry(4,6);
	copy_entry(1,3);
	copy_entry(2,4);
	copy_entry(5,7);
	create_neighbour(lat,lon,0,alpha);
	create_neighbour(lat,lon,1,alpha);
	create_neighbour(lat,lon,2,alpha);
	create_neighbour(lat,lon,5,alpha);
	create_neighbour(lat,lon,8,alpha);
	}
else if (index == 3)
	{
	copy_entry(1,2);
	copy_entry(4,5);
	copy_entry(7,8);
	copy_entry(0,1);
	copy_entry(3,4); 
	copy_entry(6,7);
	create_neighbour(lat,lon,0,alpha);
	create_neighbour(lat,lon,3,alpha);
	create_neighbour(lat,lon,6,alpha);
	}
else if (index == 5)
	{
	copy_entry(1,0);
	copy_entry(4,3);
	copy_entry(7,6);
	copy_entry(2,1);
	copy_entry(5,4); 
	copy_entry(8,7);
	create_neighbour(lat,lon,2,alpha);
	create_neighbour(lat,lon,5,alpha);
	create_neighbour(lat,lon,8,alpha);
	}
else if (index == 6)
	{
	copy_entry(4,2);
	copy_entry(3,1);
	copy_entry(6,4);
	copy_entry(7,5);
	create_neighbour(lat,lon,0,alpha);
	create_neighbour(lat,lon,3,alpha);
	create_neighbour(lat,lon,6,alpha);
	create_neighbour(lat,lon,7,alpha);
	create_neighbour(lat,lon,8,alpha);
	}
else if (index == 7)
	{
	copy_entry(3,0);
	copy_entry(4,1);
	copy_entry(5,2);
	copy_entry(6,3);
	copy_entry(7,4); 
	copy_entry(8,5);
	create_neighbour(lat,lon,6,alpha);
	create_neighbour(lat,lon,7,alpha);
	create_neighbour(lat,lon,8,alpha);
	}
else if (index == 8)
	{
	copy_entry(4,0);
	copy_entry(7,3);
	copy_entry(8,4);
	copy_entry(5,1);
	create_neighbour(lat,lon,2,alpha);
	create_neighbour(lat,lon,5,alpha);
	create_neighbour(lat,lon,6,alpha);
	create_neighbour(lat,lon,7,alpha);
	create_neighbour(lat,lon,8,alpha);
	}


}

#####################################
# copy tile info in neighbour matrix
#####################################

var copy_entry = func (from_index, to_index) {

var tNode = props.globals.getNode(lw~"tiles");

var f = tNode.getChild("tile",from_index,0);
var t = tNode.getChild("tile",to_index,0);

t.getNode("latitude-deg").setValue(f.getNode("latitude-deg").getValue());
t.getNode("longitude-deg").setValue(f.getNode("longitude-deg").getValue());
t.getNode("generated-flag").setValue(f.getNode("generated-flag").getValue());
t.getNode("tile-index").setValue(f.getNode("tile-index").getValue());
t.getNode("code").setValue(f.getNode("code").getValue());
t.getNode("timestamp-sec").setValue(f.getNode("timestamp-sec").getValue());
t.getNode("orientation-deg").setValue(f.getNode("orientation-deg").getValue());
}

#####################################
# create adjacent tile coordinates
#####################################

var create_neighbour = func (blat, blon, index, alpha) {

var x = 0.0;
var y = 0.0;
var phi = alpha * math.pi/180.0;

calc_geo(blat);

if ((index == 0) or (index == 3) or (index == 6)) {x =-40000.0;}
if ((index == 2) or (index == 5) or (index == 8)) {x = 40000.0;}

if ((index == 0) or (index == 1) or (index == 2)) {y = 40000.0;}
if ((index == 6) or (index == 7) or (index == 8)) {y = -40000.0;}

var t = props.globals.getNode(lw~"tiles").getChild("tile",index,0);

t.getNode("latitude-deg",1).setValue(blat + get_lat(x,y,phi));
t.getNode("longitude-deg",1).setValue(blon + get_lon(x,y,phi));
t.getNode("generated-flag",1).setValue(0);
t.getNode("tile-index",1).setValue(-1);
t.getNode("code",1).setValue("");
t.getNode("timestamp-sec",1).setValue(weather_dynamics.time_lw);
t.getNode("orientation-deg",1).setValue(0.0);
}

#####################################
# find the 8 adjacent tile coordinates
# after the initial setup call
#####################################

var create_neighbours = func (blat, blon, alpha)	{

var x = 0.0;
var y = 0.0;
var phi = alpha * math.pi/180.0;

calc_geo(blat);

x = -40000.0; y = 40000.0; 
setprop(lw~"tiles/tile[0]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[0]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[0]/generated-flag",0);
setprop(lw~"tiles/tile[0]/tile-index",-1);
setprop(lw~"tiles/tile[0]/code","");
setprop(lw~"tiles/tile[0]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[0]/orientation-deg",0.0);

x = 0.0; y = 40000.0; 
setprop(lw~"tiles/tile[1]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[1]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[1]/generated-flag",0);
setprop(lw~"tiles/tile[1]/tile-index",-1);
setprop(lw~"tiles/tile[1]/code","");
setprop(lw~"tiles/tile[1]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[1]/orientation-deg",0.0);

x = 40000.0; y = 40000.0; 
setprop(lw~"tiles/tile[2]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[2]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[2]/generated-flag",0);
setprop(lw~"tiles/tile[2]/tile-index",-1);
setprop(lw~"tiles/tile[2]/code","");
setprop(lw~"tiles/tile[2]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[2]/orientation-deg",0.0);

x = -40000.0; y = 0.0; 
setprop(lw~"tiles/tile[3]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[3]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[3]/generated-flag",0);
setprop(lw~"tiles/tile[3]/tile-index",-1);
setprop(lw~"tiles/tile[3]/code","");
setprop(lw~"tiles/tile[3]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[3]/orientation-deg",0.0);

# this is the current tile
x = 0.0; y = 0.0; 
setprop(lw~"tiles/tile[4]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[4]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[4]/generated-flag",1);
setprop(lw~"tiles/tile[4]/tile-index",1);
setprop(lw~"tiles/tile[4]/code","");
setprop(lw~"tiles/tile[4]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[4]/orientation-deg",getprop(lw~"tmp/tile-orientation-deg"));


x = 40000.0; y = 0.0; 
setprop(lw~"tiles/tile[5]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[5]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[5]/generated-flag",0);
setprop(lw~"tiles/tile[5]/tile-index",-1);
setprop(lw~"tiles/tile[5]/code","");
setprop(lw~"tiles/tile[5]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[5]/orientation-deg",0.0);

x = -40000.0; y = -40000.0; 
setprop(lw~"tiles/tile[6]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[6]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[6]/generated-flag",0);
setprop(lw~"tiles/tile[6]/tile-index",-1);
setprop(lw~"tiles/tile[6]/code","");
setprop(lw~"tiles/tile[6]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[6]/orientation-deg",0.0);

x = 0.0; y = -40000.0; 
setprop(lw~"tiles/tile[7]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[7]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[7]/generated-flag",0);
setprop(lw~"tiles/tile[7]/tile-index",-1);
setprop(lw~"tiles/tile[7]/code","");
setprop(lw~"tiles/tile[7]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[7]/orientation-deg",0.0);

x = 40000.0; y = -40000.0; 
setprop(lw~"tiles/tile[8]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[8]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[8]/generated-flag",0);
setprop(lw~"tiles/tile[8]/tile-index",-1);
setprop(lw~"tiles/tile[8]/code","");
setprop(lw~"tiles/tile[8]/timestamp-sec",weather_dynamics.time_lw);
setprop(lw~"tiles/tile[8]/orientation-deg",0.0);
}

###################
# global variables
###################

# these already exist in different namespace, but for ease of typing we define them here as well

var lat_to_m = 110952.0; # latitude degrees to meters
var m_to_lat = 9.01290648208234e-06; # meters to latitude degrees
var ft_to_m = 0.30480;
var m_to_ft = 1.0/ft_to_m;
var inhg_to_hp = 33.76389;
var hp_to_inhg = 1.0/inhg_to_hp;
var lon_to_m = 0.0; #local_weather.lon_to_m;
var m_to_lon = 0.0; # local_weather.m_to_lon;
var lw = "/local-weather/";



var modelArrays = [];

###################
# helper functions
###################

var calc_geo = func(clat) {

lon_to_m  = math.cos(clat*math.pi/180.0) * lat_to_m;
m_to_lon = 1.0/lon_to_m;
}

var get_lat = func (x,y,phi) {

return (y * math.cos(phi) - x * math.sin(phi)) * m_to_lat;
}

var get_lon = func (x,y,phi) {

return (x * math.cos(phi) + y * math.sin(phi)) * m_to_lon;
}
