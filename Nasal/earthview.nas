###########################################################
# Earthview orbital rendering
###########################################################


var lightning_table = [];

var entry = [2.85, 30.28, 0.35, 0.045];
append(lightning_table, entry);

entry = [9.3,8.0,0.1, 0.105];
append(lightning_table, entry);

entry = [6.0, -72.0, 0.2, 0.09];
append(lightning_table, entry);

entry = [30.89, -112.0, 0.72, 0.34];
append(lightning_table, entry);


var check_lightning_table = func (lat, lon) {

for (var i=0; i< size(lightning_table); i=i+1)
	{
	if (math.abs(lat - lightning_table[i][0]) < 15.0)
		{
		if (math.abs(lon - lightning_table[i][1]) < 15.0)
			{
			return i;
			}
		}
	}
return -1;

}


var start = func() {

if (earthview_running_flag ==1) {return;}

earthview_running_flag = 1;

var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg");



# define the tile centers


center_N1 = geo.Coord.new();
center_N2 = geo.Coord.new();
center_N3 = geo.Coord.new();
center_N4 = geo.Coord.new();
center_S1 = geo.Coord.new();
center_S2 = geo.Coord.new();
center_S3 = geo.Coord.new();
center_S4 = geo.Coord.new();

center_N1.set_latlon(45.0, -135.0);
center_N2.set_latlon(45.0,  -45.0);
center_N3.set_latlon(45.0,   45.0);
center_N4.set_latlon(45.0,  135.0);

center_S1.set_latlon(-45.0, -135.0);
center_S2.set_latlon(-45.0,  -45.0);
center_S3.set_latlon(-45.0,   45.0);
center_S4.set_latlon(-45.0,  135.0);

# determine which tiles to show

var shuttle_pos = geo.aircraft_position();

if (0==1){
print(shuttle_pos.distance_to(center_N1)/1000.0);
print(shuttle_pos.distance_to(center_N2)/1000.0);
print(shuttle_pos.distance_to(center_N3)/1000.0);
print(shuttle_pos.distance_to(center_N4)/1000.0);
print(shuttle_pos.distance_to(center_S1)/1000.0);
print(shuttle_pos.distance_to(center_S2)/1000.0);
print(shuttle_pos.distance_to(center_S3)/1000.0);
print(shuttle_pos.distance_to(center_S4)/1000.0);
}

setprop("/earthview/show-n1", 0);
setprop("/earthview/show-n2", 0);
setprop("/earthview/show-n3", 0);
setprop("/earthview/show-n4", 0);

setprop("/earthview/show-s1", 0);
setprop("/earthview/show-s2", 0);
setprop("/earthview/show-s3", 0);
setprop("/earthview/show-s4", 0);


aurora_model.node = earthview.place_earth_model("Models/Astro/aurora.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);

# set Basic Weather off
props.globals.getNode("/environment/config/enabled").setBoolValue(0);
props.globals.getNode("/environment/params/metar-updates-environment").setBoolValue(0);



# set some reasonable defaults

setprop("/environment/visibility-m", 80000.0);
setprop("/sim/rendering/mie", 0.0);
setprop("/sim/rendering/rayleigh", 0.00002);
setprop("/sim/rendering/dome-density", 1.0);
setprop("/earthview/shade-effect", 0.5);

earth_model.l1 = setlistener("/earthview/show-n1", func(n) {load_sector (1, n);},0,0);
earth_model.l2 = setlistener("/earthview/show-n2", func(n) {load_sector (2, n);},0,0);
earth_model.l3 = setlistener("/earthview/show-n3", func(n) {load_sector (3, n);},0,0);
earth_model.l4 = setlistener("/earthview/show-n4", func(n) {load_sector (4, n);},0,0);
earth_model.l5 = setlistener("/earthview/show-s1", func(n) {load_sector (5, n);},0,0);
earth_model.l6 = setlistener("/earthview/show-s2", func(n) {load_sector (6, n);},0,0);
earth_model.l7 = setlistener("/earthview/show-s3", func(n) {load_sector (7, n);},0,0);
earth_model.l8 = setlistener("/earthview/show-s4", func(n) {load_sector (8, n);},0,0);


control_loop();

slow_loop();

}

var stop = func () {

#earth_model.node.remove();
#cloudsphere_model.node.remove();
aurora_model.node.remove();
setprop("/earthview/control_loop_flag",0);

# unload tiles not loaded via listeners

if (cloudsphere_rotated_flag == 1)
	{clear_cloud_tiles();}

# unlock rotation flag to allow downloading of distance-managed tiles
cloudsphere_rotated_flag = 0;
setprop("/earthview/cloudsphere-angle",0.0);

setprop("/earthview/show-n1", 0);
setprop("/earthview/show-n2", 0);
setprop("/earthview/show-n3", 0);
setprop("/earthview/show-n4", 0);

setprop("/earthview/show-s1", 0);
setprop("/earthview/show-s2", 0);
setprop("/earthview/show-s3", 0);
setprop("/earthview/show-s4", 0);

settimer( func {
removelistener(earth_model.l1);
removelistener(earth_model.l2);
removelistener(earth_model.l3);
removelistener(earth_model.l4);
removelistener(earth_model.l5);
removelistener(earth_model.l6);
removelistener(earth_model.l7);
removelistener(earth_model.l8);
}, 1.0);



earthview_running_flag = 0;
}

var place_earth_model = func(path, lat, lon, alt, heading, pitch, roll) {



var m = props.globals.getNode("models", 1);
		for (var i = 0; 1; i += 1)
			if (m.getChild("model", i, 0) == nil)
				break;
var model = m.getChild("model", i, 1);

var R1 = 5800000.0;
var R2 = 58000.0;

var altitude1 = getprop("/position/altitude-ft");
var altitude2 = R2/R1 * altitude1;
var model_alt = altitude1 - altitude2 - R2 * m_to_ft;

setprop("/earthview/latitude-deg", lat);
setprop("/earthview/longitude-deg", lon);
setprop("/earthview/elevation-ft", model_alt);
setprop("/earthview/heading-deg", heading);
setprop("/earthview/pitch-deg", pitch);
setprop("/earthview/roll-deg", roll);
setprop("/earthview/yaw-deg", 0.0);

var eview = props.globals.getNode("earthview", 1);
var latN = eview.getNode("latitude-deg",1);
var lonN = eview.getNode("longitude-deg",1);
var altN = eview.getNode("elevation-ft",1);
var headN = eview.getNode("heading-deg",1);
var pitchN = eview.getNode("pitch-deg",1);
var rollN = eview.getNode("roll-deg",1);



model.getNode("path", 1).setValue(path);
model.getNode("latitude-deg-prop", 1).setValue(latN.getPath());
model.getNode("longitude-deg-prop", 1).setValue(lonN.getPath());
model.getNode("elevation-ft-prop", 1).setValue(altN.getPath());
model.getNode("heading-deg-prop", 1).setValue(headN.getPath());
model.getNode("pitch-deg-prop", 1).setValue(pitchN.getPath());
model.getNode("roll-deg-prop", 1).setValue(rollN.getPath());
model.getNode("load", 1).remove();

setprop("/earthview/heading-deg",90);
setprop("/earthview/control_loop_flag",1);



return model;
}


var control_loop = func {

if (earthview_running_flag == 0) {return;}

var R1 = 5800000.0;
var R2 = 58000.0;
var range_base = 7000000;

var altitude1 = getprop("/position/altitude-ft");
var altitude2 = R2/R1 * altitude1;
var model_alt = altitude1 - altitude2 - R2 * m_to_ft;

var horizon = math.sqrt(2.0 * R1 * altitude1 * ft_to_m );
if (horizon > 5000000.0) {horizon = 5000000.0;}

setprop("/earthview/horizon-km", horizon/1000.0);

setprop("/earthview/elevation-ft", model_alt);

var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg");

setprop("/earthview/latitude-deg", lat);
setprop("/earthview/longitude-deg", lon);

setprop("/earthview/roll-deg", -(90-lat));
setprop("/earthview/yaw-deg", -lon);

var shuttle_pos = geo.aircraft_position();


if (shuttle_pos.distance_to(center_N1) > range_base + horizon) 
	{setprop("/earthview/show-n1", 0);}
else {setprop("/earthview/show-n1", 1);}

if (shuttle_pos.distance_to(center_N2) > range_base + horizon) 
	{setprop("/earthview/show-n2", 0);}
else {setprop("/earthview/show-n2", 1);}

if (shuttle_pos.distance_to(center_N3) > range_base + horizon) 
	{setprop("/earthview/show-n3", 0);}
else {setprop("/earthview/show-n3", 1);}

if (shuttle_pos.distance_to(center_N4) > range_base + horizon) 
	{setprop("/earthview/show-n4", 0);}
else {setprop("/earthview/show-n4", 1);}

if (shuttle_pos.distance_to(center_S1) > range_base + horizon) 
	{setprop("/earthview/show-s1", 0);}
else {setprop("/earthview/show-s1", 1);}

if (shuttle_pos.distance_to(center_S2) > range_base + horizon) 
	{setprop("/earthview/show-s2", 0);}
else {setprop("/earthview/show-s2", 1);}

if (shuttle_pos.distance_to(center_S3) > range_base + horizon) 
	{setprop("/earthview/show-s3", 0);}
else {setprop("/earthview/show-s3", 1);}

if (shuttle_pos.distance_to(center_S4) > range_base + horizon) 
	{setprop("/earthview/show-s4", 0);}
else {setprop("/earthview/show-s4", 1);}

# now set scattering paramaters

if (getprop("/earthview/mrd-flag") == 1)
	{
	var rayleigh = 0.0002;
	var mie = 0.001;
	var density = 1.0;
	
	if (altitude1 < 300000.0)
		{
		setprop("/sim/rendering/rayleigh",rayleigh);
		setprop("/sim/rendering/mie",mie);
		setprop("/sim/rendering/dome-density",density);
		}
	else if (altitude1 < 650000.0)
		{
		rayleigh = rayleigh - 0.00018 * (altitude1-300000.0)/350000.0;
		mie = mie - 0.001 * (altitude1-300000.0)/350000.0;
		density = 1.0;
		setprop("/sim/rendering/rayleigh",rayleigh);
		setprop("/sim/rendering/mie",mie);
		setprop("/sim/rendering/dome-density",density);
		}
	else
		{
		rayleigh = 0.00002;
		mie = 0.0;
		density = 1.0;
		setprop("/sim/rendering/rayleigh",rayleigh);
		setprop("/sim/rendering/mie",mie);
		setprop("/sim/rendering/dome-density",density);
		}
	
	}


if (getprop("/earthview/control_loop_flag") ==1) {settimer( func {control_loop(); },0);}
}


var slow_loop = func {

if (earthview_running_flag == 0) {return;}

# thunderstorms

var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg") + getprop("/earthview/cloudsphere-angle");


var index = check_lightning_table(lat, lon);

if (index > -1)
	{
	
	
	rn = rand();

	if (rn < 0.3)
		{
		var roi_x_base = lightning_table[index][2];
		var roi_y_base = lightning_table[index][3];
	
		var rn = 0.005 * (2.0 * rand() - 0.5);
		setprop("/earthview/roi-x1", roi_x_base + rn);
	
		rn = 0.005 * (2.0 * rand() - 0.5);
		setprop("/earthview/roi-y1", roi_y_base + rn);
		
		
		lightning_strike();
		
		}
	}

if (getprop("/earthview/control_loop_flag") ==1) {settimer( func {slow_loop(); },1.0);}
}



var lightning_strike = func {

var rn = rand();

var repeat = 1;

if (rn > 0.5) {repeat = 2;}

var duration = 0.1 + 0.1 * rand();
var strength = 0.5 + 1.0 * rand();

setprop("/earthview/lightning", strength);
settimer( func{ setprop("/earthview/lightning", 0.0);}, duration);

var duration1 = 0.1 +  0.1 * rand();

if (repeat == 2)
	{
	settimer( func{ setprop("/earthview/lightning", strength);}, duration + 0.1);
	settimer( func{ setprop("/earthview/lightning", 0.0);}, duration + 0.1 + duration1);
	}

}


# rotate position of cloud tiles

var adjust_cloud_tiles = func {

# we need to load all cloud tiles if we want to rotate the cloudsphere

if (getprop("/earthview/cloudsphere-angle") > 0.0)
	{
	if (cloudsphere_rotated_flag == 0)
		{
		var lat = getprop("/position/latitude-deg");
		var lon = getprop("/position/longitude-deg");

		if (getprop("/earthview/show-n1") == 0)
			{cloudsphere_model.node1 = place_earth_model("Models/Astro/clouds_N1.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		if (getprop("/earthview/show-n2") == 0)
			{cloudsphere_model.node2 = place_earth_model("Models/Astro/clouds_N2.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		if (getprop("/earthview/show-n3") == 0)
			{cloudsphere_model.node3 = place_earth_model("Models/Astro/clouds_N3.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		if (getprop("/earthview/show-n4") == 0)
			{cloudsphere_model.node4 = place_earth_model("Models/Astro/clouds_N4.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		if (getprop("/earthview/show-s1") == 0)
			{cloudsphere_model.node5 = place_earth_model("Models/Astro/clouds_S1.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		if (getprop("/earthview/show-s2") == 0)
			{cloudsphere_model.node6 = place_earth_model("Models/Astro/clouds_S2.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		if (getprop("/earthview/show-s3") == 0)
			{cloudsphere_model.node7 = place_earth_model("Models/Astro/clouds_S3.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		if (getprop("/earthview/show-s4") == 0)
			{cloudsphere_model.node8 = place_earth_model("Models/Astro/clouds_S4.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}

		cloudsphere_rotated_flag = 1;
		}
	}
else
	{
	clear_cloud_tiles();
	cloudsphere_rotated_flag = 0;
	}

}


var clear_cloud_tiles = func {


if (getprop("/earthview/show-n1") == 0)
	{cloudsphere_model.node1.remove();}

if (getprop("/earthview/show-n2") == 0)
	{cloudsphere_model.node2.remove();}

if (getprop("/earthview/show-n3") == 0)
	{cloudsphere_model.node3.remove();}

if (getprop("/earthview/show-n4") == 0)
	{cloudsphere_model.node4.remove();}

if (getprop("/earthview/show-s1") == 0)
	{cloudsphere_model.node5.remove();}

if (getprop("/earthview/show-s2") == 0)
	{cloudsphere_model.node6.remove();}

if (getprop("/earthview/show-s3") == 0)
	{cloudsphere_model.node7.remove();}

if (getprop("/earthview/show-s4") == 0)
	{cloudsphere_model.node8.remove();}

}

# load of individual tile

var load_sector = func (i, n) {

var action = n.getValue();

if (action)
	{
	var lat = getprop("/position/latitude-deg");
	var lon = getprop("/position/longitude-deg");
	
	if (i==1)
		{
		earth_model.node1 = place_earth_model("Models/Astro/earth_N1.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node1 = place_earth_model("Models/Astro/clouds_N1.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		}
	else if (i==2)
		{
		earth_model.node2 = place_earth_model("Models/Astro/earth_N2.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node2 = place_earth_model("Models/Astro/clouds_N2.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		}
	else if (i==3)
		{
		earth_model.node3 = place_earth_model("Models/Astro/earth_N3.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		cloudsphere_model.node3 = place_earth_model("Models/Astro/clouds_N3.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		}
	else if (i==4)
		{
		earth_model.node4 = place_earth_model("Models/Astro/earth_N4.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node4 = place_earth_model("Models/Astro/clouds_N4.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		}
	else if (i==5)
		{
		earth_model.node5 = place_earth_model("Models/Astro/earth_S1.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node5 = place_earth_model("Models/Astro/clouds_S1.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		}
	else if (i==6)
		{
		earth_model.node6 = place_earth_model("Models/Astro/earth_S2.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node6 = place_earth_model("Models/Astro/clouds_S2.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		}
	else if (i==7)
		{
		earth_model.node7 = place_earth_model("Models/Astro/earth_S3.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node7 = place_earth_model("Models/Astro/clouds_S3.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		}
	else if (i==8)
		{
		earth_model.node8 = place_earth_model("Models/Astro/earth_S4.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node8 = place_earth_model("Models/Astro/clouds_S4.xml",lat, lon, 0.0, 0.0, 0.0, 0.0);}
		}
	}
else 
	{
	if (i==1)
		{
		earth_model.node1.remove();
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node1.remove();}
		}
	else if (i==2)
		{
		earth_model.node2.remove();
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node2.remove();}
		}
	else if (i==3)
		{	
		earth_model.node3.remove();
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node3.remove();}
		}
	else if (i==4)
		{
		earth_model.node4.remove();
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node4.remove();}
		}
	else if (i==5)
		{
		earth_model.node5.remove();
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node5.remove();}
		}
	else if (i==6)
		{
		earth_model.node6.remove();
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node6.remove();}
		}
	else if (i==7)
		{
		earth_model.node7.remove();
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node7.remove();}
		}
	else if (i==8)
		{
		earth_model.node8.remove();
		if (cloudsphere_rotated_flag == 0)
			{cloudsphere_model.node8.remove();}
		}
	}

}








var ft_to_m = 0.30480;
var m_to_ft = 1.0/ft_to_m;
var earth_model = {};
var cloudsphere_model = {};
var aurora_model = {};
var earthview_running_flag = 0;
var cloudsphere_rotated_flag = 0;

var center_N1 = {}; 
var center_N2 = {};
var center_N3 = {};
var center_N4 = {};
var center_S1 = {};
var center_S2 = {};
var center_S3 = {};
var center_S4 = {};


