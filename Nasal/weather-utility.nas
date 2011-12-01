##########
#this utility is a workaround for the fact that a shader uses listeners which cannot
# be used with a tied property
#

#does what it says on the tin
var clamp = func(v, min, max) { v < min ? min : v > max ? max : v }

#set global variables
var Amp = 1.0;
var Angle = 35.0;
var DAngle = 20.0;
var Freq = 0.01;
var Factor = 0.0004;
var Sharp = 1.0;

#add control properies for waves
wave_amp_Node = props.globals.getNode("/environment/wave/amp" , 1);
wave_amp_Node.setDoubleValue(Amp);

wave_freq_Node = props.globals.getNode("/environment/wave/freq" , 1);
wave_freq_Node.setDoubleValue(Freq);

wave_sharp_Node = props.globals.getNode("/environment/wave/sharp" , 1);
wave_sharp_Node.setDoubleValue(Sharp);

wave_angle_Node = props.globals.getNode("/environment/wave/angle" , 1);
wave_angle_Node.setDoubleValue(Angle);

wave_factor_Node = props.globals.getNode("/environment/wave/factor" , 1);
wave_factor_Node.setDoubleValue(Factor);

wave_factor_Node = props.globals.getNode("/environment/wave/dangle" , 1);
wave_factor_Node.setDoubleValue(DAngle);

props.globals.initNode("/environment/sea/surface/wind-speed-kt", 0, "DOUBLE");
props.globals.initNode("/environment/sea/surface/wind-from-east-fps", 0, "DOUBLE");
props.globals.initNode("/environment/sea/surface/wind-from-north-fps", 0, "DOUBLE");
props.globals.initNode("/environment/sea/surface/wind-from-deg", 0, "DOUBLE");
props.globals.initNode("/environment/sea/surface/config/enabled", 0, "DOUBLE");
#object rotation values
props.globals.initNode("/orientation/model/heading-deg", 0, "DOUBLE");
props.globals.initNode("/orientation/model/pitch-deg", 0, "DOUBLE");
props.globals.initNode("/orientation/model/roll-deg", 0, "DOUBLE");


var initialize = func {

	wind_from_east_Node = props.globals.getNode("/environment/config/boundary/entry[0]/wind-from-east-fps", 1);
	wind_from_east_Node.setDoubleValue(0);

	wind_from_north_Node = props.globals.getNode("/environment/config/boundary/entry[0]/wind-from-north-fps", 1);
	wind_from_north_Node.setDoubleValue(0);

	wind_from_Node = props.globals.getNode("/environment/config/boundary/entry[0]/wind-from-heading-deg", 1);
	wind_from_Node.setDoubleValue(0);

	wind_speed_Node = props.globals.getNode("/environment/config/boundary/entry[0]/wind-speed-kt", 1);
	wind_speed_Node.setDoubleValue(0);

	wind_status_Node = props.globals.getNode("/environment/config/enabled", 1);
	wind_status_Node.setBoolValue(1);

	ground_vis_Node = props.globals.getNode("/environment/ground-visibility-m", 1);
	ground_vis_Node.setDoubleValue(500);

	ground_thick_Node = props.globals.getNode("/environment/ground-haze-thickness-m" , 1);
	ground_thick_Node.setDoubleValue(300);

	ground_term_Node = props.globals.getNode("/environment/terminator-relative-position-m" , 1);
	ground_term_Node.setDoubleValue(60000);


# ##################  listeners ####################
#
	setlistener("/environment/sea/surface/wind-speed-kt", func (n) {
		var wind = 0;
		var amp = 0;
		var angle = 0;
		var dangle = 0;
		var freq = 0;
		var factor = 0;
		var sharp = 0;

		wind = n.getValue();

		amp = Amp + 0.02 * wind;
		amp = clamp(amp, 1.0, 2.0);

		setprop("/environment/wave/amp", amp);

		angle = Angle + 0.2 * wind;
		setprop("/environment/wave/angle", angle);

		dangle = DAngle - 0.4 * wind;
		setprop("/environment/wave/dangle", dangle);

		freq = Freq + 0.0008 * wind;
		freq = clamp(freq, 0.01, 0.015);
		setprop("/environment/wave/freq", freq);

		factor = Factor - 0.00001 * wind;
		factor = clamp(factor, 0.0001, 0.0004);
		setprop("/environment/wave/factor", factor);

		sharp = Sharp + 0.02 * wind;
		sharp = clamp(sharp, 1.0, 2.0);
		setprop("/environment/wave/sharp", sharp);


	},
		1,
		0);# end listener

		print("weather util initialized ...");
	loop();

}# end init

var loop = func {
	var value = getprop("/environment/config/boundary/entry[0]/wind-from-east-fps");
	setprop("/environment/sea/surface/wind-from-east-fps", value);
#        print("wind-from-east-fps ", getprop("/environment/sea/surface/wind-from-east-fps"));

	value = getprop("/environment/config/boundary/entry[0]/wind-from-north-fps");
	setprop("/environment/sea/surface/wind-from-north-fps", value);
#        print("wind-from-north-fps ", getprop("/environment/sea/surface/wind-from-north-fps"));

	value = getprop("/environment/config/boundary/entry[0]/wind-from-heading-deg");
	setprop("/environment/sea/surface/wind-from-deg", value);
#        print("wind-from-deg ", getprop("/environment/sea/surface/wind-from-deg"));

	value = getprop("/environment/config/boundary/entry[0]/wind-speed-kt");
	setprop("/environment/sea/surface/wind-speed-kt", value);
#        print("wind-speed-kt ", getprop("/environment/sea/surface/wind-speed-kt"));

	value = getprop("/environment/config/enabled");
	setprop("/environment/sea/config/enabled", value);
#        print("wind-speed-kt ", getprop("/environment/config/enabled"));

#						orientation fix
#orientation
	value = getprop("/orientation/heading-deg") or 0.0;
	setprop("/orientation/model/heading-deg", value);
	value = getprop("/orientation/pitch-deg") or 0.0;
	setprop("/orientation/model/pitch-deg", value);
	value = getprop("/orientation/roll-deg") or 0.0;
	setprop("/orientation/model/roll-deg", value);

	settimer(loop,0);

}

# Fire it up

setlistener("sim/signals/fdm-initialized", initialize);

# end

