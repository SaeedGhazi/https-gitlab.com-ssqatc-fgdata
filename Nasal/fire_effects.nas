# Spawns/removes the realistic placeable fire effects (Models/Effects/Fire/*.xml).
# Step 1 of the fire/smoke/extinguish feature set: visual flame placement only.

var FIRE_MODELS = {
	plain: "Models/Effects/Fire/fire.xml",
	smoke: "Models/Effects/Fire/fire-with-smoke.xml",
	tall: "Models/Effects/Fire/tall-fire.xml",
	tall_smoke: "Models/Effects/Fire/tall-fire-with-smoke.xml",
};

var fire_effects = {
	active: {},
	next_id: 0,
};

# ignite(pos, heading=0, kind="plain") : geo.Coord, double, string -> int
#   kind is one of "plain", "smoke", "tall", "tall_smoke" (see FIRE_MODELS).
#   Spawns a fire at pos and returns a handle for extinguish().
fire_effects.ignite = func(pos, heading = 0, kind = "plain") {
	var path = contains(FIRE_MODELS, kind) ? FIRE_MODELS[kind] : FIRE_MODELS["plain"];
	var model = geo.put_model(path, pos, heading);
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

# Shift+Ctrl+Click to ignite a plain fire at the clicked position (same
# convention documented in Docs/README.wildfire for wildfire.ignite()).
setlistener("/sim/signals/click", func {
	if (__kbd.shift.getBoolValue() and __kbd.ctrl.getBoolValue()) {
		fire_effects.ignite(geo.click_position());
	}
});
