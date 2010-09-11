
########################################################
# compatibility layer for local weather package
# Thorsten Renk, July 2010
########################################################

# function			purpose
#
# setVisibility			to set the visibility to a given value
# setRain			to set rain to a given value
# setSnow			to set snow to a given value
# setTurbulence			to set turbulence to a given value
# setTemperature		to set temperature to a given value
# setPressure			to set pressure to a given value
# setDewpoint			to set the dewpoint to a given value
# setWind			to set wind
# setWindSmoothly 		to set the wind gradually across a second
# smooth_wind_loop		helper function for setWindSmoothly
# create_cloud			to place a single cloud into the scenery
# create_cloud_array		to place clouds from storage arrays into the scenery
# move_cloud			to move the cloud position
# remove_clouds			to remove clouds by tile index
# waiting_loop			to ensure tile removal calls do not overlap
# remove_tile_loop		to remove a fixed number of clouds per frame
# get_elevation			to get the terrain elevation at given coordinates
# get_elevation_vector		to get terrain elevation at given coordinate vector



# This file contains portability wrappers for the local weather system: 
#   http://wiki.flightgear.org/index.php/A_local_weather_system
#   
# This module is intended to provide a certain degree of backward compatibility for past 
# FlightGear releases, while sketching out the low level APIs used and required by the 
# local weather system, as these
# are being added to FlightGear.
#
# This file contains various workarounds for doing things that are currently not yet directly 
# supported by the core FlightGear/Nasal APIs (fgfs 2.0).
#
# Some of these workarounds are purely implemented in Nasal space, and may thus not provide sufficient
# performance in some situations.
#
# The goal is to move all such workarounds eventually  into this module, so that the high level weather modules
# only refer to this "compatibility layer" (using an "ideal API"), while this module handles 
# implementation details 
# and differences among different versions of FlightGear, so that key APIs can be ported to C++ space 
# for the sake
# of improving runtime performance and efficiency.
#
# This provides an abstraction layer that isolates the rest of the local weather system from low 
# level implementation details.
# 
# C++ developers who want to help improve the local weather system (or the FlightGear/Nasal 
# interface in general) should 
# check out this file (as well as the wiki page) for APIs or features that shall eventually be 
# re/implemented in C++ space for
# improving the local weather system.
#
# 
# This module provides a handful of helpers for dynamically querying the Nasal API of the running fgfs binary,
# so that it can make use of new APIs (where available), while still working with older fgfs versions.
#
# Note: The point of these helpers is that they should really only be used 
# by this module, and not in other parts/files of the 
# local weather system. Any hard coded special cases should be moved into this module.
#
# The compatibility layer is currently work in progress and will be extended as new Nasal 
# APIs are being added to FlightGear.

###########################################
# header checking availability of functions
###########################################


var has_symbol = func(s) contains(globals,s);
var is_function = func(s) typeof(globals[s])=='func';
var has_function = func(f) has_symbol(f) and is_function(f);

# try to call a function with given parameters
# save exceptions to err vector
# returns 0 for no exceptions (exceptions vector is empty)
# returns >=1 for exception occurred (i.e. unsupported API call)


var try_call = func(f, params) {
var err=[]; 
call(globals[f], params, nil,nil,err); # see http://plausible.org/nasal/lib.html
return size(err); 
};


var query = func(api,params) {
  if ( has_function(api) ) {
   return try_call(api, params ); 
  }
  return 1; # fail
}

var patches = { geodinfo: "http://flightgear.org/forums/viewtopic.php?f=5&t=7358&st=0&sk=t&sd=a&start=90#p82805", };

# query fgfs binary for required APIs and set values in this hash
var features = {};


#fixme: compare results from new and old API
var check_geodinfo_vec = func {
  var err=[];

  if ( query('geodinfo',[ [37.618,-122.374],1000])==0 ) {
    printf("geodinfo found"); # now try to use it
    var ksfo=[37.618, -122.374];
    var alt=10000;
    # see if it returns a vector or not
    call( func { print (alt); (typeof(geodinfo(ksfo,alt))=='vector')?return:die(); }, [], caller()[0],nil,err);
    print('-','geodinfo:', (size(err) >=1) ? "Vector support unavailable" : "Vector support available");
    if(size(err) and contains(patches,'geodinfo')) print('---> A patch is available at ', patches['geodinfo']);

    return size(err)?0:1;
  } 
  return 0;
}

