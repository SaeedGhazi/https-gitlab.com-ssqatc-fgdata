var i = 0;
var net_raw = "false";
var spectator = "false";
var spectator_offset = 0.5;
var range = 3.0;
var offset = 0.0;
var apply_close = "false";
var master = 0;
var close = 0;

var mpCheck = func() {
    var mpname = getprop("/ai/models/multiplayer["~i~"]/callsign");
    if (mpname != nil) {
        if (spectator) {
			setprop("/ai/models/multiplayer["~i~"]/controls/compensate-lag", 3);
			setprop("/ai/models/multiplayer["~i~"]/controls/player-lag", -spectator_offset);
		} else {
            var server = getprop("/sim/multiplay/txhost");
			var lag = offset
		} if (apply_close) {
			var self = geo.aircraft_position();
			var x = getprop("/ai/models/multiplayer["~i~"]/position/global-x");
			var y = getprop("/ai/models/multiplayer["~i~"]/position/global-y");
			var z = getprop("/ai/models/multiplayer["~i~"]/position/global-z");
			var ac = geo.Coord.new().set_xyz(x, y, z);
			var distance = self.distance_to(ac)*M2NM;
			if ((distance > range)or(distance==nil)) {
			setprop("/ai/models/multiplayer["~i~"]/controls/compensate-lag", 1);
			} else {
				setprop("/ai/models/multiplayer["~i~"]/controls/compensate-lag", 2);
				setprop("/ai/models/multiplayer["~i~"]/controls/player-lag", lag);
			};
		} else {
			setprop("/ai/models/multiplayer["~i~"]/controls/compensate-lag", 1);
		}
	    i += 1;
	} else {
		i = 0;
		if (close) close = 0;
	}
	if ((master) or (close)) {
		settimer(mpCheck, 1);
	}
}

var mpInit = func() {
	print("initialising the mp lag system");
	var ls_spect = setlistener("/sim/multiplay/lag/spectator",func { spectator = getprop("/sim/multiplay/lag/spectator")}, 1);
	var ls_spctoffset = setlistener("/sim/multiplay/lag/spectator-offset",func { spectator_offset = getprop("/sim/multiplay/lag/spectator-offset")}, 1);
	var ls_range = setlistener("/sim/multiplay/lag/range",func { range = getprop("/sim/multiplay/lag/range")}, 1);
	var ls_wingmen = setlistener("/sim/multiplay/lag/apply-to-wingmen",func { apply_to_wingmen = getprop("/sim/multiplay/lag/apply-to-wingmen")}, 1);
	var ls_offset = setlistener("/sim/multiplay/lag/offset",func { offset = getprop("/sim/multiplay/lag/offset")}, 1);
	var ls_close = setlistener("/sim/multiplay/lag/apply-close", func { apply_close = getprop("/sim/multiplay/lag/apply-close")}, 1);
}

var mpClean = func() {
	i = 0;
    spectator = 0;
	spectator_offset = 0.5;
	range = 3.0;
	apply_to_wingmen = 0;
	apply_close = 0;
	offset = 0.0;
	close = 1;
	master = 0;
}

var mpStart = func() {
	var test = getprop("/sim/multiplay/lag/master");
	if (test == nil) {
		settimer(mpStart, 2);
	} else {
		mpInit();
		setlistener("/sim/multiplay/lag/master", masterSwitch,1);
    }
}

var masterSwitch = func() {
	master = getprop("/sim/multiplay/lag/master");
	if (master)  {
		mpInit();
		mpCheck();
			} else {
		mpClean();
	}
}


_setlistener("/sim/signals/nasal-dir-initialized", mpStart);
