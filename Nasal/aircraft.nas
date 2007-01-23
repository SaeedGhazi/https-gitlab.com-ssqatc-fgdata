# These classes provide basic functions for use in aircraft specific
# Nasal context. Note that even if a class is called "door" or "light"
# this doesn't mean that it can't be used for other purposes.
#
# Class instances don't have to be assigned to variables. They do also
# work if they remain anonymous. It's even a good idea to keep them
# anonymous if you don't need further access to their members. On the
# other hand, you can assign the class and apply setters at the same time:
#
#   aircraft.light.new("sim/model/foo/beacon", [1, 1]);    # anonymous
#   var strobe = aircraft.light.new("sim/model/foo/strobe", [1, 1]).cont().switch(1);
#
#
# Classes do create properties, but they don't usually overwrite the contents
# of an existing property. This makes it possible to preset them in
# a *-set.xml file or on the command line. For example:
#
#   $ fgfs --aircraft=bo105 --prop:/controls/doors/door[0]/position-norm=1
#
#
# Wherever a property argument can be given, this can either be a path,
# or a node (i.e. property node hash). In return, the property node can
# always be accessed directly as member "node", and turned into a path
# string with node.getPath():
#
#   var beacon = aircraft.light.new("sim/model/foo/beacon", [1, 1]);
#   print(beacon.node.getPath());
#
#   var strobe_node = props.globals.getNode("sim/model/foo/strobe", 1);
#   var strobe = aircraft.light.new(strobe_node, [0.05, 1.0]);
#
#
# The classes implement only commonly used features, but are easy to
# extend, as all class members are accessible from outside. For example:
#
#   # add custom property to door node:
#   frontdoor.node.getNode("name", 1).setValue("front door");
#
#   # add method to class instance (or base class -> aircraft.door.print)
#   frontdoor.print = func { print(me.position.getValue()) };
#
#


# helper functions
# ==============================================================================

# creates (if necessary) and returns a property node from arg[0],
# which can be a property node already, or a property path
#
makeNode = func {
	if (isa(arg[0], props.Node)) {
		return arg[0];
	} else {
		return props.globals.getNode(arg[0], 1);
	}
}


# returns arg[1]-th optional argument of vector arg[0] or default value arg[2]
#
optarg = func {
	if (size(arg[0]) > arg[1] and arg[0][arg[1]] != nil) {
		arg[0][arg[1]];
	} else {
		arg[2];
	}
}




# door
# ==============================================================================
# class for objects moving at constant speed, with the ability to
# reverse moving direction at any point. Appropriate for doors, canopies, etc.
#
# SYNOPSIS:
#	door.new(<property>, <swingtime> [, <startpos>]);
#
#	property   ... door node: property path or node
#	swingtime  ... time in seconds for full movement (0 -> 1)
#	startpos   ... initial position      (default: 0)
#
# PROPERTIES:
#	./position-norm   (double)     (default: <startpos>)
#	./enabled         (bool)       (default: 1)
#
# EXAMPLE:
#	var canopy = aircraft.door.new("sim/model/foo/canopy", 5);
#	canopy.open();
#
door = {
	new : func {
		m = { parents : [door] };
		m.node = makeNode(arg[0]);
		m.swingtime = arg[1];
		m.positionN = m.node.getNode("position-norm", 1);
		m.enabledN = m.node.getNode("enabled", 1);
		if (m.enabledN.getValue() == nil) {
			m.enabledN.setBoolValue(1);
		}
		pos = optarg(arg, 2, 0);
		if (m.positionN.getValue() == nil) {
			m.positionN.setDoubleValue(pos);
		}
		m.target = pos < 0.5;
		return m;
	},
	# door.enable(bool)    ->  set ./enabled
	enable  : func { me.enabledN.setBoolValue(arg[0]); me },

	# door.setpos(double)  ->  set ./position-norm without movement
	setpos  : func { me.positionN.setValue(arg[0]); me.target = arg[0] < 0.5; me },

	# double door.getpos() ->  return current position as double
	getpos  : func { me.positionN.getValue() },

	# door.close()         ->  move to closed state
	close   : func { me.move(me.target = 0) },

	# door.open()          ->  move to open state
	open    : func { me.move(me.target = 1) },

	# door.toggle()        ->  move to opposite end position
	toggle  : func { me.move(me.target) },

	# door.stop()          ->  stop movement
	stop    : func { interpolate(me.positionN) },

	# door.move(double)    ->  move to arbitrary position
	move    : func {
		time = abs(me.getpos() - arg[0]) * me.swingtime;
		interpolate(me.positionN, arg[0], time);
		me.target = !me.target;
	},
};



