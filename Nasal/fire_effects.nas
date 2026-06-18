# Spawns/removes the realistic placeable fire effect (Models/Effects/Fire/fire.xml).
# Step 1 of the fire/smoke/extinguish feature set: visual flame placement only.

var FIRE_MODEL = "Models/Effects/Fire/fire.xml";

var fire_effects = {
	active: {},
	next_id: 0,
};

# ignite(pos, heading=0) : geo.Coord, double -> int
#   Spawns a fire at pos and returns a handle for extinguish().
fire_effects.ignite = func(pos, heading = 0) {
	var model = geo.put_model(FIRE_MODEL, pos, heading);
	var id = fire_effects.next_id += 1;
	fire_effects.active[id] = model;
	return id;
};

# extinguish(id) : int -> void
#   Removes a previously ignited fire.
fire_effects.extinguish = func(id) {
	if (contains(fire_effects.active, id)) {
		fire_effects.active[id].remove();
		delete(fire_effects.active, id);
	}
};

# Shift+Ctrl+Click to ignite a fire at the clicked position (same convention
# documented in Docs/README.wildfire for wildfire.ignite()).
setlistener("/sim/signals/click", func {
	if (__kbd.shift.getBoolValue() and __kbd.ctrl.getBoolValue()) {
		fire_effects.ignite(geo.click_position());
	}
});
