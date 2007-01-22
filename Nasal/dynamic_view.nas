# Dynamic Cockpit View manager. Tries to simulate the pilot's most likely
# deliberate view direction. Doesn't consider forced view changes due to
# acceleration.


sin = func(a) { math.sin(a * math.pi / 180.0) }
cos = func(a) { math.cos(a * math.pi / 180.0) }
sigmoid = func(x) { 1 / (1 + math.exp(-x)) }
nsigmoid = func(x) { 2 / (1 + math.exp(-x)) - 1 }
pow = func(v, w) { math.exp(math.ln(v) * w) }
npow = func(v, w) { math.exp(math.ln(abs(v)) * w) * (v < 0 ? -1 : 1) }
clamp = func(v, min, max) { v < min ? min : v > max ? max : v }
normatan = func(x) { math.atan2(x, 1) * 2 / math.pi }

normdeg = func(a) {
	while (a >= 180) {
		a -= 360;
	}
	while (a < -180) {
		a += 360;
	}
	return a;
}



# Class that reads a property value, applies factor & offset, clamps to min & max,
# and optionally lowpass filters.
#
Input = {
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
ViewAxis = {
	new : func(prop) {
		var m = { parents : [ViewAxis] };
		m.prop = props.globals.getNode(prop, 0);
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
};



# Class that manages a dynamic cockpit view by manipulating
# sim/current-view/goal-*-offset-deg properties.
#
ViewManager = {
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

		m.heading_axis = ViewAxis.new("/sim/current-view/goal-heading-offset-deg");
		m.pitch_axis = ViewAxis.new("/sim/current-view/goal-pitch-offset-deg");
		m.roll_axis = ViewAxis.new("/sim/current-view/goal-roll-offset-deg");

		# accelerations are converted to G (one G is subtracted from z-accel)
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

		if (props.globals.getNode("rotors", 0) != nil) {
			m.calculate = m.default_helicopter;
		} else {
			m.calculate = m.default_plane;
		}
		m.reset();
		return m;
	},
	reset : func {
		me.lookat_active = 0;
		me.heading_axis.reset();
		me.pitch_axis.reset();
		me.roll_axis.reset();
		me.add_offset();
	},
	add_offset : func {
		me.heading_axis.add_offset();
		me.pitch_axis.add_offset();
		me.roll_axis.add_offset();
	},
	apply : func {
		me.pitch = me.pitchN.getValue();
		me.roll = me.rollN.getValue();

		me.calculate();
		if (!me.lookat_active) {
			me.heading_axis.apply(me.heading_offset);
			me.pitch_axis.apply(me.pitch_offset);
			me.roll_axis.apply(me.roll_offset);
		}
	},
	lookat : func(heading = nil, pitch = nil) {
		if (heading != nil and pitch != nil) {
			if (!me.lookat_active) {
				me.save_heading = me.heading_axis.sub_offset();
				me.save_pitch = me.pitch_axis.sub_offset();
				me.save_roll = me.roll_axis.sub_offset();
			}
			me.lookat_active = 1;
			me.heading_axis.prop.setDoubleValue(heading);
			me.pitch_axis.prop.setDoubleValue(pitch);
			me.roll_axis.prop.setDoubleValue(0);
		} else {
			if (me.lookat_active) {
				me.heading_axis.prop.setDoubleValue(me.save_heading);
				me.pitch_axis.prop.setDoubleValue(me.save_pitch);
				me.roll_axis.prop.setDoubleValue(me.save_roll);
				me.add_offset();
			}
			me.lookat_active = 0;
			me.heading_axis.apply(me.heading_offset);
			me.pitch_axis.apply(me.pitch_offset);
			me.roll_axis.apply(me.roll_offset);
		}
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
main_loop = func(id) {
	if (id != loop_id) {
		return;
	}
	if (cockpit_view and !panel_visible and !mouse_button) {
		view_manager.apply();
	}
	settimer(func { main_loop(id) }, 0);
}


register = func(f) {
	view_manager.calculate = f;
}

reset = func {
	view_manager.reset();
}

lookat = func(heading = nil, pitch = nil) {
	view_manager.lookat(heading, pitch);
}

var original_resetView = nil;
var panel_visibilityN = nil;
var dynamic_view = nil;
var view_manager = nil;

var cockpit_view = nil;
var panel_visible = nil;
var mouse_button = nil;

var loop_id = 0;
var L = [];	# vector of listener ids; allows to remove all listeners (= useless feature :-)



# Initialization.
#
_setlistener("/sim/signals/nasal-dir-initialized", func {
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

	# let listeners keep some variables up-to-date, so that they don't have
	# to be queried in the loop
	append(L, setlistener("/sim/current-view/view-number", func {
		cockpit_view = (cmdarg().getValue() == 0);
	}, 1));

	append(L, setlistener("/sim/signals/reinit", func {
		cockpit_view = getprop("/sim/current-view/view-number") == 0;
		view_manager.reset();
	}, 0));

	append(L, setlistener("/sim/panel/visibility", func {
		panel_visible = cmdarg().getBoolValue();
	}, 1));

	append(L, setlistener("/devices/status/mice/mouse/button", func {
		mouse_button = cmdarg().getBoolValue();
	}, 1));

	view_manager = ViewManager.new();

	original_resetView = view.resetView;
	view.resetView = func {
		original_resetView();
		if (cockpit_view and dynamic_view) {
			view_manager.add_offset();
		}
	}

	append(L, setlistener("/sim/view/dynamic/enabled", func {
		dynamic_view = cmdarg().getBoolValue();
		loop_id += 1;
		view.resetView();
		if (dynamic_view) {
			main_loop(loop_id);
		}
	}, 1));
});


