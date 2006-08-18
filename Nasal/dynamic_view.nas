
sin = func(a) { math.sin(a * math.pi / 180.0) }
cos = func(a) { math.cos(a * math.pi / 180.0) }
sigmoid = func(x) { 1 / (1 + math.exp(-x)) }
nsigmoid = func(x) { 2 / (1 + math.exp(-x)) - 1 }
pow = func(v, w) { math.exp(math.ln(v) * w) }
npow = func(v, w) { math.exp(math.ln(abs(v)) * w) * (v < 0 ? -1 : 1) }
clamp = func(v, min, max) { v < min ? min : v > max ? max : v }



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
		m.headingN = props.globals.getNode("/orientation/heading-deg", 1);
		m.pitchN = props.globals.getNode("/orientation/pitch-deg", 1);
		m.rollN = props.globals.getNode("/orientation/roll-deg", 1);

		m.heading_axis = ViewAxis.new("/sim/current-view/goal-heading-offset-deg");
		m.pitch_axis = ViewAxis.new("/sim/current-view/goal-pitch-offset-deg");
		m.roll_axis = ViewAxis.new("/sim/current-view/goal-roll-offset-deg");

		# accerations are converted to G (one G is subtraced from z-accel)
		m.ax = Input.new("/accelerations/pilot/x-accel-fps_sec", 0.03108095, 0, 1.1, 0);
		m.ay = Input.new("/accelerations/pilot/y-accel-fps_sec", 0.03108095, 0, 1.1);
		m.az = Input.new("/accelerations/pilot/z-accel-fps_sec", -0.03108095, -1, 1.0073);

		# velocities are converted to knots
		m.vx = Input.new("/velocities/uBody-fps", 0.5924838, 0);
		m.vy = Input.new("/velocities/vBody-fps", 0.5924838, 0);
		m.vz = Input.new("/velocities/wBody-fps", 0.5924838, 0);

		# turn WoW bool into smooth values ranging from -1 to 1
		m.wow = Input.new("/gear/gear/wow", 2, -1, 1.2);
		m.reset();
		return m;
	},
	reset : func {
		me.heading_axis.reset();
		me.pitch_axis.reset();
		me.roll_axis.reset();
	},
	add_offset : func {
		me.heading_axis.add_offset();
		me.pitch_axis.add_offset();
		me.roll_axis.add_offset();
	},
	apply : func {
		var pitch = me.pitchN.getValue();
		var roll = me.rollN.getValue();
		var wow = me.wow.get();

		var ax = me.ax.get();
		var ay = me.ay.get();
		var az = me.az.get();
		var adir = math.atan2(-ay, ax) * 180 / math.pi;
		var aval = math.sqrt(ax * ax + ay * ay);

		#var vx = me.vx.get();
		#var vy = me.vy.get();
		#var vdir = math.atan2(vy, vx) * 180 / math.pi;
		#var vval = math.sqrt(vx * vx + vy * vy);

		var steering = 80 * wow * nsigmoid(adir * 5.5 / 180) * nsigmoid(aval);

		me.heading_axis.apply(				# heading ...
			-20 * sin(roll) * cos(pitch)		#     due to roll
			+ steering				#     due to accleration (also ground steering)
		);
		me.pitch_axis.apply(				# pitch ...
			10 * sin(roll) * sin(roll)		#     due to roll
			+ 30 * (1 / (1 + math.exp(2 - az))	#     due to G load
				- 0.119202922)			#         [move to origin; 1/(1+exp(2)) ]
		);
		me.roll_axis.apply(0				# roll ...
			#0.0 * sin(roll) * cos(pitch)		#     due to roll  (none)
		);

	},
};



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



# Register new, aircraft specific manager. (Needs to offer the
# same methods, of course.)
#
register = func(mgr) {
	view_manager = mgr;
	var p = "/sim/view/dynamic/enabled";
	setprop(p, getprop(p));		# fire listener
}



var dynamic_view = nil;
var original_resetView = nil;
var view_manager = nil;
var panel_visibilityN = nil;

var cockpit_view = nil;
var panel_visible = nil;
var mouse_button = nil;

var loop_id = 0;
var L = [];	# vector of listener ids; allows to remove all listeners (= useless feature :-)



# Initialization.
#
settimer(func {
	# some properties may still be unavailable or nil
	props.globals.getNode("/accelerations/pilot/x-accel-fps_sec", 1).setDoubleValue(0);
	props.globals.getNode("/accelerations/pilot/y-accel-fps_sec", 1).setDoubleValue(0);
	props.globals.getNode("/accelerations/pilot/z-accel-fps_sec", 1).setDoubleValue(-32);
	props.globals.getNode("/gear/gear/wow", 1).setBoolValue(1);

	# let listeners keep some variables up-to-date, so that they don't have
	# to be queried in the loop
	append(L, setlistener("/sim/current-view/view-number", func {
		cockpit_view = (cmdarg().getValue() == 0);
	}, 1));

	append(L, setlistener("/sim/signals/reinit", func {
		cockpit_view = getprop("/sim/current-view/view-number") == 0;
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

	append(L, setlistener("/sim/signals/reinit", func {
		view_manger.reset();
	}, 0));
}, 0);


