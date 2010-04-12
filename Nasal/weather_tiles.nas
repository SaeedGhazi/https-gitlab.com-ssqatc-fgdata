####################################
# tile setup calls
####################################

####################################
# Altocumulus sky
####################################

var set_altocumulus_tile = func {

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)

local_weather.set_weather_station(blat, blon, 35000.0, 22.0, 14.0, 30.02);

# then draw the Altocumulus streaks, dense at 15.000 ft, sparse at 17.000 ft

local_weather.create_streak("Altocumulus",blat, blon, 15000.0+alt_offset,40,900.0,0.2, 40,900.0,0.2,0.0 ,1.0);
local_weather.create_streak("Altocumulus",blat, blon, 17000.0+alt_offset,18,1900.0,0.35,18,1900.0,0.35,0.0,1.0);
local_weather.randomize_pos("Altocumulus",1000.0,600.0,600.0,0.0);

# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}
}

####################################
# Overcast stratus sky
####################################

var set_overcast_stratus_tile = func {

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)

local_weather.set_weather_station(blat, blon, 10000.0, 14.0, 12.0, 29.78);

# then draw the Stratus layers

var size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Stratus"];
local_weather.create_streak("Stratus",blat, blon, 1500.0+alt_offset+size_offset,30,1200.0,0.2, 30,1200.0,0.2,0.0 ,1.0);
local_weather.randomize_pos("Stratus",0.0,600.0,600.0,0.0);

size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Stratus_structured"];
local_weather.create_streak("Stratus (structured)",blat, blon, 5000.0+alt_offset+size_offset,18,2500.0,0.3,18,2500.0,0.3,0.0,1.0);
local_weather.randomize_pos("Stratus (structured)",0.0,600.0,600.0,0.0);


# reduce visibility even more below lowest layer
# and add a slight drizzle by a nested effect volume

local_weather.create_effect_volume(3, blat, blon, 18000.0, 18000.0, 0.0, 0.0, 1800.0, 8000.0, -1, -1, -1, -1, 0);
local_weather.create_effect_volume(3, blat, blon, 14000.0, 14000.0, 0.0, 0.0, 1500.0, 6000.0, 0.1, -1, -1, -1,0 );

# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}

# start the effect volume loop

if (getprop(lw~"effect-loop-flag") == 0) 
{setprop(lw~"effect-loop-flag",1); local_weather.effect_volume_loop();}

}


####################################
# Incoming rainfront
####################################

var set_rainfront_tile = func {

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)
local_weather.set_weather_station(blat, blon, 9000.0, 14.0, 12.0, 990 * hp_to_inhg);

x = 15000.0; y = 20000.0;
local_weather.set_weather_station(blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 6000.0, 12.0, 10.0, 985 * hp_to_inhg);

x = -15000.0; y = 20000.0;
local_weather.set_weather_station(blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 6000.0, 12.0, 10.0, 990 * hp_to_inhg);

#  draw two Stratus layers

x = 0.0; y = -15000.0;
var size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Stratus"];
local_weather.create_streak("Stratus",blat, blon, 3000.0+alt_offset+size_offset,17,2500.0,0.2, 6,2000.0,0.2,alpha ,1.0);
local_weather.randomize_pos("Stratus",500.0,1100.0,1100.0,alpha);

x = 0.0; y = 0.0;
var size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Stratus"];
local_weather.create_streak("Stratus",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 2000.0+alt_offset+size_offset,40,1000.0,0.2, 10,1000.0,0.2,alpha ,1.0);
local_weather.randomize_pos("Stratus",300.0,600.0,600.0,alpha);

#  and a Nimbus layer with precipitation

x = 0.0; y = 15000.0;
var size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Nimbus"];
local_weather.create_layer("Nimbus", blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 1000.0+alt_offset, 500.0, 22000.0, 13000.0, alpha, 1.0, 0.2, 1, 1.0);

# set visibility and rain inside the precipitation area

local_weather.create_effect_volume(2, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 19000.0, 10000.0, alpha, 0.0, 2000.0, 5000.0, 0.1, -1, -1, -1,0 );
local_weather.create_effect_volume(2, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 16000.0, 7000.0, alpha, 0.0, 1500.0, 1500.0, 0.5, -1, -1, -1,0 );

