########################################################
# routines to simulate cloud wind drift and evolution
# Thorsten Renk, July 2010
########################################################

# function			purpose
#
# get_windfield			to get the current wind in the tile
# timing_loop			to provide accurate timing information for wind drift calculations
# quadtree_loop			to manage drift of clouds in the field of view
# weather_dynamics_loop		to manage drift of weather effects, tile centers and interpolation points
# generate_quadtree_structure	to generate a quadtree data structure used for managing the visual field
# sort_into_quadtree		to sort objects into a quadtree structure
# quadtree_recursion		to search the quadtree for objects in the visual field
# check_visibility		to check if a quadrant is currently visible
# move_tile			to move tile coordinates in the wind
# move_effect_volume		to move an effect volume in the wind
# move_weather_station		to move a weather station in the wind
# get_cartesian			to get local Cartesian coordinates out of coordinates


####################################################
# get the windfield for a given locatio and altitude
# (currently constant, but supposed to be local later)
####################################################


var get_windfield = func (tile_index) {

var windfield = [];



if ((local_weather.wind_model_flag == 1) or (local_weather.wind_model_flag == 3))
	{
	var windspeed = tile_wind_speed[0] * kt_to_ms;
	var wind_direction = tile_wind_direction[0];
	}
else if ((local_weather.wind_model_flag ==2) or (local_weather.wind_model_flag == 4) or (local_weather.wind_model_flag == 5))
	{
	var windspeed = tile_wind_speed[tile_index-1] * kt_to_ms;
	var wind_direction = tile_wind_direction[tile_index-1];
	}



var windfield_x = -windspeed * math.sin(wind_direction * math.pi/180.0);
var windfield_y = -windspeed * math.cos(wind_direction * math.pi/180.0);

append(windfield,windfield_x);
append(windfield,windfield_y);

return windfield;
}


########################################################
# timing loop
# this gets the accurate time since the start of weather dynamics
# and hence the timestamps for cloud evolution since
# the available elapsed-time-sec is not accurate enough
########################################################

var timing_loop = func {

time_lw = time_lw + getprop("/sim/time/delta-sec");

if (getprop(lw~"timing-loop-flag") ==1) {settimer(timing_loop, 0);}

}


###########################################################
# quadtree loop
# the quadtree loop is a fast loop updating the position
# of visible objects in the field of view only
###########################################################

var quadtree_loop = func {


var vangle = 0.55 * getprop("/sim/current-view/field-of-view");
var viewdir = getprop("/sim/current-view/goal-heading-offset-deg");
var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
var course = getprop("orientation/heading-deg");

cloud_counter = 0;

# pre-calculate trigonometry 

tan_vangle = math.tan(vangle * math.pi/180.0);



# use the quadtree to move clouds inside the field of view

var tiles = props.globals.getNode(lw~"tiles").getChildren("tile");


foreach (t; tiles)
	{
	var generated_flag = t.getNode("generated-flag").getValue();
	
	if ((generated_flag == 1) or (generated_flag ==2))
		{
		var index = t.getNode("tile-index").getValue();
		current_tile_index_wd = index;

		var blat = t.getNode("latitude-deg").getValue();
		var blon = t.getNode("longitude-deg").getValue();
		var alpha = t.getNode("orientation-deg").getValue();
		var xy_vec = get_cartesian(blat, blon, alpha, lat, lon);

		var beta = course - alpha - viewdir ;
		cos_beta = math.cos(beta * math.pi/180.0);
		sin_beta = math.sin(beta * math.pi/180.0);
		plane_x = xy_vec[0]; plane_y = xy_vec[1];

		quadtree_recursion(cloudQuadtrees[index-1],0,1,0.0,0.0);
		}

	}


# dynamically adjust the range of the processed view field
# if there are plenty of moving clouds nearby, no one pays attention to the small motion of distant clouds
# price to pay is that some clouds appear to jump once they get into range

if (cloud_counter < 0.5 * max_clouds_in_loop) {view_distance = view_distance * 1.1;}
else if (cloud_counter > max_clouds_in_loop) {view_distance = view_distance * 0.9;}
if (view_distance > weather_tile_management.cloud_view_distance) {view_distance = weather_tile_management.cloud_view_distance;}

#print(cloud_counter, " ", view_distance/1000.0);

# shift the tile centers with the windfield

var tiles = props.globals.getNode("local-weather/tiles", 1).getChildren("tile");
foreach (t; tiles) {move_tile(t);}




# loop over

if (getprop(lw~"dynamics-loop-flag") ==1) {settimer(quadtree_loop, 0);}
}


