
########################################################
# routines to set up, transform and manage local weather
# Thorsten Renk, May 2010
# thermal model by Patrice Poly, April 2010
########################################################

# function			purpose
#
# calc_geo			to compute the latitude to meter conversion
# calc_d_sq			to compute a distance square in local Cartesian approximation
# volume_effect_loop		to check if the aircraft has entered an effect volume
# interpolation_loop		to continuously interpolate weather parameters between stations 
# thermal_lift _loop		to manage the detailed thermal lift model
# thermal_lift_start		to start the detailed thermal model
# effect_volume_start		to manage parameters when an effect volume is entered
# effect_volume_stop		to manage parameters when an effect volume is left
# setVisibility			to set the visibility to a given value
# setRain			to set rain to a given value
# setSnow			to set snow to a given value
# setTemperature		to set temperature to a given value
# setPressure			to set pressure to a given value
# setDewpoint			to set the dewpoint to a given value
# setLift			to set thermal lift to a given value - obsolete
# ts_factor			(helper function for thermal lift model)
# tl_factor			(helper function for thermal lift model)
# calcLift_max			to calculate the maximal available thermal lift for given altitude
# calcLift			to calculate the thermal lift at aircraft position
# randomize_pos			to randomize the position of clouds placed in a streak call
# select_cloud_model		to select a path to the cloud model, given the cloud type and subtype
# create_cloud			to place a single cloud into the scenery
# create_cloud_vec		to place a single cloud into an array to be written later
# clear_all			to remove all clouds, effect volumes and weather stations and stop loops
# create_detailed_cumulus_cloud	to place multiple cloudlets into a box based on a size parameter
# create_cumulonimbus_cloud	to place multiple cloudlets into a box 
# create_cumosys		wrapper to place a convective cloud system based on terrain coverage
# cumulus_loop			to place 25 Cumulus clouds each frame
# create_cumulus		to place a convective cloud system based on terrain coverage
# terrain_presampling		to get information about terrain elevation
# create_rise_clouds		to create a barrier cloud system
# create_streak			to create a cloud streak
# create_layer			to create a cloud layer with optional precipitation
# cloud_placement_loop		to place clouds from a storage array into the scenery
# create_effect_volume		to create an effect volume
# effect_placement_loop		to place effect volumes from a storage array
# create_effect_volume_vec	to create effect volumes in a storage array
# set_weather_station		to specify a weather station for interpolation
# streak_wrapper		wrapper to execute streak from menu
# convection wrapper		wrapper to execute convective clouds from menu
# barrier wrapper 		wrapper to execute barrier clouds from menu
# single_cloud_wrapper		wrapper to create single cloud from menu
# layer wrapper			wrapper to create layer from menu
# set_tile			to call a weather tile creation from menu
# startup			to prepare the package at startup

###################################
# geospatial helper functions
###################################

