var boom_tanker = "Models/Geometry/KC135/KC135.xml";
var probe_tanker = "Models/Geometry/KA6-D/KA6-D.xml";


var wind_speed_from = func(azimuth) {
	var dir = (getprop("/environment/wind-from-heading-deg") - azimuth) * D2R;
	return getprop("/environment/wind-speed-kt") * math.cos(dir);
}


var clock = func(bearing) {
	var d = sprintf("%.0f", geo.normdeg(bearing) / 30);
	return d ? d : 12;
}


var Tanker = {
	new: func(callsign, tacan, type, kias, heading, coord) {
		var m = { parents: [Tanker] };
		me.callsign = callsign;
		me.tacan = tacan;
		me.kias = kias;
		me.heading = heading;
		me.coord = geo.Coord.new(coord);
		me.out_of_range_time = 0;

		var n = props.globals.getNode("models", 1);
		for (var i = 0; 1; i += 1)
			if (n.getChild("model", i, 0) == nil)
				break;
		me.model = n.getChild("model", i, 1);

		var n = props.globals.getNode("ai/models", 1);
		for (var i = 0; 1; i += 1)
			if (n.getChild("tanker", i, 0) == nil)
				break;
		me.ai = n.getChild("tanker", i, 1);

		me.ai.getNode("callsign", 1).setValue(me.callsign);
		me.ai.getNode("tanker", 1).setBoolValue(1);
		me.ai.getNode("valid", 1).setBoolValue(1);
		me.ai.getNode("navaids/tacan/channel-ID", 1).setValue(me.tacan);
		me.ai.getNode("refuel/type", 1).setValue(type);

		me.contactN = me.ai.initNode("refuel/contact", 1, "BOOL");

		var ai = me.ai.getPath() ~ "/";
		me.model.setValues({
			"path": type == "boom" ? boom_tanker : probe_tanker,
			"latitude-deg-prop": ai ~ "position/latitude-deg",
			"longitude-deg-prop": ai ~ "position/longitude-deg",
			"elevation-ft-prop": ai ~ "position/altitude-ft",
			"heading-deg-prop": ai ~ "orientation/heading-deg",
			"pitch-deg-prop": ai ~ "orientation/pitch-deg",
			"roll-deg-prop": ai ~ "orientation/roll-deg",
		});

		me.update();
		me.model.getNode("load", 1).remove();
		me.identify();
		return Tanker.active[me.callsign] = m;
	},
	del: func {
		me.model.remove();
		me.ai.remove();
		delete(Tanker.active, me.callsign);
	},
	update: func {
		var dt = getprop("sim/time/delta-sec");
		var alt = me.coord.alt();
		var wind = wind_speed_from(me.heading);
		var ktas = me.kias + (me.kias * alt * M2FT / 50000); # +2% per 1000 ft

		me.coord.apply_course_distance(me.heading, dt * (ktas + wind) * NM2M / 3600);

		me.ac = geo.aircraft_position();
		me.distance = me.ac.distance_to(me.coord);
		me.bearing = me.ac.course_to(me.coord);
		me.contactN.setBoolValue(me.distance < 76 and me.ac.alt() < me.coord.alt());  # 250 ft

		me.ai.setValues({
			"position/latitude-deg": me.coord.lat(),
			"position/longitude-deg": me.coord.lon(),
			"position/altitude-ft": me.coord.alt() * M2FT,
			"orientation/heading-deg": me.heading,
			"orientation/pitch-deg": 0,
			"orientation/roll-deg": 0,
		});

		var now = getprop("/sim/time/elapsed-sec");
		if (me.distance < 100000)
			me.out_of_range_time = now;
		if (now - me.out_of_range_time > 600)
			return me.del();
		settimer(func me.update(), 0);
	},
	identify: func {
		var alt = int((me.coord.alt() * M2FT + 50) / 100) * 100;
		var msg = sprintf("%s at %.0f, heading %.0f with %.0f knots, TACAN %s",
				me.callsign, alt, me.heading, me.kias, me.tacan);
		setprop("sim/messages/ai-plane", msg);
	},
	report: func {
		var dist = int(me.distance * M2NM);
		var hdg = getprop("orientation/heading-deg");
		var diff = (me.coord.alt() - me.ac.alt()) * M2FT;
		var qual = diff > 3000 ? " well" : abs(diff) > 1000 ? " slightly" : "";
		var rel = diff > 1000 ? " above" : diff < -1000 ? " below" : "";
		var msg = sprintf("Tanker %s is at %s o'clock%s",
				me.callsign, clock(me.ac.course_to(me.coord) - hdg),
				qual ~ rel);
		setprop("sim/messages/ground", msg);
	},
	active: {},
};



var request = func {
	var tanker = values(Tanker.active);
	if (size(tanker))
		return tanker[0].identify();
	var type = props.globals.getNode("systems/refuel").getChildren("type");
	if (!size(type))
		return;

	var hdg = getprop("orientation/heading-deg");
	var course = hdg + (rand() - 0.5) * 60;
	var dist = 8000 + rand() * 8000;
	var alt = int(10 + rand() * 15) * 1000;  # FL100--FL250
	var coord = geo.aircraft_position().apply_course_distance(course, dist).set_alt(alt * FT2M);
	type = type[rand() * size(type)].getValue();
	Tanker.new("MOBIL3", "062X", type, 250, hdg, coord);
}


var report = func {
	var tanker = values(Tanker.active);
	if (size(tanker))
		tanker[0].report();
}


_setlistener("/sim/signals/nasal-dir-initialized", func {
	var aar_capable = size(props.globals.getNode("systems/refuel").getChildren("type"));
	gui.menuEnable("tanker", aar_capable);
	if (!aar_capable)
		request = func setprop("sim/messages/ai-plane", "no tanker in range");

	setlistener("/sim/signals/reinit", func(n) {
		foreach (var t; values(Tanker.active))
			t.del();
	});
});

