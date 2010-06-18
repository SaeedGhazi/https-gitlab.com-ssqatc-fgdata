####################################
# tile setup calls
####################################

var tile_start = func {

if (getprop(lw~"tmp/thread-flag") == 1){setprop(lw~"tmp/thread-status","computing");}

}

var tile_finished = func {

setprop(lw~"clouds/placement-index",0);
setsize(elat,0); setsize(elon,0); setsize(erad,0);

if (getprop(lw~"tmp/thread-flag") == 1){setprop(lw~"tmp/thread-status","placing");}
}





####################################
# test tile
####################################

var set_4_8_stratus_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)

local_weather.set_weather_station(blat, blon, 20000.0, 14.0, 12.0, 29.78);


create_2_8_cirrocumulus(blat, blon, 12000.0, alpha); 

#x = 2.0 * (rand()-0.5) * 12000;
#y = 2.0 * (rand()-0.5) * 12000;
#create_medium_thunderstorm(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), 3000.0+alt_offset, alpha);

#x = 2.0 * (rand()-0.5) * 12000;
#y = 2.0 * (rand()-0.5) * 12000;
#create_medium_thunderstorm(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), 3000.0+alt_offset, alpha);

# create_big_thunderstorm(blat, blon, 3000.0+alt_offset, alpha);




#var strength = 1.0;
#var n = int(4000 * strength) * 0.2;
#local_weather.cumulus_exclusion_layer(blat, blon, 3000.0+alt_offset, n, 20000.0, 20000.0, alpha, 0.0, 2.5, size(elat), elat, elon, erad);

# some turbulence below the convection layer

#local_weather.create_effect_volume(3, blat, blon, 20000.0, 20000.0, alpha, 0.0, 3500.0+alt_offset, -1, -1, -1, 0.4, -1,0 );

tile_finished();

}


####################################
# high pressure core
####################################

var set_high_pressure_core_tile = func {

tile_start();

setprop(lw~"tiles/code","high_pressure_core");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 35000.0 + rand() * 20000.0;
var T = 20.0 + rand() * 10.0;
var spread = 5.0 + 3.0 * rand();
var D = T - spread;
var p = 1025.0 + rand() * 6.0; p = adjust_p(p);

# and set them at the tile center
local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);

# weak cumulus development

var alt = spread * 1000;
var strength = rand() * 0.05;

local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);


tile_finished();

}


####################################
# high pressure 
####################################

var set_high_pressure_tile = func {

tile_start();

setprop(lw~"tiles/code","high_pressure");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 25000.0 + rand() * 15000.0;
var T = 15.0 + rand() * 10.0;
var spread = 4.0 + 2.0 * rand();
var D = T - spread;
var p = 1019.0 + rand() * 6.0; p = adjust_p(p);

# and set them at the tile center
local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);

# moderate cumulus development

var alt = spread * 1000;



var rn = rand();

if (rn > 0.5)
	{
	# cloud scenario 1: possible Cirrus over Cumulus
	var strength = 0.2 + rand() * 0.4;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);

	# if cumulus are weak, increase likelihood of Cirrus (the logic is the other way round
	# but this makes no difference and is easier to implement)

	# try to place two spatially separated Cirrus clouds

	if (rand() > 2.0 * strength)
		{
		x = 2000.0 + rand() * 16000.0;
		y = 2.0 * (rand()-0.5) * 18000;
		alt = 25000.0 + rand() * 5000.0;
		var path = local_weather.select_cloud_model("Cirrus", "small");
		local_weather.create_cloud("Cirrus", path, blat + get_lat(x,y,phi), blon+get_lon(x,y,phi),  alt + alt_offset,alpha, 0);
		}

	if (rand() > 2.0 * strength)
		{
		x = -2000.0 - rand() * 16000.0;
		y = 2.0 * (rand()-0.5) * 18000;
		alt = 25000.0 + rand() * 5000.0;
		var path = local_weather.select_cloud_model("Cirrus", "small");
		local_weather.create_cloud("Cirrus", path, blat + get_lat(x,y,phi), blon+get_lon(x,y,phi),  alt + alt_offset,alpha, 0);
		}
	}
else if (rn > 0.0)
	{
	# cloud scenario 2: Cirrostratus over weak Cumulus

	var strength = 0.2 + rand() * 0.2;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);

	create_2_8_cirrostratus(blat, blon, alt+alt_offset+25000.0, alpha);
	}

tile_finished();

}


####################################
# high pressure border
####################################

var set_high_pressure_border_tile = func {

tile_start();

setprop(lw~"tiles/code","high_pressure_border");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 20000.0 + rand() * 12000.0;
var T = 12.0 + rand() * 10.0;
var spread = 3.0 + 2.0 * rand();
var D = T - spread;
var p = 1013.0 + rand() * 6.0; p = adjust_p(p);

# and set them at the tile center
local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);


# now a random selection of different possible cloud configuration scenarios

var alt = spread * 1000;

var rn = rand();


if (rn > 0.833)
	{
	# cloud scenario 1: Altocumulus patch over weak Cumulus
	var strength = 0.1 + rand() * 0.1;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);

	x = 2.0 * (rand()-0.5) * 5000;
	y = 2.0 * (rand()-0.5) * 5000;
	local_weather.create_streak("Altocumulus",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 12000.0+alt+alt_offset,30,1000.0,0.2, 30,1000.0,0.2,alpha ,1.0);
	local_weather.randomize_pos("Altocumulus",1500.0,800.0,800.0,alpha);
	}
else if (rn > 0.666)
	{
	# cloud scenario 2: Altocumulus streaks
	var strength = 0.15 + rand() * 0.2;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);

	x = 2.0 * (rand()-0.5) * 10000;
	y = 2.0 * (rand()-0.5) * 10000;
	local_weather.create_streak("Altocumulus",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 12000.0+alt+alt_offset,25,700.0,0.2, 10,700.0,0.2,alpha ,1.4);
	x = 2.0 * (rand()-0.5) * 10000;
	y = 2.0 * (rand()-0.5) * 10000;
	local_weather.create_streak("Altocumulus",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 12000.0+alt+alt_offset,22,750.0,0.2, 8,750.0,0.2,alpha ,1.1);
	local_weather.randomize_pos("Altocumulus",1500.0,800.0,800.0,alpha);
	}
else if (rn > 0.5)
	{
	# cloud scenario 3: Cirrus

	var strength = 0.1 + rand() * 0.1;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);

	x = 2.0 * (rand()-0.5) * 3000;
	y = 2.0 * (rand()-0.5) * 3000;
	local_weather.create_streak("Cirrus",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 22000.0+alt+alt_offset,3,9000.0,0.0, 1,8000.0,0.0,alpha ,1.0);
	local_weather.randomize_pos("Cirrus",1500.0,800.0,800.0,alpha);
	}
else if (rn > 0.333)
	{
	# cloud scenario 4: Cumulonimbus banks

	var strength = 0.7 + rand() * 0.3;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);

	for (var i = 0; i < 3; i = i + 1)
		{
		x = 2.0 * (rand()-0.5) * 16000;
		y = 2.0 * (rand()-0.5) * 16000;
	
		create_cloud_bank("Cumulonimbus", blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset, 1600.0, 800.0, 3000.0, 9, alpha);
		}
	}
