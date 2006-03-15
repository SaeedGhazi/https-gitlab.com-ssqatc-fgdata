# MAXIMUM SPEED ###################################################################################

var maxspeed = props.globals.getNode("engines/engine/speed-max-mps");
var speed = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000];
var current = 7;


controls.flapsDown = func(x) {
	if (!x) {
		return;
	} elsif (x < 0 and current > 0) {
		current -= 1;
	} elsif (x > 0 and current < size(speed) - 1) {
		current += 1;
	}
	var s = speed[current];
	maxspeed.setDoubleValue(s);
	gui.popupTip("MaxSpeed " ~ s ~ " m/s");
}



# CURSOR ##########################################################################################

ft2m = func { arg[0] * 0.3048 }
m2ft = func { arg[0] / 0.3048 }
floor = func { arg[0] < 0.0 ? -int(-arg[0]) - 1 : int(arg[0]) }


normdeg = func(angle) {
	while (angle < 0) {
		angle += 360;
	}
	while (angle >= 360) {
		angle -= 360;
	}
	angle;
}


format = func(lon, lat) {
	sprintf("%s%03d%s%02d", lon < 0 ? "w" : "e", abs(lon), lat < 0 ? "s" : "n", abs(lat));
}


bucket_span = func(lat) {
	if (lat >= 89.0 ) {
		360.0;
	} elsif (lat >= 88.0 ) {
		8.0;
	} elsif (lat >= 86.0 ) {
		4.0;
	} elsif (lat >= 83.0 ) {
		2.0;
	} elsif (lat >= 76.0 ) {
		1.0;
	} elsif (lat >= 62.0 ) {
		0.5;
	} elsif (lat >= 22.0 ) {
		0.25;
	} elsif (lat >= -22.0 ) {
		0.125;
	} elsif (lat >= -62.0 ) {
		0.25;
	} elsif (lat >= -76.0 ) {
		0.5;
	} elsif (lat >= -83.0 ) {
		1.0;
	} elsif (lat >= -86.0 ) {
		2.0;
	} elsif (lat >= -88.0 ) {
		4.0;
	} elsif (lat >= -89.0 ) {
		8.0;
	} else {
		360.0;
	}
}


tile_index = func(lon, lat) {
	lon_floor = floor(lon);
	lat_floor = floor(lat);
	span = bucket_span(lat);

	if (span < 0.0000001) {
		lon = 0;
		x = 0;
	} elsif (span <= 1.0) {
		x = int((lon - lon_floor) / span);
	} else {
		if (lon >= 0) {
			lon = int(int(lon / span) * span);
		} else {
			lon = int(int((lon + 1) / span) * span - span);
			if (lon < -180) {
				lon = -180;
			}
		}
		x = 0;
	}

	y = int((lat - lat_floor) * 8);
	(lon_floor + 180) * 16384 + (lat_floor + 90) * 64 + y * 8 + x;
}


tile_path = func(lon, lat) {
	var lon_floor = floor(lon);
	var lat_floor = floor(lat);
	var lon_chunk = floor(lon / 10.0) * 10;
	var lat_chunk = floor(lat / 10.0) * 10;
	format(lon_chunk, lat_chunk) ~ "/" ~ format(lon_floor, lat_floor)
			~ "/" ~ tile_index(lon, lat) ~ ".stg";
}


Value = {
	new : func(baseN, name, init) {
		m = { parents : [Value] };
		m.lastOffs = 0;
		m.init = init;

		m.inOffsN = baseN.getNode("offset-" ~ name, 1);
		m.inOffsN.setValue(m.lastOffs);

		m.outN = baseN.getNode(name, 1);
		m.outN.setValue(m.init);

		m.lst = setlistener(m.inOffsN, func { m.update() });
		return m;
	},
	del : func {
		removelistener(me.lst);
	},
	reset : func {
		me.center();
		me.outN.setValue(me.init);
	},
	center : func {
		me.update();
		me.inOffsN.setValue(me.lastOffs = 0);
	},
	update : func {
		var offs = me.inOffsN.getValue();
		me.outN.setValue(me.outN.getValue() + offs - me.lastOffs);
		me.lastOffs = offs;
	},
	set : func(v) {
		me.center();
		me.outN.setValue(v);
	},
	get : func {
		me.outN.getValue();
	},
	add : func(v) {
		me.center();
		me.outN.setValue(me.outN.getValue() + v);
	},
};


Object = {
	new : func {
		m = { parents : [Object] };
		baseN = props.globals.getNode("/cursor", 1);
		m.values = {
			lon:   Value.new(baseN, "longitude-deg", 0),
			lat:   Value.new(baseN, "latitude-deg", 0),
			alt:   Value.new(baseN, "elevation-ft", -1000),

			hdg:   Value.new(baseN, "heading-deg", 0),
			pitch: Value.new(baseN, "pitch-deg", 0),
			roll:  Value.new(baseN, "roll-deg", 0),
		};
		return m;
	},
	reset : func {
		foreach (v; keys(me.values)) { me.values[v].reset() }
	},
	center : func {
		foreach (v; keys(me.values)) { me.values[v].center() }
	},
	update : func {
		foreach (v; keys(me.values)) { me.valuse[v].update() }
	},
};


