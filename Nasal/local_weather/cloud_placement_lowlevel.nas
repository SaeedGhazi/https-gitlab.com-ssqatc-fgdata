########################################################
# routines to set up, transform and manage advanced weather
# Thorsten Renk, April 2012
########################################################

# function			purpose
#
# create_undulatus		to create an undulating cloud pattern
# create_cumulus_alleys		to create an alley pattern of Cumulus clouds
# create_layer			to create a cloud layer with optional precipitation

###########################################################
# place an undulatus pattern 
###########################################################

var create_undulatus = func (type, blat, blong, balt, alt_var, nx, xoffset, edgex, x_var, ny, yoffset, edgey, y_var, und_strength, direction, tri) {

var flag = 0;
var path = "Models/Weather/blank.ac";
local_weather.calc_geo(blat);
var dir = direction * math.pi/180.0;

var ymin = -0.5 * ny * yoffset;
var xmin = -0.5 * nx * xoffset;
var xinc = xoffset * (tri-1.0) /ny;
 
var jlow = int(nx*edgex);
var ilow = int(ny*edgey);

var und = 0.0;
var und_array = [];

for (var i=0; i<ny; i=i+1)
	{
	und = und + 2.0 * (rand() -0.5) * und_strength;
	append(und_array,und);
	}

for (var i=0; i<ny; i=i+1)
	{
	var y = ymin + i * yoffset + 2.0 * (rand() -0.5) * 0.2 * yoffset; 
	
	for (var j=0; j<nx; j=j+1)
		{
		var y0 = y + y_var * 2.0 * (rand() -0.5);
		var x = xmin + j * (xoffset + i * xinc) + x_var * 2.0 * (rand() -0.5) + und_array[i];
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
			if (thread_flag == 1)
				{create_cloud_vec(path, lat, long, alt, 0.0);}
			else
				{local_weather.create_cloud(path, lat, long, alt, 0.0);}
			

				}
		}

	} 

}



###########################################################
# place a Cumulus alley pattern 
###########################################################

var create_cumulus_alleys = func (blat, blon, balt, alt_var, nx, xoffset, edgex, x_var, ny, yoffset, edgey, y_var, und_strength, direction, tri) {

var flag = 0;
var path = "Models/Weather/blank.ac";
local_weather.calc_geo(blat);
var dir = direction * math.pi/180.0;

var ymin = -0.5 * ny * yoffset;
var xmin = -0.5 * nx * xoffset;
var xinc = xoffset * (tri-1.0) /ny;
 
var jlow = int(nx*edgex);
var ilow = int(ny*edgey);

var und = 0.0;
var und_array = [];

var spacing = 0.0;
var spacing_array = [];


for (var i=0; i<ny; i=i+1)
	{
	und = und + 2.0 * (rand() -0.5) * und_strength;
	append(und_array,und);
	}

for (var i=0; i<nx; i=i+1)
	{
	spacing = spacing + 2.0 * (rand() -0.5) * 0.5 * xoffset;
	append(spacing_array,spacing);
	}


for (var i=0; i<ny; i=i+1)
	{
	var y = ymin + i * yoffset; 
	var xshift = 2.0 * (rand() -0.5) * 0.5 * xoffset; 
	x_var = 0.0; xshift = 0.0;

	for (var j=0; j<nx; j=j+1)
		{
		var y0 = y + y_var * 2.0 * (rand() -0.5);
		var x = xmin + j * (xoffset + i * xinc) + x_var * 2.0 * (rand() -0.5) + spacing_array[j] + und_array[i];
		var lat = blat + m_to_lat * (y0 * math.cos(dir) - x * math.sin(dir));
		var lon = blon + m_to_lon * (x * math.cos(dir) + y0 * math.sin(dir));

		var alt = balt + alt_var * 2 * (rand() - 0.5);
		
		flag = 0;
		var strength = 0.0;
		var rn = 6.0 * rand();

		if (((j<jlow) or (j>(nx-jlow-1))) and ((i<ilow) or (i>(ny-ilow-1)))) # select a small or no cloud		
			{
			if (rn > 2.0) {flag = 1;} else {strength = 0.3 + rand() * 0.5;}
			}
		if ((j<jlow) or (j>(nx-jlow-1)) or (i<ilow) or (i>(ny-ilow-1))) 	
			{
			if (rn > 5.0) {flag = 1;} else {strength = 0.7 + rand() * 0.5;}
			}
		else	{ # select a large cloud
			if (rn > 5.0) {flag = 1;} else {strength = 1.1 + rand() * 0.6;}
			}


		if (flag==0){create_detailed_cumulus_cloud(lat, lon, alt, strength); }
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

#print("density: ",n);

phi = phi * math.pi/180.0;

if (contains(local_weather.cloud_vertical_size_map, type)) 
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
			if (thread_flag == 1)
				{create_cloud_vec(path, lat, lon, alt, 0.0);}
			else
				{compat_layer.create_cloud(path, lat, lon, alt, 0.0);}
				}
			}
		else {
			path = select_cloud_model(type,"large");
			if (thread_flag == 1)
				{create_cloud_vec(path, lat, lon, alt, 0.0);}
			else 
				{compat_layer.create_cloud(path, lat, lon, alt, 0.0);}
			}
		i = i + 1;
		}
	}

i = 0;

if (rainflag ==1){

if (local_weather.hardcoded_clouds_flag == 1) {balt = balt + local_weather.offset_map[type]; }

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
		
		if (thread_flag == 1)
		{create_cloud_vec(path, lat, lon,balt +0.5*bthick+ alt_shift, 0.0);}		
		else		
		{compat_layer.create_cloud(path, lat, lon, balt + 0.5 * bthick + alt_shift, 0.0);}
		i = i + 1;
		} # end while	
	} # end if (rainflag ==1)
}