var calc_geo = func(clat) {

lon_to_m  = math.cos(clat*math.pi/180.0) * lat_to_m;
m_to_lon = 1.0/lon_to_m;

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
var evNode = props.globals.getNode("local-weather/effect-volumes", 1).getChildren("effect-volume");
var esize = size(evNode);

var viewpos = geo.aircraft_position();
var active_counter = n_active;

var i_max = index + 25;
if (i_max > esize) {i_max = esize;}

for (var i = index; i < i_max; i = i+1)
	{
	e = evNode[i];

	
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

#if (getprop(lw~"effect-loop-flag") ==1) {settimer(effect_volume_loop, 1.0);}
#if (getprop(lw~"effect-loop-flag") ==1) {settimer(effect_volume_loop, 0);}

if (getprop(lw~"effect-loop-flag") ==1) {settimer( func {effect_volume_loop(i, active_counter); },0);}
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

vis = vis + 0.5 * getprop("position/altitude-ft");

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
	setVisibility(vis);
	}

flag = props.globals.getNode("local-weather/effect-volumes/number-active-turb").getValue();
if ((flag ==0))
	{
	cNode.getNode("turbulence").setValue(0.0);
	setTurbulence(0.0);
	}


flag = props.globals.getNode("local-weather/effect-volumes/number-active-lift").getValue();
if (flag ==0) 
	{
	cNode.getNode("thermal-lift").setValue(0.0);
	}

# no need to check for these, as they are not modelled in effect volumes

cNode.getNode("temperature-degc",1).setValue(T);
setTemperature(T);

cNode.getNode("dewpoint-degc",1).setValue(D);
setDewpoint(D);

if (p>0.0) {cNode.getNode("pressure-sea-level-inhg",1).setValue(p); setPressure(p);}


if (getprop(lw~"interpolation-loop-flag") ==1) {settimer(interpolation_loop, 3.0);}

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

lNode.getNode("latitude-deg",1).setValue(ev.getNode("position/latitude-deg").getValue());
lNode.getNode("longitude-deg",1).setValue(ev.getNode("position/longitude-deg").getValue());

# and start the lift loop, unless another one is already running
# so we block overlapping calls

if (getprop(lw~"lift-loop-flag") == 0) 
{setprop(lw~"lift-loop-flag",1); thermal_lift_loop();}

}

###################################
# thermal lift loop stop
###################################

var thermal_lift_stop = func {

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
	setVisibility(vis);

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
	setRain(rain);
	ev.getNode("restore/number-entry-rain",1).setValue(getprop(lw~"effect-volumes/number-active-rain"));
	setprop(lw~"effect-volumes/number-active-rain",getprop(lw~"effect-volumes/number-active-rain")+1);
	}

if (ev.getNode("effects/snow-flag", 1).getValue()==1)
	{
	var snow = ev.getNode("effects/snow-norm").getValue();
	ev.getNode("restore/snow-norm",1).setValue(cNode.getNode("snow-norm").getValue());
	cNode.getNode("snow-norm").setValue(snow);
	setSnow(snow);
	ev.getNode("restore/number-entry-snow",1).setValue(getprop(lw~"effect-volumes/number-active-snow"));
	setprop(lw~"effect-volumes/number-active-snow",getprop(lw~"effect-volumes/number-active-snow")+1);
	}

