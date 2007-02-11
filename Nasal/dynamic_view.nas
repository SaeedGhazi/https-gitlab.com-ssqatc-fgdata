# Dynamic Cockpit View manager. Tries to simulate the pilot's most likely
# deliberate view direction. Doesn't consider forced view changes due to
# acceleration.
#
# To override the default recipes, put something like this into one of
# your aircraft's Nasal files:
#
#   dynamic_view.register(func {
#           # me.default_plane();      # uncomment one of these if you want
#           # me.default_helicopter(); # to base your code on the defaults
#
#                                      # positive values rotate (deg) or move (m)
#           me.heading_offset = ...    #     left
#           me.pitch_offset = ...      #     up
#           me.roll_offset = ...       #     right
#           me.x_offset = ...          #     right     (transversal axis)
#           me.y_offset = ...          #     up        (vertical axis)
#           me.z_offset = ...          #     back/aft  (longitudinal axis)
#           me.fov_offset = ...        #     zoom out  (field of view)
#   });
#
# All offsets are by default 0, and you only need to set them if they should
# be non-zero. The registered function is called for each frame and the respective
# view parameters are set accordingly. The function can access all internal
# variables of the ViewManager class, such as me.roll, me.pitch, etc., and it
# can, of course, also use module variables from the file where it's defined.
#
# The following commands move smoothly to a fixed view position and back.
# All values are relative to aircraft origin (absolute), not relative to
# the default cockpit view position. The speed and field-of-view argument
# is optional.
#
#   dynamic_view.lookat(hdg, pitch, roll, x, y, z [, speed=0.2 [, fov=55]]);
#   dynamic_view.resume();


var sin = func(a) { math.sin(a * math.pi / 180.0) }
var cos = func(a) { math.cos(a * math.pi / 180.0) }
var sigmoid = func(x) { 1 / (1 + math.exp(-x)) }
var nsigmoid = func(x) { 2 / (1 + math.exp(-x)) - 1 }
var pow = func(v, w) { v < 0 ? nil : v == 0 ? 0 : math.exp(math.ln(v) * w) }
var npow = func(v, w) { v == 0 ? 0 : math.exp(math.ln(abs(v)) * w) * (v < 0 ? -1 : 1) }
var clamp = func(v, min, max) { v < min ? min : v > max ? max : v }
var normatan = func(x) { math.atan2(x, 1) * 2 / math.pi }

var normdeg = func(a) {
	while (a >= 180) {
		a -= 360;
	}
	while (a < -180) {
		a += 360;
	}
	return a;
}




var FREEZE_DURATION = 2;
var BLEND_SPEED = 0.2;



# Class that reads a property value, applies factor & offset, clamps to min & max,
# and optionally lowpass filters.
#
var Input = {
	new : func(prop = "/null", factor = 1, offset = 0, filter = 0, min = nil, max = nil) {
		var m = { parents : [Input] };
		m.prop = isa(props.Node, prop) ? prop : props.globals.getNode(prop, 1);
		m.factor = factor;
		m.offset = offset;
		m.min = min;
		m.max = max;
		m.lowpass = filter ? aircraft.lowpass.new(filter) : nil;
		return m;
	},
	get : func {
		var v = me.prop.getValue() * me.factor + me.offset;
		if (me.min != nil and v < me.min) {
			v = me.min;
		}
		if (me.max != nil and v > me.max) {
			v = me.max;
		}
		return me.lowpass == nil ? v : me.lowpass.filter(v);

	},
	set : func(v) {
		me.prop.setDoubleValue(v);
	},
};



# Class that maintains one sim/current-view/goal-*-offset-deg property.
#
var ViewAxis = {
	new : func(prop) {
		var m = { parents : [ViewAxis] };
		m.prop = props.globals.getNode(prop, 1);
		if (m.prop.getType() == "NONE") {
			m.prop.setDoubleValue(0);
		}
		m.reset();
		return m;
	},
	reset : func {
		me.applied_offset = 0;
	},
	add_offset : func {
		me.prop.setValue(me.prop.getValue() + me.applied_offset);
	},
	sub_offset : func {
		var raw = me.prop.getValue() - me.applied_offset;
		me.prop.setValue(raw);
		return raw;
	},
	apply : func(v) {
		var raw = me.prop.getValue() - me.applied_offset;
		me.applied_offset = v;
		me.prop.setDoubleValue(raw + me.applied_offset);
	},
	static : func(v) {
		normdeg(v - me.prop.getValue() + me.applied_offset);
	},
};