# set visibility good above the clouds

local_weather.create_effect_volume(3, blat, blon, 20000.0, 20000.0, 0.0, 2100.0, 85000.0, 18000.0, -1, -1, -1, -1,0 );

# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}

# start the effect volume loop

if (getprop(lw~"effect-loop-flag") == 0) 
{setprop(lw~"effect-loop-flag",1); local_weather.effect_volume_loop();}

}


####################################
# Broken layers 
####################################

var set_broken_layers_tile = func {

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)
local_weather.set_weather_station(blat, blon, 20000.0, 14.0, 12.0, 1005 * hp_to_inhg);

# set the broken stratus layers

size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Stratus_structured"];

local_weather.create_streak("Stratus (structured)",blat, blon, 4000.0+alt_offset+size_offset,22,0.0,0.3,22,0.0,0.3,0.0,1.0);
local_weather.randomize_pos("Stratus (structured)",1000.0,20000.0,20000.0,0.0);

local_weather.create_streak("Stratus (structured)",blat, blon, 6000.0+alt_offset+size_offset,16,0.0,0.4,16,0.0,0.4,0.0,1.0);
local_weather.randomize_pos("Stratus (structured)",1000.0,20000.0,20000.0,0.0);

local_weather.create_streak("Stratus (structured)",blat, blon, 7000.0+alt_offset+size_offset,11,0.0,0.5,11,0.0,0.5,0.0,1.0);
local_weather.randomize_pos("Stratus (structured)",1000.0,20000.0,20000.0,0.0);

# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}
}


####################################
# Fair weather and Cumulus
####################################

var set_fair_weather_tile = func {

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)
local_weather.set_weather_station(blat, blon, 35000.0, 20.0, 16.0, 1018 * hp_to_inhg);


# add convective clouds

var strength = 1;
var n = int(4000 * strength); # calculate the number of placement tries from tile size 20x20km and strength
local_weather.create_cumosys(blat,blon, 3000.0+alt_offset,n, 20000.0);


# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}

}


####################################
# Glider's sky
####################################

var set_gliders_sky_tile = func {

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)
local_weather.set_weather_station(blat, blon, 35000.0, 20.0, 16.0, 1018 * hp_to_inhg);

# switch the placement of thermal effect volumes on
setprop(lw~"tmp/generate-thermal-lift-flag",1); 


# add convective clouds

var strength = 0.5;
var n = int(4000 * strength); # calculate the number of placement tries from tile size 20x20km and strength
local_weather.create_cumosys(blat,blon, 3000.0+alt_offset,n, 20000.0);


# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}

# start the effect volume loop

if (getprop(lw~"effect-loop-flag") == 0) 
{setprop(lw~"effect-loop-flag",1); local_weather.effect_volume_loop();}




}




####################################
# Summer rain
####################################

var set_summer_rain_tile = func {

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)
local_weather.set_weather_station(blat, blon, 25000.0, 25.0, 22.0, 1013 * hp_to_inhg);

# then add some developing thunderstorms
local_weather.create_streak("Cumulonimbus (rain)",blat, blon, 3000.0+alt_offset,3,0.0,1.0,3,0.0,1.0,0.0,1.0);
local_weather.randomize_pos("Cumulonimbus (rain)",0.0,20000.0,20000.0,0.0);


# add overdeveloped convective clouds

var strength = 1.5;
var n = int(4000 * strength); # calculate the number of placement tries from tile size 20x20km and strength
local_weather.create_cumosys(blat,blon, 3000.0+alt_offset,n, 20000.0);

# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}

# start the effect volume loop

if (getprop(lw~"effect-loop-flag") == 0) 
{setprop(lw~"effect-loop-flag",1); local_weather.effect_volume_loop();}


}

####################################
# Cold front
####################################


var set_coldfront_tile = func {


var lat = getprop("position/latitude-deg");
var lon = getprop("position/longitude-deg");
calc_geo(lat);

local_weather.create_streak("Altocumulus",lat, lon-0.05, 12000.0, 7, 800, 0.4, 13, 1100, 0.4, 30.0, 1.0);
local_weather.randomize_pos("Altocumulus",500.0,500.0,500.0,30.0);
local_weather.create_streak("Cumulus", lat,lon-0.1,3000,19,700.0,0.2,36,800.0,0.2,30.0,1.0);
local_weather.randomize_pos("Cumulus",600.0,600.0,600.0,30.0);
local_weather.create_streak("Cumulonimbus", lat,lon-0.12,2800,1,5000.0,0.2,3,6000.0,0.4,30.0,1.0);
local_weather.randomize_pos("Cumulonimbus",1000.0,1000.0,1000.0,30.0);
}