else if (rn > 0.166)
	{
	# cloud scenario 5: scattered Stratus

	var strength = 0.4 + rand() * 0.2;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);

	var size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Stratus_structured"];

	local_weather.create_streak("Stratus (structured)",blat, blon, alt+6000.0+alt_offset+size_offset,18,0.0,0.3,18,0.0,0.3,0.0,1.0);
	local_weather.randomize_pos("Stratus (structured)",1000.0,20000.0,20000.0,0.0);
	}
else if (rn > 0.0)
	{
	# cloud scenario 6: Cirrocumulus

	var strength = 0.2 + rand() * 0.2;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);
	
	x = 2.0 * (rand()-0.5) * 5000;
	y = 2.0 * (rand()-0.5) * 5000;


	var path = local_weather.select_cloud_model("Cirrocumulus", "large");
	local_weather.create_cloud("Cirrocumulus", path, blat + get_lat(x,y,phi), blon+get_lon(x,y,phi),  alt + alt_offset +22000,alpha, 0);

	}



tile_finished();

}

####################################
# low pressure border
####################################

var set_low_pressure_border_tile = func {

tile_start();

setprop(lw~"tiles/code","low_pressure_border");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;

if (getprop(lw~"tmp/presampling-flag") == 0)
	{var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");}
else
	{var alt_offset = getprop(lw~"tmp/tile-alt-layered-ft");}


# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 15000.0 + rand() * 10000.0;
var T = 10.0 + rand() * 10.0;
var spread = 2.0 + 2.0 * rand();
var D = T - spread;
var p = 1007.0 + rand() * 6.0; p = adjust_p(p);

# and set them at the tile center
local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;

# now a random selection of different possible cloud configuration scenarios

var rn = rand();

if (rn > 0.75)
	{
	# cloud scenario 1: a low 4/8 stratus patches, thin patches above

	alt = alt + local_weather.cloud_vertical_size_map["Stratus"] * 0.5 * m_to_ft;
	create_4_8_stratus_patches(blat, blon, alt+alt_offset,alpha);
	create_4_8_tstratus_patches(blat, blon, alt+alt_offset+6000,alpha);
	}
else if (rn > 0.5)
	{
	# cloud scenario 2: a low 4/8 undulatus, thin patches above

	alt = alt + local_weather.cloud_vertical_size_map["Stratus"] * 0.5 * m_to_ft;
	create_4_8_sstratus_undulatus(blat, blon, alt+alt_offset,alpha);
	create_2_8_tstratus(blat, blon, alt+alt_offset+7000,alpha);
	}
else if (rn > 0.25)
	{
	# cloud scenario 3: low Stratocumulus

	alt = alt + local_weather.cloud_vertical_size_map["Stratus"] * 0.5 * m_to_ft;
	create_stratocumulus_bank(blat, blon, alt+alt_offset,alpha);
	create_2_8_sstratus(blat, blon, alt+alt_offset+3000,alpha);
	create_2_8_tstratus(blat, blon, alt+alt_offset+9000,alpha);
	}
else if (rn > 0.0)
	{
	# cloud scenario 4: dense low Stratocumulus

	alt = alt + local_weather.cloud_vertical_size_map["Stratus"] * 0.5 * m_to_ft;
	create_stratocumulus_bank(blat, blon, alt+alt_offset,alpha);
	create_stratocumulus_bank(blat, blon, alt+alt_offset,alpha);
	create_2_8_sstratus(blat, blon, alt+alt_offset+8000,alpha);
	}


tile_finished();

}

####################################
# low pressure 
####################################

var set_low_pressure_tile = func {

tile_start();

setprop(lw~"tiles/code","low_pressure");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;


if (getprop(lw~"tmp/presampling-flag") == 0)
	{var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");}
else
	{var alt_offset = getprop(lw~"tmp/tile-alt-layered-ft");}

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 10000.0 + rand() * 10000.0;
var T = 5.0 + rand() * 10.0;
var spread = 1.0 + 2.0 * rand();
var D = T - spread;
var p = 1001.0 + rand() * 6.0; p = adjust_p(p);

# and set them at the tile center
local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;

var rn = rand();


if (rn > 0.75)
	{

	# cloud scenario 1: two patches of Nimbostratus with precipitation
	# overhead broken stratus layers
	# cloud count 1050

	x = 2.0 * (rand()-0.5) * 11000.0;
	y = 2.0 * (rand()-0.5) * 11000.0;
	var beta = rand() * 360.0;

	local_weather.create_layer("Nimbus", blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset, 500.0, 12000.0, 7000.0, beta, 1.0, 0.2, 1, 1.0);
	local_weather.create_effect_volume(2, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 10000.0, 6000.0, beta, 0.0, alt + alt_offset, 5000.0, 0.3, -1, -1, -1,0 );
	local_weather.create_effect_volume(2, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 9000.0, 5000.0, beta, 0.0, alt+alt_offset-300.0, 1500.0, 0.5, -1, -1, -1,0 );

	x = 2.0 * (rand()-0.5) * 11000.0;
	y = 2.0 * (rand()-0.5) * 11000.0;
	var beta = rand() * 360.0;

	local_weather.create_layer("Nimbus", blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset, 500.0, 10000.0, 6000.0, beta, 1.0, 0.2, 1, 1.0);
	local_weather.create_effect_volume(2, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 9000.0, 5000.0, beta, 0.0, alt + alt_offset, 5000.0, 0.3, -1, -1, -1,0 );
	local_weather.create_effect_volume(2, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 8000.0, 4000.0, beta, 0.0, alt+alt_offset-300.0, 1500.0, 0.5, -1, -1, -1,0 );

	create_4_8_sstratus_undulatus(blat, blon, alt+alt_offset +3000.0, alpha);
	create_2_8_tstratus(blat, blon, alt+alt_offset +6000.0, alpha);
	}
else if (rn >0.5)
	{
	# cloud scenario 2: 8/8 Stratus with light precipitation
	# above broken cover
	# cloud count 1180

	alt = alt + local_weather.cloud_vertical_size_map["Stratus"] * 0.5 * m_to_ft;
	create_8_8_stratus(blat, blon, alt+alt_offset,alpha);
	local_weather.create_effect_volume(3, blat, blon, 18000.0, 18000.0, 0.0, 0.0, 1800.0, 8000.0, -1, -1, -1, -1, 0);
	local_weather.create_effect_volume(3, blat, blon, 14000.0, 14000.0, 0.0, 0.0, 1500.0, 6000.0, 0.1, -1, -1, -1,0 );
	create_2_8_sstratus(blat, blon, alt+alt_offset+3000,alpha);
	}
else if (rn >0.25)
	{
	# cloud scenario 3: multiple broken layers
	# cloud count 1350

	alt = alt + local_weather.cloud_vertical_size_map["Stratus"] * 0.5 * m_to_ft;
	create_4_8_stratus(blat, blon, alt+alt_offset,alpha);
	create_4_8_stratus_patches(blat, blon, alt+alt_offset+3000,alpha);
	create_4_8_sstratus_undulatus(blat, blon, alt+alt_offset+6000,alpha);
	create_2_8_tstratus(blat, blon, alt+alt_offset+8000,alpha);
	}
else if (rn >0.0)
	{
	# cloud scenario 4: a low 6/8 layer and some clouds above
	# cloud count 650

	alt = alt + local_weather.cloud_vertical_size_map["Stratus"] * 0.5 * m_to_ft;
	create_6_8_stratus(blat, blon, alt+alt_offset,alpha);
	create_2_8_sstratus(blat, blon, alt+alt_offset+6000,alpha);
	}
	
tile_finished();

}


####################################
# low pressure core
####################################

var set_low_pressure_core_tile = func {

tile_start();

setprop(lw~"tiles/code","low_pressure_core");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;

if (getprop(lw~"tmp/presampling-flag") == 0)
	{var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");}
else
	{var alt_offset = getprop(lw~"tmp/tile-alt-layered-ft");}

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 8000.0 + rand() * 7000.0;
var T = 3.0 + rand() * 7.0;
var spread = 1.0 + 1.0 * rand();
var D = T - spread;
var p = 995.0 + rand() * 6.0; p = adjust_p(p);

# and set them at the tile center
local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);


# set a closed Nimbostratus layer

var alt = spread * 1000.0 + local_weather.cloud_vertical_size_map["Nimbus"] * 0.5 * m_to_ft;

#print("alt: ",spread*1000);

create_8_8_nimbus(blat, blon, alt+alt_offset, alpha);

# and a precipitation layer below, more rain in the center of the tile

local_weather.create_effect_volume(3, blat, blon, 20000.0, 20000.0, alpha, 0.0, alt + alt_offset, 3000.0, 0.3, -1, -1, -1,0 );
local_weather.create_effect_volume(3, blat , blon, 16000.0, 16000.0, alpha, 0.0, alt + alt_offset - 300.0, 1500.0, 0.5, -1, -1, -1,0 );


# and some broken Stratus cover above

var rn = rand();

if (rn > 0.5){create_4_8_stratus_patches(blat, blon, alt+alt_offset+3000.0, alpha);}
else {create_4_8_stratus(blat, blon, alt+alt_offset+3000.0, alpha);}


tile_finished();

}


####################################
# cold sector
####################################

var set_cold_sector_tile = func {

tile_start();

setprop(lw~"tiles/code","cold_sector");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 35000.0 + rand() * 20000.0;
var T = 8.0 + rand() * 8.0;
var spread = 3.0 + 2.0 * rand();
var D = T - spread;
var p = 1005.0 + rand() * 10.0; p = adjust_p(p);

# and set them at the tile center
local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;

var rn = rand();


if (rn > 0.0)
	{
	# cloud scenario 1: strong Cumulus development
	var strength = 0.8 + rand() * 0.2;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);
	}

tile_finished();

}


####################################
# Warm sector
####################################

var set_warm_sector_tile = func {

tile_start();

setprop(lw~"tiles/code","warm_sector");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 15000.0 + rand() * 10000.0;
var T = 16.0 + rand() * 10.0;
var spread = 2.0 + 2.0 * rand();
var D = T - spread;
var p = 1005.0 + rand() * 10.0; p = adjust_p(p);

# and set them at the tile center
local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;

var rn = rand();


if (rn > 0.0)
	{
	# cloud scenario 1: weak Cumulus development, some Cirrostratus
	var strength = 0.3 + rand() * 0.2;
	local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);
	create_4_8_cirrostratus_patches(blat, blon, alt+alt_offset+25000.0, alpha);
	}

tile_finished();

}