if (ev.getNode("effects/turbulence-flag", 1).getValue()==1)
	{
	var turbulence = ev.getNode("effects/turbulence").getValue();
	ev.getNode("restore/turbulence",1).setValue(cNode.getNode("turbulence").getValue());
	cNode.getNode("turbulence").setValue(turbulence);
	setTurbulence(turbulence);
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
	setVisibility(vis);
	
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
	setRain(rain);
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
	setSnow(snow);
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
	setTurbulence(turbulence);
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
# randomize positions of clouds created in a fixed pattern 
###########################################################

var randomize_pos = func (type, alt_var, pos_var_x, pos_var_y, dir) {

# it is rather stupid coding to force the randomization call after the streak call, and I'll probably
# restructure the whole thing soon

dir = dir * math.pi/180.0;


if (getprop(lw~"tmp/thread-flag") == 1)
	{
	var s = size(clouds_type);
	for (i=0; i<s; i=i+1)
		{
		if (clouds_type[i] == "tmp_cloud")
			{
			var x = pos_var_x * 2.0 * (rand() -0.5);
			var y = pos_var_y * 2.0 * (rand() -0.5);
			clouds_lat[i] = clouds_lat[i] + m_to_lat * (y * math.cos(dir) - x * math.sin(dir));
			clouds_lon[i] = clouds_lon[i] + m_to_lon * (x * math.cos(dir) + y * math.sin(dir));
			clouds_alt[i] = clouds_alt[i] + alt_var * 2 * (rand() - 0.5);
			clouds_type[i] = type;
			}

		if (type=="Cumulonimbus (rain)") # we add a rain model
		{	
			var path = "Models/Weather/rain2.xml";	
			create_cloud_vec("Rain", path, clouds_lat[i], clouds_lon[i], clouds_alt[i], 0.0, 0);	
			create_effect_volume(1, clouds_lat[i], clouds_lon[i], 2000.0, 2000.0, 0.0, 0.0, clouds_alt[i], 8000, 0.3, -1, -1, -1,0);
		}


		}
	
	}
else 	
	{
	var tile_counter = getprop(lw~"tiles/tile-counter");
	var cloudNode = props.globals.getNode("local-weather/clouds", 1).getChild("tile",tile_counter,1).getChildren("cloud");
	foreach (var e; cloudNode) {
	var name = e.getNode("type",1).getValue();
	

	if (name=="tmp_cloud")
	{
	var e_lat = e.getNode("position/latitude-deg");
	var e_long = e.getNode("position/longitude-deg");
	var e_alt = e.getNode("position/altitude-ft");

	var slat = e_lat.getValue();
	var slon = e_long.getValue();
	var salt = e_alt.getValue();	

	var x = pos_var_x * 2.0 * (rand() -0.5);
	var y = pos_var_y * 2.0 * (rand() -0.5);

	slat = slat + m_to_lat * (y * math.cos(dir) - x * math.sin(dir));
	slon = slon + m_to_lon * (x * math.cos(dir) + y * math.sin(dir));


	salt = (salt + alt_var * 2 * (rand() - 0.5));

	e_lat.setValue(slat);
	e_long.setValue(slon);
	e_alt.setValue(salt);
	
	e.getNode("type").setValue(type);

	if (type=="Cumulonimbus (rain)") # we add a rain model
		{	
		var path = "Models/Weather/rain2.xml";	
		create_cloud("Rain", path, slat, slon, salt, 0.0, 0);	
		create_effect_volume(1, slat, slon, 2000.0, 2000.0, 0.0, 0.0, salt, 8000, 0.3, -1, -1, -1,0);
		}
	} # end if
	} # end foreach
	} # end else

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
		if (rn > 0.8) {path = "Models/Weather/cumulus_sl7.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulus_sl8.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulus_sl9.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulus_sl10.xml";}
		#else if (rn > 0.1) {path = "Models/Weather/cumulus_hires_small1.xml";}
		else  {path = "Models/Weather/cumulus_sl11.xml";}
		#if (rn > 0.83) {path = "Models/Weather/cumulus_hires_small1.xml";}
		#else if (rn > 0.664) {path = "Models/Weather/cumulus_hires_small2.xml";}
		#else if (rn > 0.5) {path = "Models/Weather/cumulus_hires_small3.xml";}
		#else if (rn > 0.332) {path = "Models/Weather/cumulus_hires_small4.xml";}
		#else if (rn > 0.166) {path = "Models/Weather/cumulus_hires_small5.xml";}
		#else if (rn > 0.0) {path = "Models/Weather/cumulus_hires_small6.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/cumulus_sl1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulus_sl2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulus_sl3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulus_sl4.xml";}
		else  {path = "Models/Weather/cumulus_sl5.xml";}
		#if (rn > 0.75) {path = "Models/Weather/cumulus_hires1.xml";}
		#else if (rn > 0.5) {path = "Models/Weather/cumulus_hires2.xml";}
		#if (rn > 0.0) {path = "Models/Weather/cumulus_hires3a.xml";}
		#else if (rn > 0.0) {path = "Models/Weather/cumulus_hires4.xml";}
		#else if (rn > 0.0) {path = "Models/Weather/cumulus_hires5.xml";}
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
		if (rn > 0.75) {path = "Models/Weather/cirrocumulus_hires1.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cirrocumulus_hires2.xml";}
		else if (rn > 0.25) {path = "Models/Weather/cirrocumulus_hires3.xml";}
		else  {path = "Models/Weather/cirrocumulus_hires4.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.75) {path = "Models/Weather/cirrocumulus_hires1.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cirrocumulus_hires2.xml";}
		else if (rn > 0.25) {path = "Models/Weather/cirrocumulus_hires3.xml";}
		else  {path = "Models/Weather/cirrocumulus_hires4.xml";}
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
		if (rn > 0.8) {path = "Models/Weather/test1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/test2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/test3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/test4.xml";}
		else  {path = "Models/Weather/test5.xml";}
			
	}


else {print("Cloud type ", type, " subtype ",subtype, " not available!");}

return path;
}


###########################################################
# place a single cloud 
###########################################################

var create_cloud = func(type, path, lat, long, alt, heading, rnd_flag) {

var tile_counter = getprop(lw~"tiles/tile-counter");

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



cl.getNode("type", 1).setValue(type);
var latN = cl.getNode("position/latitude-deg", 1); latN.setValue(lat);
var lonN = cl.getNode("position/longitude-deg", 1); lonN.setValue(long);
var altN = cl.getNode("position/altitude-ft", 1); altN.setValue(alt);
var hdgN = cl.getNode("orientation/true-heading-deg", 1); hdgN.setValue(heading);
var pitchN = cl.getNode("orientation/pitch-deg", 1); pitchN.setValue(0.0);
var rollN = cl.getNode("orientation/roll-deg", 1);rollN.setValue(0.0);

cl.getNode("tile-index",1).setValue(tile_counter);

model.getNode("path", 1).setValue(path);
model.getNode("legend", 1).setValue("Cloud");
model.getNode("latitude-deg-prop", 1).setValue(latN.getPath());
model.getNode("longitude-deg-prop", 1).setValue(lonN.getPath());
model.getNode("elevation-ft-prop", 1).setValue(altN.getPath());
model.getNode("heading-deg-prop", 1).setValue(hdgN.getPath());
model.getNode("pitch-deg-prop", 1).setValue(pitchN.getPath());
model.getNode("roll-deg-prop", 1).setValue(rollN.getPath());
model.getNode("tile-index",1).setValue(tile_counter);
model.getNode("load", 1).remove();

n.getNode("cloud-number").setValue(n.getNode("cloud-number").getValue()+1);

}


###########################################################
# place a single cloud into a vector to be processed
# in a split loop
###########################################################

var create_cloud_vec = func(type, path, lat, long, alt, heading, rain_flag) {

append(clouds_type,type);
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
	var l = m.getNode("legend").getValue();
	if (l == "Cloud")
		{
		m.remove();
		}
	}

cloudNode.getNode("cloud-number",1).setValue(0);

# clear effect volumes

props.globals.getNode("local-weather/effect-volumes", 1).removeChildren("effect-volume");

# clear weather stations

props.globals.getNode("local-weather/interpolation", 1).removeChildren("station");

# reset pressure continuity

weather_tiles.last_pressure = 0.0;

# stop the effect loop and the interpolation loop, make sure thermal generation is off

setprop(lw~"effect-loop-flag",0);
setprop(lw~"interpolation-loop-flag",0);
setprop(lw~"tile-loop-flag",0);
setprop(lw~"lift-loop-flag",0);
setprop(lw~"tmp/generate-thermal-lift-flag",0); 

# also remove rain and snow effects

setRain(0.0);
setSnow(0.0);

# set placement indices to zero

setprop(lw~"clouds/placement-index",0);
setprop(lw~"clouds/model-placement-index",0);
setprop(lw~"effect-volumes/effect-placement-index",0);
setprop(lw~"tiles/tile-counter",0);



}