###########################################################
# weather_dynamics_loop
# the weather dynamics loop is a slow loop updating
# position and state of invisible objects, currently
# effect volumes and weather stations
###########################################################



var weather_dynamics_loop = func (index) {

var n = 20;


var i_max = index + n;
if (i_max > local_weather.n_effectVolumeArray) {i_max = local_weather.n_effectVolumeArray;}

for (var i = index; i < i_max; i = i+1)
	{
	move_effect_volume(local_weather.effectVolumeArray[i]);
	}

index = index + n;
if (i >= local_weather.n_effectVolumeArray)  {index = 0;} 

var stations = props.globals.getNode(lw~"interpolation").getChildren("station");

foreach (s; stations)
	{
	move_weather_station(s);
	}

if (getprop(lw~"dynamics-loop-flag") ==1) {settimer( func {weather_dynamics_loop(index); },0);}

}


###########################################################
# generate quadtree structure
###########################################################

var generate_quadtree_structure = func (depth, tree_base_vec) {

var c_vec = [];

for (var i=0; i<4; i=i+1)
	{
	if (depth == quadtree_depth)
		{var c = [];}
	else
		{var c = generate_quadtree_structure(depth+1, tree_base_vec);}

	if (depth==0) 
		{append(tree_base_vec,c); }
	else	
		{append(c_vec,c); }	
	}

if (depth ==0) {return tree_base_vec;} else {return c_vec;}

}


###########################################################
# sort into quadtree
###########################################################

var sort_into_quadtree = func (blat, blon, alpha, lat, lon, tree, object) {

xy_vec = get_cartesian (blat, blon, alpha, lat, lon);

sorting_recursion (xy_vec[0], xy_vec[1], tree, object, 0);

}


var sorting_recursion = func (x, y, tree, object, depth) {

if (depth == quadtree_depth+1) {append(tree,object); return;}

var length_scale = 20000.0 / math.pow(2,depth);

# print("depth: ", depth, "x: ", x, "y: ",y);

if (y > 0.0) 
	{
	if (x < 0.0)
		{var v = tree[0]; x = x + 0.5 * length_scale; y = y - 0.5 * length_scale;}
	else
		{var v = tree[1]; x = x - 0.5 * length_scale; y = y - 0.5 * length_scale;}
	}
else
	{
	if (x < 0.0)
		{var v = tree[2]; x = x + 0.5 * length_scale; y = y + 0.5 * length_scale;}
	else
		{var v = tree[3]; x = x - 0.5 * length_scale; y = y + 0.5 * length_scale;}
	}

sorting_recursion(x, y, v, object, depth+1);

}


####################################################
# quadtree recursive search
####################################################

