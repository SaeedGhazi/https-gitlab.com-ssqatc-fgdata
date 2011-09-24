
########################################################
# routines to set up, transform and manage local weather
# Thorsten Renk, August 2011
########################################################

# function			purpose
#
# select_cloud_model		to define the cloud parameters, given the cloud type and subtype


###########################################################
# define various cloud models
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


	# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") 
			{
			cloudAssembly.texture_sheet = "/Models/Weather/cumulus_sheet2.rgb";
			cloudAssembly.n_sprites = 10;
			cloudAssembly.min_width = 500.0;
			cloudAssembly.max_width = 700.0;
			cloudAssembly.min_height = 500.0;
			cloudAssembly.max_height = 700.0;
			cloudAssembly.min_cloud_width = 1300;
			cloudAssembly.min_cloud_height = 700;
			cloudAssembly.bottom_shade = 0.7;
			}
		else
			{
			cloudAssembly.texture_sheet = "/Models/Weather/cumulus_sheet1.rgb";
			cloudAssembly.n_sprites = 5;
			cloudAssembly.min_width = 600.0;
			cloudAssembly.max_width = 900.0;
			cloudAssembly.min_height = 600.0;
			cloudAssembly.max_height = 900.0;
			cloudAssembly.min_cloud_width = 1300;
			cloudAssembly.min_cloud_height = 700;
			cloudAssembly.bottom_shade = 0.4;
			}
			

		# characterize the basic texture sheet
		cloudAssembly.num_tex_x = 3;
		cloudAssembly.num_tex_y = 3;
	
		#characterize the cloud
		cloudAssembly.z_scale = 1.0;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{


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
	
	}

else if (type == "Cu (volume)"){



	cloudAssembly = local_weather.cloud.new(type, subtype);

	if (subtype == "small") 
		{
		cloudAssembly.texture_sheet = "/Models/Weather/cumulus_sheet2.rgb";
		cloudAssembly.n_sprites = 5;
		cloudAssembly.min_width = 400.0;
		cloudAssembly.max_width = 700.0;
		cloudAssembly.min_height = 400.0;
		cloudAssembly.max_height = 700.0;
		cloudAssembly.min_cloud_width = 1000;
		cloudAssembly.min_cloud_height = 1000;
		cloudAssembly.bottom_shade = 0.7;
		}
	else
		{
		cloudAssembly.texture_sheet = "/Models/Weather/cumulus_sheet1.rgb";
		cloudAssembly.n_sprites = 5;
		cloudAssembly.min_width = 800.0;
		cloudAssembly.max_width = 1100.0;
		cloudAssembly.min_height = 800.0;
		cloudAssembly.max_height = 1100.0;
		cloudAssembly.min_cloud_width = 1500;
		cloudAssembly.min_cloud_height = 1000;
		cloudAssembly.bottom_shade = 0.4;
		}
			

	# characterize the basic texture sheet
	cloudAssembly.num_tex_x = 3;
	cloudAssembly.num_tex_y = 3;
	
	#characterize the cloud
	cloudAssembly.z_scale = 1.0;

	#signal that new routines are used
	path = "new";
	}


