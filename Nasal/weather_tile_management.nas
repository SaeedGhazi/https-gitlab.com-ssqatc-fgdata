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
# buffer_loop			to manage the buffering of faraway clouds in an array
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
var current_visibility = getprop(lw~"interpolation/visibility-m");
var current_heading = getprop("orientation/heading-deg");
var loading_flag = getprop(lw~"tmp/asymmetric-tile-loading-flag");
var this_frame_action_flag = 0; # use this flag to avoid overlapping tile operations

setsize(active_tile_list,0);

if (distance_to_load > 3.0 * current_visibility)
	{distance_to_load = 3.0 * current_visibility;}
if (distance_to_load < 25000.0)
	{distance_to_load = 25000.0;}

foreach (var t; tNode) {

	var tpos = geo.Coord.new();
	tpos.set_latlon(t.getNode("latitude-deg").getValue(),t.getNode("longitude-deg").getValue(),0.0);
	var d = viewpos.distance_to(tpos);
	if (d < d_min) {d_min = d; i_min = i;}
	var flag = t.getNode("generated-flag").getValue();
	
	if ((flag ==2) or (flag ==1)) {append(active_tile_list,t.getNode("tile-index").getValue());}

	var dir = viewpos.course_to(tpos);
	var d_load = distance_to_load;
	var d_remove = distance_to_remove;
	if (loading_flag == 1)
		{
		var angle = abs(dir-current_heading);
		#if (i==7) {print(angle);}
		if ((angle > 135.0) and (angle < 225.0))
			{		
			d_load = 0.7 * d_load;
			d_remove = 0.7 * d_remove;
			} 
		}

	# the tile needs to be generated, unless it already has been
	# and if no other tile has been generated in this loop cycle
	# and the thread and convective system are idle
	# (we want to avoid overlapping tile generation)

	if ((d < d_load) and (flag==0) and (this_frame_action_flag == 0) and (getprop(lw~"tmp/thread-status") == "idle") and (getprop(lw~"tmp/convective-status") == "idle") and (getprop(lw~"tmp/presampling-status") == "idle")) 
		{
		this_frame_action_flag = 1;
		setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);
		print("Building tile unique index ",getprop(lw~"tiles/tile-counter"), " in direction ",i);
		append(active_tile_list,getprop(lw~"tiles/tile-counter"));

		if (getprop(lw~"config/dynamics-flag") == 1) 
			{
			var quadtree = [];
			weather_dynamics.generate_quadtree_structure(0, quadtree);
			append(weather_dynamics.cloudQuadtrees,quadtree);
			}

		t.getNode("generated-flag").setValue(1);
		t.getNode("timestamp-sec").setValue(weather_dynamics.time_lw);
		t.getNode("tile-index",1).setValue(getprop(lw~"tiles/tile-counter"));
		
		generate_tile(code, tpos.lat(), tpos.lon(),i);

		} 

	if ((d > d_remove) and (flag == 2) and (this_frame_action_flag == 0)) # the tile needs to be deleted if it exists
		{
		print("Removing tile, unique index ", t.getNode("tile-index").getValue()," direction ",i);
		remove_tile(t.getNode("tile-index").getValue());
		t.getNode("generated-flag").setValue(0);
		this_frame_action_flag = 1;
		}
	i = i + 1;
	} # end foreach

	#print("Minimum distance to: ",i_min);

	var presampling_status = getprop(lw~"tmp/presampling-status");
	var convective_status = getprop(lw~"tmp/convective-status");
	var thread_status = getprop(lw~"tmp/thread-status");

	if ((presampling_status == "idle") and (convective_status == "idle") and (thread_status == "idle"))
		{
		var system_status = "idle";
		} 	
	else
		{system_status = "computing";}
	
	#  and (this_frame_action_flag == 0) and (presampling_status == "idle") and (convective_status=="idle")) 

	# check if we've entered a different tile and if no operation is in progress

	# var gen_flag = tNode[i_min].getNode("generated-flag").getValue();
	if ((i_min != 4) and (system_status == "idle"))
		{

		var gen_flag = tNode[i_min].getNode("generated-flag").getValue();
		if (gen_flag != 2){	
			print("Tile direction ",i_min, " not generated!");
			print("Flag: ",gen_flag);
			}

		print("Changing active tile to direction ", i_min);
		change_active_tile(i_min);
			
		}    

	

