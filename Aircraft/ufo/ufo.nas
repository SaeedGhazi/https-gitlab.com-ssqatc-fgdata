
# maximum speed -----------------------------------------------------------------------------------


var maxspeed = props.globals.getNode("engines/engine/speed-max-mps");
var speed = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000];
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
	gui.popupTip("Max. Speed " ~ s ~ " m/s");
}





# library stuff -----------------------------------------------------------------------------------

var EPSILON = 0.0000000000001;
var ERAD = 6378138.12;		# Earth radius (m)
var D2R = math.pi / 180;
var R2D = 180 / math.pi;
var FT2M = 0.3048;
var M2FT = 3.28083989501312335958;


var printf = func(_...) { print(call(sprintf, _)) }
var floor = func(v) { v < 0.0 ? -int(-v) - 1 : int(v) }
var ceil = func(v) { -floor(-v) }
var pow = func(v, w) { v < 0 ? nil : v ? math.exp(math.ln(v) * w) : 0 }
var pow2 = func(e) { e ? 2 * pow2(e - 1) : 1 }
var sin = math.sin;
var cos = math.cos;
var atan2 = math.atan2;
var sqrt = math.sqrt;
var asin = func(v) { math.atan2(v, math.sqrt(1 - v * v)) }
var acos = func(v) { math.atan2(math.sqrt(1 - v * v), v) }
var mod = func(v, w) {
	var x = v - w * int(v / w);
	return x < 0 ? x + abs(w) : x;
}


# class that maintains one set of geographical coordinates and provides
# simple conversion methods that assume a spherical Earth
#
var Coord = {
	new : func(copy = nil) {
		var m = { parents: [Coord] };
		m._pdirty = 1;  # polar
		m._cdirty = 1;  # cartesian
		m._lon = nil;   # in radian
		m._lat = nil;
		m._alt = nil;   # ASL
		m._x = nil;     # in m
		m._y = nil;
		m._z = nil;
		if (copy != nil) {
			m.set(copy);
		}
		return m;
	},
	_cupdate : func {
		me._cdirty or return;
		var rad = ERAD + me._alt;
		var cosphi = cos(me._lat) * rad;
		me._x = cosphi * cos(me._lon);
		me._y = cosphi * sin(me._lon);
		me._z = sin(me._lat) * rad;
		me._cdirty = 0;
	},
	_pupdate : func {
		me._pdirty or return;
		me._lat = atan2(me._z, sqrt(me._x * me._x + me._y * me._y));
		me._lon = atan2(me._y, me._x);
		me._alt = sqrt(me._x * me._x + me._y * me._y + me._z * me._z) - ERAD;
		me._pdirty = 0;
	},

	x : func { me._cupdate(); me._x },
	y : func { me._cupdate(); me._y },
	z : func { me._cupdate(); me._z },
	xyz : func { me._cupdate(); [me._x, me._y, me._z] },

	lon : func { me._pupdate(); me._lon * R2D },  # return in degree
	lat : func { me._pupdate(); me._lat * R2D },
	alt : func { me._pupdate(); me._alt },
	lonlat : func { me._pupdate(); [me._lon, me._lat, me._alt] },

	set_x : func(x) { me._pupdate(); me._pdirty = 1; me._x = x; me },
	set_y : func(y) { me._pupdate(); me._pdirty = 1; me._y = y; me },
	set_z : func(z) { me._pupdate(); me._pdirty = 1; me._z = z; me },

	set_lon : func(lon) { me._cupdate(); me._cdirty = 1; me._lon = lon * D2R; me },
	set_lat : func(lat) { me._cupdate(); me._cdirty = 1; me._lat = lat * D2R; me },
	set_alt : func(alt) { me._cupdate(); me._cdirty = 1; me._alt = alt; me },

	set : func(c) {
		c._pupdate();
		me._lon = c._lon;
		me._lat = c._lat;
		me._alt = c._alt;
		me._cdirty = 1;
		me._pdirty = 0;
		me;
	},
	set_lonlat : func(lon, lat, alt = 0) {
		me._lon = lon * D2R;
		me._lat = lat * D2R;
		me._alt = alt;
		me._cdirty = 1;
		me._pdirty = 0;
		me;
	},
	set_xyz : func(x, y, z) {
		me._x = x;
		me._y = y;
		me._z = z;
		me._pdirty = 1;
		me._cdirty = 0;
		me;
	},
	apply_course_distance : func(course, dist) {
		me._pupdate();
		course *= D2R;
		dist /= ERAD;
		me._lat = asin(sin(me._lat) * cos(dist) + cos(me._lat) * sin(dist) * cos(course));

		if (cos(me._lat) > EPSILON) {
			me._lon = math.pi - mod(math.pi - me._lon - asin(sin(course) * sin(dist)
					/ cos(me._lat)), 2 * math.pi);
		}
		me._cdirty = 1;
		me;
	},
	course_to : func(dest) {
		me._pupdate();
		dest._pupdate();

		if (me._lon == dest._lon and me._lat == dest._lat) {
			return 0;
		}
		var dlon = dest._lon - me._lon;
		return mod(atan2(sin(dlon) * cos(dest._lat), cos(me._lat) * sin(dest._lat)
				- sin(me._lat) * cos(dest._lat) * cos(dlon)), 2 * math.pi) * R2D;
	},
	# arc distance on an earth sphere; doesn't consider altitude
	distance_to : func(dest) {
		me._pupdate();
		dest._pupdate();

		if (me._lon == dest._lon and me._lat == dest._lat) {
			return 0;
		}
		var o = sin((me._lon - dest._lon) * 0.5);
		var a = sin((me._lat - dest._lat) * 0.5);
		return 2.0 * ERAD * asin(sqrt(a * a + cos(me._lat) * cos(dest._lat) * o * o));
	},
	direct_distance_to : func(dest) {
		me._cupdate();
		dest._cupdate();
		var dx = dest._x - me._x;
		var dy = dest._y - me._y;
		var dz = dest._z - me._z;
		return sqrt(dx * dx + dy * dy + dz * dz);
	},
	dump : func {
		if (me._cdirty and me._pdirty) {
			print("Coord.print(): coord undefined");
		}
		me._cupdate();
		me._pupdate();
		printf("x=%f  y=%f  z=%f    lon=%f  lat=%f  alt=%f",
				me.x(), me.y(), me.z(), me.lon(), me.lat(), me.alt());
	},
};



