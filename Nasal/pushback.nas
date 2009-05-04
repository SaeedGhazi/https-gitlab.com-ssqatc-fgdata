# Pushback
# =============================================================================
# Creates an object to move the pushback to or out of the towing position.
# Needs  /sim/model/pushback to exist in order to be executed.

var tractor = nil;

var tractor_init = func() {
	var pushback_node = props.globals.getNode("sim/model/pushback");
	if (pushback_node != nil) {
		tractor = aircraft.door.new("sim/model/pushback", 10.0);
	}
}


var tractor_connect = func() {
	tractor.toggle();
}

_setlistener("/sim/signals/nasal-dir-initialized", func { tractor_init() });