####################################
# Tropical weather
####################################

var set_tropical_weather_tile = func {

tile_start();

setprop(lw~"tiles/code","tropical_weather");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var sec_to_rad = 2.0 * math.pi/86400; # conversion factor for sinusoidal dependence on daytime

# get the local time of the day in seconds

var t = getprop("sim/time/utc/day-seconds");
t = t + getprop("sim/time/local-offset");

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 10000.0 + rand() * 10000.0;
var T = 20.0 + rand() * 15.0;
var spread = 3.0 + 2.0 * rand();
var D = T - spread;
var p = 970 + rand() * 10.0; p = adjust_p(p);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)

local_weather.set_weather_station(blat, blon, vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;

# tropical weather has a strong daily variation, call thunderstorm only in the correct afternoon time window

var t_factor = 0.5 * (1.0-math.cos((t * sec_to_rad)-0.9)); 

var rn = rand();

if (rn > (t_factor * t_factor * t_factor * t_factor)) # call a normal convective cloud system
{
var strength = 1.0 + rand() * 0.2;
local_weather.create_cumosys(blat,blon, alt + alt_offset, get_n(strength), 20000.0);
}

else 
{

# a random selection of different possible thunderstorm cloud configuration scenarios

rn = rand();

if (rn > 0.2)
	{
	# cloud scenario 1: 1-2 medium sized storms

	x = 2.0 * (rand()-0.5) * 12000;
	y = 2.0 * (rand()-0.5) * 12000;

	if (rand() > 0.6)
		{create_medium_thunderstorm(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), alt+alt_offset, alpha);}
	else	
		{create_small_thunderstorm(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), alt+alt_offset, alpha);}

	if (rand() > 0.5) # we do a second thunderstorm
		{
		x = 2.0 * (rand()-0.5) * 12000;
		y = 2.0 * (rand()-0.5) * 12000;
		if (rand() > 0.8)
			{create_medium_thunderstorm(blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset, alpha);}
		else
			{create_small_thunderstorm(blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset, alpha);}
		}
	}
else if (rn > 0.0)
	{
	# cloud scenario 1: Single big storm

	x = 2.0 * (rand()-0.5) * 12000;
	y = 2.0 * (rand()-0.5) * 12000;

	create_big_thunderstorm(blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset, alpha);
	}


# the convective layer

var strength = 0.5 * t_factor;
var n = int(4000 * strength) * 0.2;
local_weather.cumulus_exclusion_layer(blat, blon, alt+alt_offset, n, 20000.0, 20000.0, alpha, 0.3,1.4 , size(elat), elat, elon, erad);
local_weather.cumulus_exclusion_layer(blat, blon, alt+alt_offset, n, 20000.0, 20000.0, alpha, 1.9,2.5 , size(elat), elat, elon, erad);

# some turbulence in the convection layer

local_weather.create_effect_volume(3, blat, blon, 20000.0, 20000.0, alpha, 0.0, alt+3000.0+alt_offset, -1, -1, -1, 0.4, -1,0 );

} # end thundercloud placement

tile_finished();

}


####################################
# Coldfront
####################################


var set_coldfront_tile = func {

tile_start();

setprop(lw~"tiles/code","coldfront");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;



var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 20000.0 + rand() * 10000.0;
var T = 20.0 + rand() * 8.0;
var spread = 3.0 + 2.0 * rand();
var D = T - spread;
var p = 1005 + rand() * 10.0; p = adjust_p(p);

# first weather info for tile  (lat, lon, visibility, temperature, dew point, pressure)

# after the front

x = 15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T-3.0, D-3.0, p * hp_to_inhg);

