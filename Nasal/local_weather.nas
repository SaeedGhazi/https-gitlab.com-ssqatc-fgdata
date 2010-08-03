
########################################################
# routines to set up, transform and manage local weather
# Thorsten Renk, July 2010
# thermal model by Patrice Poly, April 2010
########################################################

# function			purpose
#
# calc_geo			to compute the latitude to meter conversion
# calc_d_sq			to compute a distance square in local Cartesian approximation
# effect_volume_loop		to check if the aircraft has entered an effect volume
# assemble_effect_array 	to create a Nasal internal array with pointers to all effect volumes
# add_vectors			to add two vectors in polar coordinates
# wind_altitude_interpolation 	to interpolate aloft winds in altitude
# wind_interpolation		to interpolate aloft winds in altitude and position
# interpolation_loop		to continuously interpolate weather parameters between stations 
# thermal_lift _loop		to manage the detailed thermal lift model
# thermal_lift_start		to start the detailed thermal model
# effect_volume_start		to manage parameters when an effect volume is entered
# effect_volume_stop		to manage parameters when an effect volume is left
# ts_factor			(helper function for thermal lift model)
# tl_factor			(helper function for thermal lift model)
# calcLift_max			to calculate the maximal available thermal lift for given altitude
# calcLift			to calculate the thermal lift at aircraft position
# select_cloud_model		to select a path to the cloud model, given the cloud type and subtype
# create_cloud_vec		to place a single cloud into an array to be written later
# clear_all			to remove all clouds, effect volumes and weather stations and stop loops
# create_detailed_cumulus_cloud	to place multiple cloudlets into a box based on a size parameter
# create_cumulonimbus_cloud	to place multiple cloudlets into a box 
# create_cumosys		wrapper to place a convective cloud system based on terrain coverage
# cumulus_loop			to place 25 Cumulus clouds each frame
# create_cumulus		to place a convective cloud system based on terrain coverage
# cumulus_exclusion_layer	to create a layer with 'holes' left for thunderstorm placement
# create_rise_clouds		to create a barrier cloud system
# create_streak			to create a cloud streak
# create_layer			to create a cloud layer with optional precipitation
# create_hollow_layer		to create a cloud layer in a hollow cylinder (better for performance)
# create_cloudbox		to create a sophisticated cumulus cloud with different textures (experimental)
# terrain_presampling_start	to initialize terrain presampling
# terrain_presampling_loop 	to sample 25 terrain points per frame
# terrain_presampling		to sample terrain elevation at a random point within specified area
# terrain_presampling_analysis	to analyze terrain presampling results
# get_convective_altitude	to determine the altitude at which a Cumulus cloud is placed
# manage presampling		to take proper action when a presampling call has been finished
# set_wind_model_flag		to convert the wind model string into an integer flag
# create_effect_volume		to create an effect volume
# set_weather_station		to specify a weather station for interpolation
# set_wind_ipoint		to set an aloft wind interpolation point
# showDialog			to pop up a dialog window
# streak_wrapper		wrapper to execute streak from menu
# convection wrapper		wrapper to execute convective clouds from menu
# barrier wrapper 		wrapper to execute barrier clouds from menu
# single_cloud_wrapper		wrapper to create single cloud from menu
# layer wrapper			wrapper to create layer from menu
# box wrapper			wrapper to create a cloudbox (experimental)
# set aloft wrapper		wrapper to create aloft winds from menu
# set_tile			to call a weather tile creation from menu
# startup			to prepare the package at startup

###################################
# geospatial helper functions
###################################

var calc_geo = func(clat) {

lon_to_m  = math.cos(clat*math.pi/180.0) * lat_to_m;
m_to_lon = 1.0/lon_to_m;

weather_dynamics.lon_to_m = lon_to_m;
weather_dynamics.m_to_lon = m_to_lon;

}


var calc_d_sq = func (lat1, lon1, lat2, lon2) {

var x = (lat1 - lat2) * lat_to_m;
var y = (lon1 - lon2) * lon_to_m;

return (x*x + y*y);
}


###################################
# effect volume management loop
###################################

var effect_volume_loop = func (index, n_active) {

var n = 25;
#var evNode = props.globals.getNode("local-weather/effect-volumes", 1).getChildren("effect-volume");
#var esize = size(evNode);

var esize = n_effectVolumeArray;

var viewpos = geo.aircraft_position();
var active_counter = n_active;

var i_max = index + n;
if (i_max > esize) {i_max = esize;}

for (var i = index; i < i_max; i = i+1)
	{
	#e = evNode[i];
	e = effectVolumeArray[i];
	
	var flag = 0; #default assumption is that we're not in the volume
	var ealt_min = e.getNode("position/min-altitude-ft").getValue() * ft_to_m;
	var ealt_max = e.getNode("position/max-altitude-ft").getValue() * ft_to_m;
	
	if ((viewpos.alt() > ealt_min) and (viewpos.alt() < ealt_max)) # we are in the correct alt range
		{
		# so we load geometry next
		var geometry = e.getNode("geometry").getValue();
		var elat = e.getNode("position/latitude-deg").getValue();
		var elon = e.getNode("position/longitude-deg").getValue();
		var rx = e.getNode("volume/size-x").getValue();


		if (geometry == 1) # we have a cylinder
			{
			var d_sq = calc_d_sq(viewpos.lat(), viewpos.lon(), elat, elon);
			if (d_sq < (rx*rx)) {flag =1;}
			}
		else if (geometry == 2) # we have an elliptic shape
			{
			# get orientation
			var ry = e.getNode("volume/size-y").getValue();
			var phi = e.getNode("volume/orientation-deg").getValue();
			phi = phi * math.pi/180.0;
			# first get unrotated coordinates 
			var xx = (viewpos.lon() - elon) * lon_to_m;
			var yy = (viewpos.lat() - elat) * lat_to_m;
			# then rotate to align with the shape
			var x = xx * math.cos(phi) - yy * math.sin(phi);
			var y = yy * math.cos(phi) + xx * math.sin(phi); 
			# then check elliptic condition
			if ((x*x)/(rx*rx) + (y*y)/(ry*ry) <1) {flag = 1;}
			}
		else if (geometry == 3) # we have a rectangular shape
			{
			# get orientation
			var ry = e.getNode("volume/size-y").getValue();
			var phi = e.getNode("volume/orientation-deg").getValue();
			phi = phi * math.pi/180.0;
			# first get unrotated coordinates 
			var xx = (viewpos.lon() - elon) * lon_to_m;
			var yy = (viewpos.lat() - elat) * lat_to_m;
			# then rotate to align with the shape
			var x = xx * math.cos(phi) - yy * math.sin(phi);
			var y = yy * math.cos(phi) + xx * math.sin(phi); 
			# then check rectangle condition
			if ((x>-rx) and (x<rx) and (y>-ry) and (y<ry)) {flag = 1;}
			}
		} # end if altitude
	
	
	# if flag ==1 at this point, we are inside the effect volume
	# but we only need to take action on entering and leaving, so we check also active_flag
	
	#if (flag==1) {print("Inside volume");}
	
	var active_flag = e.getNode("active-flag").getValue(); # see if the node was active previously

	if ((flag==1) and (active_flag ==0)) # we just entered the node
		{
		#print("Entered volume");
		e.getNode("active-flag").setValue(1);
		effect_volume_start(e);
		}
	else if ((flag==0) and (active_flag ==1)) # we left an active node
		{
		#print("Left volume!");
		e.getNode("active-flag").setValue(0);
		effect_volume_stop(e);
		}
	if (flag==1) {active_counter = active_counter + 1;} # we still count the active volumes
	
	} # end foreach

# at this point, all active effect counters should have been set to zero if we're outside all volumes
# however there seem to be rare configurations of overlapping volumes for which this doesn't happen
# therefore we zero them for redundancy here so that the interpolation loop can take over
# and set the properties correctly for outside

#print(i);

if (i == esize) # we check the number of actives and reset all counters
	{
	if (active_counter == 0)
		{
		var vNode = props.globals.getNode("local-weather/effect-volumes", 1);
		vNode.getChild("number-active-vis").setValue(0);
		vNode.getChild("number-active-snow").setValue(0);
		vNode.getChild("number-active-rain").setValue(0);
		vNode.getChild("number-active-lift").setValue(0);
		vNode.getChild("number-active-turb").setValue(0);
		}
	#print("n_active: ", active_counter);
	active_counter = 0; i = 0;
	}

# and we repeat the loop as long as the control flag is set


if (getprop(lw~"effect-loop-flag") ==1) {settimer( func {effect_volume_loop(i, active_counter); },0);}
}


###################################
# assemble effect volume array
###################################


var assemble_effect_array = func {

setsize(effectVolumeArray,0);
effectVolumeArray = props.globals.getNode("local-weather/effect-volumes", 1).getChildren("effect-volume");
n_effectVolumeArray = size(effectVolumeArray);
#print("Effect vector size: ",n_effectVolumeArray);
}



###################################
# vector addition
###################################

var add_vectors = func (phi1, r1, phi2, r2) {

phi1 = phi1 * math.pi/180.0;
phi2 = phi2 * math.pi/180.0;

var x1 = r1 * math.sin(phi1);
var x2 = r2 * math.sin(phi2);

var y1 = r1 * math.cos(phi1);
var y2 = r2 * math.cos(phi2);

var x = x1+x2;
var y = y1+y2;

var phi = math.atan2(x,y) * 180.0/math.pi;
var r = math.sqrt(x*x + y*y);

var vec = [];

append(vec, phi);
append(vec,r);

return vec;
}


###################################
# windfield altitude interpolation
###################################


var wind_altitude_interpolation = func (altitude, w) {

if (altitude < wind_altitude_array[0]) {var alt_wind = wind_altitude_array[0];}
else if (altitude > wind_altitude_array[8]) {var alt_wind = 0.99* wind_altitude_array[8];}
else {alt_wind = altitude;}

for (var i = 0; i<9; i=i+1)
	{if (alt_wind < wind_altitude_array[i]) {break;}}
	

var altNodeMin = w.getChild("altitude",i-1);
var altNodeMax = w.getChild("altitude",i);	

var vmin = altNodeMin.getNode("windspeed-kt").getValue();
var vmax = altNodeMax.getNode("windspeed-kt").getValue();

var dir_min = altNodeMin.getNode("wind-from-heading-deg").getValue();
var dir_max = altNodeMax.getNode("wind-from-heading-deg").getValue();

var f = (alt_wind - wind_altitude_array[i-1])/(wind_altitude_array[i] - wind_altitude_array[i-1]);

var res = add_vectors(dir_min, (1-f) * vmin, dir_max, f * vmax);

return res;
}

var wind_interpolation = func (lat, lon, alt) {

var windNodes = props.globals.getNode(lw~"interpolation").getChildren("wind");
var sum_norm = 0;
var sum_wind = [0,0];

	
foreach (var w; windNodes) {
	
	var wlat = w.getNode("latitude-deg").getValue();
	var wlon = w.getNode("longitude-deg").getValue();

	var wpos = geo.Coord.new();
	wpos.set_latlon(wlat,wlon,1000.0);

	var ppos = geo.Coord.new();
	ppos.set_latlon(lat,lon,1000.0);

	var d = ppos.distance_to(wpos);
	if (d <100.0) {d = 100.0;} # to prevent singularity at zero

	sum_norm = sum_norm + 1./d;

	var res = wind_altitude_interpolation(alt,w);
	sum_wind = add_vectors(sum_wind[0], sum_wind[1], res[0], res[1]/d);	

	}

sum_wind[1] = sum_wind[1] /sum_norm;

return sum_wind;
}


###################################
# interpolation management loop
###################################

