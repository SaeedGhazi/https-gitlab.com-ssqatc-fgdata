##
## view.nas
##
##  Nasal code for implementing view-specific functionality.



# Dynamically calculate limits so that it takes STEPS iterations to
# traverse the whole range, the maximum FOV is fixed at 120 degrees,
# and the minimum corresponds to normal maximum human visual acuity
# (~1 arc minute of resolution, although apparently people vary widely
# in this ability).  Quick derivation of the math:
#
#   mul^steps = max/min
#   steps * ln(mul) = ln(max/min)
#   mul = exp(ln(max/min) / steps)
STEPS = 40;
ACUITY = 1/60; # Maximum angle subtended by one pixel (== 1 arc minute)
max = min = mul = 0;
calcMul = func {
    max = 120; # Fixed at 120 degrees
    min = getprop("/sim/startup/xsize") * ACUITY;
    mul = math.exp(math.ln(max/min) / STEPS);
}

##
# Handler.  Increase FOV by one step
#
increase = func {
    calcMul();
    val = fovProp.getValue() * mul;
    if(val == max) { return; }
    if(val > max) { val = max }
    fovProp.setDoubleValue(val);
    gui.popupTip(sprintf("FOV: %.1f", val));
}

##
# Handler.  Decrease FOV by one step
#
decrease = func {
    calcMul();
    val = fovProp.getValue() / mul;
    fovProp.setDoubleValue(val);
    gui.popupTip(sprintf("FOV: %.1f%s", val, val < min ? " (overzoom)" : ""));
}

##
# Handler.  Reset FOV to default.
#
var resetFOV = func {
    setprop("/sim/current-view/field-of-view",
            getprop("/sim/current-view/config/default-field-of-view-deg"));
}

var resetViewPos = func {
    var v = views[getprop("/sim/current-view/view-number")].getNode("config");
    setprop("/sim/current-view/x-offset-m", v.getNode("x-offset-m", 1).getValue() or 0);
    setprop("/sim/current-view/y-offset-m", v.getNode("y-offset-m", 1).getValue() or 0);
    setprop("/sim/current-view/z-offset-m", v.getNode("z-offset-m", 1).getValue() or 0);
}

var resetViewDir = func {
    setprop("/sim/current-view/goal-heading-offset-deg",
            getprop("/sim/current-view/config/heading-offset-deg"));
    setprop("/sim/current-view/goal-pitch-offset-deg",
            getprop("/sim/current-view/config/pitch-offset-deg"));
    setprop("/sim/current-view/goal-roll-offset-deg",
            getprop("/sim/current-view/config/roll-offset-deg"));
}

##
# Handler.  Step to the next (force=1) or next enabled view.
#
var stepView = func(n, force = 0) {
    var i = getprop("/sim/current-view/view-number") + n;
    while (1) {
        if (i < 0)
            i = size(views) - 1;
        elsif (i >= size(views))
            i = 0;
        if (!i or force or (var e = views[i].getNode("enabled")) == nil or e.getValue())
            break;
        i += n > 0 ? 1 : -1;
    }
    setprop("/sim/current-view/view-number", i);

    # And pop up a nice reminder
    gui.popupTip(views[i].getNode("name").getValue());
}

##
# Get view index by name.
#
var indexof = func(name) {
    forindex (var i; views)
        if (views[i].getNode("name", 1).getValue() == name)
            return i;
    return nil;
}

##
# Standard view "slew" rate, in degrees/sec.
#
VIEW_PAN_RATE = 60;

##
# Pans the view horizontally.  The argument specifies a relative rate
# (or number of "steps" -- same thing) to the standard rate.
#
panViewDir = func(step) {
    if (getprop("/sim/freeze/master"))
        prop = "/sim/current-view/heading-offset-deg";
    else
        prop = "/sim/current-view/goal-heading-offset-deg";

    controls.slewProp(prop, step * VIEW_PAN_RATE);
}

##
# Pans the view vertically.  The argument specifies a relative rate
# (or number of "steps" -- same thing) to the standard rate.
#
panViewPitch = func(step) {
    if (getprop("/sim/freeze/master"))
        prop = "/sim/current-view/pitch-offset-deg";
    else
        prop = "/sim/current-view/goal-pitch-offset-deg";

    controls.slewProp(prop, step * VIEW_PAN_RATE);
}


##
# Reset view to default using current view manager (see default_handler).
#
var resetView = func {
	manager.reset();
}


##
# Default view handler used by view.manager.
#
var default_handler = {
	reset : func {
		resetViewDir();
		resetFOV();
	},
};