####################################
# Cirrus sky
####################################

var set_cirrus_sky_tile = func {

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop("position/latitude-deg");
var blon = getprop("position/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)

local_weather.set_weather_station(blat, blon, 20000.0, 20.0, 16.0, 29.80);

# visibility is slightly worse north, pressure is lower, so set additional stations

x = -10000.0; y = 18000.0; 
lat = blat + (y * math.cos(phi) - x * math.sin(phi)) * m_to_lat;
lon = blon + (x * math.cos(phi) + y * math.sin(phi)) * m_to_lon;
local_weather.set_weather_station(lat, lon, 18000.0, 20.0, 16.0, 29.75);

x = 10000.0; y = 18000.0; 
lat = blat + (y * math.cos(phi) - x * math.sin(phi)) * m_to_lat;
lon = blon + (x * math.cos(phi) + y * math.sin(phi)) * m_to_lon;
local_weather.set_weather_station(lat, lon, 18000.0, 20.0, 16.0, 29.75);

# now set up the clouds

x = 0.0; y = 0.0; 
local_weather.create_cloud("Cirrus", "Models/Weather/cirrus1.xml", blat + get_lat(x,y,phi), blon+get_lon(x,y,phi), 28000.0 + alt_offset,alpha, 0);

x = 7500.0; y = 1000.0; 
local_weather.create_cloud("Cirrus", "Models/Weather/cirrus2.xml", blat + get_lat(x,y,phi), blon+get_lon(x,y,phi), 28500.0 + alt_offset,alpha, 0);

x = 16000.0; y = -1000.0; 
local_weather.create_cloud("Cirrus", "Models/Weather/cirrus1.xml", blat + get_lat(x,y,phi), blon+get_lon(x,y,phi), 29500.0 + alt_offset,alpha, 0);

x = -16000.0; y = 2500.0; 
local_weather.create_cloud("Cirrus", "Models/Weather/cirrus1.xml",blat + get_lat(x,y,phi), blon+get_lon(x,y,phi), 30000.0 + alt_offset,alpha, 0);

x = 7000.0; y = 8000.0; 
local_weather.create_cloud("Cirrocumulus", "Models/Weather/cirrocumulus1.xml", blat + get_lat(x,y,phi), blon+get_lon(x,y,phi), 22000.0 + alt_offset,alpha, 0);

x = -3000.0; y = 9000.0; 
local_weather.create_cloud("Cirrocumulus", "Models/Weather/cirrocumulus1.xml", blat + get_lat(x,y,phi), blon+get_lon(x,y,phi), 21000.0 + alt_offset,alpha, 0);

x = -1000.0; y = 14000.0; 
local_weather.create_cloud("Cirrocumulus", "Models/Weather/cirrocumulus2.xml", blat + get_lat(x,y,phi), blon+get_lon(x,y,phi), 20000.0 + alt_offset,alpha, 0);

# add moderately strong convective clouds

var strength = 0.4;
var n = int(4000 * strength); # calculate the number of placement tries from tile size 20x20km and strength
local_weather.create_cumosys(blat,blon, 4000.0+alt_offset,n, 20000.0);

# start the interpolation loop

if (getprop(lw~"interpolation-loop-flag") == 0) 
{setprop(lw~"interpolation-loop-flag",1); local_weather.interpolation_loop();}
}

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


###################
# global variables
###################



var lat_to_m = 110952.0; # latitude degrees to meters
var m_to_lat = 9.01290648208234e-06; # meters to latitude degrees
var ft_to_m = 0.30480;
var m_to_ft = 1.0/ft_to_m;
var inhg_to_hp = 33.76389;
var hp_to_inhg = 1.0/inhg_to_hp;

var lon_to_m = 0.0; # needs to be calculated dynamically
var m_to_lon = 0.0; # we do this on startup
var lw = "/local-weather/";