###########################################################
# detailed Cumulus clouds created from multiple cloudlets
###########################################################

var create_detailed_cumulus_cloud = func (lat, lon, alt, size) {

#print(size);

if (size > 2.0)
	{create_cumulonimbus_cloud(lat, lon, alt, size); return;}

else if (size>1.5)
	{
	var height = 1000;
	var n = 30;
	var x = 700.0;
	var y = 300.0;
	var edge = 0.3;
	}

else if (size>1.0)
	{
	var height = 400;
	var n = 8;
	var x = 400.0;
	var y = 200.0;
	var edge = 0.3;
	}
else
	{
	var height = 100;
	var n = 4;
	var x = 200.0;
	var y = 200.0;
	var edge = 1.0;
	}

var alpha = rand() * 180.0;



create_streak("Cumulus (cloudlet)",lat,lon, alt+ 0.5* (height +cloud_vertical_size_map["Cumulus"] * ft_to_m),n,0.0,edge,1,0.0,0.0,alpha,1.0);
randomize_pos("Cumulus (cloudlet)",height,x,y,alpha);

} 

###########################################################
# detailed small Cumulonimbus clouds created from multiple cloudlets
###########################################################

var create_cumulonimbus_cloud = func(lat, lon, alt, size) {

var height = 3000.0;
var alpha = rand() * 180.0;

create_streak("Cumulonimbus",lat,lon, alt+ 0.5* height,8,0.0,0.0,1,0.0,0.0,alpha,1.0);
randomize_pos("Cumulonimbus",height,1600.0,800.0,alpha);

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

if (nc < 0) {print("Convective system done!");setprop(lw~"tmp/convective-status", "idle");return;}

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
				if (detail_flag == 0){create_cloud_vec("Cumulus",path,lat,lon, place_alt, 0.0, 0);}
				else {create_detailed_cumulus_cloud(lat, lon, place_alt, strength);}
				}
			else
				{
				if (detail_flag == 0){create_cloud("Cumulus", path, lat, lon, place_alt, 0.0, 0);}
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
			if (detail_flag == 0){create_cloud_vec("Cumulus",path,lat,lon, balt, 0.0, 0);}
			else {create_detailed_cumulus_cloud(lat, lon, balt, strength);}
			}
		else
			{
			if (detail_flag == 0){create_cloud("Cumulus", path, lat, lon, balt, 0.0, 0);}
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
		info = geodinfo(tlat, tlon);
		if (info != nil) {
			elevation = info[0] * m_to_ft;
			if (elevation > balt)
				{
				p = 1.0 - j * (1.0/nsample);
				break;
				}
			}
		
		}
	}
	if (counter > 500) {print("Cannot place clouds - exiting..."); i = nc;}
	if (rand() < p)
	{
		path = select_cloud_model("Altocumulus","large");
		#print("Cloud ",i, " after ",counter, " tries");
		create_cloud("Altocumulus", path, lat, lon, balt, 0.0, 0);
	counter = 0;
	i = i+1;
	}

	} # end while

}