var init_prop = func(prop, value) {
	if (prop.getValue() != nil) {
		value = prop.getValue();
	}
	prop.setDoubleValue(value);
	return value;
}


# sort vector of strings (bubblesort)
#
var sort = func(l) {
	while (1) {
		var n = 0;
		for (var i = 0; i < size(l) - 1; i += 1) {
			if (cmp(l[i], l[i + 1]) > 0) {
				var t = l[i + 1];
				l[i + 1] = l[i];
				l[i] = t;
				n += 1;
			}
		}
		if (!n) {
			return l;
		}
	}
}


# binary search of string in sorted vector; returns index or -1 if not found
#
var search = func(list, which) {
	var left = 0;
	var right = size(list);
	var middle = nil;
	while (1) {
		middle = int((left + right) / 2);
		var c = cmp(list[middle], which);
		if (!c) {
			return middle;
		} elsif (left == middle) {
			return -1;
		} elsif (c > 0) {
			right = middle;
		} else {
			left = middle;
		}
	}
}


# scan all objects in subdir of $FG_ROOT. (Prefer *.xml files to *.ac files
# if both exist)
#
var scan_models = func(base) {
	var result = [];
	var list = directory(getprop("/sim/fg-root") ~ "/" ~ base);
	if (list == nil) {
		return result;
	}
	var xml = {};
	var ac = {};
	foreach (var d; list) {
		if (d[0] != `.` and d != "CVS") {
			if (substr(d, size(d) - 4) == ".xml") {
				xml[base ~ "/" ~ d] = 1;
			} elsif (substr(d, size(d) - 3) == ".ac") {
				ac[base ~ "/" ~ d] = 1;
			} else {
				foreach (var s; scan_models(base ~ "/" ~ d)) {
					append(result, s);
				}
			}
		}
	}
	foreach (var m; keys(xml)) {
		append(result, m);
		delete(ac, substr(m, 0, size(m) - 3) ~ "ac");
	}
	foreach (var m; keys(ac)) {
		append(result, m);
	}
	return result;
}