x = -15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T-3.0, D-3.0, p * hp_to_inhg);

# before the front

x = 15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis*0.7, T+3.0, D+3.0, (p-2.0) * hp_to_inhg);

x = -15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis*0.7, T+3.0, D+3.0, (p-2.0) * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;

# thunderstorms first

for (var i =0; i < 3; i=i+1)
	{
	x = 2.0 * (rand()-0.5) * 15000;
	y = 2.0 * (rand()-0.5) * 2000 + 5000.0;
	if (rand() > 0.7)
		{create_medium_thunderstorm(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), alt+alt_offset, alpha);}
	else	
		{create_small_thunderstorm(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), alt+alt_offset, alpha);}
	}

# next the dense cloud layer underneath the thunderstorms

x = 0.0;
y = 5000.0;

var strength = 0.3;
var n = int(4000 * strength) * 0.2;
local_weather.cumulus_exclusion_layer(blat+get_lat(x,y,phi), blon+ get_lon(x,y,phi), alt+alt_offset, n, 20000.0, 10000.0, alpha, 2.1,2.5 , size(elat), elat, elon, erad);

# then leading and traling Cumulus

x = 0.0;
y = 15500.0;

strength = 1.0;
n = int(4000 * strength) * 0.15;
local_weather.cumulus_exclusion_layer(blat+get_lat(x,y,phi), blon+ get_lon(x,y,phi), alt+alt_offset, n, 20000.0, 2000.0, alpha, 0.5,1.4 , size(elat), elat, elon, erad);

x = 0.0;
y = -5500.0;

strength = 1.0;
n = int(4000 * strength) * 0.15;
local_weather.cumulus_exclusion_layer(blat+get_lat(x,y,phi), blon+ get_lon(x,y,phi), alt+alt_offset, n, 20000.0, 2000.0, alpha, 0.5,1.4 , size(elat), elat, elon, erad);

# finally some thin stratus underneath the Cumulus

x = 0.0;
y = 13000.0;
local_weather.create_streak("Stratus (thin)",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset,20,2000.0,0.2,3,1500.0,0.2,alpha,1.0);
local_weather.randomize_pos("Stratus (thin)",0.0,1200.0,1200.0,0.0);

x = 0.0;
y = -3000.0;
local_weather.create_streak("Stratus (thin)",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset,20,2000.0,0.2,3,1500.0,0.2,alpha,1.0);
local_weather.randomize_pos("Stratus (thin)",0.0,1200.0,1200.0,0.0);

# some turbulence in the convection layer

x=0.0; y = 5000.0;
local_weather.create_effect_volume(3, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 20000.0, 11000.0, alpha, 0.0, alt+3000.0+alt_offset, -1, -1, -1, 0.4, -1,0 );

# some rain and reduced visibility in its core 

x=0.0; y = 5000.0;
local_weather.create_effect_volume(3, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 20000.0, 8000.0, alpha, 0.0, alt+alt_offset, 10000.0, 0.1, -1, -1, -1,0 );

tile_finished();

}


####################################
# Warmfront 1
####################################


var set_warmfront1_tile = func {

tile_start();

setprop(lw~"tiles/code","warmfront1");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;



var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;

if (getprop(lw~"tmp/presampling-flag") == 0)
	{var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");}
else
	{var alt_offset = getprop(lw~"tmp/tile-alt-layered-ft");}

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 20000.0 + rand() * 5000.0;
var T = 10.0 + rand() * 8.0;
var spread = 3.0 + 3.0 * rand();
var D = T - spread;
var p = 1005 + rand() * 10.0; p = adjust_p(p);

# first weather info for tile  (lat, lon, visibility, temperature, dew point, pressure)

# after the front

x = 15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T+2.0, D+1.0, p * hp_to_inhg);

x = -15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T+2.0, D+1.0, p * hp_to_inhg);

# before the front

x = 15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T, D, p * hp_to_inhg);

x = -15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;

# high Cirrus leading

x = 2.0 * (rand()-0.5) * 3000;
y = 2.0 * (rand()-0.5) * 3000 - 12000.0; 
	

local_weather.create_streak("Cirrus",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 25000.0+alt+alt_offset,3,11000.0,0.0, 1,8000.0,0.0,alpha ,1.0);
local_weather.randomize_pos("Cirrus",1500.0,800.0,10000.0,alpha);

# followed by random patches of Cirrostratus

for (var i=0; i<6; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 15000;
	var y = 2.0 * (rand()-0.5) * 10000 + 10000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Cirrostratus",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 18000 + alt + alt_offset,4,2300.0,0.2,4,2300.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Cirrostratus",300.0,600.0,600.0,alpha+beta);
	}

tile_finished();

}


####################################
# Warmfront 2
####################################


var set_warmfront2_tile = func {

tile_start();

setprop(lw~"tiles/code","warmfront2");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;



var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;

if (getprop(lw~"tmp/presampling-flag") == 0)
	{var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");}
else
	{var alt_offset = getprop(lw~"tmp/tile-alt-layered-ft");}

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 15000.0 + rand() * 5000.0;
var T = 13.0 + rand() * 8.0;
var spread = 2.0 + 2.0 * rand();
var D = T - spread;
var p = 1005 + rand() * 10.0; p = adjust_p(p);

# first weather info for tile  (lat, lon, visibility, temperature, dew point, pressure)

# after the front

x = 15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T+2.0, D+1.0, p * hp_to_inhg);

x = -15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T+2.0, D+1.0, p * hp_to_inhg);

# before the front

x = 15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T, D, p * hp_to_inhg);

x = -15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;


# followed by random patches of Cirrostratus

for (var i=0; i<3; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 18000;
	var y = 2.0 * (rand()-0.5) * 5000 - 15000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Cirrostratus",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 15000 + alt + alt_offset,4,2300.0,0.2,4,2300.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Cirrostratus",300.0,600.0,600.0,alpha+beta);
	}

# patches of thin Altostratus

for (var i=0; i<14; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 18000;
	var y = 2.0 * (rand()-0.5) * 9000 - 10000.0;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Stratus (thin)",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset +12000.0,4,950.0,0.2,6,950.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Stratus (thin)",300.0,500.0,500.0,alpha+beta);
	}

# patches of structured Stratus

for (var i=0; i<10; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 9000;
	var y = 2.0 * (rand()-0.5) * 9000 + 2000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Stratus (structured)",blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset+9000.0,5,900.0,0.2,7,900.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Stratus (structured)",300.0,500.0,500.0,alpha+beta);
	}


# merging with a broken Stratus layer

var x = 0.0;
var y = 8000.0;

local_weather.create_streak("Stratus",blat +get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset +5000.0,30,0.0,0.2,10,0.0,0.2,alpha,1.0);
local_weather.randomize_pos("Stratus",1000.0,20000.0,12000.0,alpha);

tile_finished();

}


####################################
# Warmfront 3
####################################