# Class that manages a dynamic cockpit view by manipulating
# sim/current-view/goal-*-offset-deg properties.
#
var ViewManager = {
	new : func {
		var m = { parents : [ViewManager] };
		m.elapsedN = props.globals.getNode("/sim/time/elapsed-sec", 1);
		m.deltaN = props.globals.getNode("/sim/time/delta-realtime-sec", 1);

		m.headingN = props.globals.getNode("/orientation/heading-deg", 1);
		m.pitchN = props.globals.getNode("/orientation/pitch-deg", 1);
		m.rollN = props.globals.getNode("/orientation/roll-deg", 1);
		m.slipN = props.globals.getNode("/orientation/side-slip-deg", 1);
		m.speedN = props.globals.getNode("velocities/airspeed-kt", 1);

		m.wind_dirN = props.globals.getNode("/environment/wind-from-heading-deg", 1);
		m.wind_speedN = props.globals.getNode("/environment/wind-speed-kt", 1);

		m.axes = [
			m.heading_axis = ViewAxis.new("/sim/current-view/goal-heading-offset-deg"),
			m.pitch_axis = ViewAxis.new("/sim/current-view/goal-pitch-offset-deg"),
			m.roll_axis = ViewAxis.new("/sim/current-view/goal-roll-offset-deg"),
			m.x_axis = ViewAxis.new("/sim/current-view/x-offset-m"),
			m.y_axis = ViewAxis.new("/sim/current-view/y-offset-m"),
			m.z_axis = ViewAxis.new("/sim/current-view/z-offset-m"),
			m.fov_axis = ViewAxis.new("/sim/current-view/field-of-view"),
		];

		# accelerations are converted to G (Earth gravitation is omitted)
		m.ax = Input.new("/accelerations/pilot/x-accel-fps_sec", 0.03108095, 0, 0.58, 0);
		m.ay = Input.new("/accelerations/pilot/y-accel-fps_sec", 0.03108095, 0, 0.95);
		m.az = Input.new("/accelerations/pilot/z-accel-fps_sec", -0.03108095, -1, 0.46);

		# velocities are converted to knots
		m.vx = Input.new("/velocities/uBody-fps", 0.5924838, 0, 0.45);
		m.vy = Input.new("/velocities/vBody-fps", 0.5924838, 0);
		m.vz = Input.new("/velocities/wBody-fps", 0.5924838, 0);

		# turn WoW bool into smooth values ranging from 0 to 1
		m.wow = Input.new("/gear/gear/wow", 1, 0, 0.74);
		m.hdg_change = aircraft.lowpass.new(0.95);
		m.ubody = aircraft.lowpass.new(0.95);
		m.last_heading = m.headingN.getValue();
		m.size_factor = getprop("/sim/chase-distance-m") / -25;

		# "lookat" blending
		m.blendN = props.globals.getNode("/sim/view/dynamic/blend", 1);
		m.blendN.setDoubleValue(0);
		m.blendspeed = BLEND_SPEED;
		m.frozen = 0;

		if (props.globals.getNode("rotors", 0) != nil) {
			m.calculate = m.default_helicopter;
		} else {
			m.calculate = m.default_plane;
		}
		m.reset();
		return m;
	},
	reset : func {
		me.heading_offset = me.heading = me.target_heading = 0;
		me.pitch_offset = me.pitch = me.target_pitch = 0;
		me.roll_offset = me.roll = me.target_roll = 0;
		me.x_offset = me.x = me.target_x = 0;
		me.y_offset = me.y = me.target_y = 0;
		me.z_offset = me.z = me.target_z = 0;
		me.fov_offset = me.fov = me.target_fov = 0;

		interpolate(me.blendN);
		me.blendN.setDoubleValue(0);
		foreach (var a; me.axes) {
			a.reset();
		}
		me.add_offset();
	},
	add_offset : func {
		me.heading_axis.add_offset();
		me.pitch_axis.add_offset();
		me.roll_axis.add_offset();
		me.fov_axis.add_offset();
	},
	apply : func {
		if (me.elapsedN.getValue() < me.frozen) {
			return;
		} elsif (me.frozen) {
			me.unfreeze();
		}

		me.pitch = me.pitchN.getValue();
		me.roll = me.rollN.getValue();

		me.calculate();

		var b = me.blendN.getValue();
		var B = 1 - b;
		me.heading = me.target_heading * b + me.heading_offset * B;
		me.pitch = me.target_pitch * b + me.pitch_offset * B;
		me.roll = me.target_roll * b + me.roll_offset * B;
		me.x = me.target_x * b + me.x_offset * B;
		me.y = me.target_y * b + me.y_offset * B;
		me.z = me.target_z * b + me.z_offset * B;
		me.fov = me.target_fov * b + me.fov_offset * B;

		me.heading_axis.apply(me.heading);
		me.pitch_axis.apply(me.pitch);
		me.roll_axis.apply(me.roll);
		me.x_axis.apply(me.x);
		me.y_axis.apply(me.y);
		me.z_axis.apply(me.z);
		me.fov_axis.apply(me.fov);
	},
	lookat : func(heading, pitch, roll, x, y, z, speed, fov) {
		me.target_heading = me.heading_axis.static(heading);
		me.target_pitch = me.pitch_axis.static(pitch);
		me.target_roll = me.roll_axis.static(roll);
		me.target_x = me.x_axis.static(x);
		me.target_y = me.y_axis.static(y);
		me.target_z = me.z_axis.static(z);
		me.target_fov = me.fov_axis.static(fov);

		me.blendspeed = speed;
		me.blendN.setValue(0);
		interpolate(me.blendN, 1, me.blendspeed);
	},
	resume : func {
		interpolate(me.blendN, 0, me.blendspeed);
		me.blendspeed = BLEND_SPEED;
	},
	freeze : func {
		if (!me.frozen) {
			me.target_heading = me.heading;
			me.target_pitch = me.pitch;
			me.target_roll = me.roll;
			me.target_x = me.x;
			me.target_y = me.y;
			me.target_z = me.z;
			me.target_fov = me.fov;
			me.blendN.setDoubleValue(1);
		}
		me.frozen = me.elapsedN.getValue() + FREEZE_DURATION;
	},
	unfreeze : func {
		me.frozen = 0;
		me.resume();
	},
};