# normalize degree to 0 <= angle < 360
#
var normdeg = func(angle) {
	while (angle < 0) {
		angle += 360;
	}
	while (angle >= 360) {
		angle -= 360;
	}
	return angle;
}


var bucket_span = func(lat) {
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


var tile_index = func(lon, lat) {
	var lon_floor = floor(lon);
	var lat_floor = floor(lat);
	var span = bucket_span(lat);
	var x = 0;

	if (span < 0.0000001) {
		lon = 0;
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
	}

	var y = int((lat - lat_floor) * 8);
	(lon_floor + 180) * 16384 + (lat_floor + 90) * 64 + y * 8 + x;
}


var format = func(lon, lat) {
	sprintf("%s%03d%s%02d", lon < 0 ? "w" : "e", abs(lon), lat < 0 ? "s" : "n", abs(lat));
}


var tile_path = func(lon, lat) {
	var p = format(floor(lon / 10.0) * 10, floor(lat / 10.0) * 10);
	p ~= "/" ~ format(floor(lon), floor(lat));
	p ~= "/" ~ tile_index(lon, lat) ~ ".stg";
}







# -------------------------------------------------------------------------------------------------


# loop that generates the model flashing pulse
#
var clock = 0;
var clock_loop = func {
	clock = !clock;
	settimer(clock_loop, 0.3);
}
clock_loop();


var ufo_position = func {
	var lon = getprop("/position/longitude-deg");
	var lat = getprop("/position/latitude-deg");
	var alt = getprop("/position/altitude-ft") * FT2M;
	Coord.new().set_lonlat(lon, lat, alt);
}


# class that maintains one adjustable model property (see src/Model/modelmgr.cxx)
#
var ModelValue = {
	new : func(base, name, value) {
		var m = { parents: [ModelValue] };
		m.propN = base.getNode(name, 1);
		m.propN.setDoubleValue(value);
		base.getNode(name ~ "-prop", 1).setValue(m.propN.getPath());
		return m;
	},
	set : func(v) {
		me.propN.setDoubleValue(v);
	},
	get : func {
		me.propN.getValue();
	},
};


# class that maintains one scenery object (see src/Model/modelmgr.cxx)
#
var Model = {
	new : func(path, pos, data = nil) {
		var m = { parents: [Model] };
		m.pos = pos;
		m.path = path;
		m.selected = 1;
		m.visible = 1;
		m.flash_until = 0;
		m.loopid = 0;
		m.elapsedN = props.globals.getNode("/sim/time/elapsed-sec", 1);

		var models = props.globals.getNode("/models", 1);
		for (var i = 0; 1; i += 1) {
			if (models.getChild("model", i, 0) == nil) {
				m.node = models.getChild("model", i, 1);
				break;
			}
		}

		m.node.getNode("legend", 1).setValue("");
		if (isa(data, props.Node)) {
			props.copy(data, m.node);		# import node
		}
		var hdg = init_prop(m.node.getNode("heading-deg", 1), 0);
		var pitch = init_prop(m.node.getNode("pitch-deg", 1), 0);
		var roll = init_prop(m.node.getNode("roll-deg", 1), 0);

		m.node.getNode("path", 1).setValue(path);
		m.lon = ModelValue.new(m.node, "longitude-deg", pos.lon());
		m.lat = ModelValue.new(m.node, "latitude-deg", pos.lat());
		m.alt = ModelValue.new(m.node, "elevation-ft", pos.alt() * M2FT);
		m.hdg = ModelValue.new(m.node, "heading-deg", hdg);
		m.pitch = ModelValue.new(m.node, "pitch-deg", pitch);
		m.roll = ModelValue.new(m.node, "roll-deg", roll);

		m.node.getNode("load", 1).setValue(1);
		m.node.removeChildren("load");
		return m;
	},
	remove : func {
		props.globals.getNode("/models", 1).removeChild("model", me.node.getIndex());
	},
	clone : func(path) {
		Model.new(path, me.pos, me.node);
	},
	move : func(pos) {
		var v = me.visible;
		me.unhide();
		me.pos.set(pos);
		me.lon.set(me.pos.lon());
		me.lat.set(me.pos.lat());
		me.alt.set(me.pos.alt() * M2FT);
		v or me.hide();
	},
	raise : func (dist) {
		var v = me.visible;
		me.unhide();
		me.pos.set_alt(me.pos.alt() + dist);
		me.alt.set(me.pos.alt() * M2FT);
		v or me.hide();
	},
	apply_course_distance : func(course, dist) {
		me.pos.apply_course_distance(course, dist);
		me.lon.set(me.pos.lon());
		me.lat.set(me.pos.lat());
	},
	direct_distance_to : func(dest) {
		me.pos.direct_distance_to(dest);
	},
	flash : func(v) {
		me.loopid += 1;
		if (v) {
			me.flash_until = me.elapsedN.getValue() + 2;
			me._flash_(me.loopid);
		} else {
			me.unhide();
		}
	},
	_flash_ : func(id) {
		id == me.loopid or return;
		if (me.elapsedN.getValue() > me.flash_until) {
			return me.unhide();
		} elsif (clock) {
			me.hide();
		} else {
			me.unhide();
		}
		settimer(func { me._flash_(id) }, 0);
	},
	hide : func {
		me.visible or return;
		me.alt.set(me.alt.get() - ERAD);
		me.visible = 0;
	},
	unhide : func {
		me.visible and return;
		me.alt.set(me.alt.get() + ERAD);
		me.visible = 1;
	},
	get_data : func {
		var n = props.Node.new();
		props.copy(me.node, n);
		me.add_derived_data(n);
		return n;
	},
	add_derived_data : func(node) {
		node.removeChildren("longitude-deg-prop");
		node.removeChildren("latitude-deg-prop");
		node.removeChildren("elevation-ft-prop");
		node.removeChildren("heading-deg-prop");
		node.removeChildren("pitch-deg-prop");
		node.removeChildren("roll-deg-prop");

		var path = node.getNode("path").getValue();
		var lon = node.getNode("longitude-deg").getValue();
		var lat = node.getNode("latitude-deg").getValue();
		var elev = node.getNode("elevation-ft").getValue();
		var hdg = node.getNode("heading-deg").getValue();
		var legend = node.getNode("legend").getValue();
		var type = nil;
		var spec = "";

		if (path == "Aircraft/ufo/Models/sign.ac") {
			type = "OBJECT_SIGN";
			if (legend == "") {
				legend = "{@size=10,@material=RedSign}NO_CONTENTS_" ~ int(10000 * rand());
			}
			foreach (var c; split('', legend)) {
				if (c != ' ') {
					spec ~= c;
				}
			}
		} else {
			type = "OBJECT_SHARED";
			spec = path;
		}

		var elev_m = elev * FT2M;
		var stg_hdg = normdeg(360 - hdg);
		var stg_path = tile_path(lon, lat);
		var abs_path = getprop("/sim/fg-root") ~ "/" ~ path;
		var obj_line = sprintf("%s %s %.8f %.8f %.4f %.1f", type, spec, lon, lat, elev_m, stg_hdg);

		node.getNode("absolute-path", 1).setValue(abs_path);
		node.getNode("legend", 1).setValue(legend);
		node.getNode("stg-path", 1).setValue(stg_path);
		node.getNode("stg-heading-deg", 1).setDoubleValue(stg_hdg);
		node.getNode("elevation-m", 1).setDoubleValue(elev_m);
		node.getNode("object-line", 1).setValue(obj_line);
		return node;
	},
};


var ModelMgr = {
	new : func(path) {
		var m = { parents: [ModelMgr] };
		m.active = nil;
		m.models = [];
		m.legendN = props.globals.getNode("/sim/gui/dialogs/ufo-status/input", 1);
		m.legendN.setValue("");
		m.mouse_coord = ufo_position();
		m.import();
		m.cursor = Model.new("Aircraft/ufo/Models/marker.ac", Coord.new().set_xyz(0, 0, 0));
		m.cursor.hide();
		m.modelpath = path;

		if (path != "Aircraft/ufo/Models/cursor.ac") {
			status_dialog.open();
		}
		return m;
	},
	click : func(mouse_coord) {
		me.mouse_coord = mouse_coord;
		status_dialog.open();
		adjust_dialog.center_sliders();

		if (KbdAlt.getBoolValue()) {	# move active object here (and other selected ones along with it)
			(me.active == nil) and return;
			var course = me.active.pos.course_to(me.mouse_coord);
			var distance = me.active.pos.distance_to(me.mouse_coord);
			foreach (var m; me.models) {
				m.pos.set_alt(me.mouse_coord.alt());
				m.selected and m.apply_course_distance(course, distance);
			}
			me.cursor.move(me.active.pos);
			return;
		}

		if (!KbdShift.getBoolValue()) {
			me.deselect_all();
		}

		if (KbdCtrl.getBoolValue()) {	# select existing object
			me.select();
		} else {			# add one new object
			me.active = Model.new(me.modelpath, mouse_coord, me.sticky_data());
			append(me.models, me.active);
			me.display_status(me.modelpath);
			me.cursor.move(me.active.pos);

			if (KbdShift.getBoolValue()) {
				foreach (var m; me.models) {
					m.flash(m.selected);
				}
			}
		}
	},
	select : func() {
		if (!size(me.models)) {
			me.active = nil;
			me.cursor.move(Coord.new().set_xyz(0, 0, 0));
			return;
		}
		var min_dist = 10 * ERAD;

		forindex (var i; me.models) {
			var dist = me.models[i].direct_distance_to(me.mouse_coord);
			if (dist < min_dist) {
				min_dist = dist;
				me.active = me.models[i];
			}
		}
		me.active.selected = 1;
		me.cursor.move(me.active.pos);
		foreach (var m; me.models) {
			m.flash(m.selected);
		}
		me.display_status(me.modelpath = me.active.path);
	},
	deselect_all : func {
		foreach (var m; me.models) {
			m.flash(m.selected = 0);
		}
	},
	remove_selected : func {
		var models = [];
		foreach (var m; me.models) {
			if (m.selected) {
				m.remove();
			} else {
				append(models, m);
			}
		}
		me.models = models;
		me.select();
		me.display_status(me.modelpath);
	},
	set_modelpath : func(path) {
		me.modelpath = path;
		me.display_status(path);
	},
	update_legend : func {
		if (me.active != nil) {
			me.active.node.getNode("legend", 1).setValue(me.legendN.getValue());
		}
	},
	display_status : func(path) {
		var legend = me.active == nil ? "" : me.active.node.getNode("legend", 1).getValue();
		me.legendN.setValue(legend);
		setprop("/sim/model/ufo/status", "(" ~ size(me.models) ~ ")  " ~ path);
	},
	get_data : func {
		var n = props.Node.new();
		forindex (var i; me.models) {
			props.copy(me.models[i].get_data(), n.getChild("model", i, 1));
		}
		return n;
	},
	cycle : func(up) {
		var i = search(modellist, me.modelpath) + up;
		if (i < 0) {
			i = size(modellist) - 1;
		} elsif (i >= size(modellist)) {
			i = 0;
		}
		me.set_modelpath(modellist[i]);

		var models = [];
		foreach (var m; me.models) {
			if (m.selected) {
				append(models, m.clone(modellist[i]));
				m.remove();
			} else {
				append(models, m);
			}
		}
		me.models = models;
	},
	sticky_data : func {
		var n = props.Node.new();
		if (me.active == nil) {
			return n;
		}
		var hdg = n.getNode("heading-deg", 1);
		var pitch = n.getNode("pitch-deg", 1);
		var roll = n.getNode("roll-deg", 1);
		if (getprop("/models/adjust/sticky-heading")) {
			hdg.setDoubleValue(me.active.node.getNode("heading-deg").getValue());
		} else {
			hdg.setDoubleValue(0);
		}
		if (getprop("/models/adjust/sticky-orientation")) {
			pitch.setDoubleValue(me.active.node.getNode("pitch-deg").getValue());
			roll.setDoubleValue(me.active.node.getNode("roll-deg").getValue());
		} else {
			pitch.setDoubleValue(0);
			roll.setDoubleValue(0);
		}
		return n;
	},
	reset_heading : func {
		foreach (var m; me.models) {
			if (m.selected) {
				m.hdg.set(0);
			}
		}
	},
	reset_orientation : func {
		foreach (var m; me.models) {
			if (m.selected) {
				m.pitch.set(0);
				m.roll.set(0);
			}
		}
	},
	import : func {
		me.active = nil;
		var mandatory = ["path", "longitude-deg", "latitude-deg", "elevation-ft"];
		foreach (var m; props.globals.getNode("models", 1).getChildren("model")) {
			var ok = 1;
			foreach (var a; mandatory) {
				if (m.getNode(a) == nil or m.getNode(a).getType() == "NONE") {
					ok = 0;
				}
			}
			if (ok) {
				var tmp = props.Node.new({ legend:"", "heading-deg":0, "pitch-deg":0, "roll-deg":0 });
				props.copy(m, tmp);
				m.getParent().removeChild(m.getName(), m.getIndex());
				var c = Coord.new().set_lonlat(
						tmp.getNode("longitude-deg").getValue(),
						tmp.getNode("latitude-deg").getValue(),
						tmp.getNode("elevation-ft").getValue() * FT2M);
				append(me.models, me.active = Model.new(tmp.getNode("path").getValue(), c, tmp));
			}
		}
	},
	adjust : func(name, value, scale = 0) {
		if (!size(me.models) or me.active == nil) {
			return;
		}
		var ufo = ufo_position();
		var dist = scale ? ufo.distance_to(me.active.pos) * 0.05 : 1;
		if (name == "longitudinal") {
			var dir = ufo.course_to(me.active.pos);
			foreach (var m; me.models) {
				m.selected and m.apply_course_distance(dir, value * dist);
			}
		} elsif (name == "transversal") {
			var dir = ufo.course_to(me.active.pos) + 90;
			foreach (var m; me.models) {
				m.selected and m.apply_course_distance(dir, value * dist);
			}
		} elsif (name == "altitude") {
			foreach (var m; me.models) {
				m.selected and m.raise(value * dist * 0.4);
			}
		} elsif (name == "heading") {
			foreach (var m; me.models) {
				m.selected and m.hdg.set(m.hdg.get() + value * 4);
			}
		} elsif (name == "pitch") {
			foreach (var m; me.models) {
				m.selected and m.pitch.set(m.pitch.get() + value * 6);
			}
		} elsif (name == "roll") {
			foreach (var m; me.models) {
				m.selected and m.roll.set(m.roll.get() + value * 6);
			}
		}
		me.cursor.move(me.active.pos);
	},
	toggle_cursor : func {
		me.cursor.visible ? me.cursor.hide() : me.cursor.unhide();
	},
};



var scan_dirs = func(csv) {
	var list = ["Aircraft/ufo/Models/sign.ac"];
	foreach(var dir; split(",", csv)) {
		foreach(var m; scan_models(dir)) {
			append(list, m);
		}
	}
	return sort(list);
}



var print_ufo_data = func {
	print("\n\n------------------------------ UFO -------------------------------\n");

	var lon = getprop("/position/longitude-deg");
	var lat = getprop("/position/latitude-deg");
	var alt_ft = getprop("/position/altitude-ft");
	var elev_m = getprop("/position/ground-elev-m");
	var heading = getprop("/orientation/heading-deg");
	var agl_ft = alt_ft - elev_m * M2FT;

	printf("Longitude:    %.8f deg", lon);
	printf("Latitude:     %.8f deg", lat);
	printf("Altitude ASL: %.4f m (%.4f ft)", alt_ft * FT2M, alt_ft);
	printf("Altitude AGL: %.4f m (%.4f ft)", agl_ft * FT2M, agl_ft);
	printf("Heading:      %.1f deg", normdeg(heading));
	printf("Ground Elev:  %.4f m (%.4f ft)", elev_m, elev_m * M2FT);
	print();
	print("# " ~ tile_path(lon, lat));
	printf("OBJECT_STATIC %.8f %.8f %.4f %.1f", lon, lat, elev_m, normdeg(360 - heading));
	print();

	var hdg = normdeg(heading + getprop("/sim/current-view/goal-pitch-offset-deg"));
	var fgfs = sprintf("$ fgfs --aircraft=ufo --lon=%.6f --lat=%.6f --altitude=%.2f --heading=%.1f",
			lon, lat, agl_ft, hdg);
	print(fgfs);
}


var print_model_data = func(prop) {
	print("\n\n------------------------ Selected Object -------------------------\n");
	var elev = prop.getNode("elevation-ft").getValue();
	printf("Path:         %s", prop.getNode("path").getValue());
	printf("Longitude:    %.8f deg", prop.getNode("longitude-deg").getValue());
	printf("Latitude:     %.8f deg", prop.getNode("latitude-deg").getValue());
	printf("Altitude ASL: %.4f m (%.4f ft)", elev * FT2M, elev);
	printf("Heading:      %.1f deg", prop.getNode("heading-deg").getValue());
	printf("Pitch:        %.1f deg", prop.getNode("pitch-deg").getValue());
	printf("Roll:         %.1f deg", prop.getNode("roll-deg").getValue());
}





# interface functions -----------------------------------------------------------------------------

var print_data = func {
	var rule = "\n------------------------------------------------------------------\n";
	print("\n\n");
	print_ufo_data();

	var data = modelmgr.get_data();

	var selected = data.getChild("model", 0);
	if (selected == nil) {
		print(rule);
		return;
	}

	print_model_data(selected);
	print(rule);

	# group all objects of a bucket
	var bucket = {};
	foreach (var m; data.getChildren("model")) {
		var stg = m.getNode("stg-path").getValue();
		var obj = m.getNode("object-line").getValue();
		if (contains(bucket, stg)) {
			append(bucket[stg], obj);
		} else {
			bucket[stg] = [obj];
		}
	}
	foreach (var key; keys(bucket)) {
		print("\n# ", key);
		foreach (var obj; bucket[key]) {
			print(obj);
		}
	}
	print(rule);
}


var export_data = func {
	savexml = func(name, node) {
		fgcommand("savexml", props.Node.new({ "filename": name, "sourcenode": node }));
	}
	var tmp = "save-ufo-data";
	save = props.globals.getNode(tmp, 1);
	props.copy(modelmgr.get_data(), save.getNode("models", 1));
	var path = getprop("/sim/fg-home") ~ "/ufo-model-export.xml";
	savexml(path, save.getPath());
	print("model data exported to ", path);
	props.globals.removeChild(tmp);
}


# dialogs -----------------------------------------------------------------------------------------

var status_dialog = gui.Dialog.new("/sim/gui/dialogs/ufo/status/dialog", "Aircraft/ufo/Dialogs/status.xml");
var select_dialog = gui.Dialog.new("/sim/gui/dialogs/ufo/select/dialog", "Aircraft/ufo/Dialogs/select.xml");
var adjust_dialog = gui.Dialog.new("/sim/gui/dialogs/ufo/adjust/dialog", "Aircraft/ufo/Dialogs/adjust.xml");

adjust_dialog.center_sliders = func {
	var ns = adjust_dialog.namespace();
	if (ns != nil) {
		ns.center();
	}
}


# hide status line in screenshots
#
var status_restore = nil;
setlistener("/sim/signals/screenshot", func {
	if (cmdarg().getBoolValue()) {
		status_restore = status_dialog.is_open();
		status_dialog.close();
	} else {
		status_restore and status_dialog.open();
	}
});



# init --------------------------------------------------------------------------------------------

var KbdShift = props.globals.getNode("/devices/status/keyboard/shift");
var KbdCtrl = props.globals.getNode("/devices/status/keyboard/ctrl");
var KbdAlt = props.globals.getNode("/devices/status/keyboard/alt");

var click_lon = props.globals.getNode("/sim/input/click/longitude-deg", 1);
var click_lat = props.globals.getNode("/sim/input/click/latitude-deg", 1);
var click_elev = props.globals.getNode("/sim/input/click/elevation-m", 1);

var modellist = scan_dirs(getprop("/source"));
var modelmgr = ModelMgr.new(getprop("/cursor"));

setlistener("/sim/signals/click", func {
	var lon = click_lon.getValue();
	var lat = click_lat.getValue();
	var elev = click_elev.getValue();
	modelmgr.click(Coord.new().set_lonlat(lon, lat, elev));
});