##
# View manager. Administrates optional Nasal view handlers.
# Usage:  view.manager.register(<view-id>, <view-handler>);
#
#   view-id:      the view's name, e.g. "Chase View"
#   view-handler: a hash with any combination of the functions listed in the
#                 following example, or none at all. Only define the interface
#                 functions that you really need! The hash may contain local
#                 variables and other, non-interface functions.
#
# Example:
#
#   var some_view_handler = {
#           init   : func {},    # called only once at startup
#           start  : func {},    # called when view is switched to our view
#           stop   : func {},    # called when view is switched away from our view
#           reset  : func {},    # called with view.resetView()
#           update : func { 0 }, # called iteratively if defined. Must return
#   };                           # interval in seconds until next invocation
#                                # Don't define it if you don't need it!
#
#   view.manager.register("Some View", some_view_handler);
#
#
var manager = {
	current : { node: nil, handler: default_handler },
	init : func {
		me.views = {};
		me.loopid = 0;
		var viewnodes = props.globals.getNode("sim").getChildren("view");
		forindex (var i; viewnodes)
			me.views[i] = { node: viewnodes[i], handler: default_handler };
		setlistener("/sim/current-view/view-number", func(n) {
			manager.set_view(n.getValue());
		}, 1);
	},
	register : func(which, handler = nil) {
		if (num(which) == nil)
			which = view.indexof(which);
		if (handler == nil)
			handler = default_handler;
		me.views[which]["handler"] = handler;
		if (contains(handler, "init"))
			handler.init(me.views[which].node);
		me.set_view();
	},
	set_view : func(which = nil) {
		if (which == nil)
			which = getprop("/sim/current-view/view-number");
		elsif (num(which) == nil)
			which = view.indexof(which);

		me.loopid += 1;
		if (contains(me.current.handler, "stop"))
			me.current.handler.stop();

		me.current = me.views[which];

		if (contains(me.current.handler, "start"))
			me.current.handler.start();
		if (contains(me.current.handler, "update"))
			me._loop_(me.loopid += 1);
	},
	reset : func {
		if (contains(me.current.handler, "reset"))
			me.current.handler.reset();
		else
			default_handler.reset();
	},
	_loop_ : func(id) {
		id == me.loopid or return;
		settimer(func { me._loop_(id) }, me.current.handler.update());
	},
};


##
# View handler for fly-by view.
#
var fly_by_view_handler = {
	init : func {
		me.latN = props.globals.getNode("/sim/viewer/latitude-deg", 1);
		me.lonN = props.globals.getNode("/sim/viewer/longitude-deg", 1);
		me.altN = props.globals.getNode("/sim/viewer/altitude-ft", 1);
		me.hdgN = props.globals.getNode("/orientation/heading-deg", 1);

		setlistener("/sim/signals/reinit", func(n) { n.getValue() or me.reset() });
		setlistener("/sim/crashed", func(n) { n.getValue() and me.reset() });
		setlistener("/sim/freeze/replay-state", func {
			settimer(func { me.reset() }, 1); # time for replay to catch up
		});
		me.reset();
	},
	start : func {
		me.reset();
	},
	reset: func {
		me.chase = -getprop("/sim/chase-distance-m");
		me.course = me.hdgN.getValue();
		me.last = geo.aircraft_position();
		me.setpos(1);
		me.dist = 20;
	},
	setpos : func(force = 0) {
		var pos = geo.aircraft_position();

		# check if the aircraft has moved enough
		var dist = me.last.distance_to(pos);
		if (dist < 1.7 * me.chase and !force)
			return 1.13;

		# "predict" and remember next aircraft position
		var course = me.hdgN.getValue();
		var delta_alt = (pos.alt() - me.last.alt()) * 0.5;
		pos.apply_course_distance(course, dist * 0.8);
		pos.set_alt(pos.alt() + delta_alt);
		me.last.set(pos);

		# apply random deviation
		var radius = me.chase * (0.5 * rand() + 0.7);
		var agl = getprop("/position/altitude-agl-ft") * geo.FT2M;
		if (agl > me.chase)
			var angle = rand() * 2 * math.pi;
		else
			var angle = ((2 * rand() - 1) * 0.15 + 0.5) * (rand() < 0.5 ? -math.pi : math.pi);

		var dev_alt = math.cos(angle) * radius;
		var dev_side = math.sin(angle) * radius;
		pos.apply_course_distance(course + 90, dev_side);

		# and make sure it's not under ground
		var lat = pos.lat();
		var lon = pos.lon();
		var alt = pos.alt();
		var elev = geo.elevation(lat, lon);
		if (elev != nil) {
			elev += 2;   # min elevation
			if (alt + dev_alt < elev and dev_alt < 0)
				dev_alt = -dev_alt;
			if (alt + dev_alt < elev)
				alt = elev;
			else
				alt += dev_alt;
		}

		# set new view point
		me.latN.setValue(lat);
		me.lonN.setValue(lon);
		me.altN.setValue(alt * geo.M2FT);
		return 6.3;
	},
	update : func {
		return me.setpos();
	},
};


