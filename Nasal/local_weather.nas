
#################################################
# routines to set up, transform and manage local weather
# Thorsten Renk, April 2010
#################################################

var calc_geo = func(clat) {

lon_to_m  = math.cos(clat*math.pi/180.0) * lat_to_m;
m_to_lon = 1.0/lon_to_m;

}


###################################
# effect volume management loop
###################################

var effect_volume_loop = func {

var evNode = props.globals.getNode("local-weather/effect-volumes", 1).getChildren("effect-volume");
var viewpos = geo.viewer_position();


foreach (var e; evNode) {
	
	var flag = 0; #default assumption is that we're not in the volume
	var geometry = e.getNode("geometry").getValue();
	var elat = e.getNode("position/latitude-deg").getValue();
	var elon = e.getNode("position/longitude-deg").getValue();
	var ealt_min = e.getNode("position/min-altitude-ft").getValue() * ft_to_m;
	var ealt_max = e.getNode("position/max-altitude-ft").getValue() * ft_to_m;
	var rx = e.getNode("volume/size-x").getValue();
	var ry = e.getNode("volume/size-y").getValue();
	var phi = e.getNode("volume/orientation-deg").getValue();
	phi = phi * math.pi/180.0;
	
	var evpos = geo.Coord.new();
	evpos.set_latlon(elat,elon,ealt_min);

	var d = viewpos.distance_to(evpos);
	#print(d);

	var active_flag = e.getNode("active-flag").getValue(); # see if the node was active previously
	
	if ((viewpos.alt() > ealt_min) and (viewpos.alt() < ealt_max)) # we are in the correct alt range
		{
		if (geometry == 1) # we have a cylinder
			{
			if (d < rx) {flag =1;}
			}
		if (geometry == 2) # we have an elliptic shape
			{
			# first get unrotated coordinates 
			var xx = (viewpos.lon() - evpos.lon()) * lon_to_m;
			var yy = (viewpos.lat() - evpos.lat()) * lat_to_m;
			# then rotate to align with the shape
			var x = xx * math.cos(phi) - yy * math.sin(phi);
			var y = yy * math.cos(phi) + xx * math.sin(phi); 
			# then check elliptic condition
			if ((x*x)/(rx*rx) + (y*y)/(ry*ry) <1) {flag = 1;}
			}
		if (geometry == 3) # we have a rectangular shape
			{
			# first get unrotated coordinates 
			var xx = (viewpos.lon() - evpos.lon()) * lon_to_m;
			var yy = (viewpos.lat() - evpos.lat()) * lat_to_m;
			# then rotate to align with the shape
			var x = xx * math.cos(phi) - yy * math.sin(phi);
			var y = yy * math.cos(phi) + xx * math.sin(phi); 
			# then check rectangle condition
			if ((x>-rx) and (x<rx) and (y>-ry) and (y<ry)) {flag = 1;}
			}
		}
	
	
	# if flag ==1 at this point, we are inside the effect volume
	# but we only need to take action on entering and leaving, so we check also active_flag
	
	#if (flag==1) {print("Inside volume");}
	
	if ((flag==1) and (active_flag ==0)) # we just entered the node
		{
		#print("Entered volume");
		e.getNode("active-flag").setValue(1);
		effect_volume_start(e);
		}
	if ((flag==0) and (active_flag ==1)) # we left an active node
		{
		#print("Left volume!");
		e.getNode("active-flag").setValue(0);
		effect_volume_stop(e);
		}
	
	} # end foreach

    if (getprop(lw~"effect-loop-flag") ==1) {settimer(effect_volume_loop, 1.0);}
}


###################################
# interpolation management loop
###################################

var interpolation_loop = func {

var iNode = props.globals.getNode(lw~"interpolation", 1);
var cNode = props.globals.getNode(lw~"current", 1);
var stNode = iNode.getChildren("station");
var viewpos = geo.viewer_position();

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
	}

var vis = sum_vis/sum_norm;
var p = sum_p/sum_norm;
var D = sum_D/sum_norm;
var T = sum_T/sum_norm;

iNode.getNode("visibility-m",1).setValue(vis);
iNode.getNode("temperature-degc",1).setValue(T);
iNode.getNode("dewpoint-degc",1).setValue(D);
iNode.getNode("pressure-sea-level-inhg",1).setValue(p);

# now check if an effect volume writes the property and set only if not