var interpolation_loop = func {

var iNode = props.globals.getNode(lw~"interpolation", 1);
var cNode = props.globals.getNode(lw~"current", 1);
var stNode = iNode.getChildren("station");
var viewpos = geo.aircraft_position();

var sum_vis = 0.0;
var sum_T = 0.0;
var sum_p = 0.0;
var sum_D = 0.0;
var sum_norm = 0.0;


# get an inverse distance weighted average from all defined weather stations

foreach (var s; stNode) {
	
	var slat = s.getNode("latitude-deg").getValue();
	var slon = s.getNode("longitude-deg").getValue();

	var stpos = geo.Coord.new();
	stpos.set_latlon(slat,slon,1000.0);

	var d = viewpos.distance_to(stpos);
	if (d <100.0) {d = 100.0;} # to prevent singularity at zero

	sum_norm = sum_norm + 1./d;
	sum_vis = sum_vis + (s.getNode("visibility-m").getValue()/d);
	sum_T = sum_T + (s.getNode("temperature-degc").getValue()/d);
	sum_D = sum_D + (s.getNode("dewpoint-degc").getValue()/d);
	sum_p = sum_p + (s.getNode("pressure-sea-level-inhg").getValue()/d);

	# automatically delete stations out of range
	# take care not to unload if weird values appear for a moment
	if ((d > 80000.0) and (d<100000.0)) {s.remove();} 
	}

var vis = sum_vis/sum_norm;
var p = sum_p/sum_norm;
var D = sum_D/sum_norm;
var T = sum_T/sum_norm;

# a simple altitude model for visibility - increase it with increasing altitude

var altitude = getprop("position/altitude-ft");

vis = vis + 0.5 * altitude;

if (vis > 0.0) {iNode.getNode("visibility-m",1).setValue(vis);} # a redundancy check
iNode.getNode("temperature-degc",1).setValue(T);
iNode.getNode("dewpoint-degc",1).setValue(D);
if (p>0.0) {iNode.getNode("pressure-sea-level-inhg",1).setValue(p);} # a redundancy check
iNode.getNode("turbulence",1).setValue(0.0);

# now check if an effect volume writes the property and set only if not

flag = props.globals.getNode("local-weather/effect-volumes/number-active-vis").getValue();
if ((flag ==0) and (vis > 0.0))
	{
	cNode.getNode("visibility-m").setValue(vis);
	compat_layer.setVisibility(vis);
	}

flag = props.globals.getNode("local-weather/effect-volumes/number-active-turb").getValue();
if ((flag ==0))
	{
	cNode.getNode("turbulence").setValue(0.0);
	compat_layer.setTurbulence(0.0);
	}


flag = props.globals.getNode("local-weather/effect-volumes/number-active-lift").getValue();
if (flag ==0) 
	{
	cNode.getNode("thermal-lift").setValue(0.0);
	}

# no need to check for these, as they are not modelled in effect volumes

cNode.getNode("temperature-degc",1).setValue(T);
compat_layer.setTemperature(T);

cNode.getNode("dewpoint-degc",1).setValue(D);
compat_layer.setDewpoint(D);

if (p>0.0) {cNode.getNode("pressure-sea-level-inhg",1).setValue(p); compat_layer.setPressure(p);}


# now determine the local wind 

var tile_index = props.globals.getNode(lw~"tiles").getChild("tile",4).getNode("tile-index").getValue();

if (wind_model_flag ==1) # constant
	{
	var winddir = weather_dynamics.tile_wind_direction[0];
	var windspeed = weather_dynamics.tile_wind_speed[0];
	}
else if (wind_model_flag ==2) # constant in tile
	{
	var winddir = weather_dynamics.tile_wind_direction[tile_index-1];
	var windspeed = weather_dynamics.tile_wind_speed[tile_index-1];
	}	
else if (wind_model_flag ==3) # aloft interpolated, constant in tiles
	{
	var w = props.globals.getNode(lw~"interpolation").getChild("wind",0);
	var res = wind_altitude_interpolation(altitude,w);
	var winddir = res[0];
	var windspeed = res[1];
	}
else if (wind_model_flag == 5) # aloft waypoint interpolated
	{
	var res = wind_interpolation(viewpos.lat(), viewpos.lon(), viewpos.alt());
	
	var winddir = res[0];
	var windspeed = res[1];
	}


# now do the boundary layer computations

var altitude_agl = getprop("/position/altitude-agl-ft");

if (getprop("tmp/presampling-flag") == 0)
	{
	var boundary_alt = 600.0;

	var windspeed_ground = windspeed/3.0;

	if (altitude_agl < boundary_alt)
	{var windspeed_current = windspeed_ground + 2.0 * windspeed_ground * (altitude_agl/boundary_alt);}
	else 
		{var windspeed_current = windspeed;}
	}
else
	{
	var alt_median = alt_50_array[tile_index - 1];
	var alt_difference = alt_median - (altitude - altitude_agl);
	var base_layer_thickness = 150.0;	

	# get the boundary layer size dependent on terrain altitude above terrain median

	if (alt_difference > 0.0) # we're low and the boundary layer grows
		{var boundary_alt = base_layer_thickness + 0.3 * alt_difference;}
	else # the boundary layer shrinks
		{var boundary_alt = base_layer_thickness + 0.1 * alt_difference;}

	if (boundary_alt < 50.0){boundary_alt = 50.0;}
	if (boundary_alt > 3000.0) {boundary_alt = 3000.0;}

	# get the boundary effect as a function of bounday layer size
	
	var f_min = 0.2 + 0.17 * math.ln(boundary_alt/base_layer_thickness);


	if (altitude_agl < boundary_alt)
		{
		var windspeed_current = (1-f_min) * windspeed + f_min * windspeed * (altitude_agl/boundary_alt);
		}
	else 
		{var windspeed_current = windspeed;}

	}




compat_layer.setWindSmoothly(winddir, windspeed_current);

iNode.getNode("wind-from-heading-deg").setValue(winddir);
iNode.getNode("wind-speed-kt").setValue(windspeed_current);

cNode.getNode("wind-from-heading-deg").setValue(winddir);
cNode.getNode("wind-speed-kt").setValue(windspeed_current);


if (getprop(lw~"interpolation-loop-flag") ==1) {settimer(interpolation_loop, 1.0);}

}

###################################
# thermal lift loop
###################################

var thermal_lift_loop = func {

var cNode = props.globals.getNode(lw~"current", 1);
var lNode = props.globals.getNode(lw~"lift",1);

var apos = geo.aircraft_position();

var tlat = lNode.getNode("latitude-deg").getValue();
var tlon = lNode.getNode("longitude-deg").getValue();
var tpos = geo.Coord.new();
tpos.set_latlon(tlat,tlon,0.0);

var d = apos.distance_to(tpos);
var alt = getprop("position/altitude-ft");


var R = lNode.getNode("radius").getValue();
var height = lNode.getNode("height").getValue();
var cn = lNode.getNode("cn").getValue();
var sh = lNode.getNode("sh").getValue();
var max_lift = lNode.getNode("max_lift").getValue();
var f_lift_radius = lNode.getNode("f_lift_radius").getValue();

# print(d," ", alt, " ", R, " ", height, " ", cn, " ", sh," ", max_lift," ", f_lift_radius, " ",0.0);

var lift = calcLift(d, alt, R, height, cn, sh, max_lift, f_lift_radius, 0.0);
# print(lift);

cNode.getChild("thermal-lift").setValue(lift);

if (getprop(lw~"lift-loop-flag") ==1) {settimer(thermal_lift_loop, 0);}
}

###################################
# thermal lift loop startup
###################################

var thermal_lift_start = func (ev) {

# copy the properties from effect volume to the lift folder

var lNode = props.globals.getNode(lw~"lift",1);
lNode.getNode("radius",1).setValue(ev.getNode("effects/radius").getValue());
lNode.getNode("height",1).setValue(ev.getNode("effects/height").getValue());
lNode.getNode("cn",1).setValue(ev.getNode("effects/cn").getValue());
lNode.getNode("sh",1).setValue(ev.getNode("effects/sh").getValue());
lNode.getNode("max_lift",1).setValue(ev.getNode("effects/max_lift").getValue());
lNode.getNode("f_lift_radius",1).setValue(ev.getNode("effects/f_lift_radius").getValue());

#lNode.getNode("latitude-deg",1).setValue(ev.getNode("position/latitude-deg").getValue());
#lNode.getNode("longitude-deg",1).setValue(ev.getNode("position/longitude-deg").getValue());

lNode.getNode("latitude-deg",1).alias(ev.getNode("position/latitude-deg"));
lNode.getNode("longitude-deg",1).alias(ev.getNode("position/longitude-deg"));

# and start the lift loop, unless another one is already running
# so we block overlapping calls

if (getprop(lw~"lift-loop-flag") == 0) 
{setprop(lw~"lift-loop-flag",1); settimer(thermal_lift_loop,0);}

}

###################################
# thermal lift loop stop
###################################

var thermal_lift_stop = func {

# unalias later to avoid an error being generated

settimer( func {
var lNode = props.globals.getNode(lw~"lift",1);
lNode.getNode("latitude-deg",1).unalias();
lNode.getNode("longitude-deg",1).unalias(); },0.1);

setprop(lw~"lift-loop-flag",0);
setprop(lw~"current/thermal-lift",0.0);
}

####################################
# action taken when in effect volume
####################################

var effect_volume_start = func (ev) {

var cNode = props.globals.getNode(lw~"current");

if (ev.getNode("effects/visibility-flag", 1).getValue()==1)
	{
	# first store the current setting in case we need to restore on leaving 
	var vis = ev.getNode("effects/visibility-m").getValue();
	ev.getNode("restore/visibility-m",1).setValue(cNode.getNode("visibility-m").getValue());
	
	# then set the new value in current and execute change
	cNode.getNode("visibility-m").setValue(vis);
	compat_layer.setVisibility(vis);

	# then count the number of active volumes on entry (we need that to determine
	# what to do on exit)
	ev.getNode("restore/number-entry-vis",1).setValue(getprop(lw~"effect-volumes/number-active-vis"));
	
	# and add to the counter
	setprop(lw~"effect-volumes/number-active-vis",getprop(lw~"effect-volumes/number-active-vis")+1);
	}

if (ev.getNode("effects/rain-flag", 1).getValue()==1)
	{
	var rain = ev.getNode("effects/rain-norm").getValue();
	ev.getNode("restore/rain-norm",1).setValue(cNode.getNode("rain-norm").getValue());
	cNode.getNode("rain-norm").setValue(rain);
	compat_layer.setRain(rain);
	ev.getNode("restore/number-entry-rain",1).setValue(getprop(lw~"effect-volumes/number-active-rain"));
	setprop(lw~"effect-volumes/number-active-rain",getprop(lw~"effect-volumes/number-active-rain")+1);
	}

if (ev.getNode("effects/snow-flag", 1).getValue()==1)
	{
	var snow = ev.getNode("effects/snow-norm").getValue();
	ev.getNode("restore/snow-norm",1).setValue(cNode.getNode("snow-norm").getValue());
	cNode.getNode("snow-norm").setValue(snow);
	compat_layer.setSnow(snow);
	ev.getNode("restore/number-entry-snow",1).setValue(getprop(lw~"effect-volumes/number-active-snow"));
	setprop(lw~"effect-volumes/number-active-snow",getprop(lw~"effect-volumes/number-active-snow")+1);
	}

if (ev.getNode("effects/turbulence-flag", 1).getValue()==1)
	{
	var turbulence = ev.getNode("effects/turbulence").getValue();
	ev.getNode("restore/turbulence",1).setValue(cNode.getNode("turbulence").getValue());
	cNode.getNode("turbulence").setValue(turbulence);
	compat_layer.setTurbulence(turbulence);
	ev.getNode("restore/number-entry-turb",1).setValue(getprop(lw~"effect-volumes/number-active-turb"));
	setprop(lw~"effect-volumes/number-active-turb",getprop(lw~"effect-volumes/number-active-turb")+1);
	}

if (ev.getNode("effects/thermal-lift-flag", 1).getValue()==1)
	{
	var lift = ev.getNode("effects/thermal-lift").getValue();
	ev.getNode("restore/thermal-lift",1).setValue(cNode.getNode("thermal-lift").getValue());
	cNode.getNode("thermal-lift").setValue(lift);
	#setLift(ev.getNode("position/latitude-deg").getValue(),ev.getNode("position/longitude-deg").getValue(),1);
	ev.getNode("restore/number-entry-lift",1).setValue(getprop(lw~"effect-volumes/number-active-lift"));
	setprop(lw~"effect-volumes/number-active-lift",getprop(lw~"effect-volumes/number-active-lift")+1);
	}
else if (ev.getNode("effects/thermal-lift-flag", 1).getValue()==2) # thermal by function
	{
	ev.getNode("restore/thermal-lift",1).setValue(cNode.getNode("thermal-lift").getValue());
	ev.getNode("restore/number-entry-lift",1).setValue(getprop(lw~"effect-volumes/number-active-lift"));
	setprop(lw~"effect-volumes/number-active-lift",getprop(lw~"effect-volumes/number-active-lift")+1);
	thermal_lift_start(ev);
	}

}



var effect_volume_stop = func (ev) {

var cNode = props.globals.getNode(lw~"current");


if (ev.getNode("effects/visibility-flag", 1).getValue()==1)
	{

	var n_active = getprop(lw~"effect-volumes/number-active-vis");
	var n_entry = ev.getNode("restore/number-entry-vis").getValue();	
	
	# if no other nodes affecting property are active, restore to outside
	# else restore settings as they have been when entering the volume when the number
	# of active volumes is the same as on entry (i.e. volumes are nested), otherwise
	# leave property at current because new definitions are already active and should not
	# be cancelled
	
	if (n_active ==1){var vis = props.globals.getNode(lw~"interpolation/visibility-m").getValue();}
	else if ((n_active -1) == n_entry) {var vis = ev.getNode("restore/visibility-m").getValue();}
	else {var vis = cNode.getNode("visibility-m").getValue();}
	cNode.getNode("visibility-m").setValue(vis);
	compat_layer.setVisibility(vis);
	
	# and subtract from the counter
	setprop(lw~"effect-volumes/number-active-vis",getprop(lw~"effect-volumes/number-active-vis")-1);
	}

if (ev.getNode("effects/rain-flag", 1).getValue()==1)
	{
	var n_active = getprop(lw~"effect-volumes/number-active-rain");
	var n_entry = ev.getNode("restore/number-entry-rain").getValue();	
	if (n_active ==1){var rain = props.globals.getNode(lw~"interpolation/rain-norm").getValue();}
	else if ((n_active -1) == n_entry) {var rain = ev.getNode("restore/rain-norm").getValue();}
	else {var rain = cNode.getNode("rain-norm").getValue();}
	cNode.getNode("rain-norm").setValue(rain);
	compat_layer.setRain(rain);
	setprop(lw~"effect-volumes/number-active-rain",getprop(lw~"effect-volumes/number-active-rain")-1);
	}

if (ev.getNode("effects/snow-flag", 1).getValue()==1)
	{
	var n_active = getprop(lw~"effect-volumes/number-active-snow");
	var n_entry = ev.getNode("restore/number-entry-snow").getValue();	
	if (n_active ==1){var snow = props.globals.getNode(lw~"interpolation/snow-norm").getValue();}
	else if ((n_active -1) == n_entry) {var snow = ev.getNode("restore/snow-norm").getValue();}
	else {var snow = cNode.getNode("snow-norm").getValue();}
	cNode.getNode("snow-norm").setValue(snow);
	compat_layer.setSnow(snow);
	setprop(lw~"effect-volumes/number-active-snow",getprop(lw~"effect-volumes/number-active-snow")-1);
	}

if (ev.getNode("effects/turbulence-flag", 1).getValue()==1)
	{
	var n_active = getprop(lw~"effect-volumes/number-active-turb");
	var n_entry = ev.getNode("restore/number-entry-turb").getValue();	
	if (n_active ==1){var turbulence = props.globals.getNode(lw~"interpolation/turbulence").getValue();}
	else if ((n_active -1) == n_entry) {var turbulence = ev.getNode("restore/turbulence").getValue();}
	else {var turbulence = cNode.getNode("turbulence").getValue();}
	cNode.getNode("turbulence").setValue(turbulence);
	compat_layer.setTurbulence(turbulence);
	setprop(lw~"effect-volumes/number-active-turb",getprop(lw~"effect-volumes/number-active-turb")-1);
	}

if (ev.getNode("effects/thermal-lift-flag", 1).getValue()==1)
	{
	var n_active = getprop(lw~"effect-volumes/number-active-lift");
	var n_entry = ev.getNode("restore/number-entry-lift").getValue();	
	if (n_active ==1){var lift = props.globals.getNode(lw~"interpolation/thermal-lift").getValue();}
	else if ((n_active -1) == n_entry) {var lift = ev.getNode("restore/thermal-lift").getValue();}
	else {var lift = cNode.getNode("thermal-lift").getValue();}
	cNode.getNode("thermal-lift").setValue(lift);
	# some cheat code
	# setLift(ev.getNode("position/latitude-deg").getValue(),ev.getNode("position/longitude-deg").getValue(),0);

	setprop(lw~"effect-volumes/number-active-lift",getprop(lw~"effect-volumes/number-active-lift")-1);
	}
else if (ev.getNode("effects/thermal-lift-flag", 1).getValue()==2) # thermal by function
	{
	thermal_lift_stop();
	setprop(lw~"effect-volumes/number-active-lift",getprop(lw~"effect-volumes/number-active-lift")-1);
	}

}