else if (type == "Congestus"){


	# new code

	if (local_weather.hardcoded_clouds_flag ==1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") 
			{
			cloudAssembly.texture_sheet = "/Models/Weather/cumulus_sheet1.rgb";
			cloudAssembly.num_tex_x = 3;
			cloudAssembly.num_tex_y = 3;
			cloudAssembly.n_sprites = 5;
			cloudAssembly.min_width = 600.0;
			cloudAssembly.max_width = 900.0;
			cloudAssembly.min_height = 600.0;
			cloudAssembly.max_height = 900.0;
			cloudAssembly.min_cloud_width = 1300;
			cloudAssembly.min_cloud_height = 1000;
			cloudAssembly.bottom_shade = 0.4;
			}
		else 
			{	

			if (rand() > 0.5)
				{
				cloudAssembly.texture_sheet = "/Models/Weather/congestus_sheet1.rgb";
				cloudAssembly.num_tex_x = 1;
				cloudAssembly.num_tex_y = 3;
				cloudAssembly.min_width = 1300.0;
				cloudAssembly.max_width = 2000.0;
				cloudAssembly.min_height = 600.0;
				cloudAssembly.max_height = 900.0;			
				}
			else	
				{
				cloudAssembly.texture_sheet = "/Models/Weather/congestus_sheet2.rgb";
				cloudAssembly.num_tex_x = 1;
				cloudAssembly.num_tex_y = 2;
				cloudAssembly.min_width = 1200.0;
				cloudAssembly.max_width = 1800.0;
				cloudAssembly.min_height = 700.0;
				cloudAssembly.max_height = 1000.0;			
				}


			cloudAssembly.n_sprites = 3;
			cloudAssembly.min_cloud_width = 2200.0;
			cloudAssembly.min_cloud_height = 1200.0;
			cloudAssembly.bottom_shade = 0.4;

			}
		cloudAssembly.z_scale = 1.0;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{


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
	}
else if (type == "Stratocumulus"){

# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") 
			{
			cloudAssembly.texture_sheet = "/Models/Weather/cumulus_sheet1.rgb";
			cloudAssembly.num_tex_x = 3;
			cloudAssembly.num_tex_y = 3;
			cloudAssembly.n_sprites = 7;
			cloudAssembly.min_width = 600.0;
			cloudAssembly.max_width = 900.0;
			cloudAssembly.min_height = 600.0;
			cloudAssembly.max_height = 900.0;
			cloudAssembly.min_cloud_width = 1300;
			cloudAssembly.min_cloud_height = 1300;
			cloudAssembly.bottom_shade = 0.6;
			}
		else
			{
			if (rand() > 0.66)
				{
				cloudAssembly.texture_sheet = "/Models/Weather/congestus_sheet1.rgb";
				cloudAssembly.num_tex_x = 1;
				cloudAssembly.num_tex_y = 3;
				cloudAssembly.min_width = 1900.0;
				cloudAssembly.max_width = 2100.0;
				cloudAssembly.min_height = 1000.0;
				cloudAssembly.max_height = 1100.0;	
				cloudAssembly.n_sprites = 3;	
				cloudAssembly.bottom_shade = 0.5;
				cloudAssembly.min_cloud_width = 3500.0;	
				cloudAssembly.min_cloud_height = 1600.0;
				}
			else if (rand() > 0.33)
				{
				cloudAssembly.texture_sheet = "/Models/Weather/congestus_sheet2.rgb";
				cloudAssembly.num_tex_x = 1;
				cloudAssembly.num_tex_y = 2;
				cloudAssembly.min_width = 1900.0;
				cloudAssembly.max_width = 2000.0;
				cloudAssembly.min_height = 1000.0;
				cloudAssembly.max_height = 1100.0;	
				cloudAssembly.n_sprites = 3;	
				cloudAssembly.bottom_shade = 0.5;
				cloudAssembly.min_cloud_width = 3500.0;
				cloudAssembly.min_cloud_height = 1600.0;	
				}	
			else 
				{
				cloudAssembly.texture_sheet = "/Models/Weather/cumulus_sheet1.rgb";
				cloudAssembly.num_tex_x = 3;
				cloudAssembly.num_tex_y = 3;
				cloudAssembly.min_width = 800.0;
				cloudAssembly.max_width = 1000.0;
				cloudAssembly.min_height = 800.0;
				cloudAssembly.max_height = 1000.0;	
				cloudAssembly.n_sprites = 5;	
				cloudAssembly.bottom_shade = 0.6;
				cloudAssembly.min_cloud_width = 3000.0;
				cloudAssembly.min_cloud_height = 1100.0;	
				}	






			}
			

		cloudAssembly.z_scale = 1.0;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{


	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/stratocumulus_small1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratocumulus_small2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratocumulus_small3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratocumulus_small4.xml";}
		else  {path = "Models/Weather/stratocumulus_small5.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/stratocumulus_sl1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/stratocumulus_sl2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/stratocumulus_sl3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/stratocumulus_sl4.xml";}
		else  {path = "Models/Weather/stratocumulus_sl5.xml";}
		}
		}
	
	}
else if (type == "Cumulus (whisp)"){

# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		mult = 1.0;

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/altocumulus_sheet1.rgb";
		cloudAssembly.num_tex_x = 3;
		cloudAssembly.num_tex_y = 3;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.9;
		cloudAssembly.n_sprites = 4;
		cloudAssembly.min_width = 400.0 * mult;
		cloudAssembly.max_width = 600.0 * mult;
		cloudAssembly.min_height = 400.0 * mult;
		cloudAssembly.max_height = 600.0 * mult;
		cloudAssembly.min_cloud_width = 800 * mult * mult;
		cloudAssembly.min_cloud_height = 800 * mult * mult;
		cloudAssembly.z_scale = 1.0;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{


	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/cumulus_whisp1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulus_whisp2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulus_whisp3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulus_whisp4.xml";}
		else  {path = "Models/Weather/cumulus_whisp5.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/cumulus_whisp1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulus_whisp2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulus_whisp3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulus_whisp4.xml";}
		else  {path = "Models/Weather/cumulus_whisp5.xml";}
		}

		}
	
	}
