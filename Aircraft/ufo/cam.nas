####   Aerotro's Flightgear Cam  ####

var CAM = props.globals.getNode("/sim/cam");

var MPS = 0.514444444;
var D2R = math.pi / 180;
var R2D = 180 / math.pi;
var sin = func(v) math.sin(v * D2R);
var cos = func(v) math.cos(v * D2R);
var atan2 = func(v, w) math.atan2(v, w) * R2D;

var ViewNum = 0;
var Grd_Offset = 5.0;
var panel = gui.Dialog.new("/sim/gui/dialogs/cam/dialog", "Aircraft/ufo/Dialogs/campanel.xml");
var maxspeedN = props.globals.getNode("engines/engine/speed-max-mps");
var speed = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000];
var current = 7;
var maxspeed = speed[current];
var cam_view = nil;

var targetN = nil;
var target = geo.Coord.new();
var self = nil;


controls.flapsDown = func(x) {
	if (!x)
		return;
	elsif (x < 0 and current > 0)
		current -= 1;
	elsif (x > 0 and current < size(speed) - 1)
		current += 1;

	maxspeed = speed[current];
}


var throttle = 0;
controls.throttleAxis = func {
	val = cmdarg().getNode("setting").getValue();
	if (size(arg) > 0)
		val = -val;
	throttle = (1 - val) * 0.5;
}


# directly called from the dialog
var goto_target = func {
	targetN != nil or return;
	var lat = targetN.getNode("position/latitude-deg").getValue();
	var lon = targetN.getNode("position/longitude-deg").getValue();
	var alt = targetN.getNode("position/altitude-ft").getValue() * geo.FT2M;
	var speed = targetN.getNode("velocities/true-airspeed-kt").getValue() * MPS * 2;
	var course = targetN.getNode("orientation/true-heading-deg").getValue();
	self.set_latlon(lat, lon, alt).apply_course_distance(course + 180, 100);
	setprop("/position/latitude-deg", self.lat());
	setprop("/position/longitude-deg", self.lon());
	altL.set(self.alt());
	speedL.set(speed);
	mode.chase.setValue(1);
	mode.focus.setValue(1);
	mode.alt.setValue(1);
	mode.speed.setValue(1);
	maxspeed = speed * 2;
	throttleL.set(0.5);
}


var set_aircraft = func {
	var list = [];
	if (getprop("/sim/cam/target-ai"))
		list ~= props.globals.getNode("/ai/models").getChildren("aircraft");
	if (getprop("/sim/cam/target-mp"))
		list ~= props.globals.getNode("/ai/models").getChildren("multiplayer");

	var name = "";
	var index = getprop("/sim/cam/target-number");
	targetN = nil;

	if (size(list)) {
		if (index < 0)
			index = size(list) - 1;
		elsif (index >= size(list))
			index = 0;

		targetN = list[index];
		name = targetN.getNode("callsign").getValue();
		printlog("info", "cam: new aircraft: ", targetN.getPath(), "\t", name);
	}

	setprop("/sim/cam/target-number", index);
	setprop("/sim/cam/target-name", name);
}


var viewhdgL = aircraft.angular_lowpass.new(0.2);
var viewpitchL = aircraft.lowpass.new(0.1);
var viewrollL = aircraft.lowpass.new(0.1);

var hdgL = aircraft.angular_lowpass.new(0.6);
var altL = aircraft.lowpass.new(3);
var speedL = aircraft.lowpass.new(2);
var throttleL = aircraft.lowpass.new(0.3);

var goal_headingN = props.globals.getNode("sim/current-view/goal-heading-offset-deg");
var goal_pitchN = props.globals.getNode("sim/current-view/goal-pitch-offset-deg");
var goal_rollN = props.globals.getNode("sim/current-view/goal-roll-offset-deg");
var mode = {
	chase : props.globals.getNode("/sim/cam/chase"),
	focus : props.globals.getNode("/sim/cam/focus"),
	speed : props.globals.getNode("/sim/cam/speed"),
	alt   : props.globals.getNode("/sim/cam/alt"),
	lock  : props.globals.getNode("/sim/cam/lock"),
};