_setlistener("/sim/signals/nasal-dir-initialized", func { 
   print ("Compatibility layer: Checking available Nasal APIs:");
   print ("(this may cause harmless error messages when hard-coded support is lacking)");
   print ("##########################################");
   features.geodinfo_supports_vectors= check_geodinfo_vec ();
   print("features.geodinfo_supports_vectors=", features.geodinfo_supports_vectors);
   print ("##########################################");
   print("Compatibility checks done.");
});

# this is now where we can simply refer to features.geodinfo_supports_vectors 
# for checking if vector support is available or not - to use the most appropriate 
# APIs



####################################
# set visibility to given value
####################################

var setVisibility = func (vis) {

# this is a rather dirty workaround till a better solution becomes available
# essentially we update all entries in config and reinit environment

var entries_aloft = props.globals.getNode("environment/config/aloft", 1).getChildren("entry");
foreach (var e; entries_aloft) {
		e.getNode("visibility-m",1).setValue(vis);
		}

var entries_boundary = props.globals.getNode("environment/config/boundary", 1).getChildren("entry");
foreach (var e; entries_boundary) {
		e.getNode("visibility-m",1).setValue(vis);
		}
fgcommand("reinit", props.Node.new({subsystem:"environment"}));

}

####################################
# set rain to given value
####################################

var setRain = func (rain) {

# setting the lowest cloud layer to 30.000 ft is a workaround
# as rain is only created below that layer in default

setprop("environment/clouds/layer[0]/elevation-ft", 30000.0);
setprop("environment/metar/rain-norm",rain);

}

####################################
# set snow to given value
####################################

var setSnow = func (snow) {

# setting the lowest cloud layer to 30.000 ft is a workaround
# as snow is only created below that layer in default

setprop("environment/clouds/layer[0]/elevation-ft", 30000.0);
setprop("environment/metar/snow-norm",snow);
}


####################################
# set turbulence to given value
####################################

var setTurbulence = func (turbulence) {

# this is a rather dirty workaround till a better solution becomes available
# essentially we update all entries in config and reinit environment

var entries_aloft = props.globals.getNode("environment/config/aloft", 1).getChildren("entry");
foreach (var e; entries_aloft) {
		e.getNode("turbulence/magnitude-norm",1).setValue(turbulence);
		}

# turbulence is slightly reduced in boundary layers

var entries_boundary = props.globals.getNode("environment/config/boundary", 1).getChildren("entry");
var i = 1;
foreach (var e; entries_boundary) {
		e.getNode("turbulence/magnitude-norm",1).setValue(turbulence * 0.25*i);
		i = i + 1;
		}
fgcommand("reinit", props.Node.new({subsystem:"environment"}));

}


####################################
# set temperature to given value
####################################

var setTemperature = func (T) {

# this is a rather dirty workaround till a better solution becomes available
# essentially we update the entry in config and reinit environment

setprop(ec~"boundary/entry[0]/temperature-degc",T);
fgcommand("reinit", props.Node.new({subsystem:"environment"}));
}

####################################
# set pressure to given value
####################################

var setPressure = func (p) {

# this is a rather dirty workaround till a better solution becomes available
# essentially we update the entry in config and reinit environment

setprop(ec~"boundary/entry[0]/pressure-sea-level-inhg",p);
setprop(ec~"aloft/entry[0]/pressure-sea-level-inhg",p);
fgcommand("reinit", props.Node.new({subsystem:"environment"}));
}

####################################
# set dewpoint to given value
####################################

var setDewpoint = func (D) {

# this is a rather dirty workaround till a better solution becomes available
# essentially we update the entry in config and reinit environment

setprop(ec~"boundary/entry[0]/dewpoint-degc",D);
fgcommand("reinit", props.Node.new({subsystem:"environment"}));
}

###########################################################
# set wind to given direction and speed
###########################################################