var quadtree_recursion = func (tree, depth, flag, qx, qy) {

# flag = 0: quadrant invisible, stop search
# flag = 1: quadrant partially visible, continue search with visibility tests
# flag = 2: quadrant fully visible, no further visibility test needed


if (depth == quadtree_depth +1)
	{
	foreach (var c; tree)
		{
		compat_layer.move_cloud(c, current_tile_index_wd);
		cloud_counter = cloud_counter + 1;
		}
	return;
	}



for (var i =0; i<4; i=i+1)
	{
	if (flag==2) {quadtree_recursion(tree[i], depth+1, flag, qx, qy);}
	else if (flag==1)
		{
		# compute the subquadrant coordinates
		var length_scale = 20000.0 / math.pow(2,depth);
		if (i==0) {var qxnew = qx - 0.5 * length_scale; var qynew = qy + 0.5 * length_scale;}
		else if (i==1) {var qxnew = qx + 0.5 * length_scale; var qynew = qy + 0.5 * length_scale;}
		else if (i==2) {var qxnew = qx - 0.5 * length_scale; var qynew = qy - 0.5 * length_scale;}
		else if (i==3) {var qxnew = qx + 0.5 * length_scale; var qynew = qy - 0.5 * length_scale;}
		

		var newflag = check_visibility(qxnew,qynew, length_scale);	

		if (newflag!=0) {quadtree_recursion(tree[i], depth+1, newflag, qxnew, qynew);}
		}
	}

}

####################################################
# quadrant visibility test
####################################################

var check_visibility = func (qx,qy, length_scale) {

# (qx,qy) are the quadrant coordinates in tile local Cartesian
# beta is the plane course in the tile local Cartesian

# the function returns a flag: 0: invisible 1:  partially visible, track further 2: fully visible



# first translate/rotate (qx,qy) into the plane system

qx = qx - plane_x; qy = qy - plane_y;

var x = qx * cos_beta - qy * sin_beta;
var y = qy * cos_beta + qx * sin_beta;

# now get the maximum and minimum quadrant extensions

var ang_factor = abs(cos_beta) + abs(sin_beta); # a square seen from an angle extends larger

var xmax = x + 0.5 * length_scale * ang_factor;
var xmin = x - 0.5 * length_scale * ang_factor;

var ymax = y + 0.5 * length_scale * ang_factor;
var ymin = y - 0.5 * length_scale * ang_factor;

# now do visibility checks

if ((ymax < 0.0) and (ymin < 0.0)) # quadrant is behind us, we can never see it
	{return 0;} 

if (ymin > view_distance) # the quadrant is beyond visible range
	{return 0;}

var xcomp_min = ymin * tan_vangle;
var xcomp_max = ymax * tan_vangle;

if ((ymax > 0.0) and (ymin < 0.0)) # object is at most partially visible, check if  in visual cone at ymax
	{
	if ((xmax < -xcomp_max) and (xmin < -xcomp_max)) {return 0;}
	if ((xmax > xcomp_max) and (xmin > xcomp_max)) {return 0;}
	return 1;		
	}

# now we know the quadrant must be in front

# check if invisible

if ((xmax < -xcomp_max) and (xmin < -xcomp_max)) {return 0;}
if ((xmax > xcomp_max) and (xmin > xcomp_max)) {return 0;}

# check if completely visible

if ((xmax > -xcomp_min) and (xmin > -xcomp_min) and (xmax < xcomp_min) and (xmin < xcomp_min))
	{return 2;}

# at this point, it must be partially visible

return 1;
}

####################################################
# move a tile
####################################################

var move_tile = func (t) {

# get the old spacetime position of the tile

var lat_old = t.getNode("latitude-deg").getValue();
var lon_old = t.getNode("longitude-deg").getValue();
var timestamp = t.getNode("timestamp-sec").getValue();

var tile_index = t.getNode("tile-index").getValue();

# if the tile is not yet generated, we use the windfield of the tile we're in

if (tile_index == -1)
	{
	tile_index = props.globals.getNode(lw~"tiles").getChild("tile",4).getNode("tile-index").getValue();
	}

# get windfield and time since last update

var windfield = get_windfield(tile_index);
var dt = time_lw - timestamp;


# update the spacetime position of the tile

t.getNode("latitude-deg",1).setValue(lat_old + windfield[1] * dt * local_weather.m_to_lat);
t.getNode("longitude-deg",1).setValue(lon_old + windfield[0] * dt * local_weather.m_to_lon);
t.getNode("timestamp-sec",1).setValue(weather_dynamics.time_lw);

}