####################################
# set thermal lift to given value 
####################################

var setLift = func (lat, lon, flag) {

# this is a cheat - if you have an AI thermal present, this sets its coordinates to the
# current position

if (flag==1) 
	{	
	setprop("ai/models/thermal/position/latitude-deg",lat);
	setprop("ai/models/thermal/position/longitude-deg",lon);
	}
else	
	{
	setprop("ai/models/thermal/position/latitude-deg",0.1);
	setprop("ai/models/thermal/position/longitude-deg",0.1);

	}

#setprop("environment/thermal-lift",L);
}

#########################################
# compute thermal lift in detailed model 
#########################################

var ts_factor = func (t, alt, height) {

# no time dependence modelled yet
return 1.0; 


var t_a = t - (alt/height) * t1 -t1;

if (t_a<0) {return 0.0;}
else if (t_a<t1) {return 0.5 + 0.5 * math.cos((1.0-t_a/t1)* math.pi);}
else if ((t_a >= t1) and (t < t2)) {return 1.0;}
else if (t_a >= t2) {return 0.5 - 0.5 * math.cos((1.0-(t2-t_a)/(t3-t2))*math.pi);}
}

var tl_factor = func (t, alt, height) {

# no time dependence modelled yet
return 1.0; 

var t_a = t - (alt/height) * t1;

if (t_a<0) {return 0.0;}
else if (t_a<t1) {return 0.5 + 0.5 * math.cos((1.0-t_a/t1)* math.pi);}
else if ((t_a >= t1) and (t < t2)) {return 1.0;}
else if (t_a >= t2) {return 0.5 - 0.5 * math.cos((1.0-(t2-t_a)/(t3-t2))*math.pi);}      
}


var calcLift_max = func (alt, max_lift, height) {
    
# no lift below ground
if (alt < 0.0) {return 0.0;}   
    
# lift ramps up to full within 200 m
else if (alt < 200.0*m_to_ft) 
	{return max_lift * 0.5 * (1.0 + math.cos((1.0-alt/(200.0*m_to_ft))*math.pi));}

# constant max. lift in main body
else if ((alt > 200.0*m_to_ft) and (alt < height))
	{return max_lift;}

# decreasing lift from cloudbase to 10% above base
else if ((alt > height ) and (alt < height*1.1)) 
	{return max_lift * 0.5 * (1.0 - math.cos((1.0-10.0*alt/height)*math.pi));}
    
# no lift available above
else {return 0.0;}
}



var calcLift = func (d, alt, R, height, cn, sh, max_lift, f_lift_radius, t) {

# radius of slice at given altitude
var r_total = (cn + alt/height*(1.0-cn)) * (R - R * (1.0- sh ) * (1.0 - ((2.0*alt/height)-1.0)*((2.0*alt/height)-1.0)));


# print("r_total: ", r_total, "d: ",d);
# print("alt: ", alt, "height: ",height);

# no lift if we're outside the radius or above the thermal
if ((d > r_total) or (alt > 1.1*height)) { return 0.0; } 

# fraction of radius providing lift
var r_lift = f_lift_radius * r_total;

# print("r_lift: ", r_lift);

# if we are in the sink portion, get the max. sink for this time and altitude and adjust for actual position
if ((d < r_total ) and (d > r_lift)) 
	{
	var s_max = 0.5 * calcLift_max(alt, max_lift, height) * ts_factor(t, alt, height);
	# print("s_max: ", s_max);
	return s_max * math.sin(math.pi * (1.0 + (d-r_lift) * (1.0/(r_total - r_lift))));
	}
# else we are in the lift portion, get the max. lift for this time and altitude and adjust for actual position
else
	{  
    	var l_max = calcLift_max(alt, max_lift, height) * tl_factor(t, alt, height);
	# print("l_max: ", l_max);
	return l_max * math.cos(math.pi * (d/(2.0 * r_lift)));
	}
}



###########################################################
# select a cloud model 
###########################################################

var select_cloud_model = func(type, subtype) {

var rn = rand();
var path="Models/Weather/blank.ac";

if (type == "Cumulus"){
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/cumulus_small_shader1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulus_small_shader2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulus_small_shader3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulus_small_shader4.xml";}
		else  {path = "Models/Weather/cumulus_small_shader5.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.83) {path = "Models/Weather/cumulus_shader1.xml";}
		else if (rn > 0.664) {path = "Models/Weather/cumulus_shader2.xml";}
		else if (rn > 0.498) {path = "Models/Weather/cumulus_shader3.xml";}
		else if (rn > 0.332) {path = "Models/Weather/cumulus_shader4.xml";}
		else if (rn > 0.166) {path = "Models/Weather/cumulus_shader5.xml";}
		else  {path = "Models/Weather/cumulus_shader6.xml";}
		}
	}
else if (type == "Cumulus (cloudlet)"){
	if (subtype == "small") {
		if (rn > 0.875) {path = "Models/Weather/cumulus_small_sl1.xml";}
		else if (rn > 0.750) {path = "Models/Weather/cumulus_small_sl2.xml";}
		else if (rn > 0.625) {path = "Models/Weather/cumulus_small_sl3.xml";}
		else if (rn > 0.500) {path = "Models/Weather/cumulus_small_sl4.xml";}
		else if (rn > 0.375) {path = "Models/Weather/cumulus_small_sl5.xml";}
		else if (rn > 0.250) {path = "Models/Weather/cumulus_small_sl6.xml";}
		else if (rn > 0.125) {path = "Models/Weather/cumulus_small_sl7.xml";}
		else  {path = "Models/Weather/cumulus_small_sl8.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.9) {path = "Models/Weather/cumulus_sl1.xml";}
		else if (rn > 0.8) {path = "Models/Weather/cumulus_sl2.xml";}
		else if (rn > 0.7) {path = "Models/Weather/cumulus_sl3.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulus_sl4.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cumulus_sl5.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulus_sl6.xml";}
		else if (rn > 0.3) {path = "Models/Weather/cumulus_sl7.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulus_sl8.xml";}
		else if (rn > 0.1) {path = "Models/Weather/cumulus_sl9.xml";}
		else  {path = "Models/Weather/cumulus_sl10.xml";}
		}
	
	}
else if (type == "Congestus"){
	if (subtype == "small") {
		if (rn > 0.9) {path = "Models/Weather/cumulus_sl1.xml";}
		else if (rn > 0.8) {path = "Models/Weather/cumulus_sl2.xml";}
		else if (rn > 0.7) {path = "Models/Weather/cumulus_sl3.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulus_sl4.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cumulus_sl5.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulus_small_sl4.xml";}
		else if (rn > 0.3) {path = "Models/Weather/cumulus_small_sl5.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulus_small_sl6.xml";}
		else if (rn > 0.1) {path = "Models/Weather/cumulus_small_sl7.xml";}
		else  {path = "Models/Weather/cumulus_small_sl8.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/congestus_sl1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/congestus_sl2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/congestus_sl3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/congestus_sl4.xml";}
		else  {path = "Models/Weather/congestus_sl5.xml";}
		}
	
	}
else if (type == "Cumulus bottom"){
	if (subtype == "small") {
		if (rn > 0.0) {path = "Models/Weather/cumulus_bottom1.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.0) {path = "Models/Weather/cumulus_bottom1.xml";}
		}
	
	}
else if (type == "Congestus bottom"){
	if (subtype == "small") {
		if (rn > 0.0) {path = "Models/Weather/congestus_bottom1.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.0) {path = "Models/Weather/congestus_bottom1.xml";}
		}
	
	}

else if (type == "Cumulonimbus (cloudlet)"){
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/cumulonimbus_sl1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulonimbus_sl2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulonimbus_sl3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulonimbus_sl4.xml";}
		else  {path = "Models/Weather/cumulonimbus_sl5.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/cumulonimbus_sl1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulonimbus_sl2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulonimbus_sl3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulonimbus_sl4.xml";}
		else  {path = "Models/Weather/cumulonimbus_sl5.xml";}
		}
	
	}

else if (type == "Altocumulus"){
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/altocumulus_shader6.xml";}
		else if (rn > 0.6) {path = "Models/Weather/altocumulus_shader7.xml";}
		else if (rn > 0.4) {path = "Models/Weather/altocumulus_shader8.xml";}
		else if (rn > 0.2) {path = "Models/Weather/altocumulus_shader9.xml";}
		else  {path = "Models/Weather/altocumulus_shader10.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/altocumulus_shader1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/altocumulus_shader2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/altocumulus_shader3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/altocumulus_shader4.xml";}
		else  {path = "Models/Weather/altocumulus_shader5.xml";}
		}
	}

else if (type == "Stratus (structured)"){
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/altocumulus_layer6.xml";}
		else if (rn > 0.6) {path = "Models/Weather/altocumulus_layer7.xml";}
		else if (rn > 0.4) {path = "Models/Weather/altocumulus_layer8.xml";}
		else if (rn > 0.2) {path = "Models/Weather/altocumulus_layer9.xml";}
		else  {path = "Models/Weather/altocumulus_layer10.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/altocumulus_layer1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/altocumulus_layer2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/altocumulus_layer3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/altocumulus_layer4.xml";}
		else  {path = "Models/Weather/altocumulus_layer5.xml";}
		}
	}
else if ((type == "Cumulonimbus") or (type == "Cumulonimbus (rain)")) {
	if (subtype == "small") {
		if (rn > 0.5) {path = "Models/Weather/cumulonimbus_small1.xml";}
		else  {path = "Models/Weather/cumulonimbus_small2.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.5) {path = "Models/Weather/cumulonimbus_small1.xml";}
		else  {path = "Models/Weather/cumulonimbus_small2.xml";}
		}
	}	
else if (type == "Cirrus") {
	if (subtype == "large") {
		if (rn > 0.66) {path = "Models/Weather/cirrus1.xml";}
		else if (rn > 0.33) {path = "Models/Weather/cirrus2.xml";}
		else  {path = "Models/Weather/cirrus3.xml";}
		}	
	else if (subtype == "small") {
		if (rn > 0.5) {path = "Models/Weather/cirrus_amorphous1.xml";}
		else  {path = "Models/Weather/cirrus_amorphous2.xml";}
		}	
	}
else if (type == "Cirrocumulus") {
	if (subtype == "small") {
		if (rn > 0.5) {path = "Models/Weather/cirrocumulus1.xml";}
		else  {path = "Models/Weather/cirrocumulus2.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.5) {path = "Models/Weather/cirrocumulus1.xml";}
		else  {path = "Models/Weather/cirrocumulus4.xml";}
		}	
	}
else if (type == "Cirrocumulus (cloudlet)") {
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/cirrocumulus_cloudlet6.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cirrocumulus_cloudlet7.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cirrocumulus_cloudlet8.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cirrocumulus_cloudlet9.xml";}
		else  {path = "Models/Weather/cirrocumulus_cloudlet10.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/cirrocumulus_cloudlet1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cirrocumulus_cloudlet2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cirrocumulus_cloudlet3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cirrocumulus_cloudlet4.xml";}
		else  {path = "Models/Weather/cirrocumulus_cloudlet5.xml";}
		}	
	}
else if (type == "Nimbus") {
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/nimbus_sls1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/nimbus_sls2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/nimbus_sls3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/nimbus_sls4.xml";}
		else  {path = "Models/Weather/nimbus_sls5.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/nimbus_sl1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/nimbus_sl2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/nimbus_sl3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/nimbus_sl4.xml";}
		else  {path = "Models/Weather/nimbus_sl5.xml";}
		}	
	}
else if (type == "Stratus") {
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/stratus_layer1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratus_layer2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratus_layer3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratus_layer4.xml";}
		else  {path = "Models/Weather/stratus_layer5.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/stratus_layer1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratus_layer2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratus_layer3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratus_layer4.xml";}
		else  {path = "Models/Weather/stratus_layer5.xml";}
		}	
	}
else if (type == "Stratus (thin)") {
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/stratus_tlayer1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratus_tlayer2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratus_tlayer3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratus_tlayer4.xml";}
		else  {path = "Models/Weather/stratus_tlayer5.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/stratus_tlayer1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratus_tlayer2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratus_tlayer3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratus_tlayer4.xml";}
		else  {path = "Models/Weather/stratus_tlayer5.xml";}
		}	
	}