# light
# ==============================================================================
# class for generation of pulsing values. Appropriate for controlling
# beacons, strobes, etc.
#
# SYNOPSIS:
#	light.new(<property>, <pattern> [, <switch>]);
#	light.new(<property>, <stretch>, <pattern> [, <switch>]);
#
#	property   ... light node: property path or node
#	stretch    ... multiplicator for all pattern values
#	pattern    ... array of on/off time intervals (in seconds)
#	switch     ... property path or node to use as switch   (default: ./enabled)
#                      instead of ./enabled
#
# PROPERTIES:
#	./state           (bool)   (default: 0)
#	./enabled         (bool)   (default: 0) except if <switch> given)
#
# EXAMPLES:
#	aircraft.light.new("sim/model/foo/beacon", [0.4, 0.4]);    # anonymous light
#-------
#	var strobe = aircraft.light.new("sim/model/foo/strobe", [0.05, 0.05, 0.05, 1],
#	                "controls/lighting/strobe");
#	strobe.switch(1);
#-------
#	var switch = props.globals.getNode("controls/lighting/strobe", 1);
#	var pattern = [0.02, 0.03, 0.02, 1];
#	aircraft.light.new("sim/model/foo/strobe-top", 1.001, pattern, switch);
#	aircraft.light.new("sim/model/foo/strobe-bot", 1.005, pattern, switch);
#
light = {
	new : func {
		m = { parents : [light] };
		m.node = makeNode(arg[0]);
		var stretch = 1.0;
		var c = 1;
		if (typeof(arg[c]) == "scalar") {
			stretch = arg[c];
			c += 1;
		}
		if (typeof(arg[c]) != "vector") {
			die("aircraft.nas: the arguments of aircraft.light.new() have changed!\n" ~
					"  *** BEFORE: aircraft.light.new(property, 0.1, 0.9, switch)\n" ~
					"  ***    NOW: aircraft.light.new(property, [0.1, 0.9], switch)");
		}
		m.pattern = arg[c];
		c += 1;
		if (size(arg) > c and arg[c] != nil) {
			m.switchN = makeNode(arg[c]);
		} else {
			m.switchN = m.node.getNode("enabled", 1);
		}
		if (m.switchN.getValue() == nil) {
			m.switchN.setBoolValue(0);
		}
		m.stateN = m.node.getNode("state", 1);
		if (m.stateN.getValue() == nil) {
			m.stateN.setBoolValue(0);
		}
		forindex (var i; m.pattern) {
			m.pattern[i] *= stretch;
		}
		m.index = 0;
		m.loopid = 0;
		m.continuous = 0;
		m.lastswitch = 0;
		m.switchL = setlistener(m.switchN, func { m._switch_() }, 1);
		return m;
	},
	# class destructor
	del : func {
		removelistener(me.switchL);
	},
	# light.switch(bool)   ->  set light switch (also affects other lights
	#                          that use the same switch)
	switch : func(v) { me.switchN.setBoolValue(v); me },

	# light.toggle()       ->  toggle light switch
	toggle : func { me.switchN.setBoolValue(!me.switchN.getValue()); me },

	# light.cont()         ->  continuous light
	cont : func {
		if (!me.continuous) {
			me.continuous = 1;
			me.loopid += 1;
			me.stateN.setBoolValue(me.lastswitch);
		}
		me;
	},

	# light.blink()        ->  blinking light  (default)
	blink : func {
		if (me.continuous) {
			me.continuous = 0;
			me.index = 0;
			me.stateN.setBoolValue(0);
			me.lastswitch and me._loop_(me.loopid += 1);
		}
		me;
	},

	_switch_ : func {
		var switch = me.switchN.getBoolValue();
		switch != me.lastswitch or return;
		me.lastswitch = switch;
		me.loopid += 1;
		if (me.continuous or !switch) {
			me.stateN.setBoolValue(switch);
		} elsif (switch) {
			me.stateN.setBoolValue(0);
			me.index = 0;
			me._loop_(me.loopid);
		}
	},

	_loop_ : func(id) {
		id == me.loopid or return;
		me.stateN.setBoolValue(me.index == 2 * int(me.index / 2));
		settimer(func { me._loop_(id) }, me.pattern[me.index]);
		if ((me.index += 1) >= size(me.pattern)) {
			me.index = 0;
		}
	},
};



