########################################################
# routines to set up, transform and manage weather tiles
# Thorsten Renk, April 2010
########################################################


###################################
# tile management loop
###################################

var tile_management_loop = func {

var tNode = props.globals.getNode(lw~"tiles", 1).getChildren("tile");
var viewpos = geo.aircraft_position(); # using viewpos here triggers massive tile ops for tower view...
var code = getprop(lw~"tiles/code");
var i = 0;
var d_min = 100000.0;
var i_min = 0;
var distance_to_load = getprop(lw~"config/distance-to-load-tile-m");
var distance_to_remove = getprop(lw~"config/distance-to-remove-tile-m");
var current_heading = getprop("orientation/heading-deg");
var loading_flag = getprop(lw~"tmp/asymmetric-tile-loading-flag");

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

	#print(d);
	if ((d < distance_to_load) and (flag==0)) # the tile needs to be generated, unless it already has been
		{
		setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);
		print("Building tile unique index ",getprop(lw~"tiles/tile-counter"));
		generate_tile(code, tpos.lat(), tpos.lon(),0);
		t.getNode("generated-flag").setValue(1);
		t.getNode("tile-index",1).setValue(getprop(lw~"tiles/tile-counter"));
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

var generate_tile = func (code, lat, lon, index) {

setprop(lw~"tiles/tmp/latitude-deg", lat);
setprop(lw~"tiles/tmp/longitude-deg",lon);

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
	}
else if (getprop(lw~"tmp/tile-management") == "realistic weather")
	{
	var rn = rand();
	
	if (code == "low_pressure_core") 
		{
		if (rn > 0.3) {weather_tiles.set_low_pressure_core_tile();}
		else {weather_tiles.set_low_pressure_tile();}
		}
	else if (code == "low_pressure") 
		{
		if (rn > 0.3) {weather_tiles.set_low_pressure_tile();}
		else if (rn > 0.15) {weather_tiles.set_low_pressure_core_tile();}
		else {weather_tiles.set_low_pressure_border_tile();}
		}
	else if (code == "low_pressure_border") 
		{
		if (rn > 0.3) {weather_tiles.set_low_pressure_border_tile();}
		else if (rn > 0.15) {weather_tiles.set_low_pressure_tile();}
		else {weather_tiles.set_high_pressure_border_tile();}
		}
	else if (code == "high_pressure_border") 
		{
		if (rn > 0.3) {weather_tiles.set_high_pressure_border_tile();}
		else if (rn > 0.15) {weather_tiles.set_high_pressure_tile();}
		else {weather_tiles.set_low_pressure_border_tile();}
		}
	else if (code == "high_pressure") 
		{
		if (rn > 0.3) {weather_tiles.set_high_pressure_tile();}
		else if (rn > 0.15) {weather_tiles.set_high_pressure_border_tile();}
		else {weather_tiles.set_high_pressure_core_tile();}
		}
	else if (code == "high_pressure_core") 
		{
		if (rn > 0.3) {weather_tiles.set_high_pressure_core_tile();}
		else {weather_tiles.set_high_pressure_tile();}
		}

	} # end if mode == realistic weather
}
	

###################################
# tile removal call
###################################


var remove_tile_loop = func (index) {

var n = 100;

var flag_mod = 0;

#var mvec = props.globals.getNode("models", 1).getChildren("model");
#var msize = size(mvec);

var status = getprop(lw~"tmp/thread-status");

if ((status == "computing") or (status == "placing")) # the array is blocked
	{
	settimer( func {remove_tile_loop(index); },0); # try again next frame
	return;
	}
else if (status == "idle") # we initialize the loop
	{
	mvec = props.globals.getNode("models", 1).getChildren("model");
	msize = size(mvec);
	setprop(lw~"tmp/last-reading-pos-mod", msize);
	setprop(lw~"tmp/thread-status", "removing"); 
	}

var lastpos = getprop(lw~"tmp/last-reading-pos-mod"); 

# print("msize: ", msize, "lastpos ", lastpos);

if (lastpos < (msize-1)) {var istart = lastpos;} else {var istart = (msize-1);}

if (istart<0) {istart=0;}

var i_min = istart - n;
if (i_min < -1) {i_min =-1;}

for (var i = istart; i > i_min; i = i- 1)
		{
		m = mvec[i];
		if (m.getNode("legend",1).getValue() == "Cloud")
			{
			if (m.getNode("tile-index").getValue() == index) 
				{
				m.remove();
				}
			}
		}

if (i<0) {flag_mod = 1;}


if (flag_mod == 0) {setprop(lw~"tmp/last-reading-pos-mod",i); }

if (flag_mod == 0) # we still have work to do
	{settimer( func {remove_tile_loop(index); },0);}
else 
	{
	print("Tile deletion loop finished!");
	setprop(lw~"tmp/thread-status", "idle"); 
	setprop(lw~"clouds/placement-index",0);
	setprop(lw~"clouds/model-placement-index",0);
	}

}