var setWind = func (dir, speed) {

# this is a rather dirty workaround till a better solution becomes available
# essentially we update all entries in config and reinit environment

var entries_aloft = props.globals.getNode("environment/config/aloft", 1).getChildren("entry");
foreach (var e; entries_aloft) {
		e.getNode("wind-from-heading-deg",1).setValue(dir);
		e.getNode("wind-speed-kt",1).setValue(speed);
		}

var entries_boundary = props.globals.getNode("environment/config/boundary", 1).getChildren("entry");
foreach (var e; entries_boundary) {
		e.getNode("wind-from-heading-deg",1).setValue(dir);
		e.getNode("wind-speed-kt",1).setValue(speed);
		}

fgcommand("reinit", props.Node.new({subsystem:"environment"}));

}

###########################################################
# set wind smoothly to given direction and speed
# interpolating across several frames
###########################################################


var setWindSmoothly = func (dir, speed) {

var entries_aloft = props.globals.getNode("environment/config/aloft", 1).getChildren("entry");

var dir_old = entries_aloft[0].getNode("wind-from-heading-deg",1).getValue();
var speed_old = entries_aloft[0].getNode("wind-speed-kt",1).getValue();

var dir = dir * math.pi/180.0;
var dir_old = dir_old * math.pi/180.0;

var vx = speed * math.sin(dir);
var vx_old = speed_old * math.sin(dir_old);

var vy = speed * math.cos(dir);
var vy_old = speed_old * math.cos(dir_old);

smooth_wind_loop(vx,vy,vx_old, vy_old, 4, 4);

}


var smooth_wind_loop = func (vx, vy, vx_old, vy_old, counter, count_max) {

var time_delay = 0.9/count_max;

if (counter == 0) {return;}

var f = (counter -1)/count_max;

var vx_set = f * vx_old + (1-f) * vx;
var vy_set = f * vy_old + (1-f) * vy;

var speed_set = math.sqrt(vx_set * vx_set + vy_set * vy_set);
var dir_set = math.atan2(vx_set,vy_set) * 180.0/math.pi;

setWind(dir_set,speed_set);

settimer( func {smooth_wind_loop(vx,vy,vx_old,vy_old,counter-1, count_max); },time_delay);

}

###########################################################
# place a single cloud 
###########################################################