#------------------------------------------------------------------------------
#
# Saves/restores/moves the view point (position, orientation, field-of-view).
# Moves are interpolated with sinusoidal characteristic. There's only one
# instance of this class, available as "view.point".
#
# Usage:
#    view.point.save();        ... save current view and return reference to
#                                  saved values in the form of a props.Node
#
#    view.point.restore();     ... restore saved view parameters
#
#    view.point.move(<prop> [, <time>]);
#                              ... set view parameters from a props.Node with
#                                  optional move time in seconds. <prop> may be
#                                  nil, in which case nothing happens.
#
# A parameter set as expected by set() and returned by save() is a props.Node
# object containing any (or none) of these children:
#
#   <heading-offset-deg>
#   <pitch-offset-deg>
#   <roll-offset-deg>
#   <x-offset-m>
#   <y-offset-m>
#   <z-offset-m>
#   <field-of-view>
#   <move-time-sec>
#
# The <move-time> isn't really a property of the view, but is available
# for convenience. The time argument in the move() method overrides it.


##
# Normalize angle to  -180 <= angle < 180
#
var normdeg = func(a) {
	while (a >= 180) {
		a -= 360;
	}
	while (a < -180) {
		a += 360;
	}
	return a;
}


##
# Manages one translation/rotation axis. (For simplicity reasons the
# field-of-view parameter is also managed by this class.)
#
var ViewAxis = {
	new : func(prop) {
		var m = { parents : [ViewAxis] };
		m.prop = props.globals.getNode(prop, 1);
		if (m.prop.getType() == "NONE") {
			m.prop.setDoubleValue(0);
		}
		m.from = m.to = m.prop.getValue();
		return m;
	},
	reset : func {
		me.from = me.to = normdeg(me.prop.getValue());
	},
	target : func(v) {
		me.to = normdeg(v);
	},
	move : func(blend) {
		me.prop.setValue(me.from + blend * (me.to - me.from));
	},
};



##
# view.point: handles smooth view movements
#
var point = {
	init : func {
		me.axes = {
			"heading-offset-deg" : ViewAxis.new("/sim/current-view/goal-heading-offset-deg"),
			"pitch-offset-deg" : ViewAxis.new("/sim/current-view/goal-pitch-offset-deg"),
			"roll-offset-deg" : ViewAxis.new("/sim/current-view/goal-roll-offset-deg"),
			"x-offset-m" : ViewAxis.new("/sim/current-view/x-offset-m"),
			"y-offset-m" : ViewAxis.new("/sim/current-view/y-offset-m"),
			"z-offset-m" : ViewAxis.new("/sim/current-view/z-offset-m"),
			"field-of-view" : ViewAxis.new("/sim/current-view/field-of-view"),
		};
		me.storeN = props.Node.new();
		me.dtN = props.globals.getNode("/sim/time/delta-realtime-sec", 1);
		me.currviewN = props.globals.getNode("/sim/current-view", 1);
		me.blend = 0;
		me.loop_id = 0;
		props.copy(props.globals.getNode("/sim/view/config"), me.storeN);
	},
	save : func {
		me.storeN = props.Node.new();
		props.copy(me.currviewN, me.storeN);
		return me.storeN;
	},
	restore : func {
		me.move(me.storeN);
	},
	move : func(prop, time = nil) {
		prop != nil or return;
		foreach (var a; keys(me.axes)) {
			var n = prop.getNode(a);
			me.axes[a].reset();
			if (n != nil) {
				me.axes[a].target(n.getValue());
			}
		}
		var m = prop.getNode("move-time-sec");
		if (m != nil) {
			time = m.getValue();
		}
		if (time == nil) {
			time = 1;
		}
		me.blend = -1;   # range -1 .. 1
		me._loop_(me.loop_id += 1, time);
	},
	_loop_ : func(id, time) {
		me.loop_id == id or return;
		me.blend += me.dtN.getValue() / time;
		if (me.blend > 1) {
			me.blend = 1;
		}
		var b = (math.sin(me.blend * math.pi / 2) + 1) / 2; # range 0 .. 1
		foreach (var a; keys(me.axes)) {
			me.axes[a].move(b);
		}
		if (me.blend < 1) {
			settimer(func { me._loop_(id, time) }, 0);
		}
	},
};



var views = nil;
var fovProp = nil;


_setlistener("/sim/signals/nasal-dir-initialized", func {
	views = props.globals.getNode("/sim").getChildren("view");
	fovProp = props.globals.getNode("/sim/current-view/field-of-view");
	point.init();
});


_setlistener("/sim/signals/fdm-initialized", func {
	foreach (var v; views) {
		var index = v.getIndex();
		if (index > 6 and index < 100) {
			globals["view"] = nil;
			die("\n***\n*\n*  Illegal use of reserved view index "
					~ index ~ ". Use indices >= 100!\n*\n***");
		} elsif (index >= 100 and index < 200) {
			var e = v.getNode("enabled");
			if (e != nil) {
				aircraft.data.add(e);
				e.setAttribute("userarchive", 0);
			}
		}
	}

	manager.init();
	manager.register("Fly-By View", fly_by_view_handler);
});


