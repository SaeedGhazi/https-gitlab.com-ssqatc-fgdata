var boom_tanker = "Models/Geometry/KC135/KC135.xml";
var probe_tanker = "Models/Geometry/KA6-D/KA6-D.xml";


var oclock = func(bearing) int(0.5 + geo.normdeg(bearing) / 30) or 12;


var identity = {
	# return free ai id number and least used, free callsign/channel pair
	get: func {
		var data = {};     # copy of me.pool
		var revdata = {};  # channel->callsign
		foreach (var k; keys(me.pool)) {
			data[k] = me.pool[k];
			revdata[me.pool[k][0]] = k;
		}
		var id_used = {};
		foreach (var t; props.globals.getNode("ai/models", 1).getChildren()) {
			if ((var c = t.getNode("callsign")) != nil)
				delete(data, c.getValue() or "");
			if ((var c = t.getNode("navaids/tacan/channel-ID")) != nil)
				delete(data, revdata[c.getValue() or ""]);
			if ((var c = t.getNode("id")) != nil)
				id_used[c.getValue()] = 1;
		}
		for (var aiid = -2; aiid; aiid -= 1)
			if (!id_used[aiid])
				break;
		if (!size(data))
			return [aiid, "MOBIL3", "062X"];
		var d = sort(keys(data), func(a, b) data[a][1] - data[b][1])[0];
		me.pool[d][1] += 1;
		return [aiid, d, data[d][0]];
	},
	pool: {
		ESSO1: ["040X", 0], ESSO2: ["041X", 0], ESSO3: ["042X", 0],
		TEXACO1: ["050X", 0], TEXACO2: ["051X", 0], TEXACO3: ["052X", 0],
		MOBIL1: ["060X", 0], MOBIL2: ["061X", 0], MOBIL3: ["062X", 0],
	},
};


var Tanker = {
	new: func(aiid, callsign, tacan, type, kias, heading, coord) {
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

		m.ai.getNode("id", 1).setIntValue(aiid);
		m.ai.getNode("callsign", 1).setValue(m.callsign);
		m.ai.getNode("tanker", 1).setBoolValue(1);
		m.ai.getNode("valid", 1).setBoolValue(1);
		m.ai.getNode("navaids/tacan/channel-ID", 1).setValue(m.tacan);
		m.ai.getNode("refuel/type", 1).setValue(type);
		m.ai.getNode("refuel/contact", 1).setBoolValue(0);

		m.latN = m.ai.getNode("position/latitude-deg", 1);
		m.lonN = m.ai.getNode("position/longitude-deg", 1);
		m.altN = m.ai.getNode("position/altitude-ft", 1);
		m.hdgN = m.ai.getNode("orientation/true-heading-deg", 1);
		m.pitchN = m.ai.getNode("orientation/pitch-deg", 1);
		m.rollN = m.ai.getNode("orientation/roll-deg", 1);
		m.ktasN = m.ai.getNode("velocities/true-airspeed-kt", 1);
		m.vertN = m.ai.getNode("velocities/vertical-speed-fps", 1);
		m.rangeN = m.ai.getNode("radar/range-nm", 1);
		m.brgN = m.ai.getNode("radar/bearing-deg", 1);
		m.elevN = m.ai.getNode("radar/elevation-deg", 1);
		m.contactN = m.ai.getNode("refuel/contact", 1);

		m.update();
		m.model.getNode("path", 1).setValue(type == "boom" ? boom_tanker : probe_tanker);
		m.model.getNode("latitude-deg-prop", 1).setValue(m.latN.getPath());
		m.model.getNode("longitude-deg-prop", 1).setValue(m.lonN.getPath());
		m.model.getNode("elevation-ft-prop", 1).setValue(m.altN.getPath());
		m.model.getNode("heading-deg-prop", 1).setValue(m.hdgN.getPath());
		m.model.getNode("pitch-deg-prop", 1).setValue(m.pitchN.getPath());
		m.model.getNode("roll-deg-prop", 1).setValue(m.rollN.getPath());
		m.model.getNode("load", 1).remove();
		m.identify();
		return Tanker.active[m.callsign] = m;
	},
	del: func {
		setprop("sim/messages/ai-plane", me.callsign ~ " returns to base");
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

		me.latN.setDoubleValue(me.coord.lat());
		me.lonN.setDoubleValue(me.coord.lon());
		me.altN.setDoubleValue(alt * M2FT);
		me.hdgN.setDoubleValue(me.heading);
		me.pitchN.setDoubleValue(0);
		me.rollN.setDoubleValue(0);
		me.ktasN.setDoubleValue(me.ktas);
		me.vertN.setDoubleValue(0);
		me.rangeN.setDoubleValue(me.distance * M2NM);
		me.brgN.setDoubleValue(me.bearing);
		me.elevN.setDoubleValue(math.atan2(dalt, me.distance) * R2D);
		me.contactN.setBoolValue(me.distance < 76 and dalt > 0  # 250 ft
				and abs(view.normdeg(me.bearing - ac_hdg)) < 20);

		var now = getprop("/sim/time/elapsed-sec");
		if (me.distance < 90000)
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

	var (aiid, callsign, tacanid) =_= identity.get();
	var hdg = getprop("orientation/heading-deg");
	var course = hdg + (rand() - 0.5) * 60;
	var dist = 6000 + rand() * 4000;
	var alt = int(10 + rand() * 15) * 1000;  # FL100--FL250
	var coord = geo.aircraft_position().apply_course_distance(course, dist).set_alt(alt * FT2M);
	Tanker.new(aiid, callsign, tacanid, type, 250, hdg, coord);
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
		request = func { setprop("sim/messages/ai-plane", "no tanker in range") };

	setlistener("/sim/signals/reinit", func {
		foreach (var t; values(Tanker.active))
			t.del();
	});

	# randomize tacan pool usage counter (0 and -1)
	foreach (var t; values(identity.pool))
		t[1] = int(rand() * 2) - 1;
});