var set_warmfront3_tile = func {

tile_start();

setprop(lw~"tiles/code","warmfront3");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;



var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;

if (getprop(lw~"tmp/presampling-flag") == 0)
	{var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");}
else
	{var alt_offset = getprop(lw~"tmp/tile-alt-layered-ft");}

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 12000.0 + rand() * 3000.0;
var T = 15.0 + rand() * 7.0;
var spread = 2.0 + 1.0 * rand();
var D = T - spread;
var p = 1005 + rand() * 10.0; p = adjust_p(p);

# first weather info for tile  (lat, lon, visibility, temperature, dew point, pressure)

# after the front

x = 15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T+2.0, D+1.0, p * hp_to_inhg);

x = -15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T+2.0, D+1.0, p * hp_to_inhg);

# before the front

x = 15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T, D, p * hp_to_inhg);

x = -15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;


# closed Stratus layer

var x = 0.0;
var y = -8000.0;

local_weather.create_streak("Stratus",blat +get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset +1000.0,32,1250.0,0.2,20,1250.0,0.2,alpha,1.0);
local_weather.randomize_pos("Stratus",500.0,400.0,400.0,alpha);




# merging with a Nimbostratus layer

var x = 0.0;
var y = 8000.0;

local_weather.create_streak("Nimbus",blat +get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset,32,1250.0,0.0,20,1250.0,0.0,alpha,1.0);
local_weather.randomize_pos("Nimbus",500.0,200.0,200.0,alpha);


# some rain beneath the stratus

x=0.0; y = -10000.0;
local_weather.create_effect_volume(3, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 20000.0, 10000.0, alpha, 0.0, alt+alt_offset+1000, vis * 0.7, 0.1, -1, -1, -1,0 );

# heavier rain beneath the Nimbostratus

x=0.0; y = 10000.0;
local_weather.create_effect_volume(3, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 20000.0, 10000.0, alpha, 0.0, alt+alt_offset, vis * 0.5, 0.3, -1, -1, -1,0 );

tile_finished();

}


####################################
# Warmfront 4
####################################


var set_warmfront4_tile = func {

tile_start();

setprop(lw~"tiles/code","warmfront4");

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;



var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;

if (getprop(lw~"tmp/presampling-flag") == 0)
	{var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");}
else
	{var alt_offset = getprop(lw~"tmp/tile-alt-layered-ft");}

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get probabilistic values for the weather parameters

var vis = 12000.0 + rand() * 3000.0;
var T = 17.0 + rand() * 6.0;
var spread = 1.0 + 1.0 * rand();
var D = T - spread;
var p = 1005 + rand() * 10.0; p = adjust_p(p);

# first weather info for tile  (lat, lon, visibility, temperature, dew point, pressure)

# after the front

x = 15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T+2.0, D+1.0, p * hp_to_inhg);

x = -15000.0; y = 15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T+2.0, D+1.0, p * hp_to_inhg);

# before the front

x = 15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T, D, p * hp_to_inhg);

x = -15000.0; y = -15000.0;
local_weather.set_weather_station(blat +get_lat(x,y,phi), blon + get_lon(x,y,phi), vis, T, D, p * hp_to_inhg);

# altitude for the lowest layer
var alt = spread * 1000.0;

# low Nimbostratus layer

var x = 0.0;
var y = -5000.0;

local_weather.create_streak("Nimbus",blat +get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset,32,1250.0,0.0,24,1250.0,0.0,alpha,1.0);
local_weather.randomize_pos("Nimbus",500.0,200.0,200.0,alpha);

# a little patchy structured Stratus above for effect

create_2_8_sstratus(blat, blon, alt+alt_offset+3000.0, alpha); 

# eventually breaking up

var x = 0.0;
var y = 14000.0;

local_weather.create_streak("Nimbus",blat +get_lat(x,y,phi), blon+get_lon(x,y,phi), alt+alt_offset,25,1600.0,0.2,9,1400.0,0.3,alpha,1.0);
local_weather.randomize_pos("Nimbus",500.0,200.0,200.0,alpha);


# rain beneath the Nimbostratus

x=0.0; y = -5000.0;
local_weather.create_effect_volume(3, blat+get_lat(x,y,phi), blon+get_lon(x,y,phi), 20000.0, 15000.0, alpha, 0.0, alt+alt_offset, vis * 0.5, 0.3, -1, -1, -1,0 );

tile_finished();

}


####################################
# Altocumulus sky
# cloud count 1400/tile
####################################

var set_altocumulus_tile = func {

tile_start();

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)

local_weather.set_weather_station(blat, blon, 35000.0, 22.0, 14.0, 30.02);

# then draw the Altocumulus streaks, dense at 15.000 ft, sparse at 17.000 ft

local_weather.create_streak("Altocumulus",blat, blon, 15000.0+alt_offset,40,1000.0,0.2, 40,1000.0,0.2,alpha ,1.0);
local_weather.create_streak("Altocumulus",blat, blon, 17000.0+alt_offset,18,2000.0,0.35,18,2000.0,0.35,alpha,1.0);
local_weather.randomize_pos("Altocumulus",1500.0,800.0,800.0,alpha);

tile_finished();

}




####################################
# Overcast stratus sky
# cloud count 1000/tile
####################################

var set_overcast_stratus_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)

local_weather.set_weather_station(blat, blon, 10000.0, 14.0, 12.0, 29.78);

# then draw the Stratus layers

var size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Stratus"];
local_weather.create_streak("Stratus",blat, blon, 1500.0+alt_offset+size_offset,32,1250.0,0.2, 32,1250.0,0.2,0.0 ,1.0);
local_weather.randomize_pos("Stratus",0.0,600.0,600.0,0.0);

size_offset = 0.5 * m_to_ft * local_weather.cloud_vertical_size_map["Stratus_structured"];
local_weather.create_streak("Stratus (structured)",blat, blon, 5000.0+alt_offset+size_offset,16,2500.0,0.3,16,2500.0,0.3,0.0,1.0);
local_weather.randomize_pos("Stratus (structured)",0.0,1200.0,1200.0,0.0);


# reduce visibility even more below lowest layer
# and add a slight drizzle by a nested effect volume

local_weather.create_effect_volume(3, blat, blon, 18000.0, 18000.0, 0.0, 0.0, 1800.0, 8000.0, -1, -1, -1, -1, 0);
local_weather.create_effect_volume(3, blat, blon, 14000.0, 14000.0, 0.0, 0.0, 1500.0, 6000.0, 0.1, -1, -1, -1,0 );


tile_finished();

}


####################################
# Incoming rainfront
# cloud count 1500/tile
####################################

var set_rainfront_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
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

tile_finished();



}


####################################
# Broken layers 
# cloud count 550/tile
####################################

var set_broken_layers_tile = func {

tile_start();


var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
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

tile_finished();


}


####################################
# Fair weather and Cumulus
# cloud count max. 800/tile
####################################

var set_fair_weather_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates


var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)
local_weather.set_weather_station(blat, blon, 35000.0, 20.0, 16.0, 1018 * hp_to_inhg);


# add convective clouds


var strength = 1.0;
var n = int(4000 * strength); # calculate the number of placement tries from tile size 20x20km and strength
local_weather.create_cumosys(blat,blon, 3000.0 + alt_offset, n, 20000.0);

tile_finished();


}


####################################
# Glider's sky
####################################

var set_gliders_sky_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)
local_weather.set_weather_station(blat, blon, 35000.0, 20.0, 16.0, 1018 * hp_to_inhg);