###########################################################
# place a cloud streak 
###########################################################

var create_streak = func (type, blat, blong, balt, nx, xoffset, edgex, ny, yoffset, edgey, direction, tri) {

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
	#print("xmax is now:", ny * (xoffset + i * xinc));
	
	for (var j=0; j<nx; j=j+1)
		{
		var x = xmin + j * (xoffset + i * xinc);
		var lat = blat + m_to_lat * (y * math.cos(dir) - x * math.sin(dir));
		var long = blong + m_to_lon * (x * math.cos(dir) + y * math.sin(dir));
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

		#if (rand() > 0.5) {var beta = 0.0;} else {var beta = 180.0;}

		if (flag==0){
			if (getprop(lw~"tmp/thread-flag") == 1)
				{create_cloud_vec("tmp_cloud", path, lat, long, balt, 0.0, 0);}
			else
				{create_cloud("tmp_cloud", path, lat, long, balt, 0.0, 0);}
			

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
				create_cloud(type, path, lat, lon, alt, 0.0, 0);
				}
			}
		else {
			path = select_cloud_model(type,"large");
			if (getprop(lw~"tmp/thread-flag") == 1)
				{create_cloud_vec(type, path, lat, lon, alt, 0.0, 0);}
			else 
				{create_cloud(type, path, lat, lon, alt, 0.0, 0);}
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
		{create_cloud_vec("Rain", path, lat, lon,balt +0.5*bthick+ alt_shift, 0.0, 0);}		
		else		
		{create_cloud("Rain", path, lat, lon, balt + 0.5 * bthick + alt_shift, 0.0, 0);}
		i = i + 1;
		} # end while	
	} # end if (rainflag ==1)
}