# lowpass
# ==============================================================================
# class that implements a variable-interval EWMA (Exponentially Weighted
# Moving Average) lowpass filter with characteristics independent of the
# frame rate.
#
# SYNOPSIS:
#	lowpass.new(<coefficient>);
#
# EXAMPLE:
#	var lp = aircraft.lowpass.new(0.5);
#	print(lp.filter(10));  # prints 10
#	print(lp.filter(0));
#
lowpass = {
	new : func(coeff) {
		var m = { parents : [lowpass] };
		m.dtN = props.globals.getNode("/sim/time/delta-realtime-sec", 1);
		m.coeff = coeff >= 0 ? coeff : die("aircraft.lowpass(): coefficient must be >= 0");
		m.value = nil;
		return m;
	},
	# filter(raw_value)    -> push new value, returns filtered value
	filter : func(v) {
		me.filter = me._filter_;
		me.value = v;
	},
	# get()                -> returns filtered value
	get : func {
		me.value;
	},
	# set()                -> sets new average and returns it
	set : func(v) {
		me.value = v;
	},
	_filter_ : func(v) {
		var dt = me.dtN.getValue();
		var c = dt / (me.coeff + dt);
		me.value = v * c + me.value * (1 - c);
	},
};



# Data
# ==============================================================================
# class that loads and saves properties to aircraft-specific data files in
# ~/.fgfs/aircraft-data/ (Unix) or %APPDATA%\flightgear.org\aircraft-data\.
# There's no public constructor, as the only needed instance gets created
# by the system.
#
# SYNOPSIS:
#	data.add(<properties>);
#	data.save([<interval>])
#
#	properties  ... about any combination of property nodes (props.Node)
#	                or path name strings, or lists or hashes of them,
#	                lists of lists of them, etc.
#	interval    ... save in <interval> minutes intervals, or only once
#	                if 'nil' or empty (and again at reinit/exit)
#
# SIGNALS:
#	/sim/signals/save   ... set to 'true' right before saving. Can be used
#	                        to update values that are to be saved
#
# EXAMPLE:
#	var p = props.globals.getNode("/sim/model", 1);
#	var vec = [p, p];
#	var hash = {"foo": p, "bar": p};
#
#	# add properties
#	aircraft.data.add("/sim/fg-root", p, "/sim/fg-home");
#	aircraft.data.add(p, vec, hash, "/sim/fg-root");
#
#	# now save only once (and at exit/reinit, which is automatically done)
#	aircraft.data.save();     # or aircraft.data.save(0)
#
#	# or save now and all 30 sec (and at exit/reinit)
#	aircraft.data.save(0.5);
#
Data = {
	new : func {
		var m = { parents : [Data] };
		m.path = getprop("/sim/fg-home") ~ "/aircraft-data/" ~ getprop("/sim/aircraft") ~ ".xml";
		m.signalN = props.globals.getNode("/sim/signals/save", 1);
		m.catalog = [];
		m.loop_id = 0;
		m.interval = 0;

		setlistener("/sim/signals/reinit", func { cmdarg().getBoolValue() and m._save_() });
		setlistener("/sim/signals/exit", func { m._save_() });
		return m;
	},
	load : func {
		printlog("warn", "trying to load aircraft data from ", me.path, " (OK if not found)");
		fgcommand("load", props.Node.new({ "file": me.path }));
	},
	save : func(v = nil) {
		me.loop_id += 1;
		me.interval = 60 * v;
		v == nil ? me._save_() : me._loop_(me.loop_id);
	},
	_loop_ : func(id) {
		id == me.loop_id or return;
		me._save_();
		settimer(func { me._loop_(id) }, me.interval);
	},
	_save_ : func {
		size(me.catalog) or return;
		me.signalN.setBoolValue(1);
		var tmp = "_-_-_-_-_-_aircraft.Data_-_-_-_-_-_";
		printlog("info", "saving aircraft data to ", me.path);
		props.globals.removeChildren(tmp);
		var root = props.globals.getNode(tmp, 1);
		foreach (var c; me.catalog) {
			if (c[0] == `/`) {
				c = substr(c, 1);
			}
			props.copy(props.globals.getNode(c, 1), root.getNode(c, 1));
		}
		fgcommand("savexml", props.Node.new({ "filename": me.path, "sourcenode": tmp }));
		props.globals.removeChildren(tmp);
	},
	add : func {
		foreach (var a; arg) {
			var t = typeof(a);
			if (isa(a, props.Node)) {
				append(me.catalog, a.getPath());
			} elsif (t == "scalar") {
				append(me.catalog, a);
			} elsif (t == "vector") {
				foreach (var i; a) {
					me.add(i);
				}
			} elsif (t == "hash") {
				foreach (var i; keys(a)) {
					me.add(a[i]);
				}
			} else {
				die("aircraft.data.add(): invalid item of type " ~ t);
			}
		}
	},
};


var data = nil;
_setlistener("/sim/signals/nasal-dir-initialized", func {
	data = Data.new();
	Data.new = nil;
	if (getprop("/sim/startup/save-on-exit")) {
		data.load();
	} else {
		Data._save_ = func {}
		Data._loop_ = func {}
	}
});



