var boom_tanker = "Models/Geometry/KC135/KC135.xml";
var probe_tanker = "Models/Geometry/KA6-D/KA6-D.xml";


var oclock = func(bearing) int(0.5 + geo.normdeg(bearing) / 30) or 12;


var tacan = {
	getid: func {
		return ["MOBIL3", "062X"];
	},
	data: {
		ESSO1: "040X", ESSO2: "041X", ESSO3: "042X",
		TEXACO1: "050X", TEXACO2: "051X", TEXACO3: "052X",
		MOBIL1: "060X", MOBIL2: "061X", MOBIL3: "062X",
	},
};


var Tanker = {
	new: func(callsign, tacan, type, kias, heading, coord) {
		var m = { parents: [Tanker] };
		m.callsign = callsign;
		m.tacan = tacan;
		m.kias = kias;
		m.heading = heading;
		m.coord = geo.Coord.new(coord);
		m.out_of_range_time = 0;
		m.interval = 10;

		var n = props.globals.getNode("models", 1);
		for (var i = 0; 1; i += 1)
			if (n.getChild("model", i, 0) == nil)
				break;
		m.model = n.getChild("model", i, 1);

		var n = props.globals.getNode("ai/models", 1);
		for (var i = 0; 1; i += 1)
			if (n.getChild("tanker", i, 0) == nil)
				break;
		m.ai = n.getChild("tanker", i, 1);

		m.ai.getNode("id", 1).setIntValue(-2);
		m.ai.getNode("callsign", 1).setValue(m.callsign);
		m.ai.getNode("tanker", 1).setBoolValue(1);
		m.ai.getNode("valid", 1).setBoolValue(1);
		m.ai.getNode("navaids/tacan/channel-ID", 1).setValue(m.tacan);
		m.ai.getNode("refuel/type", 1).setValue(type);
		m.ai.getNode("refuel/contact", 1).setBoolValue(0);

		var ai = m.ai.getPath() ~ "/";
		m.model.setValues({
			"path": type == "boom" ? boom_tanker : probe_tanker,
			"latitude-deg-prop": ai ~ "position/latitude-deg",
			"longitude-deg-prop": ai ~ "position/longitude-deg",
			"elevation-ft-prop": ai ~ "position/altitude-ft",
			"heading-deg-prop": ai ~ "orientation/true-heading-deg",
			"pitch-deg-prop": ai ~ "orientation/pitch-deg",
			"roll-deg-prop": ai ~ "orientation/roll-deg",
		});

		m.update();
		m.model.getNode("load", 1).remove();
		m.identify();
		return Tanker.active[m.callsign] = m;
	},
	del: func {
		me.model.remove();
		me.ai.remove();
		delete(Tanker.active, me.callsign);
	},
	update: func {
		var dt = getprop("sim/time/delta-sec");
		var alt = me.coord.alt();

		if ((me.interval += dt) >= 10) {
			me.interval -= 10;
			me.headwind = aircraft.wind_speed_from(me.heading);
			me.ktas = aircraft.kias_to_ktas(me.kias, alt);
		}

		me.coord.apply_course_distance(me.heading, dt * (me.ktas - me.headwind) * NM2M / 3600);

		me.ac = geo.aircraft_position();
		me.distance = me.ac.distance_to(me.coord);
		me.bearing = me.ac.course_to(me.coord);
		var dalt = alt - me.ac.alt();
		var ac_hdg = getprop("/orientation/heading-deg");

		me.ai.setValues({
			"position/latitude-deg": me.coord.lat(),
			"position/longitude-deg": me.coord.lon(),
			"position/altitude-ft": alt * M2FT,
			"orientation/true-heading-deg": me.heading,
			"orientation/pitch-deg": 0,
			"orientation/roll-deg": 0,
			"velocities/true-airspeed-kt": me.ktas,
			"velocities/vertical-speed-fps": 0,
			"radar/range-nm": me.distance * M2NM,
			"radar/bearing-deg": me.bearing,
			"radar/elevation-deg": math.atan2(dalt, me.distance) * R2D,
			"refuel/contact": me.distance < 76 and dalt > 0
					and abs(view.normdeg(me.bearing - ac_hdg)) < 20, # 250 ft
		});

		var now = getprop("/sim/time/elapsed-sec");
		if (me.distance < 100000)
			me.out_of_range_time = now;
		elsif (now - me.out_of_range_time > 600)
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
				me.callsign, oclock(me.ac.course_to(me.coord) - hdg),
				qual ~ rel);
		setprop("sim/messages/ground", msg);
	},
	active: {},
};



var request = func {
	var tanker = values(Tanker.active);
	if (size(tanker))
		return tanker[0].identify();

	var type = props.globals.getNode("systems/refuel", 1).getChildren("type");
	if (!size(type))
		return;
	type = type[rand() * size(type)].getValue();

	var (callsign, tacanid) =_= tacan.getid();

	var hdg = getprop("orientation/heading-deg");
	var course = hdg + (rand() - 0.5) * 60;
	var dist = 6000 + rand() * 4000;
	var alt = int(10 + rand() * 15) * 1000;  # FL100--FL250
	var coord = geo.aircraft_position().apply_course_distance(course, dist).set_alt(alt * FT2M);
	Tanker.new(callsign, tacanid, type, 250, hdg, coord);
}


var report = func {
	var tanker = values(Tanker.active);
	if (size(tanker))
		tanker[0].report();
}


_setlistener("/sim/signals/nasal-dir-initialized", func {
	var aar_capable = size(props.globals.getNode("systems/refuel", 1).getChildren("type"));
	gui.menuEnable("tanker", aar_capable);
	if (!aar_capable)
		request = func setprop("sim/messages/ai-plane", "no tanker in range");

	setlistener("/sim/signals/reinit", func(n) {
		foreach (var t; values(Tanker.active))
			t.del();
	});
});