# default calculations for a plane
#
ViewManager.default_plane = func {
	var wow = me.wow.get();

	# calculate steering factor
	var hdg = me.headingN.getValue();
	var hdiff = normdeg(me.last_heading - hdg);
	me.last_heading = hdg;
	var steering = normatan(me.hdg_change.filter(hdiff)) * me.size_factor;

	var az = me.az.get();
	var vx = me.vx.get();

	# calculate sideslip factor (zeroed when no forward ground speed)
	var wspd = me.wind_speedN.getValue();
	var wdir = me.headingN.getValue() - me.wind_dirN.getValue();
	var u = vx - wspd * cos(wdir);
	var slip = sin(me.slipN.getValue()) * me.ubody.filter(normatan(u / 10));

	me.heading_offset =							# view heading
		-15 * sin(me.roll) * cos(me.pitch)				#     due to roll
		+ 40 * steering * wow						#     due to ground steering
		+ 10 * slip * (1 - wow);					#     due to sideslip (in air)

	me.pitch_offset =							# view pitch
		10 * sin(me.roll) * sin(me.roll)				#     due to roll
		+ 30 * (1 / (1 + math.exp(2 - az))				#     due to G load
			- 0.119202922);						#         [move to origin; 1/(1+exp(2)) ]

	me.roll_offset = 0;
}