# timer
# ==============================================================================
# class that implements timer that can be started, stopped, reset, and can
# have its value saved to the aircraft specific data file. Saving the value
# is done automatically by the aircraft.Data class.
#
# SYNOPSIS:
#	timer.new(<property> [, <resolution:double> [, <save:bool>]])
#
#	<property>   ... property path or props.Node hash that holds the timer value
#	<resolution> ... timer update resolution -- interval in seconds in which the
#	                 timer property is updated while running (default: 1 s)
#	<save>       ... bool that defines whether the timer value should be saved
#	                 and restored next time, as needed for Hobbs meters
#	                 (default: 1)
#
# EXAMPLES:
#	var hobbs_turbine = aircraft.timer.new("/sim/time/hobbs/turbine[0]", 60);
#	hobbs_turbine.start();
#	
#	aircraft.timer.new("/sim/time/hobbs/battery", 60).start();  # anonymous timer
#
timer = {
	new : func(prop, res = 1, save = 1) {
		var m = { parents : [timer] };
		m.timeN = makeNode(prop);
		if (m.timeN.getType() == "NONE") {
			m.timeN.setDoubleValue(0);
		}
		m.systimeN = props.globals.getNode("/sim/time/elapsed-sec", 1);
		m.last_systime = nil;
		m.interval = res;
		m.loop_id = 0;
		m.running = 0;
		if (save) {
			data.add(m.timeN);
			m.saveL = setlistener("/sim/signals/save", func { m._save_() });
		} else {
			m.saveL = nil;
		}
		return m;
	},
	del : func {
		if (me.saveL != nil) {
			removelistener(me.saveL);
		}
	},
	start : func {
		me.running and return;
		me.last_systime = me.systimeN.getValue();
		me.interval != nil and me._loop_(me.loop_id);
		me.running = 1;
		me;
	},
	stop : func {
		me.running or return;
		me.running = 0;
		me.loop_id += 1;
		me._apply_();
	},
	reset : func {
		me.timeN.setDoubleValue(0);
		me.last_systime = me.systimeN.getValue();
	},
	_apply_ : func {
		var sys = me.systimeN.getValue();
		me.timeN.setDoubleValue(me.timeN.getValue() + sys - me.last_systime);
		me.last_systime = sys;
	},
	_save_ : func {
		if (me.running) {
			me._apply_();
		}
	},
	_loop_ : func(id) {
		id != me.loop_id and return;
		me._apply_();
		settimer(func { me._loop_(id) }, me.interval);
	},
};






# HUD control class to handle both HUD implementations.
#
HUDControl = {
	new : func {
		var m = { parents : [HUDControl] };
		m.vis0N = props.globals.getNode("/sim/hud/visibility[0]", 1);
		m.vis1N = props.globals.getNode("/sim/hud/visibility[1]", 1);
		m.currcolN = props.globals.getNode("/sim/hud/current-color", 1);
		m.paletteN = props.globals.getNode("/sim/hud/palette", 1);
		m.brightnessN = props.globals.getNode("/sim/hud/color/brightness", 1);
		m.currentN = m.vis0N;
		return m;
	},
	cycle_color : func {		# h-key
		if (!me.currentN.getBoolValue()) {		# if off, turn on
			return me.currentN.setBoolValue(1);
		}
		var i = me.currcolN.getValue() + 1;		# if through, turn off
		if (i < 0 or i >= size(me.paletteN.getChildren("color"))) {
			me.currentN.setBoolValue(0);
			me.currcolN.setIntValue(0);
		} else {					# otherwise change color
			me.currentN.setBoolValue(1);
			me.currcolN.setIntValue(i);
		}
	},
	cycle_brightness : func {	# H-key
		var br = me.brightnessN.getValue() - 0.2;
		me.brightnessN.setValue(br > 0.01 ? br : 1);
	},
	normal_type : func {		# i-key
		me.oldinit1();
		me.vis0N.setBoolValue(1);
		me.vis1N.setBoolValue(0);
		me.currentN = me.vis0N;
	},
	cycle_type : func {		# I-key
		if (me.currentN == me.vis0N) {
			me.vis0N.setBoolValue(0);
			me.vis1N.setBoolValue(1);
			me.currentN = me.vis1N;
		} elsif (me.currentN == me.vis1N) {
			me.vis0N.setBoolValue(1);
			me.vis1N.setBoolValue(0);
			me.oldinit2();
			me.currentN = me.vis0N;
		}
	},
	oldinit1 : func { fgcommand("hud-init", props.Node.new()) },
	oldinit2 : func { fgcommand("hud-init2", props.Node.new()) },
};

var HUD = nil;
settimer(func { HUD = HUDControl.new() }, 0);