# switch the placement of thermal effect volumes on: 1: constant lift 2: by function
setprop(lw~"tmp/generate-thermal-lift-flag",2); 


# add convective clouds

var strength = 0.5;
var n = int(4000 * strength); # calculate the number of placement tries from tile size 20x20km and strength
local_weather.create_cumosys(blat,blon, 3000.0+alt_offset,n, 20000.0);


tile_finished();


}

####################################
# Blue thermals
####################################

var set_blue_thermals_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# first weather info for tile center (lat, lon, visibility, temperature, dew point, pressure)
local_weather.set_weather_station(blat, blon, 45000.0, 20.0, 15.0, 1018 * hp_to_inhg);

# switch the placement of thermal effect volumes on: 1: constant lift 2: by function 3: blue
setprop(lw~"tmp/generate-thermal-lift-flag",3); 


# add convective clouds

var strength = 0.9;
var n = int(4000 * strength); # calculate the number of placement tries from tile size 20x20km and strength
local_weather.create_cumosys(blat,blon, 5000.0+alt_offset,n, 20000.0);


tile_finished();


}


####################################
# Summer rain
# cloud count max. 1200/tile
####################################

var set_summer_rain_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
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

tile_finished();


}



####################################
# Cirrus sky
####################################

var set_cirrus_sky_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

var alpha = getprop(lw~"tmp/tile-orientation-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"tmp/tile-alt-offset-ft");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
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

tile_finished();
}


####################################
# METAR
####################################

var set_METAR_tile = func {

tile_start();

var x = 0.0;
var y = 0.0;
var lat = 0.0;
var lon = 0.0;

setprop(lw~"tiles/code","METAR"); # to be replaced

var alpha = getprop(lw~"METAR/wind-direction-deg");
var phi = alpha * math.pi/180.0;
var alt_offset = getprop(lw~"METAR/altitude-ft");

# get the local time of the day in seconds

var t = getprop("sim/time/utc/day-seconds");
t = t + getprop("sim/time/local-offset");

# get tile center coordinates

var blat = getprop(lw~"tiles/tmp/latitude-deg");
var blon = getprop(lw~"tiles/tmp/longitude-deg");
calc_geo(blat);

# get the METAR position info

var station_lat = getprop(lw~"METAR/latitude-deg");
var station_lon = getprop(lw~"METAR/longitude-deg");

# get the weather parameters

var vis = getprop(lw~"METAR/visibility-m");
var T = getprop(lw~"METAR/temperature-degc");
var D = getprop(lw~"METAR/dewpoint-degc");
var p = getprop(lw~"METAR/pressure-inhg");
var rain_norm = getprop(lw~"METAR/rain-norm");
var snow_norm = getprop(lw~"METAR/snow-norm");

# and set the corresponding station
local_weather.set_weather_station(station_lat, station_lon, vis, T, D, p);

# now get the cloud layer info

var layers = props.globals.getNode(lw~"METAR", 1).getChildren("layer");
var n_layers = size(layers); # the system initializes with  4 layers, but who knows...
var n = 0; # start with lowest layer

# now determine the nature of the lowest layer

var cumulus_flag = 1; # default assumption - the lowest layer is cumulus 
var cover_low = layers[0].getNode("cover-oct").getValue();
var alt_low = layers[0].getNode("alt-agl-ft").getValue();

# first check a few obvious criteria

if (cover_low == 8) {cumulus_flag = 0;} # overcast sky is unlikely to be Cumulus, and we can't render it anyway
if ((rain_norm > 0.0) or (snow_norm > 0.0)) {cumulus_flag = 0;} # Cumulus usually doesn't rain
if (alt_low > 7000.0) {cumulus_flag = 0;} # Cumulus are low altitude clouds

# now try matching time evolution of cumuli

if ((cover_low == 5) or (cover_low == 6) or (cover_low == 7)) # broken
	{
	if ((t < 39600) or (t > 68400)) {cumulus_flag = 0;} # not before 11:00 and not after 19:00
	}

if ((cover_low == 3) or (cover_low == 4)) # scattered
	{
	if ((t < 32400) or (t > 75600)) {cumulus_flag = 0;} # not before 9:00 and not after 21:00
	}

# now see if there is a layer shading convective development

var coverage_above = layers[1].getNode("cover-oct").getValue(); 
if (coverage_above > 6) {cumulus_flag = 0;} # no Cumulus with strong layer above

# always do Cumulus when there's a thunderstorm
if (getprop(lw~"METAR/thunderstorm-flag") ==1) {cumulus_flag = 1;} 

# if cumulus_flag is still 1 at this point, the lowest layer is Cumulus
# see if we need to adjust its strength 

if (cumulus_flag == 1)
	{
	if ((cover_low < 4) and (t > 39600) and (t < 68400)) {var strength = 0.4;}
	else {var strength = 1.0;}
	local_weather.create_cumosys(blat,blon, alt_low+alt_offset,get_n(strength), 20000.0);
	n = n + 1; # do not start parsing with lowest layer
	}	


for (var i = n; i <n_layers; i=i+1)
	{
	var altitude = layers[i].getNode("alt-agl-ft").getValue();
	var cover = layers[i].getNode("cover-oct").getValue();

	if (cover == 0) {break;} # a zero cover layer indicates we are done

	if (altitude < 9000.0) # draw Nimbostratus or Stratus models
		{	
		if (cover == 8) 
			{create_8_8_nimbus(blat, blon, altitude+alt_offset, alpha);}
		else if ((cover < 8) and (cover > 4))
			{create_6_8_stratus(blat, blon, altitude+alt_offset, alpha);}
		else if ((cover == 3) or (cover == 4))
			{
			var rn = rand();
			if (rn > 0.75)
				{create_4_8_stratus(blat, blon, altitude+alt_offset, alpha);}
			else if (rn > 0.5)
				{create_4_8_stratus_patches(blat, blon, altitude+alt_offset, alpha);}
			else if (rn > 0.25)
				{create_4_8_sstratus_patches(blat, blon, altitude+alt_offset, alpha);}
			else if (rn > 0.0)
				{create_4_8_sstratus_undulatus(blat, blon, altitude+alt_offset, alpha);}
			}
		else 
			{
			var rn = rand();
			if (rn > 0.5)
				{create_2_8_stratus(blat, blon, altitude+alt_offset, alpha);}
			else if (rn > 0.0)
				{create_2_8_sstratus(blat, blon, altitude+alt_offset, alpha);}
			}
		} # end if altitude
	else if ((altitude > 9000.0) and (altitude < 20000.0)) # select thin cloud layers
		{
		if (cover == 8) 
			{create_8_8_cirrostratus(blat, blon, altitude+alt_offset, alpha);}
		else if (cover > 2)
			{
			rn = rand();
			if (rn > 0.5)
				{create_4_8_tstratus_patches(blat, blon, altitude+alt_offset, alpha);}
			else if (rn > 0.0)
				{create_4_8_tstratus_undulatus(blat, blon, altitude+alt_offset, alpha);}
			}
		else
			{create_2_8_tstratus(blat, blon, altitude+alt_offset, alpha);}
		} # end if altitude
	} # end for
	
# now that the weather info is used, set the flag so that offline mode starts unless a new METAR
# is available for the next tile

setprop(lw~"METAR/available-flag",0);


tile_finished();
}