else if (type == "Cirrostratus") {
	if (subtype == "small") {
		if (rn > 0.75) {path = "Models/Weather/cirrostratus1.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cirrostratus2.xml";}
		else if (rn > 0.25) {path = "Models/Weather/cirrostratus3.xml";}
		else  {path = "Models/Weather/cirrostratus4.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.75) {path = "Models/Weather/cirrostratus1.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cirrostratus2.xml";}
		else if (rn > 0.25) {path = "Models/Weather/cirrostratus3.xml";}
		else  {path = "Models/Weather/cirrostratus4.xml";}
		}	
	}
else if (type == "Fog (thin)") {
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/stratus_thin1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratus_thin2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratus_thin3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratus_thin4.xml";}
		else  {path = "Models/Weather/stratus_thin5.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/stratus_thin1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratus_thin2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratus_thin3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratus_thin4.xml";}
		else  {path = "Models/Weather/stratus_thin5.xml";}
		}	
	}
else if (type == "Fog (thick)") {
	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/stratus_thick1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratus_thick2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratus_thick3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratus_thick4.xml";}
		else  {path = "Models/Weather/stratus_thick5.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/stratus_thick1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratus_thick2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratus_thick3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratus_thick4.xml";}
		else  {path = "Models/Weather/stratus_thick5.xml";}
		}	
	}
else if (type == "Test") {path="Models/Weather/test.xml";}
else if (type == "Box_test") {
	if (subtype == "standard") {
		if (rn > 0.8) {path = "Models/Weather/test1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/test2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/test3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/test4.xml";}
		else  {path = "Models/Weather/test5.xml";}		
		}
	else if (subtype == "core") {
		if (rn > 0.8) {path = "Models/Weather/test_core1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/test_core2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/test_core3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/test_core4.xml";}
		else  {path = "Models/Weather/test_core5.xml";}		
		}
	else if (subtype == "bottom") {
		if (rn > 0.66) {path = "Models/Weather/test_bottom1.xml";}
		else if (rn > 0.33) {path = "Models/Weather/test_bottom2.xml";}
		else if (rn > 0.0) {path = "Models/Weather/test_bottom3.xml";}	
		}
	}


else {print("Cloud type ", type, " subtype ",subtype, " not available!");}

return path;
}




###########################################################
# place a single cloud into a vector to be processed
# separately
###########################################################

var create_cloud_vec = func(path, lat, long, alt, heading) {

append(clouds_path,path);
append(clouds_lat,lat);
append(clouds_lon,long);
append(clouds_alt,alt);
append(clouds_orientation,heading);

}
###########################################################
# clear all clouds and effects
###########################################################

var clear_all = func {

# clear the clouds and models

var cloudNode = props.globals.getNode(lw~"clouds", 1);
cloudNode.removeChildren("tile");

var modelNode = props.globals.getNode("models", 1).getChildren("model");

foreach (var m; modelNode)
	{
	var l = m.getNode("tile-index",1).getValue();
	if (l != nil)
		{
		m.remove();
		}
	}

cloudNode.getNode("cloud-number",1).setValue(0);

# clear effect volumes

props.globals.getNode("local-weather/effect-volumes", 1).removeChildren("effect-volume");

# clear weather stations

props.globals.getNode("local-weather/interpolation", 1).removeChildren("station");

# clear winds

props.globals.getNode("local-weather/interpolation", 1).removeChildren("wind");
setprop(lwi~"ipoint-number",0);

# reset pressure continuity

weather_tiles.last_pressure = 0.0;

# stop the effect loop and the interpolation loop, make sure thermal generation is off

setprop(lw~"effect-loop-flag",0);
setprop(lw~"interpolation-loop-flag",0);
setprop(lw~"tile-loop-flag",0);
setprop(lw~"lift-loop-flag",0);
setprop(lw~"dynamics-loop-flag",0);
setprop(lw~"timing-loop-flag",0);
setprop(lw~"tmp/generate-thermal-lift-flag",0); 

# also remove rain and snow effects

compat_layer.setRain(0.0);
compat_layer.setSnow(0.0);

# set placement indices to zero

setprop(lw~"clouds/placement-index",0);
setprop(lw~"clouds/model-placement-index",0);
setprop(lw~"effect-volumes/effect-placement-index",0);
setprop(lw~"effect-volumes/number",0);
setprop(lw~"tiles/tile-counter",0);

# remove any quadtrees and arrays

settimer ( func { setsize(weather_dynamics.cloudQuadtrees,0);},0.1); # to avoid error generation in this frame
setsize(effectVolumeArray,0);
n_effectVolumeArray = 0;

setsize(weather_tile_management.modelArrays,0);

}


###########################################################
# detailed Cumulus clouds created from multiple cloudlets
###########################################################

var create_detailed_cumulus_cloud = func (lat, lon, alt, size) {

#print(size);

var edge_bias = 0.0;
var size_bias = 0.0;

if (size > 2.0)
	{create_cumulonimbus_cloud(lat, lon, alt, size); return;}

else if (size>1.5)
	{
	var type = "Congestus";
	var btype = "Congestus bottom";
	var height = 400;
	var n = 8;
	var n_b = 4;
	var x = 1000.0;
	var y = 300.0;
	var edge = 0.3;
	}

else if (size>1.1)
	{
	var type = "Cumulus (cloudlet)";
	var btype = "Cumulus bottom";
	var height = 200;
	var n = 8;
	var n_b = 1;
	var x = 400.0;
	var y = 200.0;
	var edge = 0.3;
	}
else if (size>0.8)
	{
	var type = "Cumulus (cloudlet)";
	var height = 150;
	var n = 6;
	var x = 300.0;
	var y = 200.0;
	var edge = 0.3;
	}
else
	{
	var type = "Cumulus (cloudlet)";
	var btype = "Cumulus bottom";
	var height = 100;
	var n = 4;
	var x = 200.0;
	var y = 200.0;
	var edge = 1.0;
	}

var alpha = rand() * 180.0;

edge = edge + edge_bias;

create_streak(type,lat,lon, alt+ 0.5* (height +cloud_vertical_size_map["Cumulus"] * ft_to_m), height,n,0.0,edge,x,1,0.0,0.0,y,alpha,1.0);

# for large clouds, add a bottom

if ((size > 1.1) and (edge < 0.4))
	{
	create_streak(btype,lat,lon, alt, 100.0,n_b,0.0,edge,0.3*x,1,0.0,0.0,0.3*y,alpha,1.0);
	}

} 

###########################################################
# detailed small Cumulonimbus clouds created from multiple cloudlets
###########################################################

var create_cumulonimbus_cloud = func(lat, lon, alt, size) {

var height = 3000.0;
var alpha = rand() * 180.0;

create_streak("Cumulonimbus",lat,lon, alt+ 0.5* height, height,8,0.0,0.0,1600.0,1,0.0,0.0,800.0,alpha,1.0);

}

###########################################################
# wrappers for convective cloud system to distribute
# call across several frames if needed
###########################################################

var create_cumosys = func (blat, blon, balt, nc, size) {

# realistic Cumulus has somewhat larger models, so compensate to get the same coverage
if (getprop(lw~"config/detailed-clouds-flag") == 1) 
	{nc = int(0.7 * nc);}

if (getprop(lw~"tmp/thread-flag") ==  1)
	{setprop(lw~"tmp/convective-status", "computing");
	cumulus_loop(blat, blon, balt, nc, size);}

else
	{create_cumulus(blat, blon, balt, nc, size);
	print("Convective system done!");}
}



var cumulus_loop = func (blat, blon, balt, nc, size) {

var n = 25;

if (nc < 0) 
	{
	print("Convective system done!");
	setprop(lw~"tmp/convective-status", "idle");
	assemble_effect_array();
	return;
	}

#print("nc is now: ",nc);
create_cumulus(blat, blon, balt, n, size);

settimer( func {cumulus_loop(blat, blon, balt, nc-n, size) },0);
}

###########################################################
# place a convective cloud system
###########################################################

var create_cumulus = func (blat, blon, balt, nc, size) {



var path = "Models/Weather/blank.ac";
var i = 0;
var p = 0.0;
var rn = 0.0;
var place_lift_flag = 0;
var strength = 0.0;
var detail_flag = getprop(lw~"config/detailed-clouds-flag");

var alpha = getprop(lw~"tmp/tile-orientation-deg") * math.pi/180.0; # the tile orientation

var sec_to_rad = 2.0 * math.pi/86400; # conversion factor for sinusoidal dependence on daytime

calc_geo(blat);

# get the local time of the day in seconds

var t = getprop("sim/time/utc/day-seconds");
t = t + getprop("sim/time/local-offset");

# print("t is now:", t);

# and make a simple sinusoidal model of thermal strength

# daily variation in number of thermals, peaks at noon
var t_factor1 = 0.5 * (1.0-math.cos((t * sec_to_rad))); 

# daily variation in strength of thermals, peaks around 15:30
var t_factor2 = 0.5 * (1.0-math.cos((t * sec_to_rad)-0.9)); 

#print("t-factor1 is now: ",t_factor1, " ",t_factor2);

# number of possible thermals equals overall strength times daily variation times geographic variation
# this is a proxy for solar thermal energy

nc = t_factor1 * nc * math.cos(blat/180.0*math.pi); 

var thermal_conditions = getprop(lw~"config/thermal-properties");


while (i < nc) {

	p = 0.0;
	place_lift_flag = 0;
	strength = 0.0;

	# pick a trial position inside the tile and rotate by tile orientation angle
	var x = (2.0 * rand() - 1.0) * size;
	var y = (2.0 * rand() - 1.0) * size; 

	var lat = blat + (y * math.cos(alpha) - x * math.sin(alpha)) * m_to_lat;
	var lon = blon + (x * math.cos(alpha) + y * math.sin(alpha)) * m_to_lon;

	# now check ground cover type on chosen spot
	var info = geodinfo(lat, lon);

	if (info != nil) {
	var elevation = info[0] * m_to_ft;
	if (info[1] != nil){
         var landcover = info[1].names[0];
	 if (contains(landcover_map,landcover)) {p = p + landcover_map[landcover];}
	 else {print(p, " ", info[1].names[0]);}
	}}

	# then decide if the thermal energy at the spot generates an updraft and a cloud

	if (rand() < p) # we decide to place a cloud at this spot
		{
		strength = (1.5 * rand() + (2.0 * p)) * t_factor2; # the strength of thermal activity at the spot
		if (strength > 1.0)  
			{
			# we place a large cloud, and we generate lift
			path = select_cloud_model("Cumulus","large"); place_lift_flag = 1;
			}
		else {path = select_cloud_model("Cumulus","small");}

		# check if we have a terrain elevation analysis available and can use a 
		# detailed placement altitude correction

		if (getprop(lw~"tmp/presampling-flag") == 1) 
			{
			var place_alt = get_convective_altitude(balt, elevation);
			}
		else {var place_alt = balt;}


		if (getprop(lw~"tmp/generate-thermal-lift-flag") != 3) # no clouds if we produce blue thermals
			{		
			if (getprop(lw~"tmp/thread-flag") == 1)
				{
				if (detail_flag == 0){create_cloud_vec(path,lat,lon, place_alt, 0.0);}
				else {create_detailed_cumulus_cloud(lat, lon, place_alt, strength);}
				}
			else
				{
				if (detail_flag == 0){compat_layer.create_cloud(path, lat, lon, place_alt, 0.0);}
				else {create_detailed_cumulus_cloud(lat, lon, place_alt, strength);}
				}
			}	

		# now see if we need to create a thermal - first check the flag
		if (getprop(lw~"tmp/generate-thermal-lift-flag") == 1) # thermal by constant
			{
			# now check if convection is strong
			if (place_lift_flag == 1)
				{
				var lift = 3.0 + 10.0 * (strength -1.0);
				var radius = 500 + 500 * rand();
				#print("Lift: ", lift * ft_to_m - 1.0);
				create_effect_volume(1, lat, lon, radius, radius, 0.0, 0.0, place_alt+500.0, -1, -1, -1, -1, lift, 1);
				} # end if place_lift_flag		
			} # end if generate-thermal-lift-flag	
		else if ((getprop(lw~"tmp/generate-thermal-lift-flag") == 2) or (getprop(lw~"tmp/generate-thermal-lift-flag") == 3)) # thermal by function
			{

			if (place_lift_flag == 1)
				{
				#var lift = 3.0 + 20.0 * p *  rand();
				#var radius = 500 + 500 * rand();
				var lift = (3.0 + 10.0 * (strength -1.0))/thermal_conditions;
				var radius = (500 + 500 * rand())*thermal_conditions;
				#print("Lift: ", lift * ft_to_m - 1.0, " strength: ",strength);

				create_effect_volume(1, lat, lon, 1.1*radius, 1.1*radius, 0.0, 0.0, place_alt+500.0, -1, -1, -1, lift*0.02, lift, -2);
				} # end if place_lift_flag

			} # end if generate-thermal-lift-flag


		} # end if rand < p
	i = i + 1;
	} # end while

}

###########################################################
# place a Cumulus layer with excluded regions
# to avoid placing cumulus underneath a thunderstorm
###########################################################

var cumulus_exclusion_layer = func (blat, blon, balt, n, size_x, size_y, alpha, s_min, s_max, n_ex, exlat, exlon, exrad) {


var strength = 0;
var flag = 1;
var phi = alpha * math.pi/180.0;

var detail_flag = getprop(lw~"config/detailed-clouds-flag");

if (detail_flag == 1) {var i_max = int(0.25*n);} else {var i_max = int(1.0*n);}



for (var i =0; i< i_max; i=i+1)
	{
	var x = (2.0 * rand() - 1.0) * size_x;
	var y = (2.0 * rand() - 1.0) * size_y; 

	var lat = blat + (y * math.cos(phi) - x * math.sin(phi)) * m_to_lat;
	var lon = blon + (x * math.cos(phi) + y * math.sin(phi)) * m_to_lon;

	flag = 1;

	for (var j=0; j<n_ex; j=j+1)
		{
		if (calc_d_sq(lat, lon, exlat[j], exlon[j]) < (exrad[j] * exrad[j])) {flag = 0;}
		}
	if (flag == 1)
		{
		
		strength = s_min + rand() * (s_max - s_min);		
	
		if (strength > 1.0)  {var path = select_cloud_model("Cumulus","large"); }
		else {var path = select_cloud_model("Cumulus","small");}

		if (getprop(lw~"tmp/thread-flag") == 1)
			{
			if (detail_flag == 0){create_cloud_vec(path,lat,lon, balt, 0.0);}
			else {create_detailed_cumulus_cloud(lat, lon, balt, strength);}
			}
		else
			{
			if (detail_flag == 0){compat_layer.create_cloud(path, lat, lon, balt, 0.0);}
			else {create_detailed_cumulus_cloud(lat, lon, balt, strength);}
			}

		} # end if flag

	} # end for i

}