###########################################################
# place a cloud box
###########################################################


var create_cloudbox = func (type,subtype, blat, blon, balt, dx,dy,dz,n) {

var phi = 0;

for (var i=0; i<n; i=i+1)
	{

	var x = 0.5 * dx * (2.0 * rand() - 1.0); 
	var y = 0.5 * dy * (2.0 * rand() - 1.0); 
	var alt = balt + dz * rand();
	
	var lat = blat + m_to_lat * (y * math.cos(phi) - x * math.sin(phi));
	var lon = blon + m_to_lon * (x * math.cos(phi) + y * math.sin(phi));

	var path = select_cloud_model(type,subtype);

	if (getprop(lw~"tmp/thread-flag") == 1)
			{create_cloud_vec(type, path, lat, lon, alt, 0.0, 0);}
		else
			{create_cloud(type, path, lat, lon, alt, 0.0, 0);}

	}

}

###########################################################
# place a cloud layer from arrays, only 20 clouds/frame 
###########################################################

var cloud_placement_loop = func (i) {

if (getprop(lw~"tmp/thread-status") != "placing") {return;}
if (getprop(lw~"tmp/convective-status") != "idle") {return;}
if ((i < 0) or (i==0)) 
	{
	print("Cloud placement from array finished!"); 
	setprop(lw~"tmp/thread-status", "idle");
	return;
	}


var k_max = 20;
var s = size(clouds_type);  

if (s < k_max) {k_max = s;}

for (var k = 0; k < k_max; k = k+1)
	{
	#print(s, " ", k, " ", s-k-1, " ", clouds_path[s-k-1]);
	create_cloud(clouds_type[s-k-1], clouds_path[s-k-1], clouds_lat[s-k-1], clouds_lon[s-k-1], clouds_alt[s-k-1], 0.0, 0);
	}

setsize(clouds_type,s-k_max);
setsize(clouds_path,s-k_max);
setsize(clouds_lat,s-k_max);
setsize(clouds_lon,s-k_max);
setsize(clouds_alt,s-k_max);
setsize(clouds_orientation,s-k_max);

settimer( func {cloud_placement_loop(i - k ) }, 0 );
};


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



for (var i=0; i<ntries; i=i+1)
	{
	var x = (2.0 * rand() - 1.0) * size;
	var y = (2.0 * rand() - 1.0) * size; 

	var lat = blat + (y * math.cos(phi) - x * math.sin(phi)) * m_to_lat;
	var lon = blon + (x * math.cos(phi) + y * math.sin(phi)) * m_to_lon;


	var info = geodinfo(lat, lon);
	if (info != nil) {elevation = info[0] * m_to_ft;}
	for(j=0;j<20;j=j+1)
		{
		if (elevation < 500.0 * (j+1)) 
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
	
	weather_tile_management.generate_tile(code, lat, lon, 0);
	}


# set status to idle again

setprop(lw~"tmp/presampling-status", "idle");

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



# and add to the counter
setprop(lw~"effect-volumes/number",getprop(lw~"effect-volumes/number")+1);
}


###########################################################
# place an effect volume from arrays
# only 20 volumes/frame 
###########################################################