else if (type == "Cumulus bottom"){
	# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		mult = 1.0;

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/cumulus_bottom_sheet1.rgb";
		cloudAssembly.num_tex_x = 1;
		cloudAssembly.num_tex_y = 1;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 1.0;
		cloudAssembly.n_sprites = 4;
		cloudAssembly.min_width = 600.0 * mult;
		cloudAssembly.max_width = 800.0 * mult;
		cloudAssembly.min_height = 600.0 * mult;
		cloudAssembly.max_height = 800.0 * mult;
		cloudAssembly.min_cloud_width = 1200 * mult * mult;
		cloudAssembly.min_cloud_height = 800 * mult * mult;
		cloudAssembly.z_scale = 0.6;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{

	if (subtype == "small") {
		if (rn > 0.0) {path = "Models/Weather/cumulus_bottom1.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.0) {path = "Models/Weather/cumulus_bottom1.xml";}
		}
		}
	
	}
else if (type == "Congestus bottom"){

	# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		mult = 1.0;

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/cumulus_bottom_sheet1.rgb";
		cloudAssembly.num_tex_x = 1;
		cloudAssembly.num_tex_y = 1;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.7;
		cloudAssembly.n_sprites = 4;
		cloudAssembly.min_width = 1100.0 * mult;
		cloudAssembly.max_width = 1400.0 * mult;
		cloudAssembly.min_height = 1100.0 * mult;
		cloudAssembly.max_height = 1400.0 * mult;
		cloudAssembly.min_cloud_width = 1600 * mult * mult;
		cloudAssembly.min_cloud_height = 1200 * mult * mult;
		cloudAssembly.z_scale = 0.4;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{

	if (subtype == "small") {
		if (rn > 0.0) {path = "Models/Weather/congestus_bottom1.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.0) {path = "Models/Weather/congestus_bottom1.xml";}
		}
		}
	
	}
else if (type == "Stratocumulus bottom"){
	# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		mult = 1.0;

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/cumulus_bottom_sheet1.rgb";
		cloudAssembly.num_tex_x = 1;
		cloudAssembly.num_tex_y = 1;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.7;
		cloudAssembly.n_sprites = 3;
		cloudAssembly.min_width = 1200.0;
		cloudAssembly.max_width = 1600.0;
		cloudAssembly.min_height = 1200.0 ;
		cloudAssembly.max_height = 1600.0;
		cloudAssembly.min_cloud_width = 2000 ;
		cloudAssembly.min_cloud_height = 1700;
		cloudAssembly.z_scale = 0.4;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{

	if (subtype == "small") {
		if (rn > 0.0) {path = "Models/Weather/stratocumulus_bottom1.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.0) {path = "Models/Weather/stratocumulus_bottom1.xml";}
		}
		}
	
	}
else if (type == "Cumulonimbus (cloudlet)"){
	if (subtype == "small") {
		if (rn > 0.875) {path = "Models/Weather/cumulonimbus_sl1.xml";}
		else if (rn > 0.75) {path = "Models/Weather/cumulonimbus_sl2.xml";}
		else if (rn > 0.625) {path = "Models/Weather/cumulonimbus_sl3.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cumulonimbus_sl4.xml";}
		else if (rn > 0.375) {path = "Models/Weather/cumulonimbus_sl5.xml";}
		else if (rn > 0.25) {path = "Models/Weather/cumulonimbus_sl6.xml";}
		else if (rn > 0.125) {path = "Models/Weather/cumulonimbus_sl7.xml";}
		else  {path = "Models/Weather/cumulonimbus_sl8.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.875) {path = "Models/Weather/cumulonimbus_sl1.xml";}
		else if (rn > 0.75) {path = "Models/Weather/cumulonimbus_sl2.xml";}
		else if (rn > 0.625) {path = "Models/Weather/cumulonimbus_sl3.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cumulonimbus_sl4.xml";}
		else if (rn > 0.375) {path = "Models/Weather/cumulonimbus_sl5.xml";}
		else if (rn > 0.25) {path = "Models/Weather/cumulonimbus_sl6.xml";}
		else if (rn > 0.125) {path = "Models/Weather/cumulonimbus_sl7.xml";}
		else  {path = "Models/Weather/cumulonimbus_sl8.xml";}
		}
	
	}

else if (type == "Altocumulus"){
	
	# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") {var mult = 0.7;}
		else {var mult = 1.0;}

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/altocumulus_sheet1.rgb";
		cloudAssembly.num_tex_x = 3;
		cloudAssembly.num_tex_y = 3;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.8;
		cloudAssembly.n_sprites = 10;
		cloudAssembly.min_width = 400.0 * mult;
		cloudAssembly.max_width = 700.0 * mult;
		cloudAssembly.min_height = 400.0 * mult;
		cloudAssembly.max_height = 700.0 * mult;
		cloudAssembly.min_cloud_width = 1200 * mult * mult;
		cloudAssembly.min_cloud_height = 1200 * mult * mult;
		cloudAssembly.z_scale = 0.8;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{

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
	}

else if (type == "Stratus (structured)"){

	# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") {var mult = 0.7;}
		else {var mult = 1.0;}

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/altocumulus_sheet1.rgb";
		cloudAssembly.num_tex_x = 3;
		cloudAssembly.num_tex_y = 3;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.4;
		cloudAssembly.n_sprites = 25;
		cloudAssembly.min_width = 1700.0 * mult;
		cloudAssembly.max_width = 2500.0 * mult;
		cloudAssembly.min_height = 1700.0 * mult;
		cloudAssembly.max_height = 2500.0 * mult;
		cloudAssembly.min_cloud_width = 3200.0 * mult * mult;
		cloudAssembly.min_cloud_height = 500.0 * mult * mult + cloudAssembly.max_height;
		cloudAssembly.z_scale = 0.3;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{

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
	}
else if (type == "Altocumulus perlucidus"){

	# new code
	
	if (local_weather.hardcoded_clouds_flag == 1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") {var mult = 0.7;}
		else {var mult = 1.0;}

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/altocumulus_sheet1.rgb";
		cloudAssembly.num_tex_x = 3;
		cloudAssembly.num_tex_y = 3;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.8;
		cloudAssembly.n_sprites = 25;
		cloudAssembly.min_width = 1700.0 * mult;
		cloudAssembly.max_width = 2500.0 * mult;
		cloudAssembly.min_height = 1700.0 * mult;
		cloudAssembly.max_height = 2500.0 * mult;
		cloudAssembly.min_cloud_width = 3200.0 * mult * mult;
		cloudAssembly.min_cloud_height = 500.0 * mult * mult + cloudAssembly.max_height;
		cloudAssembly.z_scale = 0.2;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{


	if (subtype == "small") {
		if (rn > 0.8) {path = "Models/Weather/altocumulus_thinlayer6.xml";}
		else if (rn > 0.6) {path = "Models/Weather/altocumulus_thinlayer7.xml";}
		else if (rn > 0.4) {path = "Models/Weather/altocumulus_thinlayer8.xml";}
		else if (rn > 0.2) {path = "Models/Weather/altocumulus_thinlayer9.xml";}
		else  {path = "Models/Weather/altocumulus_thinlayer10.xml";}
		}
	else if (subtype == "large") {
		if (rn > 0.8) {path = "Models/Weather/altocumulus_thinlayer1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/altocumulus_thinlayer2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/altocumulus_thinlayer3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/altocumulus_thinlayer4.xml";}
		else  {path = "Models/Weather/altocumulus_thinlayer5.xml";}
		}
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
		if (rn > 0.916) {path = "Models/Weather/cirrus1.xml";}
		else if (rn > 0.833) {path = "Models/Weather/cirrus2.xml";}
		else if (rn > 0.75) {path = "Models/Weather/cirrus3.xml";}
		else if (rn > 0.666) {path = "Models/Weather/cirrus4.xml";}
		else if (rn > 0.583) {path = "Models/Weather/cirrus5.xml";}
		else if (rn > 0.500) {path = "Models/Weather/cirrus6.xml";}
		else if (rn > 0.416) {path = "Models/Weather/cirrus7.xml";}
		else if (rn > 0.333) {path = "Models/Weather/cirrus8.xml";}
		else if (rn > 0.250) {path = "Models/Weather/cirrus9.xml";}
		else if (rn > 0.166) {path = "Models/Weather/cirrus10.xml";}
		else if (rn > 0.083) {path = "Models/Weather/cirrus11.xml";}
		else  {path = "Models/Weather/cirrus12.xml";}
		}	
	else if (subtype == "small") {
		if (rn > 0.75) {path = "Models/Weather/cirrus_amorphous1.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cirrus_amorphous2.xml";}
		else if (rn > 0.25) {path = "Models/Weather/cirrus_amorphous3.xml";}
		else  {path = "Models/Weather/cirrus_amorphous4.xml";}
		}	
	}
else if (type == "Cirrocumulus") {
	if (subtype == "small") {
		if (rn > 0.5) {path = "Models/Weather/cirrocumulus1.xml";}
		else  {path = "Models/Weather/cirrocumulus2.xml";}
		}	
	else if (subtype == "large") {
		if (rn > 0.875) {path = "Models/Weather/cirrocumulus1.xml";}
		else if (rn > 0.750){path = "Models/Weather/cirrocumulus4.xml";}
		else if (rn > 0.625){path = "Models/Weather/cirrocumulus5.xml";}
		else if (rn > 0.500){path = "Models/Weather/cirrocumulus6.xml";}
		else if (rn > 0.385){path = "Models/Weather/cirrocumulus7.xml";}
		else if (rn > 0.250){path = "Models/Weather/cirrocumulus8.xml";}
		else if (rn > 0.125){path = "Models/Weather/cirrocumulus9.xml";}
		else {path = "Models/Weather/cirrocumulus10.xml";}
		}	
	}
else if (type == "Cirrocumulus (cloudlet)") {

	# new code

	if (local_weather.hardcoded_clouds_flag ==1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") {var mult = 0.6;}
		else {var mult = 1.0;}

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/cirrocumulus_sheet1.rgb";
		cloudAssembly.num_tex_x = 3;
		cloudAssembly.num_tex_y = 3;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 1.0;
		cloudAssembly.n_sprites = 8;
		cloudAssembly.min_width = 700.0 * mult;
		cloudAssembly.max_width = 1200.0 * mult;
		cloudAssembly.min_height = 700.0 * mult;
		cloudAssembly.max_height = 1200.0 * mult;
		cloudAssembly.min_cloud_width = 1500.0;
		cloudAssembly.min_cloud_height = 100.0 * mult;
		cloudAssembly.z_scale = 0.3;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{

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
	}
else if (type == "Cirrocumulus (new)") {

	# new code

	if (local_weather.hardcoded_clouds_flag ==1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") {var mult = 0.7;}
		else {var mult = 1.0;}

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/cirrocumulus_sheet1.rgb";
		cloudAssembly.num_tex_x = 3;
		cloudAssembly.num_tex_y = 3;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 1.0;
		cloudAssembly.n_sprites = 2;
		cloudAssembly.min_width = 200.0 * mult;
		cloudAssembly.max_width = 300.0 * mult;
		cloudAssembly.min_height = 200.0 * mult;
		cloudAssembly.max_height = 300.0 * mult;
		cloudAssembly.min_cloud_width = 400.0 * mult;
		cloudAssembly.min_cloud_height = 400.0 * mult;
		cloudAssembly.z_scale = 0.5;

		#signal that new routines are used
		path = "new";
		}
	}

else if (type == "Nimbus") {

	# new code

	if (local_weather.hardcoded_clouds_flag ==1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") {var mult = 0.7;}
		else {var mult = 1.0;}

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/nimbus_sheet1.rgb";
		cloudAssembly.num_tex_x = 2;
		cloudAssembly.num_tex_y = 3;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.8;
		cloudAssembly.n_sprites = 10;
		cloudAssembly.min_width = 2700.0 * mult;
		cloudAssembly.max_width = 3000.0 * mult;
		cloudAssembly.min_height = 2700.0 * mult;
		cloudAssembly.max_height = 3000.0 * mult;
		cloudAssembly.min_cloud_width = 3500.0 * mult * mult * mult;
		cloudAssembly.min_cloud_height = 100.0 * mult * mult * mult + cloudAssembly.min_height;
		cloudAssembly.z_scale = 0.4;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{


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
	}
else if (type == "Stratus") {
	# new code

	if (local_weather.hardcoded_clouds_flag ==1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") {var mult = 0.8;}
		else {var mult = 1.0;}

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/stratus_sheet1.rgb";
		cloudAssembly.num_tex_x = 3;
		cloudAssembly.num_tex_y = 2;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.4;
		cloudAssembly.n_sprites = 20;
		cloudAssembly.min_width = 1900.0 * mult;
		cloudAssembly.max_width = 2400.0 * mult;
		cloudAssembly.min_height = 1900.0 * mult;
		cloudAssembly.max_height = 2400.0 * mult;
		cloudAssembly.min_cloud_width = 5000.0 * mult;
		cloudAssembly.min_cloud_height = 1.1 *  cloudAssembly.max_height;
		cloudAssembly.z_scale = 0.4;

		#signal that new routines are used
		path = "new";
		}

	else # old code
	{
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
	}
else if (type == "Stratus (thin)") {

	# new code

	if (local_weather.hardcoded_clouds_flag ==1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") 
			{
			var mult = 0.5;
			cloudAssembly.texture_sheet = "/Models/Weather/cirrocumulus_sheet1.rgb";
			cloudAssembly.num_tex_x = 3;
			cloudAssembly.num_tex_y = 3;
			cloudAssembly.n_sprites = 20;
			cloudAssembly.z_scale = 0.4;
			}
		else 
			{
			var mult = 1.0;
			cloudAssembly.texture_sheet = "/Models/Weather/stratus_sheet1.rgb";
			cloudAssembly.num_tex_x = 3;
			cloudAssembly.num_tex_y = 2;
			cloudAssembly.n_sprites = 10;
			cloudAssembly.z_scale = 0.3;
			}

		
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 0.8;
		cloudAssembly.min_width = 1500.0 * mult;
		cloudAssembly.max_width = 2000.0 * mult;
		cloudAssembly.min_height = 1500.0 * mult;
		cloudAssembly.max_height = 2000.0 * mult;
		cloudAssembly.min_cloud_width = 2500.0;
		cloudAssembly.min_cloud_height = 50.0;


		#signal that new routines are used
		path = "new";
		}

	else # old code
		{

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
	}
else if (type == "Cirrostratus") {

	# new code

	if (local_weather.hardcoded_clouds_flag ==1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "small") {var mult = 0.7;}
		else {var mult = 1.0;}

		# characterize the basic texture sheet
		cloudAssembly.texture_sheet = "/Models/Weather/cirrostratus_sheet1.rgb";
		cloudAssembly.num_tex_x = 2;
		cloudAssembly.num_tex_y = 2;
	
		#characterize the cloud
		cloudAssembly.bottom_shade = 1.0;
		cloudAssembly.n_sprites = 4;
		cloudAssembly.min_width = 3500.0 * mult;
		cloudAssembly.max_width = 4000.0 * mult;
		cloudAssembly.min_height = 3500.0 * mult;
		cloudAssembly.max_height = 4000.0 * mult;
		cloudAssembly.min_cloud_width = 8000.0;
		cloudAssembly.min_cloud_height = 50.0;
		cloudAssembly.z_scale = 0.3;

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{


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
else if (type == "Test") {path="Models/Weather/single_cloud.xml";}
else if (type == "Box_test") {
	if (subtype == "standard") {
		if (rn > 0.8) {path = "Models/Weather/cloudbox1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cloudbox2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cloudbox3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cloudbox4.xml";}
		else  {path = "Models/Weather/cloudbox5.xml";}		
		}
	else if (subtype == "core") {
		if (rn > 0.8) {path = "Models/Weather/cloudbox_core1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cloudbox_core2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cloudbox_core3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cloudbox_core4.xml";}
		else  {path = "Models/Weather/cloudbox_core5.xml";}		
		}
	else if (subtype == "bottom") {
		if (rn > 0.66) {path = "Models/Weather/cloudbox_bottom1.xml";}
		else if (rn > 0.33) {path = "Models/Weather/cloudbox_bottom2.xml";}
		else if (rn > 0.0) {path = "Models/Weather/cloudbox_bottom3.xml";}	
		}
	}
else if (type == "Cb_box") {

# new code

	if (local_weather.hardcoded_clouds_flag ==1)
		{
		cloudAssembly = local_weather.cloud.new(type, subtype);

		if (subtype == "standard")
			{
			if (rand() > 0.5) # use a Congestus texture
				{

				if (rand() > 0.5)
					{
					cloudAssembly.texture_sheet = "/Models/Weather/congestus_sheet1.rgb";
					cloudAssembly.num_tex_x = 1;
					cloudAssembly.num_tex_y = 3;
					cloudAssembly.min_width = 1300.0;
					cloudAssembly.max_width = 2000.0;
					cloudAssembly.min_height = 600.0;
					cloudAssembly.max_height = 900.0;			
					}
				else	
					{
					cloudAssembly.texture_sheet = "/Models/Weather/congestus_sheet2.rgb";
					cloudAssembly.num_tex_x = 1;
					cloudAssembly.num_tex_y = 2;
					cloudAssembly.min_width = 1200.0;
					cloudAssembly.max_width = 1800.0;
					cloudAssembly.min_height = 700.0;
					cloudAssembly.max_height = 1000.0;			
					}

				cloudAssembly.n_sprites = 3;
				cloudAssembly.min_cloud_width = 2200.0;
				cloudAssembly.min_cloud_height = 1200.0;
				cloudAssembly.bottom_shade = 0.4;
				cloudAssembly.z_scale = 1.0;
				}
			else
				{
				# characterize the basic texture sheet
				cloudAssembly.texture_sheet = "/Models/Weather/cumulonimbus_sheet2.rgb";
				cloudAssembly.num_tex_x = 2;
				cloudAssembly.num_tex_y = 2;
		
				#characterize the cloud
				cloudAssembly.bottom_shade = 0.6;
				cloudAssembly.n_sprites = 6;
				cloudAssembly.min_width = 800.0;
				cloudAssembly.max_width = 1100.0;
				cloudAssembly.min_height = 800.0;
				cloudAssembly.max_height = 1100.0;
				cloudAssembly.min_cloud_width = 3000.0;
				cloudAssembly.min_cloud_height = 1500.0;
				cloudAssembly.z_scale = 1.0;
				

				}
			}
		else if (subtype == "core")
			{
			# characterize the basic texture sheet
			cloudAssembly.texture_sheet = "/Models/Weather/cumulonimbus_sheet1.rgb";
			cloudAssembly.num_tex_x = 2;
			cloudAssembly.num_tex_y = 2;
	
			#characterize the cloud
			cloudAssembly.bottom_shade = 0.6;
			cloudAssembly.n_sprites = 10;
			cloudAssembly.min_width = 1000.0;
			cloudAssembly.max_width = 1500.0;
			cloudAssembly.min_height = 1000.0;
			cloudAssembly.max_height = 1500.0 ;
			cloudAssembly.min_cloud_width = 3500.0;
			cloudAssembly.min_cloud_height = 2000.0;
			cloudAssembly.z_scale = 1.0;
			}
		else if (subtype == "bottom")
			{
			cloudAssembly.texture_sheet = "/Models/Weather/cumulus_bottom_sheet1.rgb";
			cloudAssembly.num_tex_x = 1;
			cloudAssembly.num_tex_y = 1;
	
			#characterize the cloud
			cloudAssembly.bottom_shade = 0.5;
			cloudAssembly.n_sprites = 4;
			cloudAssembly.min_width = 1100.0;
			cloudAssembly.max_width = 1400.0;
			cloudAssembly.min_height = 1100.0;
			cloudAssembly.max_height = 1400.0;
			cloudAssembly.min_cloud_width = 1600;
			cloudAssembly.min_cloud_height = 1200;
			cloudAssembly.z_scale = 0.4;

			}

		#signal that new routines are used
		path = "new";
		}

	else # old code
		{



	if (subtype == "standard") {
		if (rn > 0.833) {path = "Models/Weather/cumulonimbus_sl6.xml";}
		else if (rn > 0.666) {path = "Models/Weather/cumulonimbus_sl7.xml";}
		else if (rn > 0.5) {path = "Models/Weather/cumulonimbus_sl8.xml";}
		else if (rn > 0.333) {path = "Models/Weather/congestus_sl1.xml";}
		else if (rn > 0.166) {path = "Models/Weather/congestus_sl2.xml";}	
		else  {path = "Models/Weather/congestus_sl3.xml";}			
		}
	else if (subtype == "core") {
		if (rn > 0.8) {path = "Models/Weather/cumulonimbus_sl1.xml";}
		else if (rn > 0.6) {path = "Models/Weather/cumulonimbus_sl2.xml";}
		else if (rn > 0.4) {path = "Models/Weather/cumulonimbus_sl3.xml";}
		else if (rn > 0.2) {path = "Models/Weather/cumulonimbus_sl4.xml";}
		else  {path = "Models/Weather/cumulonimbus_sl5.xml";}			
		}
	else if (subtype == "bottom") {
		if (rn > 0.0) {path = "Models/Weather/congestus_bottom1.xml";}
		}

		}
	}


else {print("Cloud type ", type, " subtype ",subtype, " not available!");}

return path;
}

# hash for assembling hard-coded clouds

var cloudAssembly = {};