###########################################################
# place a barrier cloud system 
###########################################################

var create_rise_clouds = func (blat, blon, balt, nc, size, winddir, dist) {

var path = "Models/Weather/blank.ac";
var i = 0;
var p = 0.0;
var rn = 0.0;
var nsample = 10;
var counter = 0;
var elevation = 0.0;
var dir = (winddir + 180.0) * math.pi/180.0;
var step = dist/nsample;

calc_geo(blat);

while (i < nc) {

	counter = counter + 1;
	p = 0.0; 
	elevation=0.0;

	var x = (2.0 * rand() - 1.0) * size;
	var y = (2.0 * rand() - 1.0) * size; 

	var lat = blat + y * m_to_lat;
	var lon = blon + x * m_to_lon;

	var info = geodinfo(lat, lon);
	if (info != nil) {elevation = info[0] * m_to_ft;}
	


	if ((elevation < balt) and (elevation != 0.0))
	{
	for (var j = 0; j<nsample; j=j+1)
		{
		d = j * step;
		x = d * math.sin(dir);
		y = d * math.cos(dir);
		var tlat = lat + y * m_to_lat;
		var tlon = lon + x * m_to_lon;
		#info = geodinfo(tlat, tlon);
		#if (info != nil) {
		#	elevation = info[0] * m_to_ft;
		elevation = get_elevation(lat,lon);		
		if (elevation > balt)
			{
			p = 1.0 - j * (1.0/nsample);
			break;
			}
		
		}
	}
	if (counter > 500) {print("Cannot place clouds - exiting..."); i = nc;}
	if (rand() < p)
	{
		path = select_cloud_model("Altocumulus","large");
		#print("Cloud ",i, " after ",counter, " tries");
		compat_layer.create_cloud(path, lat, lon, balt, 0.0);
	counter = 0;
	i = i+1;
	}

	} # end while

}


###########################################################
# place a cloud streak 
###########################################################

var create_streak = func (type, blat, blong, balt, alt_var, nx, xoffset, edgex, x_var, ny, yoffset, edgey, y_var, direction, tri) {

var flag = 0;
var path = "Models/Weather/blank.ac";
calc_geo(blat);
var dir = direction * math.pi/180.0;

var ymin = -0.5 * ny * yoffset;
var xmin = -0.5 * nx * xoffset;
var xinc = xoffset * (tri-1.0) /ny;
 
var jlow = int(nx*edgex);
var ilow = int(ny*edgey);


for (var i=0; i<ny; i=i+1)
	{
	var y = ymin + i * yoffset; 
	
	for (var j=0; j<nx; j=j+1)
		{
		var y0 = y + y_var * 2.0 * (rand() -0.5);
		var x = xmin + j * (xoffset + i * xinc) + x_var * 2.0 * (rand() -0.5);
		var lat = blat + m_to_lat * (y0 * math.cos(dir) - x * math.sin(dir));
		var long = blong + m_to_lon * (x * math.cos(dir) + y0 * math.sin(dir));

		var alt = balt + alt_var * 2 * (rand() - 0.5);
		
		flag = 0;
		var rn = 6.0 * rand();

		if (((j<jlow) or (j>(nx-jlow-1))) and ((i<ilow) or (i>(ny-ilow-1)))) # select a small or no cloud		
			{
			if (rn > 2.0) {flag = 1;} else {path = select_cloud_model(type,"small");}
			}
		if ((j<jlow) or (j>(nx-jlow-1)) or (i<ilow) or (i>(ny-ilow-1))) 	
			{
			if (rn > 5.0) {flag = 1;} else {path = select_cloud_model(type,"small");}
			}
		else	{ # select a large cloud
			if (rn > 5.0) {flag = 1;} else {path = select_cloud_model(type,"large");}
			}


		if (flag==0){
			if (getprop(lw~"tmp/thread-flag") == 1)
				{create_cloud_vec(path, lat, long, alt, 0.0);}
			else
				{compat_layer.create_cloud(path, lat, long, alt, 0.0);}
			

				}
		}

	} 

}


###########################################################
# place a cloud layer 
###########################################################

var create_layer = func (type, blat, blon, balt, bthick, rx, ry, phi, density, edge, rainflag, rain_density) {


var i = 0;
var area = math.pi * rx * ry;
var circ = math.pi * (rx + ry); # that's just an approximation
var n = int(area/80000000.0 * 100 * density);
var m = int(circ/63000.0 * 40 * rain_density);
var path = "Models/Weather/blank.ac";

phi = phi * math.pi/180.0;

if (contains(cloud_vertical_size_map, type)) 
		{var alt_offset = cloud_vertical_size_map[type]/2.0 * m_to_ft;}
	else {var alt_offset = 0.0;}

while(i<n)
	{
	var x = rx * (2.0 * rand() - 1.0); 
	var y = ry * (2.0 * rand() - 1.0); 
	var alt = balt + bthick * rand() + 0.8 * alt_offset;
	var res = (x*x)/(rx*rx) + (y*y)/(ry*ry);

	if (res < 1.0)
		{
		var lat = blat + m_to_lat * (y * math.cos(phi) - x * math.sin(phi));
		var lon = blon + m_to_lon * (x * math.cos(phi) + y * math.sin(phi));
		if (res > ((1.0 - edge) * (1.0- edge)))
			{
			if (rand() > 0.4) {
				path = select_cloud_model(type,"small");
				compat_layer.create_cloud(path, lat, lon, alt, 0.0);
				}
			}
		else {
			path = select_cloud_model(type,"large");
			if (getprop(lw~"tmp/thread-flag") == 1)
				{create_cloud_vec(path, lat, lon, alt, 0.0);}
			else 
				{compat_layer.create_cloud(path, lat, lon, alt, 0.0);}
			}
		i = i + 1;
		}
	}

i = 0;

if (rainflag ==1){

	while(i<m)
		{
		var alpha = rand() * 2.0 * math.pi;
		x = 0.8 * (1.0 - edge) * (1.0-edge) * rx * math.cos(alpha);
		y = 0.8 * (1.0 - edge) * (1.0-edge) * ry * math.sin(alpha);

		lat = blat + m_to_lat * (y * math.cos(phi) - x * math.sin(phi));
		lon = blon + m_to_lon * (x * math.cos(phi) + y * math.sin(phi));	
	
		path = "Models/Weather/rain1.xml";
 		if (contains(cloud_vertical_size_map,type)) {var alt_shift = cloud_vertical_size_map[type];}
		else {var alt_shift = 0.0;}
		
		if (getprop(lw~"tmp/thread-flag") == 1)
		{create_cloud_vec(path, lat, lon,balt +0.5*bthick+ alt_shift, 0.0);}		
		else		
		{compat_layer.create_cloud(path, lat, lon, balt + 0.5 * bthick + alt_shift, 0.0);}
		i = i + 1;
		} # end while	
	} # end if (rainflag ==1)
}


###########################################################
# place a cloud layer with a gap in the middle
# (useful to reduce cloud count in large thunderstorms)
###########################################################

var create_hollow_layer = func (type, blat, blon, balt, bthick, rx, ry, phi, density, edge, gap_fraction) {


var i = 0;
var area = math.pi * rx * ry;
var n = int(area/80000000.0 * 100 * density);
var path = "Models/Weather/blank.ac";

phi = phi * math.pi/180.0;

if (contains(cloud_vertical_size_map, type)) 
		{var alt_offset = cloud_vertical_size_map[type]/2.0 * m_to_ft;}
	else {var alt_offset = 0.0;}

while(i<n)
	{
	var x = rx * (2.0 * rand() - 1.0); 
	var y = ry * (2.0 * rand() - 1.0); 
	var alt = balt + bthick * rand() + 0.8 * alt_offset;
	var res = (x*x)/(rx*rx) + (y*y)/(ry*ry);
	

	if ((res < 1.0) and (res > (gap_fraction * gap_fraction)))
		{
		var lat = blat + m_to_lat * (y * math.cos(phi) - x * math.sin(phi));
		var lon = blon + m_to_lon * (x * math.cos(phi) + y * math.sin(phi));
		if (res > ((1.0 - edge) * (1.0- edge)))
			{
			if (rand() > 0.4) {
				path = select_cloud_model(type,"small");
				compat_layer.create_cloud(path, lat, lon, alt, 0.0);
				}
			}
		else {
			path = select_cloud_model(type,"large");
			if (getprop(lw~"tmp/thread-flag") == 1)
				{create_cloud_vec(path, lat, lon, alt, 0.0);}
			else 
				{compat_layer.create_cloud(path, lat, lon, alt, 0.0);}
			}
		i = i + 1;
		}
	else	# we are in the central gap region
		{
		i = i + 1;
		}
	}

i = 0;


}




###########################################################
# place a cloud box
###########################################################


var create_cloudbox = func (type, blat, blon, balt, dx,dy,dz,n, f_core, r_core, h_core, n_core, f_bottom, h_bottom, n_bottom) {

var phi = 0;

# first get core coordinates

var core_dx = dx * f_core;
var core_dy = dy * f_core;
var core_dz = dz * h_core;

var core_x_offset = (1.0 * rand() - 0.5) *  ((dx - core_dx) * r_core);
var core_y_offset = (1.0 * rand() - 0.5) *  ((dy - core_dy) * r_core);

# get the bottom geometry

var bottom_dx = dx * f_bottom;
var bottom_dy = dy * f_bottom;
var bottom_dz = dz * h_bottom;

var bottom_offset = 400.0; # in practice, need a small shift

# fill the main body of the box

for (var i=0; i<n; i=i+1)
	{

	var x = 0.5 * dx * (2.0 * rand() - 1.0); 
	var y = 0.5 * dy * (2.0 * rand() - 1.0);
	
	# veto in core region
	if ((x > core_x_offset - 0.5 * core_dx) and (x < core_x_offset + 0.5 * core_dx))
		{
		if ((y > core_y_offset - 0.5 * core_dy) and (y < core_y_offset + 0.5 * core_dy))
			{
			i = i -1;
			continue;
			}
		}
	 
	var alt = balt + bottom_dz + bottom_offset +  dz * rand();
	
	var lat = blat + m_to_lat * (y * math.cos(phi) - x * math.sin(phi));
	var lon = blon + m_to_lon * (x * math.cos(phi) + y * math.sin(phi));

	var path = select_cloud_model(type,"standard");

	if (getprop(lw~"tmp/thread-flag") == 1)
			{create_cloud_vec(path, lat, lon, alt, 0.0);}
		else
			{compat_layer.create_cloud(path, lat, lon, alt, 0.0);}

	}

# fill the core region

for (var i=0; i<n_core; i=i+1)
	{
	var x = 0.5 * core_dx * (2.0 * rand() - 1.0); 
	var y = 0.5 * core_dy * (2.0 * rand() - 1.0);
	var alt = balt + bottom_dz + bottom_offset + core_dz * rand();


	var lat = blat + m_to_lat * (y * math.cos(phi) - x * math.sin(phi));
	var lon = blon + m_to_lon * (x * math.cos(phi) + y * math.sin(phi));

	var path = select_cloud_model(type,"core");

	if (getprop(lw~"tmp/thread-flag") == 1)
			{create_cloud_vec(path, lat, lon, alt, 0.0);}
		else
			{compat_layer.create_cloud(path, lat, lon, alt, 0.0);}

	}

# fill the bottom region


for (var i=0; i<n_bottom; i=i+1)
	{
	var x = 0.5 * bottom_dx * (2.0 * rand() - 1.0); 
	var y = 0.5 * bottom_dy * (2.0 * rand() - 1.0);
	var alt = balt + bottom_dz * rand();


	var lat = blat + m_to_lat * (y * math.cos(phi) - x * math.sin(phi));
	var lon = blon + m_to_lon * (x * math.cos(phi) + y * math.sin(phi));

	var path = select_cloud_model(type,"bottom");

	if (getprop(lw~"tmp/thread-flag") == 1)
			{create_cloud_vec(path, lat, lon, alt, 0.0);}
		else
			{compat_layer.create_cloud(path, lat, lon, alt, 0.0);}

	}


}



###########################################################
# terrain presampling initialization
###########################################################

var terrain_presampling_start = func (blat, blon, nc, size, alpha) {

var thread_flag = getprop(lw~"tmp/thread-flag");

# initialize the result vector

setsize(terrain_n,20);
for(var j=0;j<20;j=j+1){terrain_n[j]=0;}

if (thread_flag == 1)
	{
	var status = getprop(lw~"tmp/presampling-status");
	if (status != "idle") # we try a second later
		{
		settimer( func {terrain_presampling_start(blat, blon, nc, size, alpha);},1.00);
		return;
		}
	else	
		{
		setprop(lw~"tmp/presampling-status", "sampling");
		terrain_presampling_loop (blat, blon, nc, size, alpha);
		}
	}
else
	{
	terrain_presampling(blat, blon, nc, size, alpha);
	terrain_presampling_analysis();
	setprop(lw~"tmp/presampling-status", "finished");
	}
}

###########################################################
# terrain presampling loop
###########################################################

var terrain_presampling_loop = func (blat, blon, nc, size, alpha) {

var n = 25; # number of geoinfo calls per frame

if (nc <= 0) # we're done and may analyze the result
	{
	terrain_presampling_analysis();
	print("Presampling done!");
	setprop(lw~"tmp/presampling-status", "finished");
	return;
	}

terrain_presampling(blat, blon, n, size, alpha);

settimer( func {terrain_presampling_loop(blat, blon, nc-n, size, alpha) },0);
}


###########################################################
# terrain presampling routine
###########################################################