####################################
# mid-level cloud setup calls
####################################

var create_8_8_stratus = func (lat, lon, alt, alpha) {

local_weather.create_streak("Stratus",lat, lon, alt,32,1250.0,0.0,32,1250.0,0.0,alpha,1.0);
local_weather.randomize_pos("Stratus",500.0,400.0,400.0,alpha);
}

var create_8_8_cirrostratus = func (lat, lon, alt, alpha) {

local_weather.create_streak("Cirrostratus",lat, lon, alt,30,1250.0,0.0,30,1250.0,0.0,alpha,1.0);
local_weather.randomize_pos("Cirrostratus",500.0,400.0,400.0,alpha);
}

var create_8_8_nimbus = func (lat, lon, alt, alpha) {

local_weather.create_streak("Nimbus",lat, lon, alt,32,1250.0,0.0,32,1250.0,0.0,alpha,1.0);
local_weather.randomize_pos("Nimbus",500.0,200.0,200.0,alpha);
}


var create_6_8_stratus = func (lat, lon, alt, alpha) {

local_weather.create_streak("Stratus",lat, lon, alt,20,0.0,0.2,20,0.0,0.2,alpha,1.0);
local_weather.randomize_pos("Stratus",500.0,20000.0,20000.0,alpha);
}


var create_4_8_stratus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;
var x = 2.0 * (rand()-0.5) * 15000;
var y = 2.0 * (rand()-0.5) * 15000;
var beta = rand() * 360.0;

local_weather.create_streak("Stratus",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,20,1200.0,0.3,12,1200.0,0.3,beta,1.2);
local_weather.randomize_pos("Stratus",500.0,400.0,400.0,beta);

var x = 2.0 * (rand()-0.5) * 15000;
var y = 2.0 * (rand()-0.5) * 15000;
var beta = rand() * 360.0;

local_weather.create_streak("Stratus",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,18,1000.0,0.3,10,1000.0,0.3,beta,1.5);
local_weather.randomize_pos("Stratus",500.0,400.0,400.0,beta);

var x = 2.0 * (rand()-0.5) * 15000;
var y = 2.0 * (rand()-0.5) * 15000;
var beta = rand() * 360.0;

local_weather.create_streak("Stratus",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,15,1000.0,0.3,18,1000.0,0.3,beta,2.0);
local_weather.randomize_pos("Stratus",500.0,400.0,400.0,beta);
}

var create_4_8_stratus_patches = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<16; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 18000;
	var y = 2.0 * (rand()-0.5) * 18000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Stratus",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,4,950.0,0.2,6,950.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Stratus",300.0,500.0,500.0,alpha+beta);
	}

}

var create_4_8_tstratus_patches = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<16; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 18000;
	var y = 2.0 * (rand()-0.5) * 18000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Stratus (thin)",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,4,950.0,0.2,6,950.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Stratus (thin)",300.0,500.0,500.0,alpha+beta);
	}

}


var create_4_8_sstratus_patches = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<16; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 18000;
	var y = 2.0 * (rand()-0.5) * 18000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Stratus (structured)",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,4,950.0,0.2,6,950.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Stratus (structured)",300.0,500.0,500.0,alpha+beta);
	}

}


var create_4_8_cirrostratus_patches = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<6; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 12000;
	var y = 2.0 * (rand()-0.5) * 12000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Cirrostratus",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,4,2500.0,0.2,4,2500.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Cirrostratus",300.0,600.0,600.0,alpha+beta);
	}

}


var create_4_8_stratus_undulatus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;
var x = 2.0 * (rand()-0.5) * 5000;
var y = 2.0 * (rand()-0.5) * 5000;
var tri = 1.5 + 1.5*rand();
var beta = (rand() -0.5) * 60.0;

local_weather.create_streak("Stratus",lat+get_lat(x,y+4000,phi), lon+get_lon(x,y+4000,phi), alt,10,800.0,0.25,12,2800.0,0.15,alpha+90.0+beta,tri);
local_weather.randomize_pos("Stratus",500.0,400.0,600.0,alpha+90.0+beta);
local_weather.create_streak("Stratus",lat+get_lat(x,y-4000,phi), lon+get_lon(x,y-4000,phi), alt,10,800.0,0.25,12,2800.0,0.15,alpha+270.0+beta,tri);
local_weather.randomize_pos("Stratus",500.0,400.0,600.0,alpha+270.0+beta);
}

var create_4_8_tstratus_undulatus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;
var x = 2.0 * (rand()-0.5) * 5000;
var y = 2.0 * (rand()-0.5) * 5000;
var tri = 1.5 + 1.5*rand();
var beta = (rand() -0.5) * 60.0;

local_weather.create_streak("Stratus (thin)",lat+get_lat(x,y+4000,phi), lon+get_lon(x,y+4000,phi), alt,10,800.0,0.25,12,2800.0,0.15,alpha+90.0+beta,tri);
local_weather.randomize_pos("Stratus (thin)",500.0,400.0,600.0,alpha+90.0+beta);
local_weather.create_streak("Stratus (thin)",lat+get_lat(x,y-4000,phi), lon+get_lon(x,y-4000,phi), alt,10,800.0,0.25,12,2800.0,0.15,alpha+270.0+beta,tri);
local_weather.randomize_pos("Stratus (thin)",500.0,400.0,600.0,alpha+270.0+beta);
}

var create_4_8_sstratus_undulatus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;
var x = 2.0 * (rand()-0.5) * 5000;
var y = 2.0 * (rand()-0.5) * 5000;
var tri = 1 + 1.5*rand();
var beta = (rand() -0.5) * 60.0;

local_weather.create_streak("Stratus (structured)",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,20,900.0,0.25,12,2800.0,0.15,alpha+90.0+beta,tri);
local_weather.randomize_pos("Stratus (structured)",500.0,400.0,600.0,alpha+90.0+beta);
}


var create_2_8_stratus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<8; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 18000;
	var y = 2.0 * (rand()-0.5) * 18000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Stratus",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,5,900.0,0.2,7,900.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Stratus",300.0,500.0,500.0,alpha+beta);
	}

}

var create_2_8_tstratus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<8; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 18000;
	var y = 2.0 * (rand()-0.5) * 18000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Stratus (thin)",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,5,900.0,0.2,7,900.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Stratus (thin)",300.0,500.0,500.0,alpha+beta);
	}

}

var create_2_8_sstratus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<8; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 18000;
	var y = 2.0 * (rand()-0.5) * 18000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Stratus (structured)",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,5,900.0,0.2,7,900.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Stratus (structured)",300.0,500.0,500.0,alpha+beta);
	}

}

var create_2_8_cirrostratus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<3; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 12000;
	var y = 2.0 * (rand()-0.5) * 12000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Cirrostratus",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,4,2300.0,0.2,4,2300.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Cirrostratus",300.0,600.0,600.0,alpha+beta);
	}

}

var create_2_8_cirrocumulus = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;