var cursor = Object.new();
setlistener("/sim/input/click/longitude-deg", func { cursor.values["lon"].set(cmdarg().getValue())});
setlistener("/sim/input/click/latitude-deg", func { cursor.values["lat"].set(cmdarg().getValue())});
setlistener("/sim/input/click/elevation-ft", func { cursor.values["alt"].set(cmdarg().getValue())});




dialog = nil;

showDialog = func {
	name = "ufo-cursor-dialog";
	if (dialog != nil) {
		fgcommand("dialog-close", props.Node.new({ "dialog-name" : name }));
		dialog = nil;
		return;
	}

	cursor.center();

	dialog = gui.Widget.new();
	dialog.set("layout", "vbox");
	dialog.set("name", name);
	dialog.set("x", -40);
	dialog.set("y", -40);

	# "window" titlebar
	titlebar = dialog.addChild("group");
	titlebar.set("layout", "hbox");
	titlebar.addChild("empty").set("stretch", 1);
	titlebar.addChild("text").set("label", "Position Cursor");
	titlebar.addChild("empty").set("stretch", 1);

	dialog.addChild("hrule").addChild("dummy");

	w = titlebar.addChild("button");
	w.set("pref-width", 16);
	w.set("pref-height", 16);
	w.set("legend", "");
	w.set("default", 1);
	w.set("keynum", 27);
	w.set("border", 1);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("ufo.dialog = nil");
	w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

	slider = func(p, legend, col, coarse, fine) {
		group = dialog.addChild("group");
		group.set("layout", "hbox");
		group.set("default-padding", 0);
		button = func(leg, step) {
			b = group.addChild("button");
			b.set("legend", leg);
			b.set("pref-width", 22);
			b.set("pref-height", 22);
			b.set("live", 1);
			b.prop().getNode("binding[0]/command", 1).setValue("nasal");
			b.prop().getNode("binding[0]/script", 1).setValue
					('ufo.cursor.values["'~legend~'"].add('~step~');ufo.cursor.center()');
			return b;
		}

		cl = button("<<", -coarse);
		fl = button("<", -fine);

		s = group.addChild("slider");
		s.set("property", p.getPath());
		s.set("legend", legend);
		s.set("pref-width", 250);
		s.set("live", 1);
		s.set("min", -2 * fine);
		s.set("max", 2 * fine);
		s.setColor(col[0], col[1], col[2]);
		s.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

		fr = button(">", fine);
		cr = button(">>", coarse);
	}

	slider(cursor.values["lon"].inOffsN, "lon", [1.0, 0.6, 0.6], 0.0002, 0.00002);
	slider(cursor.values["lat"].inOffsN, "lat", [0.6, 1.0, 0.6], 0.0002, 0.00002);
	slider(cursor.values["alt"].inOffsN, "alt", [0.6, 0.6, 1.0], 10, 2);

	slider(cursor.values["hdg"].inOffsN, "hdg", [1.0, 1.0, 0.6], 36, 6);
	slider(cursor.values["pitch"].inOffsN, "pitch", [1.0, 0.6, 1.0], 36, 6);
	slider(cursor.values["roll"].inOffsN, "roll", [0.6, 1.0, 1.0], 36, 6);

	w = dialog.addChild("button");
	w.set("legend", "center");
	w.set("pref-height", 22);
	w.set("pref-width", 50);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("ufo.cursor.center()");

	fgcommand("dialog-new", dialog.prop());
	gui.showDialog(name);
}


dumpCoords = func {
	print("\n---------------------------- UFO -----------------------------");

	var lon = getprop("/position/longitude-deg");
	var lat = getprop("/position/latitude-deg");
	var alt_ft = getprop("/position/altitude-ft");
	var elev_m = getprop("/position/ground-elev-m");
	var heading = getprop("/orientation/heading-deg");
	var agl_ft = alt_ft - m2ft(elev_m);

	print(sprintf("Longitude:    %.6f deg", lon));
	print(sprintf("Latitude:     %.6f deg", lat));
	print(sprintf("Altitude ASL: %.4f m (%.4f ft)", ft2m(alt_ft), alt_ft));
	print(sprintf("Altitude AGL: %.4f m (%.4f ft)", ft2m(agl_ft), agl_ft));
	print(sprintf("Heading:      %.1f deg", normdeg(heading)));
	print(sprintf("Ground Elev:  %.4f m (%.4f ft)", elev_m, m2ft(elev_m)));
	print("");
	print(tile_path(lon, lat));
	print(sprintf("OBJECT_STATIC %.6f %.6f %.4f %.1f", lon, lat, elev_m, normdeg(360 - heading)));


	print("\n\n--------------------------- Cursor ---------------------------");

	var alt = cursor.values["alt"].get();
	print(sprintf("Longitude:    %.6f deg", var clon = cursor.values["lon"].get()));
	print(sprintf("Latitude:     %.6f deg", var clat = cursor.values["lat"].get()));
	print(sprintf("Altitude:     %.4f m (%.4f ft)", var celev = ft2m(alt), alt));
	print(sprintf("Heading:      %.1f deg", var chdg = normdeg(cursor.values["hdg"].get())));
	print(sprintf("Pitch:        %.1f deg", normdeg(cursor.values["pitch"].get())));
	print(sprintf("Roll:         %.1f deg", normdeg(cursor.values["roll"].get())));
	print("");
	print(tile_path(clon, clat));
	print(sprintf("OBJECT_STATIC %.6f %.6f %.4f %.1f", clon, clat, celev, normdeg(360 - chdg)));
	print("--------------------------------------------------------------");

}