var effect_placement_loop = func (i) {

if (getprop(lw~"tmp/effect-thread-status") != "placing") {return;}
if (getprop(lw~"tmp/convective-status") != "idle") {return;}
if ((i < 0) or (i==0)) 
	{
	print("Effect placement from array finished!"); 
	setprop(lw~"tmp/effect-thread-status", "idle");
	return;
	}


var k_max = 20;
var s = size(effects_geo);  

if (s < k_max) {k_max = s;}

for (var k = 0; k < k_max; k = k+1)
	{
	create_effect_volume(effects_geo[s-k-1], effects_lat[s-k-1], effects_lon[s-k-1], effects_r1[s-k-1], effects_r2[s-k-1], effects_phi[s-k-1], effects_alt_low[s-k-1], effects_alt_high[s-k-1], effects_vis[s-k-1], effects_rain[s-k-1], effects_snow[s-k-1], effects_turb[s-k-1], effects_lift[s-k-1], effects_lift_flag[s-k-1]);
	
	}

setsize(effects_geo, s-k_max);
setsize(effects_lat, s-k_max);
setsize(effects_lon, s-k_max);
setsize(effects_r1, s-k_max);
setsize(effects_r2, s-k_max);
setsize(effects_phi, s-k_max);
setsize(effects_alt_low, s-k_max);
setsize(effects_alt_high, s-k_max);
setsize(effects_vis, s-k_max);
setsize(effects_rain, s-k_max);
setsize(effects_snow, s-k_max);
setsize(effects_turb, s-k_max);
setsize(effects_lift, s-k_max);
setsize(effects_lift_flag, s-k_max);

settimer( func {effect_placement_loop(i - k ) }, 0 );
};

###########################################################
# create an effect volume vector for use in split
# frame loops
###########################################################

var create_effect_volume_vec = func (geometry, lat, lon, r1, r2, phi, alt_low, alt_high, vis, rain, snow, turb, lift, lift_flag) {

append(effects_geo,geometry);
append(effects_lat,lat);
append(effects_lon,lon);
append(effects_r1,r1);
append(effects_r2,r2);
append(effects_phi,phi);
append(effects_alt_low,alt_low);
append(effects_alt_high,alt_high);
append(effects_vis,vis);
append(effects_rain,rain);
append(effects_snow,snow);
append(effects_turb,turb);
append(effects_lift,lift);
append(effects_lift_flag,lift_flag);
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
}


###########################################################
# wrappers to call functions from the local weather menu bar 
###########################################################

var streak_wrapper = func {

setprop(lw~"tmp/thread-flag", 0);

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

create_streak(type,lat,lon,alt,nx,xoffset,xedge,ny,yoffset,yedge,dir,tri);
randomize_pos(type,rnd_alt,rnd_pos_x, rnd_pos_y, dir);


}


var convection_wrapper = func {

setprop(lw~"tmp/thread-flag", 0);

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

var type = getprop("/local-weather/tmp/scloud-type");
var subtype = getprop("/local-weather/tmp/scloud-subtype");
var lat = getprop("/local-weather/tmp/scloud-lat");
var lon = getprop("/local-weather/tmp/scloud-lon");
var alt = getprop("/local-weather/tmp/scloud-alt");
var heading = getprop("/local-weather/tmp/scloud-dir");

var path = select_cloud_model(type,subtype);

create_cloud(type, path, lat, lon, alt, heading, 0);

}

var layer_wrapper = func {

setprop(lw~"tmp/thread-flag", 0);

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

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
var alt = getprop("position/altitude-ft");
var x = getprop(lw~"tmp/box-x-m");
var y = getprop(lw~"tmp/box-y-m");
var z = getprop(lw~"tmp/box-alt-ft");
var n = getprop(lw~"tmp/box-n");

var type = "Box_test";
var subtype = "unspecified";

create_cloudbox(type,subtype,lat, lon, alt, x,y,z,n);

}


####################################
# tile setup call wrapper
####################################