# this is to avoid two tile removal loops starting at the same time

var waiting_loop = func (index) {

var status = getprop(lw~"tmp/thread-status");

if (status == "idle") {remove_tile_loop(index);}

else 	{
	print("Removal of ",index, " waiting for idle thread...");
	settimer( func {waiting_loop(index); },1.0);
	}
}

var remove_tile = func (index) {

var n = size(props.globals.getNode("local-weather/clouds").getChild("tile",index,1).getChildren("cloud"));
props.globals.getNode("local-weather/clouds", 1).removeChild("tile",index);
setprop(lw~"clouds/cloud-number",getprop(lw~"clouds/cloud-number")-n);

if (getprop(lw~"tmp/thread-flag") ==  1)
	#{remove_tile_loop(index);}
	#{waiting_loop(index);}
	# call the model removal in the next frame, because its initialization takes time 
	# and we do a lot in this frame
	{settimer( func {waiting_loop(index); },0);} 
else 
	{
	var modelNode = props.globals.getNode("models", 1).getChildren("model");
	foreach (var m; modelNode)
		{
		if (m.getNode("legend").getValue() == "Cloud")
			{
			if (m.getNode("tile-index").getValue() == index) 
				{
				m.remove();
				}
			}
		}
	}


var effectNode = props.globals.getNode("local-weather/effect-volumes").getChildren("effect-volume");

foreach (var e; effectNode)
	{
	if (e.getNode("tile-index").getValue() == index) 
		{
		e.remove();
		setprop(lw~"effect-volumes/number",getprop(lw~"effect-volumes/number")-1);
		}
	}

# set placement indices to zero to reinitiate search for free positions

setprop(lw~"clouds/placement-index",0);
setprop(lw~"clouds/model-placement-index",0);
setprop(lw~"effect-volumes/effect-placement-index",0);

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

x = 0.0; y = 40000.0; 
setprop(lw~"tiles/tile[1]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[1]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[1]/generated-flag",0);
setprop(lw~"tiles/tile[1]/tile-index",-1);

x = 40000.0; y = 40000.0; 
setprop(lw~"tiles/tile[2]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[2]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[2]/generated-flag",0);
setprop(lw~"tiles/tile[2]/tile-index",-1);

x = -40000.0; y = 0.0; 
setprop(lw~"tiles/tile[3]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[3]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[3]/generated-flag",0);
setprop(lw~"tiles/tile[3]/tile-index",-1);

# this is the current tile
x = 0.0; y = 0.0; 
setprop(lw~"tiles/tile[4]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[4]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[4]/generated-flag",1);
setprop(lw~"tiles/tile[4]/tile-index",1);

x = 40000.0; y = 0.0; 
setprop(lw~"tiles/tile[5]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[5]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[5]/generated-flag",0);
setprop(lw~"tiles/tile[5]/tile-index",-1);

x = -40000.0; y = -40000.0; 
setprop(lw~"tiles/tile[6]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[6]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[6]/generated-flag",0);
setprop(lw~"tiles/tile[6]/tile-index",-1);

x = 0.0; y = -40000.0; 
setprop(lw~"tiles/tile[7]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[7]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[7]/generated-flag",0);
setprop(lw~"tiles/tile[7]/tile-index",-1);

x = 40000.0; y = -40000.0; 
setprop(lw~"tiles/tile[8]/latitude-deg",blat + get_lat(x,y,phi));
setprop(lw~"tiles/tile[8]/longitude-deg",blon + get_lon(x,y,phi));
setprop(lw~"tiles/tile[8]/generated-flag",0);
setprop(lw~"tiles/tile[8]/tile-index",-1);
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

# storage array for model vector

var mvec = [];
var msize = 0;

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