flag = props.globals.getNode("local-weather/effect-volumes/number-active-vis").getValue();
if (flag ==0) 
	{
	cNode.getNode("visibility-m").setValue(vis);
	setVisibility(vis);
	}

# no need to check for these, as they are not modelled in effect volumes

cNode.getNode("temperature-degc",1).setValue(T);
setTemperature(T);

cNode.getNode("dewpoint-degc",1).setValue(D);
setDewpoint(D);

cNode.getNode("pressure-sea-level-inhg",1).setValue(p);
setPressure(p);


if (getprop(lw~"interpolation-loop-flag") ==1) {settimer(interpolation_loop, 3.0);}

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

if (ev.getNode("effects/thermal-lift-flag", 1).getValue()==1)
	{
	var lift = ev.getNode("effects/thermal-lift").getValue();
	ev.getNode("restore/thermal-lift",1).setValue(cNode.getNode("thermal-lift").getValue());
	cNode.getNode("thermal-lift").setValue(lift);
	ev.getNode("restore/number-entry-lift",1).setValue(getprop(lw~"effect-volumes/number-active-lift"));
	setprop(lw~"effect-volumes/number-active-lift",getprop(lw~"effect-volumes/number-active-lift")+1);
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

if (ev.getNode("effects/thermal-lift-flag", 1).getValue()==1)
	{
	var n_active = getprop(lw~"effect-volumes/number-active-lift");
	var n_entry = ev.getNode("restore/number-entry-lift").getValue();	
	if (n_active ==1){var lift = props.globals.getNode(lw~"interpolation/thermal-lift").getValue();}
	else if ((n_active -1) == n_entry) {var lift = ev.getNode("restore/thermal-lift").getValue();}
	else {var lift = cNode.getNode("thermal-lift").getValue();}
	cNode.getNode("thermal-lift").setValue(lift);
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

var setLift = func (L) {

# this doesn't actually work with Flightgear 2.0.0 since environement overwrites the
# setting - so it's a hope for CVS 
# -> probably obsolete as CVS patch reads out /local-weather/current

setprop("environment/thermal-lift",L);
}

###########################################################
# randomize positions of clouds created in a fixed pattern 
###########################################################

var randomize_pos = func (type, alt_var, pos_var_x, pos_var_y, dir) {

# it is rather stupid coding to force the randomization call after the streak call, and I'll probably
# restructure the whole thing soon

var cloudNode = props.globals.getNode("local-weather/clouds", 1).getChildren("cloud");

	
foreach (var e; cloudNode) {
	var call = e.getNode("type",1).getValue();
	

	if (call=="tmp_cloud")
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
	if (subtype == "small") {
		if (rn > 0.5) {path = "Models/Weather/cirrus1.xml";}
		else  {path = "Models/Weather/cirrus2.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.5) {path = "Models/Weather/cirrus1.xml";}
		else  {path = "Models/Weather/cirrus2.xml";}
		}	
	}
else if (type == "Cirrocumulus") {
	if (subtype == "small") {
		if (rn > 0.5) {path = "Models/Weather/cirrocumulus1.xml";}
		else  {path = "Models/Weather/cirrocumulus2.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.5) {path = "Models/Weather/cirrocumulus1.xml";}
		else  {path = "Models/Weather/cirrocumulus2.xml";}
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

else {print("Cloud type ", type, " subtype ",subtype, " not available!");}

return path;
}


###########################################################
# place a single cloud 
###########################################################

var create_cloud = func(type, path, lat, long, alt, heading, rain_flag) {

var n = props.globals.getNode("local-weather/clouds", 1);
var cloud_number = n.getNode("cloud-number").getValue();
		for (var i = cloud_number; 1; i += 1)
			if (n.getChild("cloud", i, 0) == nil)
				break;
	cl = n.getChild("cloud", i, 1);

var m = props.globals.getNode("models", 1);
		for (var i = cloud_number; 1; i += 1)
			if (m.getChild("model", i, 0) == nil)
				break;
		model = m.getChild("model", i, 1);



cl.getNode("type", 1).setValue(type);
var latN = cl.getNode("position/latitude-deg", 1); latN.setValue(lat);
var lonN = cl.getNode("position/longitude-deg", 1); lonN.setValue(long);
var altN = cl.getNode("position/altitude-ft", 1); altN.setValue(alt);
var hdgN = cl.getNode("orientation/true-heading-deg", 1); hdgN.setValue(heading);
var pitchN = cl.getNode("orientation/pitch-deg", 1); pitchN.setValue(0.0);
var rollN = cl.getNode("orientation/roll-deg", 1);rollN.setValue(0.0);
#cl.getNode("velocities/true-airspeed-kt", 1).setValue(kias);
#cl.getNode("velocities/vertical-speed-fps", 1).setValue(0.0);
#cl.getNode("position/trafo-flag", 1).setValue(1);

model.getNode("path", 1).setValue(path);
model.getNode("legend", 1).setValue("Cloud");
model.getNode("latitude-deg-prop", 1).setValue(latN.getPath());
model.getNode("longitude-deg-prop", 1).setValue(lonN.getPath());
model.getNode("elevation-ft-prop", 1).setValue(altN.getPath());
model.getNode("heading-deg-prop", 1).setValue(hdgN.getPath());
model.getNode("pitch-deg-prop", 1).setValue(pitchN.getPath());
model.getNode("roll-deg-prop", 1).setValue(rollN.getPath());
model.getNode("load", 1).remove();

n.getNode("cloud-number").setValue(n.getNode("cloud-number").getValue()+1);


}

###########################################################
# clear all clouds and effects
###########################################################

var clear_all = func {

# clear the clouds and models

var cloudNode = props.globals.getNode("local-weather/clouds", 1);
cloudNode.removeChildren("cloud");
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

# stop the effect loop and the interpolation loop, make sure thermal generation is off

setprop(lw~"effect-loop-flag",0);
setprop(lw~"interpolation-loop-flag",0);
setprop(lw~"tmp/generate-thermal-lift-flag",0); 

# also remove rain and snow effects

setRain(0.0);
setSnow(0.0);

}

###########################################################
# place a cumulus system 
###########################################################

var create_cumosys = func (blat, blon, balt, nc, size) {



var path = "Models/Weather/blank.ac";
var i = 0;
var p = 0.0;
var rn = 0.0;
var place_lift_flag = 0;

var sec_to_rad = 2.0 * math.pi/86400; 

calc_geo(blat);

# get the local time of the day in seconds

var t = getprop("sim/time/utc/day-seconds");
t = t + getprop("sim/time/local-offset");

# print("t is now:", t);

# and make a simple sinusoidal model of thermal strength

var t_factor1 = 0.5 * 1.0-math.cos((t * sec_to_rad));
var t_factor2 = 0.5 * 1.0-math.cos((t * sec_to_rad)-0.52);

# print("t-factor is now: ",t_factor);

nc = t_factor1 * nc * math.cos(blat/180.0*math.pi);


while (i < nc) {

	p = 0.0;
	place_lift_flag = 0;

	var x = (2.0 * rand() - 1.0) * size;
	var y = (2.0 * rand() - 1.0) * size; 

	var lat = blat + y * m_to_lat;
	var lon = blon + x * m_to_lon;
	var info = geodinfo(lat, lon);

	if (info != nil) {
	if (info[1] != nil){
         var landcover = info[1].names[0];
	 if (contains(landcover_map,landcover)) {p = p + landcover_map[landcover];}
	 else {print(p, " ", info[1].names[0]);}
	}}


	if (rand() < p)
		{
		if (rand() + (2.0 * p) > 1.0) 
			{
			path = select_cloud_model("Cumulus","large"); place_lift_flag = 1;
			}
		else {path = select_cloud_model("Cumulus","small");}

		create_cloud("Cumulus", path, lat, lon, balt, 0.0, 0);
		
		# now see if we need to create a thermal - first check the flag
		if (getprop(lw~"tmp/generate-thermal-lift-flag") == 1)
			{
			# now check if convection is strong
			if (place_lift_flag == 1)
			{
		var lift = 1.0 + 20.0 * p *  rand();
		var radius = 300 + 300 * rand();
		create_effect_volume(1, lat, lon, radius, radius, 0.0, 0.0, balt+500.0, -1, -1, -1, -1, lift, 1);
				
				} # end if place_lift_flag		
			} # end if generate-thermal-lift-flag	
		} # end if rand < p
	i = i + 1;
	} # end while

}

###########################################################
# terrain sampling 
###########################################################

var terrain_presampling = func {

var size = 15000.0;
var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
var elevation = 0.0;
var n=[];
setsize(n,20);

calc_geo(blat);

for(j=0;j<20;j=j+1){n[j]=0;}

for (i=0; i<1000; i=i+1)
	{
	var x = (2.0 * rand() - 1.0) * size;
	var y = (2.0 * rand() - 1.0) * size; 

	var lat = blat + y * m_to_lat;
	var lon = blon + x * m_to_lon;

	var info = geodinfo(lat, lon);
	if (info != nil) {elevation = info[0] * m_to_ft;}
	for(j=0;j<20;j=j+1){if (elevation < 500.0 * (j+1)) 
		{n[j] = n[j]+1;  break;}}
	
	}

for (i=0;i<20;i=i+1){print(500.0*i," ",n[i]);}
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
		#var label = get_label(type);
		if (flag==0){create_cloud("tmp_cloud", path, lat, long, balt, 0.0, 0);}
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
			create_cloud(type, path, lat, lon, alt, 0.0, 0);
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
		create_cloud("Rain", path, lat, lon, balt + 0.5 * bthick + cloud_vertical_size_map[type], 0.0, 0);
		i = i + 1;
		} # end while	
	} # end if (rainflag ==1)
}

###########################################################
# create an effect volume
###########################################################

var create_effect_volume = func (geometry, lat, lon, r1, r2, phi, alt_low, alt_high, vis, rain, snow, turb, lift, lift_flag) {

var flag = 0;

var n = props.globals.getNode("local-weather/effect-volumes", 1);
		for (var i = 0; 1; i += 1)
			if (n.getChild("effect-volume", i, 0) == nil)
				break;

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
if (lift_flag == 0.0) {flag = 0;}
ev.getNode("effects/thermal-lift-flag", 1).setValue(flag);
ev.getNode("effects/thermal-lift", 1).setValue(lift);


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
}


###########################################################
# wrappers to call functions from the local weather menu bar 
###########################################################

var streak_wrapper = func {

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

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
var alt = getprop("/local-weather/tmp/conv-alt");
var size = getprop("/local-weather/tmp/conv-size");
var strength = getprop("/local-weather/tmp/conv-strength");

var n = int(10 * size * size * strength);
create_cumosys(lat,lon,alt,n, size*1000.0);

}

var barrier_wrapper = func {

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


####################################
# tile setup call wrapper
####################################

var set_tile = func {

var type = getprop("/local-weather/tmp/tile-type");

if (type == "Altocumulus sky"){weather_tiles.set_altocumulus_tile();}
else if (type == "Broken layers") {weather_tiles.set_broken_layers_tile();}
else if (type == "Cold front"){weather_tiles.set_coldfront_tile();}
else if (type == "Cirrus sky"){weather_tiles.set_cirrus_sky_tile();}
else if (type == "Fair weather"){weather_tiles.set_fair_weather_tile();}
else if (type == "Glider's sky"){weather_tiles.set_gliders_sky_tile();}
else if (type == "Incoming rainfront"){weather_tiles.set_rainfront_tile();}
else if (type == "Overcast stratus sky"){weather_tiles.set_overcast_stratus_tile();}
else if (type == "Summer rain"){weather_tiles.set_summer_rain_tile();}
else {print("Tile not implemented.");}



}


#################################################
# Anything that needs to run at startup goes here
#################################################

var startup = func {
print("Loading local weather routines...");

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
calc_geo(lat);

# copy weather properties at startup to local weather

setprop(lw~"interpolation/visibility-m",getprop(ec~"boundary/entry[0]/visibility-m"));
setprop(lw~"interpolation/pressure-sea-level-inhg",getprop(ec~"boundary/entry[0]/pressure-sea-level-inhg"));
setprop(lw~"interpolation/temperature-degc",getprop(ec~"boundary/entry[0]/temperature-degc"));
setprop(lw~"interpolation/wind-from-heading-deg",getprop(ec~"boundary/entry[0]/wind-from-heading-deg"));
setprop(lw~"interpolation/wind-speed-kt",getprop(ec~"boundary/entry[0]/wind-speed-kt"));

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

# try to set up a menu from Nasal


#setprop("/sim/menubar/default/menu[4]/item[8]/label","Test");
#setprop("/sim/menubar/default/menu[4]/item[8]/binding/command","dialog-show");
#setprop("/sim/menubar/default/menu[4]/item[8]/binding/dialog-name","local_weather_tiles");
#setprop("/sim/menubar/default/menu[4]/item[8]/enabled","true");
}


#####################################################
# Standard test call (for development and debug only)
#####################################################

var test = func {

var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");

create_layer("Nimbus", lat, lon, 3000.0, 500.0, 10000.0, 5000.0, 45.0, 1.0, 0.2,1,1.0);
#create_layer(type, lat, lon, alt, thick, rx, ry, phi, density, edge, rain_flag, rain_density);

#terrain_presampling();

create_effect_volume(2, lat, lon, 9000.0, 4000.0, 45.0, 0.0, 3500.0, 1500, 0.4, -1, -1, -1, 0);


if (getprop(lw~"effect-loop-flag") == 0) 
{setprop(lw~"effect-loop-flag",1); effect_volume_loop();}

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

var landcover_map = {BuiltUpCover: 0.35, Town: 0.35, Freeway:0.35, BarrenCover:0.3, HerbTundraCover: 0.25, GrassCover: 0.2, CropGrassCover: 0.2, Sand: 0.25, Grass: 0.2, Ocean: 0.01, Marsh: 0.05, Lake: 0.01, ShrubCover: 0.15, Landmass: 0.2, CropWoodCover: 0.15, MixedForestCover: 0.1, DryCropPastureCover: 0.25, MixedCropPastureCover: 0.2, IrrCropPastureCover: 0.15, DeciduousBroadCover: 0.1, pa_taxiway : 0.35, pa_tiedown: 0.35, pc_taxiway: 0.35, pc_tiedown: 0.35};

# a hash map of average vertical cloud model sizes

var cloud_vertical_size_map = {Altocumulus: 700.0, Cumulus: 600.0, Nimbus: 1000.0, Stratus: 800.0, Stratus_structured: 600.0};


# set all sorts of default properties for the menu

setprop("/local-weather/tmp/cloud-type", "Altocumulus");
setprop("/local-weather/tmp/alt", 12000.0);
setprop("/local-weather/tmp/nx",5);
setprop("/local-weather/tmp/xoffset",800.0);
setprop("/local-weather/tmp/xedge", 0.2);
setprop("/local-weather/tmp/ny",15);
setprop("/local-weather/tmp/yoffset",800.0);
setprop("/local-weather/tmp/yedge", 0.2);
setprop("/local-weather/tmp/dir",0.0);
setprop("/local-weather/tmp/tri", 1.0);
setprop("/local-weather/tmp/rnd-pos-x",400.0);
setprop("/local-weather/tmp/rnd-pos-y",400.0);
setprop("/local-weather/tmp/rnd-alt", 300.0);
setprop("/local-weather/tmp/conv-strength", 1);
setprop("/local-weather/tmp/conv-size", 15.0);
setprop("/local-weather/tmp/conv-alt", 2000.0);
setprop("/local-weather/tmp/bar-alt", 3500.0);
setprop("/local-weather/tmp/bar-n", 150.0);
setprop("/local-weather/tmp/bar-dir", 0.0);
setprop("/local-weather/tmp/bar-dist", 5.0);
setprop("/local-weather/tmp/bar-size", 10.0);
setprop("/local-weather/tmp/scloud-type", "Altocumulus");
setprop("/local-weather/tmp/scloud-subtype", "small");
setprop("/local-weather/tmp/scloud-lat",getprop("position/latitude-deg"));
setprop("/local-weather/tmp/scloud-lon",getprop("position/longitude-deg"));
setprop("/local-weather/tmp/scloud-alt", 5000.0);
setprop("/local-weather/tmp/scloud-dir", 0.0);
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
setprop(lw~"tmp/tile-type", "Altocumulus sky");
setprop(lw~"tmp/tile-orientation-deg", 0.0);
setprop(lw~"tmp/tile-alt-offset-ft", 0.0);
setprop(lw~"tmp/generate-thermal-lift-flag", 0);

# set the default loop flags to loops inactive

setprop(lw~"fast-loop-flag",0);
setprop(lw~"slow-loop-flag",0);
setprop(lw~"effect-loop-flag",0);
setprop(lw~"interpolation-loop-flag",0);

# create other properties

setprop(lw~"clouds/cloud-number",0);

# create properties for effect volume management

setprop(lw~"effect-volumes/number",0);
setprop(lw~"effect-volumes/number-active-vis",0);
setprop(lw~"effect-volumes/number-active-rain",0);
setprop(lw~"effect-volumes/number-active-snow",0);
setprop(lw~"effect-volumes/number-active-turb",0);
setprop(lw~"effect-volumes/number-active-lift",0);

# wait for Nasal to be available and do what is in startup()

_setlistener("/sim/signals/nasal-dir-initialized", func {
	startup();
});