var terrain_presampling = func (blat, blon, ntries, size, alpha) {

var phi = alpha * math.pi/180.0;
var elevation = 0.0;

var lat_vec = [];
var lon_vec = [];


for (var i=0; i<ntries; i=i+1)
	{
	var x = (2.0 * rand() - 1.0) * size;
	var y = (2.0 * rand() - 1.0) * size; 

	#var lat = blat + (y * math.cos(phi) - x * math.sin(phi)) * m_to_lat;
	#var lon = blon + (x * math.cos(phi) + y * math.sin(phi)) * m_to_lon;

	append(lat_vec, blat + (y * math.cos(phi) - x * math.sin(phi)) * m_to_lat);
	append(lon_vec, blon + (x * math.cos(phi) + y * math.sin(phi)) * m_to_lon);
	}
	
var elevation_vec = compat_layer.get_elevation_array(lat_vec, lon_vec);

	#var info = geodinfo(lat, lon);
	#if (info != nil) {elevation = info[0] * m_to_ft;}
	
for (i=0; i<ntries;i=i+1)
	{
	for(j=0;j<20;j=j+1)
		{
		if ((elevation_vec[i] != -1.0) and (elevation_vec[i] < 500.0 * (j+1))) 
			{terrain_n[j] = terrain_n[j]+1;  break;}
		}
		
	}



}

###########################################################
# terrain presampling analysis
###########################################################

var terrain_presampling_analysis = func {

var sum = 0;
var alt_mean = 0;
var alt_med = 0;
var alt_20 = 0;
var alt_min = 0;
var alt_low_min = 0;
var alt_offset = 0;

# for (var i=0;i<20;i=i+1){print(500.0*i," ",terrain_n[i]);}

for (var i=0; i<20;i=i+1)
	{sum = sum + terrain_n[i];}

var n_tot = sum;

sum = 0;
for (var i=0; i<20;i=i+1)
	{
	sum = sum + terrain_n[i];
	if (sum > int(0.5 *n_tot)) {alt_med = i * 500.0; break;}		
	}

sum = 0;
for (var i=0; i<20;i=i+1)
	{
	sum = sum + terrain_n[i];
	if (sum > int(0.3 *n_tot)) {alt_20 = i * 500.0; break;}		
	}


for (var i=0; i<20;i=i+1) {alt_mean = alt_mean + terrain_n[i] * i * 500.0;}
alt_mean = alt_mean/n_tot;

for (var i=0; i<20;i=i+1) {if (terrain_n[i] > 0) {alt_min = i * 500.0; break;}}

var n_max = 0;
sum = 0;

for (var i=0; i<19;i=i+1) 
	{
	sum = sum + terrain_n[i];
	if (terrain_n[i] > n_max) {n_max = terrain_n[i];}
	if ((n_max > terrain_n[i+1]) and (sum > int(0.3*n_tot)))
 		{alt_low_min = i * 500; break;}
	}

print("Terrain presampling analysis results:");
print("total: ",n_tot," mean: ",alt_mean," median: ",alt_med," min: ",alt_min, " alt_20: ", alt_20);

#if (alt_low_min < alt_med) {alt_offset = alt_low_min;}
#else {alt_offset = alt_med;}

setprop(lw~"tmp/tile-alt-offset-ft",alt_20);
setprop(lw~"tmp/tile-alt-median-ft",alt_med);
setprop(lw~"tmp/tile-alt-min-ft",alt_min);
setprop(lw~"tmp/tile-alt-layered-ft",0.5 * (alt_min + alt_offset));

append(alt_50_array, alt_med);

}

###########################################################
# detailed altitude determination for convective calls
# clouds follow the terrain to some degree, but not excessively so
###########################################################

var get_convective_altitude = func (balt, elevation) {


var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");
var alt_median = getprop(lw~"tmp/tile-alt-median-ft");

# get the maximal shift
var alt_variation = alt_median - alt_offset;

# get the difference between offset and foot point
var alt_diff = elevation - alt_offset;

# now get the elevation-induced shift

var fraction = alt_diff / alt_variation;

if (fraction > 1.0) {fraction = 1.0;} # no placement above maximum shift
if (fraction < 0.0) {fraction = 0.0;} # no downward shift

# get the cloud base

var cloudbase = balt - alt_offset;

var alt_above_terrain = balt - elevation;

# the shift strength is weakened if the layer is high above base elevation
# the reference altitude is 1000 ft, anything higher has less sensitivity to terrain

var shift_strength = 1000.0/alt_above_terrain; 

if (shift_strength > 1.0) {shift_strength = 1.0;} # no enhancement for very low layers 
if (shift_strength < 0.0) {shift_strength = 0.0;} # this shouldn't happen, but just in case...

return balt + shift_strength * alt_diff * fraction;

}

###########################################################
# terrain presampling listener dispatcher
###########################################################

var manage_presampling = func {

var status = getprop(lw~"tmp/presampling-status");

# we only take action when the analysis is done
if (status != "finished") {return;} 

if (getprop(lw~"tiles/tile-counter") == 0) # we deal with a tile setup call from the menu
	{
	set_tile();
	}
else	# the tile setup call came from weather_tile_management
	{
	var lat = getprop(lw~"tiles/tmp/latitude-deg");
	var lon = getprop(lw~"tiles/tmp/longitude-deg");
	var code = getprop(lw~"tiles/tmp/code");
	var dir_index = getprop(lw~"tiles/tmp/dir-index");	

	weather_tile_management.generate_tile(code, lat, lon, dir_index);
	}


# set status to idle again

setprop(lw~"tmp/presampling-status", "idle");

}

###########################################################
# set wind model flag
###########################################################

var set_wind_model_flag = func {

var wind_model = getprop(lw~"config/wind-model");

if (wind_model == "constant") {wind_model_flag = 1;}
else if (wind_model == "constant in tile") {wind_model_flag =2;}
else if (wind_model == "aloft interpolated") {wind_model_flag =3; }
else if (wind_model == "airmass interpolated") {wind_model_flag =4;}
else if (wind_model == "aloft waypoints") {wind_model_flag =5;}
else {print("Wind model not implemented!"); wind_model_flag =1;}


}


###########################################################
# create an effect volume
###########################################################

var create_effect_volume = func (geometry, lat, lon, r1, r2, phi, alt_low, alt_high, vis, rain, snow, turb, lift, lift_flag) {

var flag = 0;

var index = getprop(lw~"effect-volumes/effect-placement-index");

var n = props.globals.getNode("local-weather/effect-volumes", 1);
		for (var i = index; 1; i += 1)
			if (n.getChild("effect-volume", i, 0) == nil)
				break;

	setprop(lw~"effect-volumes/effect-placement-index",i);


ev = n.getChild("effect-volume", i, 1);

ev.getNode("geometry", 1).setValue(geometry);
ev.getNode("active-flag", 1).setValue(0);
ev.getNode("position/latitude-deg", 1).setValue(lat);
ev.getNode("position/longitude-deg", 1).setValue(lon);
ev.getNode("position/min-altitude-ft", 1).setValue(alt_low);
ev.getNode("position/max-altitude-ft", 1).setValue(alt_high);
ev.getNode("volume/size-x", 1).setValue(r1);
ev.getNode("volume/size-y", 1).setValue(r2);
ev.getNode("volume/orientation-deg", 1).setValue(phi);
ev.getNode("tile-index",1).setValue(getprop(lw~"tiles/tile-counter"));

var flag = 1;
if (vis < 0.0) {flag = 0;}
ev.getNode("effects/visibility-flag", 1).setValue(flag);
ev.getNode("effects/visibility-m", 1).setValue(vis);

flag = 1;
if (rain < 0.0) {flag = 0;}
ev.getNode("effects/rain-flag", 1).setValue(flag);
ev.getNode("effects/rain-norm", 1).setValue(rain);

flag = 1;
if (snow < 0.0) {flag = 0;}
ev.getNode("effects/snow-flag", 1).setValue(flag);
ev.getNode("effects/snow-norm", 1).setValue(snow);

flag = 1;
if (snow < 0.0) {flag = 0;}
ev.getNode("effects/snow-flag", 1).setValue(flag);
ev.getNode("effects/snow-norm", 1).setValue(snow);

flag = 1;
if (turb < 0.0) {flag = 0;}
ev.getNode("effects/turbulence-flag", 1).setValue(flag);
ev.getNode("effects/turbulence", 1).setValue(turb);

flag = 1;
if (lift_flag == 0) {flag = 0;}
ev.getNode("effects/thermal-lift-flag", 1).setValue(flag);
ev.getNode("effects/thermal-lift", 1).setValue(lift);

flag = 1;
if (lift_flag == -2) # we create a thermal by function
	{
	ev.getNode("effects/thermal-lift-flag", 1).setValue(2);
	ev.getNode("effects/radius",1 ).setValue(0.8*r1);
	ev.getNode("effects/height",1).setValue(alt_high);
	ev.getNode("effects/cn",1).setValue(0.8);
	ev.getNode("effects/sh",1).setValue(0.8);
	ev.getNode("effects/max_lift",1).setValue(lift);
	ev.getNode("effects/f_lift_radius",1).setValue(0.8);
	}

# set a timestamp if needed

if (getprop(lw~"config/dynamics-flag") == 1)
	{
	ev.getNode("timestamp-sec",1).setValue(weather_dynamics.time_lw);
	}

# and add to the counter
setprop(lw~"effect-volumes/number",getprop(lw~"effect-volumes/number")+1);
}





###########################################################
# set a weather station for interpolation
###########################################################

var set_weather_station = func (lat, lon, vis, T, D, p) {

var n = props.globals.getNode(lwi, 1);
		for (var i = 0; 1; i += 1)
			if (n.getChild("station", i, 0) == nil)
				break;

s = n.getChild("station", i, 1);

s.getNode("latitude-deg",1).setValue(lat);
s.getNode("longitude-deg",1).setValue(lon);
s.getNode("visibility-m",1).setValue(vis);
s.getNode("temperature-degc",1).setValue(T);
s.getNode("dewpoint-degc",1).setValue(D);
s.getNode("pressure-sea-level-inhg",1).setValue(p);
s.getNode("tile-index",1).setValue(getprop(lw~"tiles/tile-counter"));

# set a timestamp if needed

if (getprop(lw~"config/dynamics-flag") == 1)
	{
	s.getNode("timestamp-sec",1).setValue(weather_dynamics.time_lw);
	}

}


###########################################################
# set a wind interpolation point
###########################################################

var set_wind_ipoint = func (lat, lon, d0, v0, d1, v1, d2, v2, d3, v3, d4, v4, d5, v5, d6, v6, d7, v7, d8, v8) {

var n = props.globals.getNode(lwi, 1);
		for (var i = 0; 1; i += 1)
			if (n.getChild("wind", i, 0) == nil)
				break;

s = n.getChild("wind", i, 1);

s.getNode("latitude-deg",1).setValue(lat);
s.getNode("longitude-deg",1).setValue(lon);

s.getChild("altitude",0,1).getNode("wind-from-heading-deg",1).setValue(d0);
s.getChild("altitude",0,1).getNode("windspeed-kt",1).setValue(v0);

s.getChild("altitude",1,1).getNode("wind-from-heading-deg",1).setValue(d1);
s.getChild("altitude",1,1).getNode("windspeed-kt",1).setValue(v1);

s.getChild("altitude",2,1).getNode("wind-from-heading-deg",1).setValue(d2);
s.getChild("altitude",2,1).getNode("windspeed-kt",1).setValue(v2);

s.getChild("altitude",3,1).getNode("wind-from-heading-deg",1).setValue(d3);
s.getChild("altitude",3,1).getNode("windspeed-kt",1).setValue(v3);

s.getChild("altitude",4,1).getNode("wind-from-heading-deg",1).setValue(d4);
s.getChild("altitude",4,1).getNode("windspeed-kt",1).setValue(v4);

s.getChild("altitude",5,1).getNode("wind-from-heading-deg",1).setValue(d5);
s.getChild("altitude",5,1).getNode("windspeed-kt",1).setValue(v5);

s.getChild("altitude",6,1).getNode("wind-from-heading-deg",1).setValue(d6);
s.getChild("altitude",6,1).getNode("windspeed-kt",1).setValue(v6);

s.getChild("altitude",7,1).getNode("wind-from-heading-deg",1).setValue(d7);
s.getChild("altitude",7,1).getNode("windspeed-kt",1).setValue(v7);

s.getChild("altitude",8,1).getNode("wind-from-heading-deg",1).setValue(d8);
s.getChild("altitude",8,1).getNode("windspeed-kt",1).setValue(v8);

}

###########################################################
# helper to show additional dialogs
###########################################################

var showDialog = func (name) {

fgcommand("dialog-show", props.Node.new({"dialog-name":name}));

}

###########################################################
# wrappers to call functions from the local weather menu bar 
###########################################################

var streak_wrapper = func {

setprop(lw~"tmp/thread-flag", 0);
setprop(lw~"config/dynamics-flag",0);

var array = [];
append(weather_tile_management.modelArrays,array);
setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
var type = getprop("/local-weather/tmp/cloud-type");
var alt = getprop("/local-weather/tmp/alt");
var nx = getprop("/local-weather/tmp/nx");
var xoffset = getprop("/local-weather/tmp/xoffset");
var xedge = getprop("/local-weather/tmp/xedge");
var ny = getprop("/local-weather/tmp/ny");
var yoffset = getprop("/local-weather/tmp/yoffset");
var yedge = getprop("/local-weather/tmp/yedge");
var dir = getprop("/local-weather/tmp/dir");
var tri = getprop("/local-weather/tmp/tri");
var rnd_alt = getprop("/local-weather/tmp/rnd-alt");
var rnd_pos_x = getprop("/local-weather/tmp/rnd-pos-x");
var rnd_pos_y = getprop("/local-weather/tmp/rnd-pos-y");

create_streak(type,lat,lon,alt,rnd_alt,nx,xoffset,xedge,rnd_pos_x,ny,yoffset,yedge,rnd_pos_y,dir,tri);
}


