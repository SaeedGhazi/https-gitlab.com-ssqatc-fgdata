
sin = func(a) { math.sin(a * math.pi / 180.0) }
cos = func(a) { math.cos(a * math.pi / 180.0) }
sigmoid = func(x) { 1 / (1 + math.exp(-x)) }
nsigmoid = func(x) { 2 / (1 + math.exp(-x)) - 1 }
pow = func(v, w) { math.exp(math.ln(v) * w) }
npow = func(v, w) { math.exp(math.ln(abs(v)) * w) * (v < 0 ? -1 : 1) }
clamp = func(v, min, max) { v < min ? min : v > max ? max : v }


var L = [];

# Let listeners keep some variables up-to-date, so that they don't have
# to be queried in the main loop.
#
var cockpit_view = nil;
append(L, setlistener("/sim/current-view/view-number",func {
	cockpit_view = (cmdarg().getValue() == 0);
}, 1));

append(L, setlistener("/sim/signals/reinit", func {
	cockpit_view = getprop("/sim/current-view/view-number") == 0;
}, 0));

var panel_visible = nil;
append(L, setlistener("/sim/panel/visibility", func {
	panel_visible = cmdarg().getBoolValue();
}, 1));

var mouse_button = nil;
append(L, setlistener("/devices/status/mice/mouse/button", func {
	mouse_button = cmdarg().getBoolValue();
}, 1));


# Class that reads a property value, applies factor & offset, clamps to min & max,
# and optionally lowpass filters. lowpass = 0 means no filtering, lowpass = 1
# generates a coefficient 0.1, lowpass = 2 a coefficient 0.01 etc.
#
Input = {
	new : func(prop = nil, factor = 1, offset = 0, lowpass = 0, min = nil, max = nil) {
		var m = { parents : [Input] };
		if (prop == nil) {
			m.get = func { 0 }
			m.set = func {}
			return m;
		}
		m.prop = isa(props.Node, prop) ? prop : props.globals.getNode(prop, 1);
		m.factor = factor;
		m.offset = offset;
		m.min = min;
		m.max = max;
		m.coeff = 0;
		m.damped = m.get();	# wants coeff = 0!
		m.coeff = lowpass ? 1.0 - 1.0 / pow(10, abs(lowpass)) : 0;
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
		return !me.coeff ? v : (me.damped = v * (1 - me.coeff) + me.damped * me.coeff);

	},
	set : func(v) {
		me.prop.setDoubleValue(v);
	},
};



# Class that maintains one sim/current-view/goal-*-offset-deg property.
# Applies the value that the input() method returns. This function needs
# to get overridden.
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
	input : func {
		die("ViewAxis.input() is pure virtual");
	},
	apply : func {
		var v = me.prop.getValue() - me.applied_offset;
		me.applied_offset = me.input();
		me.prop.setDoubleValue(v + me.applied_offset);
	},
	add_offset : func {
		me.prop.setValue(me.prop.getValue() + me.applied_offset);
	},
};



# Class that manages a dynamic cockpit view by manipulating
# sim/current-view/goal-*-offset-deg properties.
#
ViewManager = {
	new : func {
		var m = { parents : [ViewManager] };
		m.headingN = props.globals.getNode("orientation/heading-deg", 1);
		m.pitchN = props.globals.getNode("orientation/pitch-deg", 1);
		m.rollN = props.globals.getNode("orientation/roll-deg", 1);

		m.heading_axis = ViewAxis.new("sim/current-view/goal-heading-offset-deg");
		m.pitch_axis = ViewAxis.new("sim/current-view/goal-pitch-offset-deg");
		m.roll_axis = ViewAxis.new("sim/current-view/goal-roll-offset-deg");

		# accerations are converted to G
		m.ax = Input.new("accelerations/pilot/x-accel-fps_sec", 0.03108095, 0, 1.1, 0);
		m.ay = Input.new("accelerations/pilot/y-accel-fps_sec", 0.03108095, 0, 1.1);
		m.az = Input.new("accelerations/pilot/z-accel-fps_sec", -0.03108095, -1, 1.0073);

		# velocities are converted to knots
		#m.vx = Input.new("velocities/uBody-fps", 0.5924838, 0);
		#m.vy = Input.new("velocities/vBody-fps", 0.5924838, 0);
		#m.vz = Input.new("velocities/wBody-fps", 0.5924838, 0);

		m.wow = Input.new("gear/gear/wow", 2, -1, 1);
		m.adir = 0;

		m.heading_axis.input = func {				# heading ...
			-10 * sin(me.roll) * cos(me.pitch)		#     due to roll
			+ me.steering					#     due to ground steering
		}
		m.pitch_axis.input = func {				# pitch ...
			10 * sin(me.roll) * sin(me.roll)		#     due to roll
			+ 30 * (1 / (1 + math.exp(2 - me.pilot_az))	#     due to G load
				- 0.119202922)				#         [move to origin; 1/(1+exp(2)) ]
		}
		m.roll_axis.input = func {				# roll ...
			0.0 * sin(me.roll) * cos(me.pitch)		#     due to roll  (none)
		}

		m.reset();
		return m;
	},
	reset : func {
		me.heading_axis.reset();
		me.pitch_axis.reset();
		me.roll_axis.reset();
	},
	apply : func {
		var wow = me.wow.get();
		var ax = me.ax.get();
		var ay = me.ay.get();
		var az = me.az.get();
		#var vx = me.vx.get();
		#var vy = me.vy.get();

		var adir = math.atan2(-ay, ax) * 180 / math.pi;
		#var vdir = math.atan2(vy, vx) * 180 / math.pi;

		var aval = math.sqrt(ax * ax + ay * ay);
		#var vval = math.sqrt(vx * vx + vy * vy);

		ViewAxis.pilot_az = az;
		ViewAxis.pitch = me.pitchN.getValue();
		ViewAxis.roll = me.rollN.getValue();
		ViewAxis.steering = 80 * wow
				* nsigmoid(adir * 5.5 / 180)
				* nsigmoid(aval);

		me.heading_axis.apply();
		me.pitch_axis.apply();
		me.roll_axis.apply();
	},
	add_offsets : func {
		me.heading_axis.add_offset();
		me.pitch_axis.add_offset();
		me.roll_axis.add_offset();
	},
};



# Update loop for the whole dynamice view manager. It only runs if
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



var dynamic_view = nil;
var original_resetView = nil;
var view_manager = nil;
var panel_visibilityN = nil;

var loop_id = 0;



# Initialization.
#
settimer(func {
	if (getprop("/sim/flight-model") == "yasim") {
		#aglN = props.globals.getNode("position/gear-agl-ft", 1);
	} else {
		#aglN = props.globals.getNode("position/altitude-agl-ft", 1);
	}

	original_resetView = view.resetView;
	view_manager = ViewManager.new();

	view.resetView = func {
		original_resetView();
		if (cockpit_view and dynamic_view) {
			view_manager.add_offsets();
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
}, 5);


