# These classes provide basic functions to use in aircraft specific
# Nasal context. Note that even if a class is called "door" or "light"
# this doesn't mean that it can't be used for other purposes. The classes
# implement only commonly used features, but are easily to extend,
# as all class members are accessible from outside. For example:
#
#   # add custom property to door node:
#   frontdoor.node.getNode("name", 1).setValue("front door");
#
#   # add method to class instance (or base class -> aircraft.door.print)
#   frontdoor.print = func { print(me.position.getValue()) };
#
# Wherever a property argument can be given, this can either be a path,
# or a node (i.e. property node hash). For example:
#
#   beacon = aircraft.light.new("sim/model/foo/beacon");
#
#   strobe_node = props.globals.getNode("sim/model/foo/strobe", 1);
#   strobe = aircraft.light.new(strobe_node, 0.05, 1.0);
#
# Classes do create properties, but they don't usually overwrite the contents
# of an existing property. This makes it possible to preset them in
# a *-set.xml file or on the command line. For example:
#
#   $ fgfs --aircraft=bo105 --prop:/controls/doors/door[0]/position-norm=1



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



# door
# ==============================================================================
# class for objects moving at constant speed, with the ability to
# reverse moving direction at any point. Appropriate for doors, canopies, etc.
#
# SYNOPSIS:
#	door.new(<property>, <swingtime> [, <startpos>]);
#
#	property      ... door node: property path or node
#	swingtime     ... time in seconds for full movement (0 -> 1)
#	startpos      ... initial position      (default: 0)
#
# PROPERTIES:
#	<property>/position-norm   (double)
#	<property>/enabled         (bool)
#
# EXAMPLE:
#	canopy = aircraft.door.new("sim/model/foo/canopy", 5);
#	canopy.open();
#
door = {
	new : func {
		d = { parents : [door] };
		d.node = makeNode(arg[0]);
		d.swingtime = arg[1];
		d.position = d.node.getNode("position-norm", 1);
		d.enabled = d.node.getNode("enabled", 1);
		if (d.enabled.getValue() == nil) {
			d.enabled.setBoolValue(1);
		}
		pos = if (size(arg) > 2 and arg[2] != nil) { arg[2] } else { 0 };
		if (d.position.getValue() == nil) {
			d.position.setDoubleValue(pos);
		}
		d.target = pos < 0.5;
		return d;
	},
	# door.enable(bool)    ->  set <property>/enabled
	enable  : func { me.enabled.setBoolValue(!!arg[0]) },

	# door.setpos(double)  ->  set <property>/position-norm without movement
	setpos  : func { me.position.setValue(arg[0]); me.target = arg[0] < 0.5 },

	# double door.getpos() ->  return current position as double
	getpos  : func { me.position.getValue() },

	# door.close()         ->  move to closed state
	close   : func { me.move(me.target = 0) },

	# door.open()          ->  move to open state
	open    : func { me.move(me.target = 1) },

	# door.toggle()        ->  move to opposite end position
	toggle  : func { me.move(me.target) },

	# door.move(double)    ->  move to arbitrary position
	move    : func {
		time = abs(me.getpos() - arg[0]) * me.swingtime;
		interpolate(me.position, arg[0], time);
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
#	property      ... light node: property path or node
#	ontime        ... time in seconds that the light is on when blinking  (default: 0.5)
#	offtime       ... time in seconds that the light is off when blinking (default: ontime)
#	switch        ... property path or node to use as switch              (default: <property>/enabled)
#	                  If the switch node isn't given or nil, it gets
#	                  created and the light turned on.
#
# PROPERTIES:
#	<property>/state           (bool)
#	<property>/enabled         (bool)   (except if <switch> given)
#
# EXAMPLES:
#	beacon = aircraft.light.new("sim/model/foo/beacon", 0.4);
#	strobe = aircraft.light.new("sim/model/foo/strobe", 0.05, 1.0, "controls/lighting/strobe");
#	strobe.set(1);
#
light = {
	new : func {
		d = { parents : [light] };
		d.node = makeNode(arg[0]);
		d.ontime = if (size(arg) > 1 and arg[1] != nil) { arg[1] } else { 0.5 };
		d.offtime = if (size(arg) > 2 and arg[2] != nil) { arg[2] } else { d.ontime };
		if (size(arg) > 3 and arg[3] != nil) {
			d.switch = makeNode(arg[3]);
		} else {
			d.switch = d.node.getNode("enabled", 1);
		}
		if (d.switch.getValue() == nil) {
			d.switch.setBoolValue(1);
		}
		d.state = d.node.getNode("state", 1);
		if (d.state.getValue() == nil) {
			d.state.setBoolValue(0);
		}
		d.continuous = 0;
		d._loop_();
		return d;
	},
	# light.set(bool)      ->  set light switch (also affects other lights
	#                          that use the same switch)
	set     : func { me.switch.setBoolValue(!!arg[0]) },

	# light.toggle()       ->  toggle light switch
	toggle  : func { me.switch.setBoolValue(!me.switch.getValue()) },

	# light.cont()         ->  continuous light
	cont    : func { me.continuous = 1 },

	# light.blink()        ->  blinking light
	blink   : func { me.continuous = 0 },

	_loop_  : func {
		if (!me.switch.getValue()) {
			value = 0; delay = 0.5;
		} elsif (me.continuous) {
			value = 1; delay = 0.5;
		} elsif (me.state.getValue()) {
			value = 0; delay = me.offtime;
		} else {
			value = 1; delay = me.ontime;
		}
		me.state.setValue(value);
		settimer(func { me._loop_() }, delay);
	},
};