var convection_wrapper = func {

setprop(lw~"tmp/thread-flag", 0);
setprop(lw~"config/dynamics-flag",0);

var array = [];
append(weather_tile_management.modelArrays,array);
setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
var alt = getprop("/local-weather/tmp/conv-alt");
var size = getprop("/local-weather/tmp/conv-size");
var strength = getprop("/local-weather/tmp/conv-strength");

var n = int(10 * size * size * strength);
create_cumosys(lat,lon,alt,n, size*1000.0);

}

var barrier_wrapper = func {

setprop(lw~"tmp/thread-flag", 0);
setprop(lw~"config/dynamics-flag",0);

var array = [];
append(weather_tile_management.modelArrays,array);
setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
var alt = getprop("/local-weather/tmp/bar-alt");
var n = getprop("/local-weather/tmp/bar-n");
var dir = getprop("/local-weather/tmp/bar-dir");
var dist = getprop("/local-weather/tmp/bar-dist") * 1000.0;
var size = getprop("/local-weather/tmp/bar-size") * 1000.0;

create_rise_clouds(lat, lon, alt, n, size, dir, dist);

}

var single_cloud_wrapper = func {

setprop(lw~"config/dynamics-flag",0);

var array = [];
append(weather_tile_management.modelArrays,array);
setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);

var type = getprop("/local-weather/tmp/scloud-type");
var subtype = getprop("/local-weather/tmp/scloud-subtype");
var lat = getprop("/local-weather/tmp/scloud-lat");
var lon = getprop("/local-weather/tmp/scloud-lon");
var alt = getprop("/local-weather/tmp/scloud-alt");
var heading = getprop("/local-weather/tmp/scloud-dir");

var path = select_cloud_model(type,subtype);

compat_layer.create_cloud(path, lat, lon, alt, heading);

}

var layer_wrapper = func {

setprop(lw~"config/dynamics-flag",0);
setprop(lw~"tmp/thread-flag", 0);

var array = [];
append(weather_tile_management.modelArrays,array);
setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
var type = getprop(lw~"tmp/layer-type");
var rx = getprop(lw~"tmp/layer-rx") * 1000.0;
var ry = getprop(lw~"tmp/layer-ry") * 1000.0;
var phi = getprop(lw~"tmp/layer-phi");
var alt = getprop(lw~"tmp/layer-alt");
var thick = getprop(lw~"tmp/layer-thickness");
var density = getprop(lw~"tmp/layer-density");
var edge = getprop(lw~"tmp/layer-edge");
var rain_flag = getprop(lw~"tmp/layer-rain-flag");
var rain_density = getprop(lw~"tmp/layer-rain-density");

create_layer(type, lat, lon, alt, thick, rx, ry, phi, density, edge, rain_flag, rain_density);

}

var box_wrapper = func {

setprop(lw~"tmp/thread-flag", 0);
setprop(lw~"config/dynamics-flag",0);

setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
var alt = getprop("position/altitude-ft");
var x = getprop(lw~"tmp/box-x-m");
var y = getprop(lw~"tmp/box-y-m");
var z = getprop(lw~"tmp/box-alt-ft");
var n = getprop(lw~"tmp/box-n");
var f_core = getprop(lw~"tmp/box-core-fraction");
var r_core = getprop(lw~"tmp/box-core-offset");
var h_core = getprop(lw~"tmp/box-core-height");
var n_core = getprop(lw~"tmp/box-core-n");
var f_bottom = getprop(lw~"tmp/box-bottom-fraction");
var h_bottom = getprop(lw~"tmp/box-bottom-thickness");
var n_bottom = getprop(lw~"tmp/box-bottom-n");

var type = "Box_test";


#create_cloudbox(type,subtype,lat, lon, alt, x,y,z,n);

create_cloudbox(type, lat, lon, alt, x,y,z,n, f_core, r_core, h_core, n_core, f_bottom, h_bottom, n_bottom);

}


var set_aloft_wrapper = func {



var lat = getprop(lw~"tmp/ipoint-latitude-deg");
var lon = getprop(lw~"tmp/ipoint-longitude-deg");

var d0 = getprop(lw~"tmp/FL0-wind-from-heading-deg");
var v0 = getprop(lw~"tmp/FL0-windspeed-kt");

var d1 = getprop(lw~"tmp/FL50-wind-from-heading-deg");
var v1 = getprop(lw~"tmp/FL50-windspeed-kt");

var d2 = getprop(lw~"tmp/FL100-wind-from-heading-deg");
var v2 = getprop(lw~"tmp/FL100-windspeed-kt");

var d3 = getprop(lw~"tmp/FL180-wind-from-heading-deg");
var v3 = getprop(lw~"tmp/FL180-windspeed-kt");

var d4 = getprop(lw~"tmp/FL240-wind-from-heading-deg");
var v4 = getprop(lw~"tmp/FL240-windspeed-kt");

var d5 = getprop(lw~"tmp/FL300-wind-from-heading-deg");
var v5 = getprop(lw~"tmp/FL300-windspeed-kt");

var d6 = getprop(lw~"tmp/FL340-wind-from-heading-deg");
var v6 = getprop(lw~"tmp/FL340-windspeed-kt");

var d7 = getprop(lw~"tmp/FL390-wind-from-heading-deg");
var v7 = getprop(lw~"tmp/FL390-windspeed-kt");

var d8 = getprop(lw~"tmp/FL450-wind-from-heading-deg");
var v8 = getprop(lw~"tmp/FL450-windspeed-kt");

set_wind_ipoint(lat, lon, d0, v0, d1, v1, d2, v2, d3, v3, d4, v4, d5, v5, d6, v6, d7, v7, d8, v8);

if (wind_model_flag == 5)
{setprop(lwi~"ipoint-number", getprop(lwi~"ipoint-number") + 1);}

}

####################################
# tile setup call wrapper
####################################

var set_tile = func {

var type = getprop("/local-weather/tmp/tile-type");

# set tile center coordinates to current position

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");

setprop(lw~"tiles/tmp/latitude-deg",lat);
setprop(lw~"tiles/tmp/longitude-deg",lon);


# now see if we need to presample the terrain

if ((getprop(lw~"tmp/presampling-flag") == 1) and (getprop(lw~"tmp/presampling-status") == "idle")) 
	{
	terrain_presampling_start(lat, lon, 1000, 40000, getprop(lw~"tmp/tile-orientation-deg")); 
	return;
	}





# see if we need to create an aloft wind interpolation structure

if ((wind_model_flag == 3) or ((wind_model_flag ==5) and (getprop(lwi~"ipoint-number") == 0))) 
	{set_aloft_wrapper();}


# prepare the first tile wind field

if (wind_model_flag == 5) # it needs to be interpolated
	{
	var res = wind_interpolation(lat,lon,0.0);

	append(weather_dynamics.tile_wind_direction,res[0]);
	append(weather_dynamics.tile_wind_speed,res[1]);

	}
else if (wind_model_flag == 3) # it comes from a different menu
	{
	append(weather_dynamics.tile_wind_direction, getprop(lw~"tmp/FL0-wind-from-heading-deg"));
	append(weather_dynamics.tile_wind_speed, getprop(lw~"tmp/FL0-windspeed-kt"));
	}
else # it comes from the standard menu
	{
	append(weather_dynamics.tile_wind_direction, getprop(lw~"tmp/tile-orientation-deg"));
	append(weather_dynamics.tile_wind_speed, getprop(lw~"tmp/windspeed-kt"));
	}

# when the aloft wind menu is used, the lowest winds should be taken from there
# so we need to overwrite the setting from the tile generating menu in this case
# otherwise the wrong orientation is built


if (wind_model_flag ==3)
	{
	setprop(lw~"tmp/tile-orientation-deg", getprop(lw~"tmp/FL0-wind-from-heading-deg"));
	}
else if (wind_model_flag == 5) 
	{
	setprop(lw~"tmp/tile-orientation-deg", weather_dynamics.tile_wind_direction[0]);
	}


# create all the neighbouring tile coordinate sets

weather_tile_management.create_neighbours(lat,lon,getprop(lw~"tmp/tile-orientation-deg"));


# see if we use METAR for weather setup

if ((getprop(lw~"METAR/available-flag") == 1) and (getprop(lw~"tmp/tile-management") == "METAR"))
	{type = "METAR";}

setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);


# see if we need to generate a quadtree structure for clouds 

if (getprop(lw~"config/dynamics-flag") ==1)
	{
	var quadtree = [];
	weather_dynamics.generate_quadtree_structure(0, quadtree);
	append(weather_dynamics.cloudQuadtrees,quadtree);
	}


	

if (type == "High-pressure-core")
	{weather_tiles.set_high_pressure_core_tile();}
else if (type == "High-pressure")
	{weather_tiles.set_high_pressure_tile();}
else if (type == "High-pressure-border")
	{weather_tiles.set_high_pressure_border_tile();}
else if (type == "Low-pressure-border")
	{weather_tiles.set_low_pressure_border_tile();}
else if (type == "Low-pressure")
	{weather_tiles.set_low_pressure_tile();}
else if (type == "Low-pressure-core")
	{weather_tiles.set_low_pressure_core_tile();}
else if (type == "Cold-sector")
	{weather_tiles.set_cold_sector_tile();}
else if (type == "Warm-sector")
	{weather_tiles.set_warm_sector_tile();}
else if (type == "Tropical")
	{weather_tiles.set_tropical_weather_tile();}
else if (type == "Coldfront")
	{weather_tiles.set_coldfront_tile();}
else if (type == "Warmfront")
	{weather_tiles.set_warmfront1_tile();}
else if (type == "Warmfront-2")
	{weather_tiles.set_warmfront2_tile();}
else if (type == "Warmfront-3")
	{weather_tiles.set_warmfront3_tile();}
else if (type == "Warmfront-4")
	{weather_tiles.set_warmfront4_tile();}
else if (type == "METAR")
	{weather_tiles.set_METAR_tile();}
else if (type == "Altocumulus sky")
	{weather_tiles.set_altocumulus_tile();setprop(lw~"tiles/code","altocumulus_sky");}
else if (type == "Broken layers") 
	{weather_tiles.set_broken_layers_tile();setprop(lw~"tiles/code","broken_layers");}
else if (type == "Cold front")
	{weather_tiles.set_coldfront_tile();setprop(lw~"tiles/code","coldfront");}
else if (type == "Cirrus sky")
	{weather_tiles.set_cirrus_sky_tile();setprop(lw~"tiles/code","cirrus_sky");}
else if (type == "Fair weather")
	{setprop(lw~"tiles/code","cumulus_sky");weather_tiles.set_fair_weather_tile();}
else if (type == "Glider's sky")
	{setprop(lw~"tiles/code","gliders_sky");weather_tiles.set_gliders_sky_tile();}
else if (type == "Blue thermals")
	{setprop(lw~"tiles/code","blue_thermals");weather_tiles.set_blue_thermals_tile();}
else if (type == "Incoming rainfront")
	{weather_tiles.set_rainfront_tile();setprop(lw~"tiles/code","rainfront");}
else if (type == "8/8 stratus sky")
	{weather_tiles.set_overcast_stratus_tile();setprop(lw~"tiles/code","overcast_stratus");}
else if (type == "Test tile")
	{weather_tiles.set_4_8_stratus_tile();setprop(lw~"tiles/code","test");}
else if (type == "Summer rain")
	{weather_tiles.set_summer_rain_tile();setprop(lw~"tiles/code","summer_rain");}
else 
	{print("Tile not implemented.");setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")-1);return();}


# start tile management loop if needed

if (getprop(lw~"tmp/tile-management") != "single tile") {
	if (getprop(lw~"tile-loop-flag") == 0) 
	{
	setprop(lw~"tiles/tile[4]/code",getprop(lw~"tiles/code"));
	setprop(lw~"tile-loop-flag",1); 
	weather_tile_management.tile_management_loop();}
	}

# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}

# start the effect volume loop

if (getprop(lw~"effect-loop-flag") == 0) 
{setprop(lw~"effect-loop-flag",1); local_weather.effect_volume_loop(0,0);}

# start weather dynamics loops if needed


if (getprop(lw~"config/dynamics-flag") ==1)
	{
	if (getprop(lw~"timing-loop-flag") == 0) 
	{setprop(lw~"timing-loop-flag",1); weather_dynamics.timing_loop();}

	if (getprop(lw~"dynamics-loop-flag") == 0) 
		{
		setprop(lw~"dynamics-loop-flag",1); 
		weather_dynamics.quadtree_loop(); 
		weather_dynamics.weather_dynamics_loop(0);
		}

	}

}


#################################################
# Anything that needs to run at startup goes here
#################################################