####################################################
# move an effect volume
####################################################

var move_effect_volume = func (e) {

# get the old spacetime position of the effect

var lat_old = e.getNode("position/latitude-deg").getValue();
var lon_old = e.getNode("position/longitude-deg").getValue();
var tile_index = e.getNode("tile-index").getValue();
var timestamp = e.getNode("timestamp-sec").getValue();

# get windfield and time since last update

var windfield = weather_dynamics.get_windfield(tile_index);
var dt = weather_dynamics.time_lw - timestamp;


# update the spacetime position of the effect

e.getNode("position/latitude-deg",1).setValue(lat_old + windfield[1] * dt * local_weather.m_to_lat);
e.getNode("position/longitude-deg",1).setValue(lon_old + windfield[0] * dt * local_weather.m_to_lon);
e.getNode("timestamp-sec",1).setValue(weather_dynamics.time_lw);
}


####################################################
# move a weather station
####################################################

var move_weather_station = func (s) {

# get the old spacetime position of the station

var lat_old = s.getNode("latitude-deg").getValue();
var lon_old = s.getNode("longitude-deg").getValue();
var tile_index = s.getNode("tile-index").getValue();
var timestamp = s.getNode("timestamp-sec").getValue();

# get windfield and time since last update

var windfield = weather_dynamics.get_windfield(tile_index);
var dt = weather_dynamics.time_lw - timestamp;


# update the spacetime position of the effect

s.getNode("latitude-deg",1).setValue(lat_old + windfield[1] * dt * local_weather.m_to_lat);
s.getNode("longitude-deg",1).setValue(lon_old + windfield[0] * dt * local_weather.m_to_lon);
s.getNode("timestamp-sec",1).setValue(weather_dynamics.time_lw);
}


###########################################################
# get local Cartesian coordinates
###########################################################

var get_cartesian = func (blat, blon, alpha, lat, lon) {

var xy_vec = [];

var phi = alpha * math.pi/180.0;

var delta_lat = lat - blat;
var delta_lon = lon - blon;

var x1 = delta_lon * lon_to_m;
var y1 = delta_lat * lat_to_m;

var x = x1 * math.cos(phi) - y1 * math.sin(phi);
var y = y1 * math.cos(phi) + x1 * math.sin(phi);

append(xy_vec,x);
append(xy_vec,y);

return xy_vec;

}


################################
# globals, constants, properties
################################



var lat_to_m = 110952.0; # latitude degrees to meters
var m_to_lat = 9.01290648208234e-06; # meters to latitude degrees
var ft_to_m = 0.30480;
var m_to_ft = 1.0/ft_to_m;
var inhg_to_hp = 33.76389;
var hp_to_inhg = 1.0/inhg_to_hp;

var kt_to_ms = 0.514;
var ms_to_kt = 1./kt_to_ms; 

var lon_to_m = 0.0; # needs to be calculated dynamically
var m_to_lon = 0.0; # we do this on startup

# abbreviations

var lw = "/local-weather/";


# globals

var time_lw = 0.0;
var max_clouds_in_loop = 250;

# the quadtree structure

var cloudQuadtrees = [];
var quadtree_depth = 3; 

# the wind info for the individual weather tiles 
# (used for 'constant in tile' wind model)

var tile_wind_direction = [];
var tile_wind_speed = [];

# define these as global, as we need to evaluate them only once per frame
# but use them over and over

var tan_vangle = 0;
var cos_beta = 0;
var sin_beta = 0;
var plane_x = 0;
var plane_y = 0;

var current_tile_index_wd = 0;

var cloud_counter = 0;
var view_distance = 30000.0;

# create the loop flags

setprop(lw~"timing-loop-flag",0);
setprop(lw~"dynamics-loop-flag",0);