if (getprop(lw~"tile-loop-flag") ==1) {settimer(tile_management_loop, 5.0);}

}


###################################
# tile generation call
###################################

var generate_tile = func (code, lat, lon, dir_index) {


# the code should never be NIL, but this appears to happen under certain conditions
# so just to be on the safe side make sure it is set to current tile code if
# it actually is NIL

if (code == "")
	{ 
	print("No tile code - falling back on default!");
	code = getprop(lw~"tiles/code");
	}

setprop(lw~"tiles/tmp/latitude-deg", lat);
setprop(lw~"tiles/tmp/longitude-deg",lon);
setprop(lw~"tiles/tmp/code",code);
setprop(lw~"tiles/tmp/dir-index",dir_index);


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
		setprop(lw~"tmp/windspeed-kt", windspeed);

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

# remove tile from active list

var s = size(active_tile_list);

for (var j = 0; j < s; j=j+1)
	{
	if (index == active_tile_list[j])
		{	
		active_tile_list = delete_from_vector(active_tile_list,j);
		break;
		}
	}

settimer( func { props.globals.getNode("local-weather/clouds", 1).removeChild("tile",index) },100);

#compat_layer.remove_clouds(index);

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
	settimer( func {setsize(weather_dynamics.cloudQuadtrees[index-1],0);},1.0);
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
t.getNode("timestamp-sec").setValue(f.getNode("timestamp-sec").getValue());
t.getNode("orientation-deg").setValue(f.getNode("orientation-deg").getValue());
t.getNode("code").setValue(f.getNode("code").getValue());

#if (f.getNode("code").getValue() == "")
#	{print("Empty tile code copying from ", from_index," to ", to_index, "!");}

#if (f.getNode("code").getValue() != "") # we don't copy an empty code, that can trigger errors
#	{t.getNode("code").setValue(f.getNode("code").getValue());}

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

# use the last built tile code as default, in case a tile isn't formed when reached,
# the code is not empty but has a plausible value

var default_code = getprop(lw~"tiles/code");

t.getNode("latitude-deg",1).setValue(blat + get_lat(x,y,phi));
t.getNode("longitude-deg",1).setValue(blon + get_lon(x,y,phi));
t.getNode("generated-flag",1).setValue(0);
t.getNode("tile-index",1).setValue(-1);
t.getNode("code",1).setValue(default_code);
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


###############################
# buffer loop
###############################

var buffer_loop = func (index) {

var n = 5;
var n_max = size(cloudBufferArray);
var s = size(active_tile_list);

setprop(lw~"clouds/buffer-count",n_max);

# don't do anything as long as the buffer is empty

if (n_max == 0) # nothing to do, loop over
	{if (getprop(lw~"buffer-loop-flag") ==1) {settimer( func {buffer_loop(index)}, 0);} return;}

# don't process the buffer if a tile call is writing clouds into the scenery

if (getprop(lw~"tmp/thread-status") == "placing") 
	{if (getprop(lw~"buffer-loop-flag") ==1) {settimer( func {buffer_loop(index)}, 0);} return;}

# lock the system status for buffer operations and get flags

setprop(lw~"tmp/buffer-status", "placing");
var asymmetric_buffering_flag = getprop(lw~"config/asymmetric-buffering-flag");
	
if (asymmetric_buffering_flag ==1)
	{
	var buffering_angle = getprop(lw~"config/asymmetric-buffering-angle-deg");
	var buffering_reduction = getprop(lw~"config/asymmetric-buffering-reduction");
	var current_heading = getprop("orientation/heading-deg");
	}

# now process the buffer


if (index > n_max-1) {index = 0;}

var i_max = index + n;
if (i_max > n_max) {i_max = n_max;}

for (var i = index; i < i_max; i = i+1)
	{
	var c = cloudBufferArray[i];

	# check if the cloud is still part of an active tile, if not remove from buffer
	

	var flag = 0;
	for (var j = 0; j < s; j = j+1)
		{
		if (active_tile_list[j] == c.index) {flag = 1; break;}
		}

	if (flag == 0)
		{
		cloudBufferArray = delete_from_vector(cloudBufferArray,i);
		i = i -1; i_max = i_max - 1; n_max = n_max - 1;
		continue;
		}

	# if wind drift is on, move the cloud

	if (getprop(lw~"config/dynamics-flag") == 1)
		{
		c.move();
		}	


	# check distance and decide if the cloud should be created
	
	var d = c.get_distance();
	var d_comp = cloud_view_distance + 1000.0;

	if (asymmetric_buffering_flag == 1)
		{
		var dir = c.get_course();
		var angle = abs(dir-current_heading);
		if ((angle > 180.0 - 0.5 * buffering_angle) and (angle < 180 + 0.5 * buffering_angle))
			{		
			d_comp = buffering_reduction * d_comp;
			} 
		}



	if (d < d_comp) # insert the cloud into scenery and delete from buffer
		{
		setprop(lw~"tmp/buffer-tile-index",c.index);
		compat_layer.create_cloud(c.path, c.lat, c.lon, c.alt, c.orientation);
		cloudBufferArray = delete_from_vector(cloudBufferArray,i);
		i = i -1; i_max = i_max - 1; n_max = n_max - 1;
		deleted_flag = 1;
		}
	
	

	
	} # end for i


# unlock the system status for buffer operations

setprop(lw~"tmp/buffer-status", "idle");

if (getprop(lw~"buffer-loop-flag") ==1) {settimer( func {buffer_loop(i)}, 0);}
}


###############################
# housekeeping loop
###############################

var housekeeping_loop = func (index) {

var n = 5;
var n_max = size(cloudSceneryArray);
var s = size(active_tile_list);

setprop(lw~"clouds/cloud-scenery-count",n_max);

# don't do anything as long as the array is empty

if (n_max == 0) # nothing to do, loop over
	{if (getprop(lw~"housekeeping-loop-flag") ==1) {settimer( func {housekeeping_loop(index)}, 0);} return;}

# parse the flags

var asymmetric_buffering_flag = getprop(lw~"config/asymmetric-buffering-flag");
	
if (asymmetric_buffering_flag ==1)
	{
	var buffering_angle = getprop(lw~"config/asymmetric-buffering-angle-deg");
	var buffering_reduction = getprop(lw~"config/asymmetric-buffering-reduction");
	var current_heading = getprop("orientation/heading-deg");
	}

# now process the array

if (index > n_max-1) {index = 0;}

var i_max = index + n;
if (i_max > n_max) {i_max = n_max;}

for (var i = index; i < i_max; i = i+1)
	{
	var c = cloudSceneryArray[i];

	var flag = 0;
	
	for (var j = 0; j < s; j = j+1)
		{
		if (active_tile_list[j] == c.index) {flag = 1; break;}
		}

	if (flag == 0)
		{
		c.removeNodes();
		cloudSceneryArray = delete_from_vector(cloudSceneryArray,i);
		i = i -1; i_max = i_max - 1; n_max = n_max - 1;
		continue;
		}
	
	var d = c.get_distance();
	var alt = c.get_altitude();

	d_comp = cloud_view_distance + 1000.0;


	if (asymmetric_buffering_flag == 1)
		{
		var dir = c.get_course();
		var angle = abs(dir-current_heading);
		if ((angle > 180.0 - 0.5 * buffering_angle) and (angle < 180 + 0.5 * buffering_angle))
			{		
			d_comp = buffering_reduction * d_comp;
			} 
		}

	if ((d > d_comp) and (alt < 20000.0))
		{
		append(cloudBufferArray,c.to_buffer());
		cloudSceneryArray = delete_from_vector(cloudSceneryArray,i);
		i = i -1; i_max = i_max - 1; n_max = n_max - 1;
		continue;
		}

	}


if (getprop(lw~"housekeeping-loop-flag") ==1) {settimer( func {housekeeping_loop(i)}, 0);}
}


###############################
# watchdog loop for debugging
###############################


var watchdog_loop = func {

var tNode = props.globals.getNode(lw~"tiles", 1).getChildren("tile");

var i = 0;

print("====================");

foreach(t; tNode)
	{
	var code = t.getNode("code").getValue();
	var index = t.getNode("tile-index").getValue();
	var flag = t.getNode("generated-flag").getValue();

	print(i,": code: ", code, " unique id: ", index, " flag: ", flag); 
	
	i = i + 1;
	}

print("====================");

settimer(watchdog_loop, 10.0);
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

var cloud_view_distance = 20000.0;


var modelArrays = [];
var active_tile_list = [];


#####################################################
# hashes to manage clouds in scenery or in the buffer
#####################################################

var cloudBufferArray = [];

var cloudBuffer = {
	new: func(lat, lon, alt, path, orientation, index) {
	        var c = { parents: [cloudBuffer] };
	        c.lat = lat;
		c.lon = lon;
		c.alt = alt;
		c.path = path;
		c.orientation = orientation;
		c.index = index;
	        return c;
	},
	get_distance: func {
		var pos = geo.aircraft_position();
		var cpos = geo.Coord.new();
		cpos.set_latlon(me.lat,me.lon,0.0);
		return pos.distance_to(cpos);
	},
	get_course: func {
		var pos = geo.aircraft_position();
		var cpos = geo.Coord.new();
		cpos.set_latlon(me.lat,me.lon,0.0);
		return pos.course_to(cpos);
	},
	show: func {
		print("lat: ",me.lat," lon: ",me.lon," alt: ",me.alt);
		print("path: ",me.path);
	
	},
	move: func {
		var windfield = weather_dynamics.get_windfield(me.index);
		var dt = weather_dynamics.time_lw - me.timestamp;
		me.lat = me.lat + windfield[1] * dt * local_weather.m_to_lat;
		me.lon = me.lon + windfield[0] * dt * local_weather.m_to_lon;
		me.timestamp = weather_dynamics.time_lw;
	},
  
};


var cloudSceneryArray = [];

var cloudScenery = {
	new: func(index, cloudNode, modelNode) {
	        var c = { parents: [cloudScenery] };
		c.index = index;
		c.cloudNode = cloudNode;
		c.modelNode = modelNode;
	        return c;
	},
	removeNodes: func {
		me.modelNode.remove();
		me.cloudNode.remove();
	},
	to_buffer: func {
		var lat = me.cloudNode.getNode("position/latitude-deg").getValue();
		var lon = me.cloudNode.getNode("position/longitude-deg").getValue();
		var alt = me.cloudNode.getNode("position/altitude-ft").getValue();
		var path = me.modelNode.getNode("path").getValue();
		var orientation = me.cloudNode.getNode("orientation/true-heading-deg").getValue();
		var b = cloudBuffer.new(lat, lon, alt, path, orientation, me.index);

		if (getprop(lw~"config/dynamics-flag") == 1)
			{
			var timestamp = me.cloudNode.getNode("timestamp-sec").getValue();
			b.timestamp = timestamp;
			}

		me.removeNodes();
		return b;
	},
	get_distance: func {
		var pos = geo.aircraft_position();
		var cpos = geo.Coord.new();
		var lat = me.cloudNode.getNode("position/latitude-deg").getValue();
		var lon = me.cloudNode.getNode("position/longitude-deg").getValue();
		cpos.set_latlon(lat,lon,0.0);
		return pos.distance_to(cpos);
	},
	get_course: func {
		var pos = geo.aircraft_position();
		var cpos = geo.Coord.new();
		var lat = me.cloudNode.getNode("position/latitude-deg").getValue();
		var lon = me.cloudNode.getNode("position/longitude-deg").getValue();
		cpos.set_latlon(lat,lon,0.0);
		return pos.course_to(cpos);
	},
	get_altitude: func {
		return me.cloudNode.getNode("position/altitude-ft").getValue();
	},
};

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


var delete_from_vector = func(vec, index) {

var n = index+1;

var vec_end = subvec(vec, n);

setsize(vec, n-1);
return vec~vec_end;
	
}