var startup = func {
print("Loading local weather routines...");

# get local Cartesian geometry

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
calc_geo(lat);


# copy weather properties at startup to local weather

setprop(lw~"interpolation/visibility-m",getprop(ec~"boundary/entry[0]/visibility-m"));
setprop(lw~"interpolation/pressure-sea-level-inhg",getprop(ec~"boundary/entry[0]/pressure-sea-level-inhg"));
setprop(lw~"interpolation/temperature-degc",getprop(ec~"boundary/entry[0]/temperature-degc"));
setprop(lw~"interpolation/wind-from-heading-deg",getprop(ec~"boundary/entry[0]/wind-from-heading-deg"));
setprop(lw~"interpolation/wind-speed-kt",getprop(ec~"boundary/entry[0]/wind-speed-kt"));
setprop(lw~"interpolation/turbulence",getprop(ec~"boundary/entry[0]/turbulence/magnitude-norm"));

setprop(lw~"interpolation/rain-norm",0.0);
setprop(lw~"interpolation/snow-norm",0.0);
setprop(lw~"interpolation/thermal-lift",0.0);


# before interpolation starts, these are also initially current

setprop(lw~"current/visibility-m",getprop(lwi~"visibility-m"));
setprop(lw~"current/pressure-sea-level-inhg",getprop(lw~"interpolation/pressure-sea-level-inhg"));
setprop(lw~"current/temperature-degc",getprop(lw~"interpolation/temperature-degc"));
setprop(lw~"current/wind-from-heading-deg",getprop(lw~"interpolation/wind-from-heading-deg"));
setprop(lw~"current/wind-speed-kt",getprop(lw~"interpolation/wind-speed-kt"));
setprop(lw~"current/rain-norm",getprop(lw~"interpolation/rain-norm"));
setprop(lw~"current/snow-norm",getprop(lw~"interpolation/snow-norm"));
setprop(lw~"current/thermal-lift",getprop(lw~"interpolation/thermal-lift"));
setprop(lw~"current/turbulence",getprop(lwi~"turbulence"));

# create default properties for METAR system, should be overwritten by real-weather-fetch

setprop(lw~"METAR/latitude-deg",lat); 
setprop(lw~"METAR/longitude-deg",lon);
setprop(lw~"METAR/altitude-ft",0.0);
setprop(lw~"METAR/wind-direction-deg",0.0);
setprop(lw~"METAR/wind-strength-kt",10.0);
setprop(lw~"METAR/visibility-m",17000.0);
setprop(lw~"METAR/rain-norm",0.0);
setprop(lw~"METAR/snow-norm",0.0);
setprop(lw~"METAR/temperature-degc",10.0);
setprop(lw~"METAR/dewpoint-degc",7.0);
setprop(lw~"METAR/pressure-inhg",29.92);
setprop(lw~"METAR/thunderstorm-flag",0);
setprop(lw~"METAR/layer[0]/cover-oct",4);
setprop(lw~"METAR/layer[0]/alt-agl-ft", 3000.0);
setprop(lw~"METAR/layer[1]/cover-oct",0);
setprop(lw~"METAR/layer[1]/alt-agl-ft", 20000.0);
setprop(lw~"METAR/layer[2]/cover-oct",0);
setprop(lw~"METAR/layer[2]/alt-agl-ft", 20000.0);
setprop(lw~"METAR/layer[3]/cover-oct",0);
setprop(lw~"METAR/layer[3]/alt-agl-ft", 20000.0);
setprop(lw~"METAR/available-flag",1);


# set listener for worker threads

setlistener(lw~"tmp/thread-status", func {var s = size(clouds_path); compat_layer.create_cloud_array(s, clouds_path, clouds_lat, clouds_lon, clouds_alt, clouds_orientation); });
setlistener(lw~"tmp/convective-status", func {var s = size(clouds_path); compat_layer.create_cloud_array(s, clouds_path, clouds_lat, clouds_lon, clouds_alt, clouds_orientation); });
setlistener(lw~"tmp/effect-thread-status", func {var s = size(effects_geo);  effect_placement_loop(s); });
setlistener(lw~"tmp/presampling-status", func {manage_presampling(); });

setlistener(lw~"config/wind-model", func {set_wind_model_flag();});

}


#####################################################
# Standard test call (for development and debug only)
#####################################################

var test = func {

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");

showDialog("local_weather_winds");

#weather_dynamics.cos_beta = 1;
#weather_dynamics.sin_beta = 0;
#weather_dynamics.tan_vangle = 0.3;

#weather_dynamics.plane_x = 0.0;
#weather_dynamics.plane_y = 0.0;



#for (var i=0; i<16; i=i+1)
#	{
#	var pix = [];
#	for (var j=0; j<16; j=j+1)
#		{
#		var x = -18750.0 + j * 2500.0;
#		var y = 18750.0 - i * 2500.0;
#		append(pix,weather_dynamics.check_visibility(x,y,2500.0));
#		}
#	print(pix[0],pix[1],pix[2],pix[3],pix[4],pix[5],pix[6],pix[7],pix[8],pix[9],pix[10],pix[11],pix[12],pix[13],pix[14],pix[15]);
#	}

#print(weather_dynamics.check_visibility(0,0,0,8000.0,10000));
#print(weather_dynamics.check_visibility(0,0,0,15000.0,2500));
#print(weather_dynamics.check_visibility(0,0,0,-15000.0,2500));
#print(weather_dynamics.check_visibility(0,0,7000,5000.0,2500));




# terrain_presampling_start(lat, lon, 1000, 20000, 0.0);

# test: 8 identical position tuples for KSFO
#var p=[ 37.6189722, -122.3748889,   37.6189722, -122.3748889,
#        37.6289722, -122.3748889,   37.6189722, -122.3648889,
#        37.6389722, -122.3748889,   37.6189722, -122.3548889,
#        37.6489722, -122.3748889,   37.6189722, -122.3448889 ];
#
#var x=geodinfo(p, 10000); # passing in vector with position tuples

#foreach(var e;x) {
#  print("Elevation:",e);  # showing results
#}




}

#################################################################
# global variable, property creation and the startup listener
#################################################################

var rad_E = 6378138.12;	# earth radius
var lat_to_m = 110952.0; # latitude degrees to meters
var m_to_lat = 9.01290648208234e-06; # meters to latitude degrees
var ft_to_m = 0.30480;
var m_to_ft = 1.0/ft_to_m;

var lon_to_m = 0.0; # needs to be calculated dynamically
var m_to_lon = 0.0; # we do this on startup

# some common abbreviations

var lw = "/local-weather/";
var lwi = "/local-weather/interpolation/";
var ec = "/environment/config/";

# a hash map of the strength for convection associated with terrain types

var landcover_map = {BuiltUpCover: 0.35, Town: 0.35, Freeway:0.35, BarrenCover:0.3, HerbTundraCover: 0.25, GrassCover: 0.2, CropGrassCover: 0.2, Sand: 0.25, Grass: 0.2, Ocean: 0.01, Marsh: 0.05, Lake: 0.01, ShrubCover: 0.15, Landmass: 0.2, CropWoodCover: 0.15, MixedForestCover: 0.1, DryCropPastureCover: 0.25, MixedCropPastureCover: 0.2, IrrCropPastureCover: 0.15, DeciduousBroadCover: 0.1, pa_taxiway : 0.35, pa_tiedown: 0.35, pc_taxiway: 0.35, pc_tiedown: 0.35, Glacier: 0.01, DryLake: 0.3, IntermittentStream: 0.2};

# a hash map of average vertical cloud model sizes

var cloud_vertical_size_map = {Altocumulus: 700.0, Cumulus: 600.0, Nimbus: 1000.0, Stratus: 800.0, Stratus_structured: 600.0, Stratus_thin: 400.0, Cirrocumulus: 200.0};

# the array of aloft wind interpolation altitudes

var wind_altitude_array = [0.0, 5000.0, 10000.0, 18000.0, 24000.0, 30000.0, 34000.0, 39000.0, 45000.0];

# storage arrays for cloud generation

var clouds_path = [];
var clouds_lat = [];
var clouds_lon = [];
var clouds_alt = [];
var clouds_orientation = [];


# storage arrays for terrain presampling and results

var terrain_n = [];
var alt_50_array = [];


# array of currently existing effect volumes

var effectVolumeArray = [];
var n_effectVolumeArray = 0;

# a flag for the wind model (so we don't have to do string comparisons all the time)
# 1: constant 2: constant in tile 3: aloft interpolated 4: airmass interpolated

var wind_model_flag = 1;


# set all sorts of default properties for the menu

setprop(lw~"tmp/cloud-type", "Altocumulus");
setprop(lw~"tmp/alt", 12000.0);
setprop(lw~"tmp/nx",5);
setprop(lw~"tmp/xoffset",800.0);
setprop(lw~"tmp/xedge", 0.2);
setprop(lw~"tmp/ny",15);
setprop(lw~"tmp/yoffset",800.0);
setprop(lw~"tmp/yedge", 0.2);
setprop(lw~"tmp/dir",0.0);
setprop(lw~"tmp/tri", 1.0);
setprop(lw~"tmp/rnd-pos-x",400.0);
setprop(lw~"tmp/rnd-pos-y",400.0);
setprop(lw~"tmp/rnd-alt", 300.0);
setprop(lw~"tmp/conv-strength", 1);
setprop(lw~"tmp/conv-size", 15.0);
setprop(lw~"tmp/conv-alt", 2000.0);
setprop(lw~"tmp/bar-alt", 3500.0);
setprop(lw~"tmp/bar-n", 150.0);
setprop(lw~"tmp/bar-dir", 0.0);
setprop(lw~"tmp/bar-dist", 5.0);
setprop(lw~"tmp/bar-size", 10.0);
setprop(lw~"tmp/scloud-type", "Altocumulus");
setprop(lw~"tmp/scloud-subtype", "small");
setprop(lw~"tmp/scloud-lat",getprop("position/latitude-deg"));
setprop(lw~"tmp/scloud-lon",getprop("position/longitude-deg"));
setprop(lw~"tmp/scloud-alt", 5000.0);
setprop(lw~"tmp/scloud-dir", 0.0);
setprop(lw~"tmp/layer-type","Nimbus");
setprop(lw~"tmp/layer-rx",10.0);
setprop(lw~"tmp/layer-ry",10.0);
setprop(lw~"tmp/layer-phi",0.0);
setprop(lw~"tmp/layer-alt",3000.0);
setprop(lw~"tmp/layer-thickness",500.0);
setprop(lw~"tmp/layer-density",1.0);
setprop(lw~"tmp/layer-edge",0.2);
setprop(lw~"tmp/layer-rain-flag",1);
setprop(lw~"tmp/layer-rain-density",1.0);
setprop(lw~"tmp/box-x-m",600.0);
setprop(lw~"tmp/box-y-m",600.0);
setprop(lw~"tmp/box-alt-ft",300.0);
setprop(lw~"tmp/box-n",10);
setprop(lw~"tmp/box-core-fraction",0.4);
setprop(lw~"tmp/box-core-offset",0.2);
setprop(lw~"tmp/box-core-height",1.4);
setprop(lw~"tmp/box-core-n",3);
setprop(lw~"tmp/box-bottom-fraction",0.9);
setprop(lw~"tmp/box-bottom-thickness",0.5);
setprop(lw~"tmp/box-bottom-n",12);
setprop(lw~"tmp/tile-type", "High-pressure");
setprop(lw~"tmp/tile-orientation-deg", 0.0);
setprop(lw~"tmp/windspeed-kt", 8.0);
setprop(lw~"tmp/tile-alt-offset-ft", 0.0);
setprop(lw~"tmp/tile-alt-median-ft",0.0);
setprop(lw~"tmp/tile-alt-min-ft",0.0);
setprop(lw~"tmp/tile-management", "single tile");
setprop(lw~"tmp/generate-thermal-lift-flag", 0);
setprop(lw~"tmp/presampling-flag", 1);
setprop(lw~"tmp/asymmetric-tile-loading-flag", 0);
setprop(lw~"tmp/thread-flag", 1);
setprop(lw~"tmp/last-reading-pos-del",0);
setprop(lw~"tmp/last-reading-pos-mod",0);
setprop(lw~"tmp/thread-status", "idle");
setprop(lw~"tmp/convective-status", "idle");
setprop(lw~"tmp/presampling-status", "idle");
setprop(lw~"tmp/FL0-wind-from-heading-deg",0.0);
setprop(lw~"tmp/FL0-windspeed-kt",8.0);
setprop(lw~"tmp/FL50-wind-from-heading-deg",2.0);
setprop(lw~"tmp/FL50-windspeed-kt",11.0);
setprop(lw~"tmp/FL100-wind-from-heading-deg",4.0);
setprop(lw~"tmp/FL100-windspeed-kt",16.0);
setprop(lw~"tmp/FL180-wind-from-heading-deg",5.0);
setprop(lw~"tmp/FL180-windspeed-kt",24.0);
setprop(lw~"tmp/FL240-wind-from-heading-deg",9.0);
setprop(lw~"tmp/FL240-windspeed-kt",35.0);
setprop(lw~"tmp/FL300-wind-from-heading-deg",13.0);
setprop(lw~"tmp/FL300-windspeed-kt",45.0);
setprop(lw~"tmp/FL340-wind-from-heading-deg",14.0);
setprop(lw~"tmp/FL340-windspeed-kt",50.0);
setprop(lw~"tmp/FL390-wind-from-heading-deg",13.0);
setprop(lw~"tmp/FL390-windspeed-kt",56.0);
setprop(lw~"tmp/FL450-wind-from-heading-deg",12.0);
setprop(lw~"tmp/FL450-windspeed-kt",65.0);
setprop(lw~"tmp/ipoint-latitude-deg",getprop("position/latitude-deg"));
setprop(lw~"tmp/ipoint-longitude-deg",getprop("position/longitude-deg"));


# set config values

setprop(lw~"config/distance-to-load-tile-m",35000.0);
setprop(lw~"config/distance-to-remove-tile-m",37000.0);
setprop(lw~"config/detailed-clouds-flag",1);
setprop(lw~"config/dynamics-flag",1);
setprop(lw~"config/thermal-properties",1.0);
setprop(lw~"config/wind-model","constant");

# set the default loop flags to loops inactive


setprop(lw~"effect-loop-flag",0);
setprop(lw~"interpolation-loop-flag",0);
setprop(lw~"tile-loop-flag",0);
setprop(lw~"lift-loop-flag",0);

# create other management properties

setprop(lw~"clouds/cloud-number",0);
setprop(lw~"clouds/placement-index",0);
setprop(lw~"clouds/model-placement-index",0);
setprop(lw~"effect-volumes/effect-placement-index",0);

# create properties for effect volume management

setprop(lw~"effect-volumes/number",0);
setprop(lw~"effect-volumes/number-active-vis",0);
setprop(lw~"effect-volumes/number-active-rain",0);
setprop(lw~"effect-volumes/number-active-snow",0);
setprop(lw~"effect-volumes/number-active-turb",0);
setprop(lw~"effect-volumes/number-active-lift",0);



# create properties for tile management

setprop(lw~"tiles/tile-counter",0);

# create properties for wind

setprop(lwi~"ipoint-number",0);


# wait for Nasal to be available and do what is in startup()

_setlistener("/sim/signals/nasal-dir-initialized", func {
	startup();
});

