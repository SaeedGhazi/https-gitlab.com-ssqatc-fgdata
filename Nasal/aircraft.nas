# door: class for objects moving at constant speed, with the ability to
# reverse moving direction at any point. Appropriate for doors, canopies, etc.
#
# SYNOPSIS:
#	door.new(<property>, <swingtime> [, <startpos>]);
#
#	property      ... parent property (available as door.base)
#	swingtime     ... time in seconds for full movement (0 -> 1)
#	startpos      ... initial position      (default: 0)
#
# PROPERTIES:
#	<property>/position-norm   (type="double")
#	<property>/enabled         (type="bool")
#
# EXAMPLE:
#	canopy = aircraft.door.new("sim/model/foo/canopy", 5);
#	canopy.open();
#
door = {
	new : func {
		d = { parents: [door] };
		d.base = props.globals.getNode(arg[0], 1);
		d.pos = d.base.getNode("position-norm", 1);
		d.enabled = d.base.getNode("enabled", 1);
		d.enabled.setBoolValue(1);

		d.swingtime = arg[1];
		pos = if (size(arg) > 2 and arg[2] != nil) { arg[2] } else { 0 };
		d.pos.setDoubleValue(pos);
		d.target = pos < 0.5;
		return d;
	},

	# door.enable(bool)    -> set <property>/enabled
	enable  : func { me.enabled.setBoolValue(arg[0]) },

	# door.setpos(double)  -> set <property>/position-norm without movement
	setpos  : func { me.pos.setValue(arg[0]); me.target = arg[0] < 0.5 },

	# double door.getpos() -> return current position as double
	getpos  : func { me.pos.getValue() },

	# door.close()         -> move to closed state
	close   : func { me.move(0) },

	# door.open()          -> move to open state
	open    : func { me.move(1) },

	# door.toggle()        -> move to farther away end position
	#                         (0 -> 1, 1 -> 0, 0.3 -> 1, 0.6 -> 0)
	toggle  : func { me.move(me.target) },

	# door.move(double)    -> move to arbitrary position
	move    : func {
		time = abs(me.getpos() - arg[0]) * me.swingtime;
		interpolate(me.pos, arg[0], time);
		me.target = !me.target;
	},
};