var set_tile = func {

var type = getprop("/local-weather/tmp/tile-type");

# set tile center coordinates to current position

setprop(lw~"tiles/tmp/latitude-deg",getprop("position/latitude-deg"));
setprop(lw~"tiles/tmp/longitude-deg",getprop("position/longitude-deg"));

weather_tile_management.create_neighbours(getprop("position/latitude-deg"),getprop("position/longitude-deg"),getprop(lw~"tmp/tile-orientation-deg"));

# now see if we need to presample the terrain

if ((getprop(lw~"tmp/presampling-flag") == 1) and (getprop(lw~"tmp/presampling-status") == "idle")) 
	{
	terrain_presampling_start(getprop("position/latitude-deg"), getprop("position/longitude-deg"), 1000, 40000, getprop(lw~"tmp/tile-orientation-deg")); 
	return;
	}

# see if we use METAR for weather setup

if ((getprop(lw~"METAR/available-flag") == 1) and (getprop(lw~"tmp/tile-management") == "METAR"))
	{type = "METAR";}

setprop(lw~"tiles/tile-counter",getprop(lw~"tiles/tile-counter")+1);

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
else if (type == "Tropical")
	{weather_tiles.set_tropical_weather_tile();}
else if (type == "Coldfront")
	{weather_tiles.set_coldfront_tile();}
else if (type == "Warmfront-1")
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

setlistener(lw~"tmp/thread-status", func {var s = size(clouds_type);  cloud_placement_loop(s); });
setlistener(lw~"tmp/convective-status", func {var s = size(clouds_type);  cloud_placement_loop(s); });
setlistener(lw~"tmp/effect-thread-status", func {var s = size(effects_geo);  effect_placement_loop(s); });
setlistener(lw~"tmp/convective-status", func {var s = size(effects_geo);  effect_placement_loop(s); });
setlistener(lw~"tmp/presampling-status", func {manage_presampling(); });
}


#####################################################
# Standard test call (for development and debug only)
#####################################################

var test = func {

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");


# terrain_presampling_start(lat, lon, 1000, 20000, 0.0);

# test: 8 identical position tuples for KSFO
var p=[ 37.6189722, -122.3748889,   37.6189722, -122.3748889,
        37.6289722, -122.3748889,   37.6189722, -122.3648889,
        37.6389722, -122.3748889,   37.6189722, -122.3548889,
        37.6489722, -122.3748889,   37.6189722, -122.3448889 ];

var x=geodinfo(p, 10000); # passing in vector with position tuples

foreach(var e;x) {
  print("Elevation:",e);  # showing results
}




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

var cloud_vertical_size_map = {Altocumulus: 700.0, Cumulus: 600.0, Nimbus: 1000.0, Stratus: 800.0, Stratus_structured: 600.0, Stratus_thin: 400.0};

# storage arrays for cloud generation

var clouds_type = [];
var clouds_path = [];
var clouds_lat = [];
var clouds_lon = [];
var clouds_alt = [];
var clouds_orientation = [];

# storage arrays for effect volume generation

var effects_geo = [];
var effects_lat = [];
var effects_lon = [];
var effects_r1 = [];
var effects_r2 = [];
var effects_phi = [];
var effects_alt_low = [];
var effects_alt_high = [];
var effects_vis = [];
var effects_rain = [];
var effects_snow = [];
var effects_turb = [];
var effects_lift = [];
var effects_lift_flag = [];

# storage array for terrain presampling

var terrain_n = [];

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
setprop(lw~"tmp/box-x-m",300.0);
setprop(lw~"tmp/box-y-m",300.0);
setprop(lw~"tmp/box-alt-ft",300.0);
setprop(lw~"tmp/box-n",4);
setprop(lw~"tmp/tile-type", "High-pressure");
setprop(lw~"tmp/tile-orientation-deg", 0.0);
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

# set config values

setprop(lw~"config/distance-to-load-tile-m",35000.0);
setprop(lw~"config/distance-to-remove-tile-m",37000.0);
setprop(lw~"config/detailed-clouds-flag",1);
setprop(lw~"config/thermal-properties",1.0);


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


# wait for Nasal to be available and do what is in startup()

_setlistener("/sim/signals/nasal-dir-initialized", func {
	startup();
});