for (var i=0; i<3; i=i+1)
	{
	var x = 2.0 * (rand()-0.5) * 12000;
	var y = 2.0 * (rand()-0.5) * 12000;
	var beta = (rand() -0.5) * 180.0;
	local_weather.create_streak("Cirrocumulus (cloudlet)",lat+get_lat(x,y,phi), lon+get_lon(x,y,phi), alt,3,4000.0,0.2,3,4000.0,0.2,alpha+beta,1.0);
local_weather.randomize_pos("Cirrocumulus (cloudlet)",300.0,1000.0,1000.0,alpha+beta);
	}

}


var create_stratocumulus_bank = func (lat, lon, alt, alpha) {

var phi = alpha * math.pi/180.0;
var x = 2.0 * (rand()-0.5) * 10000;
var y = 2.0 * (rand()-0.5) * 10000;
var tri = 1.5 + 1.5*rand();
var beta = (rand() -0.5) * 60.0;

local_weather.create_streak("Cumulus",lat+get_lat(x,y+6000,phi), lon+get_lon(x,y+6000,phi), alt,15,600.0,0.2,20,600.0,0.2,alpha+90.0+beta,tri);
local_weather.randomize_pos("Cumulus",500.0,400.0,400.0,alpha+90.0+beta);
local_weather.create_streak("Cumulus",lat+get_lat(x,y-6000,phi), lon+get_lon(x,y-6000,phi), alt,15,600.0,0.2,20,600.0,0.2,alpha+270.0+beta,tri);
local_weather.randomize_pos("Cumulus",500.0,400.0,400.0,alpha+270.0+beta);
}

var create_cloud_bank = func (type, lat, lon, alt, x1, x2, height, n, alpha) {

local_weather.create_streak(type,lat,lon, alt+ 0.5* height,n,0.0,0.0,1,0.0,0.0,alpha,1.0);
local_weather.randomize_pos(type,height,x1,x2,alpha);

}

var create_small_thunderstorm = func(lat, lon, alt, alpha) {

var scale = 0.7 + rand() * 0.3;

local_weather.create_layer("Stratus", lat, lon, alt, 1000.0, 4000.0 * scale, 4000.0 * scale, 0.0, 1.0, 0.3, 1, 1.0);

local_weather.create_layer("Cumulonimbus (cloudlet)", lat, lon, alt+2000, 15000.0, 3000.0 * scale, 3000.0 * scale, 0.0, 2.0, 0.0, 0, 0.0);

# set the exclusion region for the Cumulus layer
append(elat, lat); append(elon, lon); append(erad, 4000.0 * scale * 1.2);

# set precipitation, visibility, updraft and turbulence in the cloud

local_weather.create_effect_volume(1, lat, lon, 4000.0 * 0.7 * scale, 4000.0 * 0.7 * scale , 0.0, 0.0, 20000.0, 600.0, 0.8, -1, 0.6, 15.0,1 );

}

var create_medium_thunderstorm = func(lat, lon, alt, alpha) {

var scale = 0.7 + rand() * 0.3;

local_weather.create_layer("Nimbus", lat, lon, alt, 500.0, 6000.0 * scale, 6000.0 * scale, 0.0, 1.0, 0.3, 1, 1.5);
local_weather.create_layer("Stratus", lat, lon, alt+1500, 1000.0, 5500.0 * scale, 5500.0 * scale, 0.0, 1.0, 0.3, 0, 0.0);
local_weather.create_layer("Fog (thick)", lat, lon, alt+4000, 6000.0, 3400.0 * scale, 3400.0 * scale, 0.0, 1.5, 0.3, 0, 0.0);
local_weather.create_layer("Cumulonimbus (cloudlet)", lat, lon, alt+10000, 10000.0, 3600.0 * scale, 3600.0 * scale, 0.0, 1.2, 0.0, 0, 0.0);

# set the exclusion region for the Cumulus layer
append(elat, lat); append(elon, lon); append(erad, 6000.0 * scale * 1.2);

# set precipitation, visibility, updraft and turbulence in the cloud

local_weather.create_effect_volume(1, lat, lon, 6000.0 * 0.7 * scale, 6000.0 * 0.7 * scale , 0.0, 0.0, 20000.0, 500.0, 1.0, -1, 0.8, 20.0,1 );

}

var create_big_thunderstorm = func(lat, lon, alt, alpha) {

# var radius = 4000 + rand() * 4000;
var phi = alpha * math.pi/180.0;

var scale = 0.8;

local_weather.create_layer("Nimbus", lat, lon, alt, 500.0, 7500.0 * scale, 7500.0 * scale, 0.0, 1.0, 0.25, 1, 1.5);
local_weather.create_layer("Stratus", lat, lon, alt+1500, 1000.0, 7200.0 * scale, 7200.0 * scale, 0.0, 1.0, 0.3, 0, 0.0);
local_weather.create_layer("Fog (thick)", lat, lon, alt+5000, 3000.0, 5500.0 * scale, 5500.0 * scale, 0.0, 0.7, 0.3, 0, 0.0);
local_weather.create_layer("Fog (thick)", lat+get_lat(0,-1000,phi), lon+get_lon(0,-1000,phi), alt+12000, 4000.0, 6300.0 * scale, 6300.0 * scale, 0.0, 0.7, 0.3, 0, 0.0);
local_weather.create_layer("Stratus", lat+get_lat(0,-2000,phi), lon+get_lon(0,-2000,phi), alt+17000, 1000.0, 7500.0 * scale, 7500.0 * scale, 0.0, 1.0, 0.3, 0, 0.0);
local_weather.create_layer("Stratus", lat+get_lat(0,-3000,phi), lon+get_lon(0,-3000,phi), alt+20000, 1000.0, 9500.0 * scale, 9500.0 * scale, 0.0, 1.0, 0.3, 0, 0.0);
local_weather.create_layer("Stratus (thin)", lat+get_lat(0,-4000,phi), lon+get_lon(0,-4000,phi), alt+24000, 1000.0, 11500.0 * scale, 11500.0 * scale, 0.0, 2.0, 0.3, 0, 0.0);

# set the exclusion region for the Cumulus layer
append(elat, lat); append(elon, lon); append(erad, 7500.0 * scale * 1.2);

local_weather.create_effect_volume(1, lat, lon, 7500.0 * 0.7 * scale, 7500.0 * 0.7 * scale , 0.0, 0.0, 20000.0, 500.0, 1.0, -1, 1.0, 25.0,1 );

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


var get_n = func(strength) {

return int(4000 * strength);
}


##################################
# continuity condition of pressure
##################################

var adjust_p = func (p) {

if (last_pressure == 0.0) {last_pressure = p; return p;}

var pressure_difference = p - last_pressure;

if (pressure_difference > 2.0) {var pout = last_pressure + 3.0;}
else if (pressure_difference < -2.0) {var pout = last_pressure - 3.0;}
else {var pout = p;}

last_pressure = pout;

return pout;
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

var last_pressure = 0.0;

var lon_to_m = 0.0; # needs to be calculated dynamically
var m_to_lon = 0.0; # we do this on startup
var lw = "/local-weather/";

var elat = [];
var elon = [];
var erad = [];