var update = func {
	target.set_latlon(
		targetN.getNode("position/latitude-deg").getValue(),
		targetN.getNode("position/longitude-deg").getValue(),
		targetN.getNode("position/altitude-ft").getValue() * geo.FT2M);

	self = geo.aircraft_position();
if (0) {
	if (mode.lock.getValue()) {
		self.set(target);
		self.apply_course_distance(rel.course, rel.distance);
		self.set_alt(target.alt() + rel.alt);
		setprop("/position/latitude-deg", self.lat());
		setprop("/position/longitude-deg", self.lon());
		setprop("/position/altitude-ft", self.alt() * geo.M2FT);
	}
}

	var self_heading = getprop("/orientation/heading-deg");
	var self_pitch = getprop("/orientation/pitch-deg");
	var self_roll = getprop("/orientation/roll-deg");

	if (abs(self_pitch) > 2)
		mode.alt.setValue(0);
	if (abs(self_roll) > 2)
		mode.chase.setValue(0);

	if (mode.alt.getValue())
		setprop("/position/altitude-ft", altL.filter(target.alt()) * geo.M2FT);
	else
		altL.filter(self.alt());

	var distance = self.direct_distance_to(target);
	if (distance < 1) {
		var course = targetN.getNode("orientation/true-heading-deg").getValue();
		mode.focus.setValue(0);
		mode.chase.setValue(0);
	} else {
		var course = self.course_to(target);
	}
	var elevation = atan2(target.alt() - altL.get(), distance);

	if (mode.chase.getValue())
		setprop("/orientation/heading-deg", self_heading = hdgL.filter(course));

	if (mode.focus.getValue()) {
		var h = viewhdgL.filter(self_heading - course);
		var p = elevation - self_pitch * cos(h);
		var r = -self_roll * sin(h);
		goal_headingN.setValue(h);
		goal_pitchN.setValue(viewpitchL.filter(p));
		goal_rollN.setValue(viewrollL.filter(r));
	}

	if (mode.speed.getValue())
		maxspeed = targetN.getNode("velocities/true-airspeed-kt").getValue() * MPS * 2;
	else
		maxspeed = speed[current];
	maxspeedN.setDoubleValue(speedL.filter(maxspeed));

	var AGL = getprop("/position/altitude-agl-ft");
	if (AGL < Grd_Offset)
		setprop("/position/altitude-ft", getprop("/position/altitude-ft") + Grd_Offset - AGL);

	props.setAll("/controls/engines/engine", "throttle", throttleL.filter(throttle));
}


var loop = func {
	if (ViewNum == cam_view and targetN != nil)
		update();

	settimer(loop, 0);
}


setlistener("/sim/cam/target-number", set_aircraft);
setlistener("/sim/cam/target-ai", set_aircraft);
setlistener("/sim/cam/target-mp", set_aircraft);
setlistener("/sim/current-view/view-number", func {
	ViewNum = cmdarg().getValue();
	if (ViewNum == 7)
		panel.open();
	else
		panel.dialog.close();
});


if (0) {
var rel = { course: 0, distance: 0, alt: 0 };
setlistener("/sim/cam/lock", func {
	if (cmdarg().getValue()) {
		rel.course = target.course_to(self);
		rel.distance = target.distance_to(self);
		rel.alt = self.alt() - target.alt();
	}
});
}


setlistener("/sim/signals/fdm-initialized", func {
	var views = props.globals.getNode("/sim").getChildren("view");
	forindex (var i; views)
		if (views[i].getNode("name").getValue() == "Cam View")
			cam_view = i;

	setprop("/sim/current-view/view-number", cam_view);
	setprop("/engines/engine/speed-max-mps", 500);
	settimer(set_aircraft, 1);
	loop();
});