# default calculations for a helicopter
#
ViewManager.default_helicopter = func {
	var lowspeed = 1 - normatan(me.speedN.getValue() / 20);

	me.heading_offset =							# view heading due to
		-50 * npow(sin(me.roll) * cos(me.pitch), 2);			#    roll

	me.pitch_offset =							# view pitch due to
		(me.pitch < 0 ? -35 : -40) * sin(me.pitch) * lowspeed		#    pitch
		+ 15 * sin(me.roll) * sin(me.roll);				#    roll

	me.roll_offset =							# view roll due to
		-15 * sin(me.roll) * cos(me.pitch) * lowspeed;			#    roll
}



# Update loop for the whole dynamic view manager. It only runs if
# /sim/view[0]/dynamic/enabled is true.
#
var main_loop = func(id) {
	if (id != loop_id) {
		return;
	}
	if (cockpit_view and !panel_visible) {
		if (mouse_button) {
			freeze();
		} else {
			view_manager.apply();
		}
	}
	settimer(func { main_loop(id) }, 0);
}



var freeze = func {
	if (mouse_mode == 0) {
		view_manager.freeze();
	}
}

var register = func(f) {
	view_manager.calculate = f;
}

var reset = func {
	view_manager.reset();
}

var lookat = func(h, p, r, x, y, z, s = BLEND_SPEED, f = 55) {
	view_manager.lookat(h, p, r, x, y, z, s, f);
}

var resume = func {
	view_manager.resume();
}


var original_resetView = nil;
var panel_visibilityN = nil;
var dynamic_view = nil;
var view_manager = nil;

var cockpit_view = nil;
var panel_visible = nil;	# whether 2D panel is visible
var elapsedN = nil;
var mouse_mode = nil;
var mouse_button = nil;

var loop_id = 0;


# Initialization.
#
var L = _setlistener("/sim/signals/nasal-dir-initialized", func {
	removelistener(L);
	# disable menu entry and return for inappropriate FDMs  (see Main/fg_init.cxx)
	var fdms = {
		acms:0, ada:0, balloon:0, external:0,
		jsb:1, larcsim:1, magic:0, network:0,
		null:0, pipe:0, ufo:0, yasim:1,
	};
	var fdm = getprop("/sim/flight-model");
	if (!contains(fdms, fdm) or !fdms[fdm]) {
		return gui.menuEnable("dynamic-view", 0);
	}

	# some properties may still be unavailable or nil
	props.globals.getNode("/accelerations/pilot/x-accel-fps_sec", 1).setDoubleValue(0);
	props.globals.getNode("/accelerations/pilot/y-accel-fps_sec", 1).setDoubleValue(0);
	props.globals.getNode("/accelerations/pilot/z-accel-fps_sec", 1).setDoubleValue(-32);
	props.globals.getNode("/orientation/side-slip-deg", 1).setDoubleValue(0);
	props.globals.getNode("/gear/gear/wow", 1).setBoolValue(1);
	elapsedN = props.globals.getNode("/sim/time/elapsed-sec", 1);

	# let listeners keep some variables up-to-date, so that they don't have
	# to be queried in the loop
	setlistener("/sim/current-view/view-number", func { cockpit_view = !cmdarg().getValue() }, 1);
	setlistener("/devices/status/mice/mouse/mode", func { mouse_mode = cmdarg().getValue() }, 1);
	setlistener("/sim/panel/visibility", func { panel_visible = cmdarg().getValue() }, 1);
	setlistener("/devices/status/mice/mouse/button", func { mouse_button = cmdarg().getValue() }, 1);
	setlistener("/devices/status/mice/mouse/x", freeze);
	setlistener("/devices/status/mice/mouse/y", freeze);

	setlistener("/sim/signals/reinit", func {
		cmdarg().getValue() and return;
		cockpit_view = getprop("/sim/current-view/view-number") == 0;
		view_manager.reset();
	}, 0);

	view_manager = ViewManager.new();

	original_resetView = view.resetView;
	view.resetView = func {
		original_resetView();
		if (cockpit_view and dynamic_view) {
			view_manager.add_offset();
		}
	}

	settimer(func {
		setlistener("/sim/view/dynamic/enabled", func {
			dynamic_view = cmdarg().getBoolValue();
			loop_id += 1;
			view.resetView();
			if (dynamic_view) {
				main_loop(loop_id);
			}
		}, 1);
	}, 0);
});