var create_cloud = func(path, lat, long, alt, heading) {

var tile_counter = getprop(lw~"tiles/tile-counter");
var buffer_flag = getprop(lw~"config/buffer-flag");
var dynamics_flag = getprop(lw~"config/dynamics-flag");
var d_max = weather_tile_management.cloud_view_distance + 1000.0;


# first check if the cloud should be stored in the buffer
# we keep it if it is in visual range or at high altitude (where visual range is different)

if (buffer_flag == 1)
	{
	# calculate the distance to the aircraft
	var pos = geo.aircraft_position();
	var cpos = geo.Coord.new();
	cpos.set_latlon(lat,long,0.0);
	var d = pos.distance_to(cpos);
	
	if ((d > d_max) and (alt < 20000.0)) # we buffer the cloud
		{
		var b = weather_tile_management.cloudBuffer.new(lat, long, alt, path, heading, tile_counter);
		if (dynamics_flag ==1) {b.timestamp = weather_dynamics.time_lw;}
		append(weather_tile_management.cloudBufferArray,b);
		return;
		}
	}

# now check if we are writing from the buffer, in this case change tile index
# to buffered one

if (getprop(lw~"tmp/buffer-status") == "placing")
	{
	tile_counter = getprop(lw~"tmp/buffer-tile-index");
	}


# if the cloud is not buffered, get property tree nodes and write it 
# into the scenery

var n = props.globals.getNode("local-weather/clouds", 1);
var c = n.getChild("tile",tile_counter,1);


var cloud_number = n.getNode("placement-index").getValue();
		for (var i = cloud_number; 1; i += 1)
			if (c.getChild("cloud", i, 0) == nil)
				break;
	cl = c.getChild("cloud", i, 1);
	n.getNode("placement-index").setValue(i);


var model_number = n.getNode("model-placement-index").getValue();
var m = props.globals.getNode("models", 1);
		for (var i = model_number; 1; i += 1)
			if (m.getChild("model", i, 0) == nil)
				break;
	model = m.getChild("model", i, 1);
	n.getNode("model-placement-index").setValue(i);	



var latN = cl.getNode("position/latitude-deg", 1); latN.setValue(lat);
var lonN = cl.getNode("position/longitude-deg", 1); lonN.setValue(long);
var altN = cl.getNode("position/altitude-ft", 1); altN.setValue(alt);
var hdgN = cl.getNode("orientation/true-heading-deg", 1); hdgN.setValue(heading);
#var pitchN = cl.getNode("orientation/pitch-deg", 1); pitchN.setValue(0.0);
#var rollN = cl.getNode("orientation/roll-deg", 1);rollN.setValue(0.0);

cl.getNode("tile-index",1).setValue(tile_counter);

model.getNode("path", 1).setValue(path);
model.getNode("latitude-deg-prop", 1).setValue(latN.getPath());
model.getNode("longitude-deg-prop", 1).setValue(lonN.getPath());
model.getNode("elevation-ft-prop", 1).setValue(altN.getPath());
model.getNode("heading-deg-prop", 1).setValue(hdgN.getPath());
#model.getNode("pitch-deg-prop", 1).setValue(pitchN.getPath());
#model.getNode("roll-deg-prop", 1).setValue(rollN.getPath());
model.getNode("tile-index",1).setValue(tile_counter);
model.getNode("load", 1).remove();

n.getNode("cloud-number").setValue(n.getNode("cloud-number").getValue()+1);

# sort the model node into a vector for easy deletion

# append(weather_tile_management.modelArrays[tile_counter-1],model);

# sort the cloud into the cloud hash array

if ((buffer_flag == 1) and (getprop(lw~"tmp/tile-management") != "single tile"))
	{
	var cs = weather_tile_management.cloudScenery.new(tile_counter, cl, model);
	append(weather_tile_management.cloudSceneryArray,cs);
	}

# if weather dynamics is on, also create a timestamp property and sort the cloud node into quadtree

#if (getprop(lw~"config/dynamics-flag") == 1)
if (dynamics_flag == 1)
	{
	cl.getNode("timestamp-sec",1).setValue(weather_dynamics.time_lw);
	var blat = getprop(lw~"tiles/tmp/latitude-deg");
	var blon = getprop(lw~"tiles/tmp/longitude-deg");
	var alpha = getprop(lw~"tmp/tile-orientation-deg");
	weather_dynamics.sort_into_quadtree(blat, blon, alpha, lat, long, weather_dynamics.cloudQuadtrees[tile_counter-1], cl); 
	}

}


###########################################################
# place a cloud layer from arrays, split across frames 
###########################################################

var create_cloud_array = func (i, clouds_path, clouds_lat, clouds_lon, clouds_alt, clouds_orientation) {

if (getprop(lw~"tmp/thread-status") != "placing") {return;}
if (getprop(lw~"tmp/convective-status") != "idle") {return;}
if ((i < 0) or (i==0)) 
	{
	print("Cloud placement from array finished!"); 
	setprop(lw~"tmp/thread-status", "idle");

	# now set flag that tile has been completely processed
	var dir_index = props.globals.getNode(lw~"tiles/tmp/dir-index").getValue();
	# print("dir_index: ",dir_index);
	props.globals.getNode(lw~"tiles").getChild("tile",dir_index).getNode("generated-flag").setValue(2);
	
	return;
	}


var k_max = 30;
var s = size(clouds_path);  

if (s < k_max) {k_max = s;}

for (var k = 0; k < k_max; k = k+1)
	{
	create_cloud(clouds_path[s-k-1], clouds_lat[s-k-1], clouds_lon[s-k-1], clouds_alt[s-k-1], clouds_orientation[s-k-1]);
	}

setsize(clouds_path,s-k_max);
setsize(clouds_lat,s-k_max);
setsize(clouds_lon,s-k_max);
setsize(clouds_alt,s-k_max);
setsize(clouds_orientation,s-k_max);

settimer( func {create_cloud_array(i - k, clouds_path, clouds_lat, clouds_lon, clouds_alt, clouds_orientation ) }, 0 );
};


