# These classes provide basic functions for use in aircraft specific
# Nasal context. Note that even if a class is called "door" or "light"
# this doesn't mean that it can't be used for other purposes.
#
# Class instances don't have to be assigned to variables. They do also
# work if they remain anonymous. It's even a good idea to keep them
# anonymous if you don't need further access to their members. On the
# other hand, you can assign the class and apply setters at the same time:
#
#   aircraft.light.new("sim/model/foo/beacon");    # anonymous
#   strobe = aircraft.light.new("sim/model/foo/strobe").cont().switch(1);
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
#   beacon = aircraft.light.new("sim/model/foo/beacon");
#   print(beacon.node.getPath());
#
#   strobe_node = props.globals.getNode("sim/model/foo/strobe", 1);
#   strobe = aircraft.light.new(strobe_node, 0.05, 1.0);
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
#	canopy = aircraft.door.new("sim/model/foo/canopy", 5);
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
#	light.new(<property> [, <ontime> [, <offtime> [, <switch>]]]);
#
#	property   ... light node: property path or node
#	ontime     ... time that the light is on when blinking  (default: 0.5 [s])
#	offtime    ... time that the light is off when blinking (default: <ontime>)
#	switch     ... property path or node to use as switch   (default: ./enabled)
#                      instead of ./enabled
#
# PROPERTIES:
#	./state           (bool)   (default: 0)
#	./enabled         (bool)   (default: 0) except if <switch> given)
#
# EXAMPLES:
#	aircraft.light.new("sim/model/foo/beacon", 0.4);    # anonymous light
#	strobe = aircraft.light.new("sim/model/foo/strobe", 0.05, 1.0,
#	                "controls/lighting/strobe");
#	strobe.switch(1);
#
light = {
	new : func {
		m = { parents : [light] };
		m.node = makeNode(arg[0]);
		m.ontime = optarg(arg, 1, 0.5);
		m.offtime = optarg(arg, 2, m.ontime);
		if (size(arg) > 3 and arg[3] != nil) {
			m.switchN = makeNode(arg[3]);
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
		m.continuous = 0;
		m.loopid = 0;
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
			me._loop_(me.loopid);
		}
	},

	_loop_ : func(id) {
		id == me.loopid or return;
		var state = !me.stateN.getBoolValue();
		me.stateN.setBoolValue(state);
		settimer(func { me._loop_(id) }, state ? me.ontime : me.offtime);
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
	# set()                -> sets new average
	set : func(v) {
		me.value = v;
	},
	_filter_ : func(v) {
		var dt = me.dtN.getValue();
		var c = dt / (me.coeff + dt);
		me.value = v * c + me.value * (1 - c);
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