####################################################
# move a cloud
####################################################

var move_cloud = func (c, tile_index) {

# get the old spacetime position of the cloud

var lat_old = c.getNode("position/latitude-deg").getValue();
var lon_old = c.getNode("position/longitude-deg").getValue();
var alt = c.getNode("position/altitude-ft").getValue();
var timestamp = c.getNode("timestamp-sec").getValue();

# get windfield and time since last update

var windfield = weather_dynamics.get_windfield(tile_index);
var dt = weather_dynamics.time_lw - timestamp;

#print(dt * windfield[1]);

# update the spacetime position of the cloud

c.getNode("position/latitude-deg",1).setValue(lat_old + windfield[1] * dt * local_weather.m_to_lat);
c.getNode("position/longitude-deg",1).setValue(lon_old + windfield[0] * dt * local_weather.m_to_lon);
c.getNode("timestamp-sec",1).setValue(weather_dynamics.time_lw);

}


####################################################
# remove clouds by tile index
####################################################

var remove_clouds = func (index) {

var n = size(props.globals.getNode("local-weather/clouds").getChild("tile",index,1).getChildren("cloud"));
props.globals.getNode("local-weather/clouds", 1).removeChild("tile",index);
setprop(lw~"clouds/cloud-number",getprop(lw~"clouds/cloud-number")-n);

if (getprop(lw~"tmp/thread-flag") ==  1)
	{settimer( func {waiting_loop(index); },0);} 
else 
	{
	var modelNode = props.globals.getNode("models", 1).getChildren("model");
	foreach (var m; modelNode)
		{
		if (m.getNode("tile-index",1).getValue() == index) {m.remove();} 		
		}
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


var remove_tile_loop = func (index) {

var n = 100;

var flag_mod = 0;


var status = getprop(lw~"tmp/thread-status");

if ((status == "computing") or (status == "placing")) # the array is blocked
	{
	settimer( func {remove_tile_loop(index); },0); # try again next frame
	return;
	}
else if (status == "idle") # we initialize the loop
	{
	mvec = weather_tile_management.modelArrays[index-1];
	msize = size(mvec);
	if (msize == 0) 
		{
		print("Tile deletion loop finished!");
		setprop(lw~"tmp/thread-status", "idle"); 
		setprop(lw~"clouds/placement-index",0);
		setprop(lw~"clouds/model-placement-index",0);
		setsize(weather_tile_management.modelArrays[index-1],0);
		return;
		}
	setprop(lw~"tmp/last-reading-pos-mod", msize);
	setprop(lw~"tmp/thread-status", "removing"); 
	}

var lastpos = getprop(lw~"tmp/last-reading-pos-mod"); 


if (lastpos < (msize-1)) {var istart = lastpos;} else {var istart = (msize-1);}

if (istart<0) {istart=0;}

var i_min = istart - n;
if (i_min < -1) {i_min =-1;}

for (var i = istart; i > i_min; i = i- 1)
		{
		m = mvec[i];
		m.remove();
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
	setsize(weather_tile_management.modelArrays[index-1],0);
	}

}




###########################################################
# get terrain elevation
###########################################################

var get_elevation = func (lat, lon) {

var info = geodinfo(lat, lon);
	if (info != nil) {var elevation = info[0] * local_weather.m_to_ft;}
	else {var elevation = -1.0;}

return elevation;
}

###########################################################
# get terrain elevation vector
###########################################################

var get_elevation_array = func (lat, lon) {

var elevation = [];
var n = size(lat);

if (features.geodinfo_supports_vectors == 0)
	{
	for(var i = 0; i < n; i=i+1)
		{
		append(elevation, get_elevation(lat[i], lon[i]));
		}
	}
else 
	{
	elevation = geodinfo(lat,10000);
	}

return elevation;
}



############################################################
# global variables
############################################################

# some common abbreviations

var lw = "/local-weather/";
var ec = "/environment/config/";

# storage arrays for model vector

var mvec = [];
var msize = 0;
