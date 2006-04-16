
# maximum speed -----------------------------------------------------------------------------------


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
	gui.popupTip("Max. Speed " ~ s ~ " m/s");
}





# library stuff -----------------------------------------------------------------------------------

var ERAD = 6378138.12;		# Earth radius
var D2R = math.pi / 180;
var R2D = 180 / math.pi;


ft2m = func { arg[0] * 0.3048 }
m2ft = func { arg[0] / 0.3048 }
floor = func(v) { v < 0.0 ? -int(-v) - 1 : int(v) }
ceil = func(v) { -floor(-v) }
pow = func(v, w) { math.exp(math.ln(v) * w) }
printf = func(_...) { print(call(sprintf, _)) }



# convert [lon, lat] to [x, y, z]
#
lonlat2xyz = func(lonlat) {
	var lonr = lonlat[0] * D2R;
	var latr = lonlat[1] * D2R;
	var cosphi = math.cos(latr);
	var x = cosphi * math.cos(lonr);
	var y = cosphi * math.sin(lonr);
	var z = math.sin(latr);
	return [x, y, z];
}


# convert [x, y, z] to [lon, lat]
#
xyz2lonlat = func(xyz) {
	var x = xyz[0];
	var y = xyz[1];
	var z = xyz[2];
	var lat = math.atan2(z, math.sqrt(x * x + y * y)) * R2D;
	var lon = math.atan2(y, x) * R2D;
	return [lon, lat];
}


# return squared distance between two [x, y, z]
#
coord_dist_sq = func(xyz0, xyz1) {
	var x = xyz0[0] - xyz1[0];
	var y = xyz0[1] - xyz1[1];
	var z = xyz0[2] - xyz1[2];
	return x * x + y * y + z * z;
}


# sort vector of strings (bubblesort)
#
sort = func(l) {
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
search = func(list, which) {
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
scan_models = func(base) {
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
		delete(ac, var x = substr(m, 0, size(m) - 3) ~ "ac");
	}
	foreach (var m; keys(ac)) {
		append(result, m);
	}
	return result;
}


# normalize degree to 0 <= angle < 360
#
normdeg = func(angle) {
	while (angle < 0) {
		angle += 360;
	}
	while (angle >= 360) {
		angle -= 360;
	}
	angle;
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


format = func(lon, lat) {
	sprintf("%s%03d%s%02d", lon < 0 ? "w" : "e", abs(lon), lat < 0 ? "s" : "n", abs(lat));
}


tile_path = func(lon, lat) {
	var p = format(floor(lon / 10.0) * 10, floor(lat / 10.0) * 10);
	p ~= "/" ~ format(floor(lon), floor(lat));
	p ~= "/" ~ tile_index(lon, lat) ~ ".stg";
}







# cursor ------------------------------------------------------------------------------------------



## manages one adjustable value for the Adjust class
#  (applies slider offsets etc.)
#
Value = {
	new : func(baseN, name, init) {
		var m = { parents: [Value] };
		m.lastOffs = 0;
		m.init = init;

		# offset node; fed by the dialog slider
		m.inOffsN = baseN.getNode("offsets/" ~ name, 1);
		m.inOffsN.setValue(m.lastOffs);

		# live number property
		m.outN = baseN.getNode("adjust/" ~ name, 1);
		m.outN.setDoubleValue(init);

		m.listener = setlistener(m.inOffsN, func { m.update() });
		return m;
	},
	del : func {
		removelistener(me.listener);
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


## manages a set of adjustable values and is the entry point for data into
#  the dynamic model
#
Adjust = {
	new : func(prop) {
		var m = { parents: [Adjust] };
		m.node = props.globals.getNode(prop, 1);
		m.val = {
			lon:   Value.new(m.node, "longitude-deg", 0),
			lat:   Value.new(m.node, "latitude-deg", 0),
			elev:  Value.new(m.node, "elevation-ft", -10000),

			hdg:   Value.new(m.node, "heading-deg", 0),
			pitch: Value.new(m.node, "pitch-deg", 0),
			roll:  Value.new(m.node, "roll-deg", 0),
		};
		m.stk_hdgN = m.node.getNode("sticky-heading", 1);
		m.stk_orientN = m.node.getNode("sticky-orientation", 1);
		m.stk_hdgN.setBoolValue(0);
		m.stk_orientN.setBoolValue(0);
		m.legendN = m.node.getNode("legend", 1);
		return m;
	},
	del : func {
		foreach (var v; keys(me.val)) {
			me.val[v].del();
		}
	},
	offsetNode : func(which) {
		me.val[which].inOffsN;
	},
	outNode : func(which) {
		me.val[which].outN;
	},
	get : func(which) {
		me.val[which].get();
	},
	set : func(which, value) {
		me.val[which].set(value);
	},
	setall : func(legend, lon, lat, elev, hdg = nil, pitch = nil, roll = nil) {
		me.legendN.setValue(legend);
		me.val["lon"].set(lon);
		me.val["lat"].set(lat);
		me.val["elev"].set(elev);
		if (hdg != nil) {
			me.val["hdg"].set(hdg);
		} elsif (!me.stk_hdgN.getBoolValue()) {
			me.val["hdg"].reset();
		}
		if (pitch != nil) {
			me.val["pitch"].set(pitch);
		} elsif (!me.stk_orientN.getBoolValue()) {
			me.val["pitch"].reset();
		}
		if (roll != nil) {
			me.val["roll"].set(roll);
		} elsif (!me.stk_orientN.getBoolValue()) {
			me.val["roll"].reset();
		}
	},
	reset : func {
		foreach (var v; keys(me.val)) {
			me.val[v].reset();
		}
	},
	step : func(which, step) {
		me.val[which].add(step);
	},
	upright : func {
		me.val["pitch"].set(0);
		me.val["roll"].set(0);
	},
	orient : func {
		me.val["hdg"].set(0);
	},
	center_sliders : func {
		foreach (var v; keys(me.val)) {
			me.val[v].center();
		}
	},
};


## base class for the dynamic and static models
#
Model = {
	# searches first free slot and sets path
	new : func(path) {
		var m = { parents: [Model] };
		var models = props.globals.getNode("/models", 1);

		for (var i = 0; 42; i += 1) {
			if (models.getChild("model", i, 0) == nil) {
				m.node = models.getChild("model", i, 1);
				break;
			}
		}
		m.path = path;
		m.node.getNode("path", 1).setValue(m.path);
		m.legend = nil;
		return m;
	},
	# signal modelmgr.cxx to load model
	load : func {
		me.node.getNode("load", 1).setValue(1);
		me.node.removeChildren("load");
	},
	add_derived_props : func(node) {
		var path = node.getNode("path").getValue();
		var lon = node.getNode("longitude-deg").getValue();
		var lat = node.getNode("latitude-deg").getValue();
		var elev = node.getNode("elevation-ft").getValue();
		var hdg = node.getNode("heading-deg").getValue();
		var type = nil;
		var spec = "";

		if (path == "Aircraft/ufo/Models/sign.ac") {
			type = "OBJECT_SIGN";
			var legend = me.legend != "" ? me.legend :
					"{@size=10,@material=RedSign}NO_CONTENTS_" ~ int(10000 * rand());
			foreach (var c; split('', legend)) {
				if (c != ' ') {
					spec ~= c;
				}
			}
		} else {
			type = "OBJECT_SHARED";
			spec = path;
		}

		var stg_hdg = normdeg(360 - hdg);
		var stg_path = tile_path(lon, lat);
		var abs_path = getprop("/sim/fg-root") ~ "/" ~ path;
		var obj_line = sprintf("%s %s %.8f %.8f %.4f %.1f", type, spec, lon, lat,
				ft2m(elev), stg_hdg);

		node.getNode("absolute-path", 1).setValue(abs_path);
		node.getNode("legend", 1).setValue(me.legend);
		node.getNode("stg-path", 1).setValue(stg_path);
		node.getNode("stg-heading-deg", 1).setDoubleValue(stg_hdg);
		node.getNode("object-line", 1).setValue(obj_line)
	}
};


## class for static models (see $FG_ROOT/Docs/README.scenery)
#
Static = {
	new : func(path, legend, lon, lat, elev, hdg, pitch, roll) {
		var m = Model.new(path);
		m.parents = [Static, Model];

		m.node.getNode("longitude-deg", 1).setDoubleValue(m.lon = lon);
		m.node.getNode("latitude-deg", 1).setDoubleValue(m.lat = lat);
		m.node.getNode("elevation-ft", 1).setDoubleValue(m.elev = elev);
		m.node.getNode("heading-deg", 1).setDoubleValue(m.hdg = hdg);
		m.node.getNode("pitch-deg", 1).setDoubleValue(m.pitch = pitch);
		m.node.getNode("roll-deg", 1).setDoubleValue(m.roll = roll);
		m.legend = legend;
		m.load();
		return m;
	},
	del : func {
		var parent = me.node.getParent();
		if (parent != nil) {
			parent.removeChild(me.node.getName(), me.node.getIndex());
		}
	},
	distance_from : func(xyz) {
		return coord_dist_sq(xyz, lonlat2xyz([me.lon, me.lat]));
	},
	get_data : func {
		var n = props.Node.new();
		props.copy(me.node, n);
		me.add_derived_props(n);
		return n;
	},
};


## class for dynamic models. Only one object is dynamic at a time -- the selected object.
#
Dynamic = {
	new : func(path, legend, lon, lat, elev, hdg = nil, pitch = nil, roll = nil) {
		var m = Model.new(path);
		m.parents = [Dynamic, Model];

		adjust.setall(legend, lon, lat, elev, hdg, pitch, roll);
		m.node.getNode("longitude-deg-prop", 1).setValue(adjust.outNode("lon").getPath());
		m.node.getNode("latitude-deg-prop", 1).setValue(adjust.outNode("lat").getPath());
		m.node.getNode("elevation-ft-prop", 1).setValue(adjust.outNode("elev").getPath());
		m.node.getNode("heading-deg-prop", 1).setValue(adjust.outNode("hdg").getPath());
		m.node.getNode("pitch-deg-prop", 1).setValue(adjust.outNode("pitch").getPath());
		m.node.getNode("roll-deg-prop", 1).setValue(adjust.outNode("roll").getPath());
		m.load();
		m.flash_count = 0;
		m.visible = 1;
		return m;
	},
	del : func {
		me.flash(0);
		var parent = me.node.getParent();
		if (parent != nil) {
			parent.removeChild(me.node.getName(), me.node.getIndex());
		}
	},
	make_static : func {
		me.del();
		return Static.new(me.path, adjust.legendN.getValue(),
				adjust.get("lon"), adjust.get("lat"), adjust.get("elev"),
				adjust.get("hdg"), adjust.get("pitch"), adjust.get("roll"));
	},
	distance_from : func(xyz) {
		var lon = adjust.get("lon");
		var lat = adjust.get("lat");
		return coord_dist_sq(xyz, lonlat2xyz([lon, lat]));
	},
	get_data : func {
		me.flash(0);
		var n = props.Node.new();
		n.getNode("path", 1).setValue(me.path);
		props.copy(props.globals.getNode("/data/adjust"), n);
		me.legend = adjust.legendN.getValue();
		me.add_derived_props(n);
		return n;
	},
	flash : func(v) {
		me.flash_count = v;
		me._flash_();
	},
	_flash_ : func {
		if (!me.visible) {
			adjust.set("elev", adjust.get("elev") + 10000);
			me.visible = 1;
		} elsif (me.flash_count) {
			adjust.set("elev", adjust.get("elev") - 10000);
			me.visible = 0;
		}
		if (me.flash_count) {
			me.flash_count -= 1;
			settimer(func { me._flash_() }, 0.3);
		}
	},
};


Static.make_dynamic = func {
	me.del();
	return Dynamic.new(me.path, me.legend, me.lon, me.lat, me.elev, me.hdg, me.pitch, me.roll);
};


## manages one dynamic and several static objects
#
ModelMgr = {
	new : func(path) {
		var m = { parents: [ModelMgr] };

		var click = props.globals.getNode("/sim/input/click", 1);
		m.lonN = click.getNode("longitude-deg", 1);
		m.latN = click.getNode("latitude-deg", 1);
		m.elevN = click.getNode("elevation-ft", 1);

		m.lonN.setValue(0);
		m.latN.setValue(0);

		m.spacebarN = props.globals.getNode("/controls/engines/engine/starter", 1);
		m.modelpath = path;

		m.dynamic = nil;
		m.static = [];
		m.block = 0;
		m.import();
		return m;
	},
	click : func {
		if (me.block) {
			return;
		}
		if (me.spacebarN.getBoolValue()) {
			me.select();
		} else {
			me.add_instance();
		}
	},
	add_instance : func {
		if (me.dynamic != nil) {
			append(me.static, me.dynamic.make_static());
		}
		me.dynamic = Dynamic.new(me.modelpath, "", me.lonN.getValue(), me.latN.getValue(),
				me.elevN.getValue());
		me.display_status(me.modelpath);
	},
	select : func {
		var click_xyz = lonlat2xyz([me.lonN.getValue(), me.latN.getValue()]);
		var min_dist = me.dynamic != nil ? me.dynamic.distance_from(click_xyz) : 1000000;
		var nearest = nil;

		# find nearest static object
		forindex (var i; me.static) {
			var dist = me.static[i].distance_from(click_xyz);
			if (dist < min_dist) {
				min_dist = dist;
				nearest = i;
			}
		}
		if (nearest != nil) {
			# swap dynamic with nearest static
			if (me.dynamic != nil) {
				var st = me.dynamic.make_static();
				me.dynamic = me.static[nearest].make_dynamic();
				me.static[nearest] = st;
				# actively selected: use this model type
				me.modelpath = me.dynamic.path;
			} else {
				me.dynamic = me.static[nearest].make_dynamic();

				var left = subvec(me.static, 0, nearest);
				if (nearest + 1 < size(me.static)) {
					foreach (var v; subvec(me.static, nearest + 1)) {
						append(left, v);
					}
				}
				me.static = left;
			}
		}
		# last object removed?
		if (me.dynamic == nil) {
			adjust.legendN.setValue("");
		} else {
			me.dynamic.flash(6);
		}
		me.display_status(me.modelpath);
	},
	remove_selected : func {
		if (me.block) {
			return;
		}
		if (me.dynamic != nil) {
			me.dynamic.del();
			me.dynamic = nil;
		}
		me.select();
	},
	setmodelpath : func(path) {
		me.modelpath = path;
		me.display_status(path);
	},
	display_status : func(p) {
		var count = (me.dynamic != nil) + size(me.static);
		setprop("/sim/model/ufo/status", "(" ~ count ~ ")  " ~ p);
	},
	get_data : func {
		var n = props.Node.new();
		if (me.dynamic != nil) {
			props.copy(me.dynamic.get_data(), n.getChild("model", 0, 1));
		}
		forindex (var i; me.static) {
			props.copy(me.static[i].get_data(), n.getChild("model", i + 1, 1));
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
		me.setmodelpath(modellist[i]);
		if (me.dynamic != nil) {
			var st = me.dynamic.make_static();
			st.path = me.modelpath;
			me.dynamic.del();
			me.dynamic = st.make_dynamic();
		}
	},
	import : func {
		var models = props.globals.getNode("models", 1);
		var tmp = props.Node.new();
		props.copy(models, tmp);
		models.removeChildren("model");
		foreach (var m; tmp.getChildren("model")) {
			append(me.static, Static.new(m.getNode("path").getValue(),
					m.getNode("legend", 1).getValue(),
					m.getNode("longitude-deg", 1).getValue(),
					m.getNode("latitude-deg", 1).getValue(),
					m.getNode("elevation-ft", 1).getValue(),
					m.getNode("heading-deg", 1).getValue(),
					m.getNode("pitch-deg", 1).getValue(),
					m.getNode("roll-deg", 1).getValue()));
		}
		me.select();
	},
};



incElevator = controls.incElevator;
controls.incElevator = func(step, apstep) {
	if (getprop("/controls/engines/engine/starter")) {
		modelmgr.cycle(step > 0 ? 1 : -1);
	} else {
		incElevator(step, apstep);
	}
}



var lastXYZ = lonlat2xyz([getprop("/position/longitude-deg"), getprop("/position/latitude-deg")]);
var lastElev = 0;

printDistance = func {
	# print distance to last cursor coordinates (horizontal distance
	# doesn't consider elevation and is rather imprecise)
	var lon = getprop("/sim/input/click/longitude-deg");
	var lat = getprop("/sim/input/click/latitude-deg");
	var elev = getprop("/sim/input/click/elevation-ft");
	var newXYZ = lonlat2xyz([lon, lat]);
	var hdist = math.sqrt(coord_dist_sq(lastXYZ, newXYZ) * ERAD);
	var vdist = ft2m(elev - lastElev);
	var s = hdist < 4 ? sprintf("%.1f m HOR, %.1f m VERT", hdist * 1000, vdist)
			: sprintf("%.1f km HOR, %.1f m VERT", hdist, vdist);
	screen.log.write(s);

	lastXYZ = newXYZ;
	lastElev = elev;
}



scanDirs = func(csv) {
	var list = [];
	foreach(var dir; split(",", csv)) {
		foreach(var m; scan_models(dir)) {
			append(list, m);
		}
	}
	append(list, "Aircraft/ufo/Models/sign.ac");
	return sort(list);
}



printUFOData = func {
	print("\n\n------------------------------ UFO -------------------------------\n");

	var lon = getprop("/position/longitude-deg");
	var lat = getprop("/position/latitude-deg");
	var alt_ft = getprop("/position/altitude-ft");
	var elev_m = getprop("/position/ground-elev-m");
	var heading = getprop("/orientation/heading-deg");
	var agl_ft = alt_ft - m2ft(elev_m);

	printf("Longitude:    %.8f deg", lon);
	printf("Latitude:     %.8f deg", lat);
	printf("Altitude ASL: %.4f m (%.4f ft)", ft2m(alt_ft), alt_ft);
	printf("Altitude AGL: %.4f m (%.4f ft)", ft2m(agl_ft), agl_ft);
	printf("Heading:      %.1f deg", normdeg(heading));
	printf("Ground Elev:  %.4f m (%.4f ft)", elev_m, m2ft(elev_m));
	print();
	print("# " ~ tile_path(lon, lat));
	printf("OBJECT_STATIC %.8f %.8f %.4f %.1f", lon, lat, elev_m, normdeg(360 - heading));
	print();

	var hdg = normdeg(heading + getprop("/sim/current-view/goal-pitch-offset-deg"));
	var fgfs = sprintf("$ fgfs --aircraft=ufo --lon=%.6f --lat=%.6f --altitude=%.2f --heading=%.1f",
			lon, lat, agl_ft, hdg);
	print(fgfs);
}


printModelData = func(prop) {
	print("\n\n------------------------ Selected Object -------------------------\n");
	var elev = prop.getNode("elevation-ft").getValue();
	printf("Path:         %s", prop.getNode("path").getValue());
	printf("Longitude:    %.8f deg", prop.getNode("longitude-deg").getValue());
	printf("Latitude:     %.8f deg", prop.getNode("latitude-deg").getValue());
	printf("Altitude ASL: %.4f m (%.4f ft)", ft2m(elev), elev);
	printf("Heading:      %.1f deg", prop.getNode("heading-deg").getValue());
	printf("Pitch:        %.1f deg", prop.getNode("pitch-deg").getValue());
	printf("Roll:         %.1f deg", prop.getNode("roll-deg").getValue());
}





# interface functions -----------------------------------------------------------------------------

printData = func {
	var rule = "\n------------------------------------------------------------------\n";
	print("\n\n");
	printUFOData();

	var data = modelmgr.get_data();

	var selected = data.getChild("model", 0);
	if (selected == nil) {
		print(rule);
		return;
	}

	printModelData(selected);
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


exportData = func {
	savexml = func(name, node) {
		fgcommand("savexml", props.Node.new({"filename": name, "sourcenode": node}));
	}
	var tmp = "save-ufo-data";
	save = props.globals.getNode(tmp, 1);
	props.copy(modelmgr.get_data(), save.getNode("models", 1));
	var path = getprop("/sim/fg-home") ~ "/ufo-model-export.xml";
	savexml(path, save.getPath());
	print("model data exported to ", path);
	props.globals.removeChild(tmp);
}


removeSelectedModel = func { modelmgr.remove_selected() }





# init --------------------------------------------------------------------------------------------

var modellist = nil;
var adjust = nil;
var modelmgr = nil;


settimer(func {
	modellist = scanDirs(getprop("/source"));
	adjust = Adjust.new("/data");
	modelmgr = ModelMgr.new(getprop("/cursor"));
	setlistener("/sim/signals/click", func { modelmgr.click() });
	#setlistener("/sim/signals/click", printDistance);
	showStatusDialog();
}, 1);





# dialogs -----------------------------------------------------------------------------------------


var dialog = {};

showModelSelectDialog = func {
	name = "ufo-model-select-dialog";

	if (contains(dialog, name)) {
		closeModelSelectDialog();
		return;
	}

	var title = 'Select Model';

	dialog[name] = gui.Widget.new();
	dialog[name].set("layout", "vbox");
	dialog[name].set("name", name);
	dialog[name].set("x", -20);
	dialog[name].set("pref-width", 600);

	# "window" titlebar
	titlebar = dialog[name].addChild("group");
	titlebar.set("layout", "hbox");
	titlebar.addChild("empty").set("stretch", 1);
	titlebar.addChild("text").set("label", title);
	titlebar.addChild("empty").set("stretch", 1);

	dialog[name].addChild("hrule").addChild("dummy");

	w = titlebar.addChild("button");
	w.set("pref-width", 16);
	w.set("pref-height", 16);
	w.set("legend", "");
	w.set("default", 1);
	w.set("keynum", 27);
	w.set("border", 1);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("ufo.closeModelSelectDialog()");

	w = dialog[name].addChild("list");
	w.set("halign", "fill");
	w.set("pref-height", 300);
	w.set("property", "/cursor");
	forindex (var i; modellist) {
		w.prop().getChild("value", i, 1).setValue(modellist[i]);
	}
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
	w.prop().getNode("binding[1]/command", 1).setValue("nasal");
	w.prop().getNode("binding[1]/script", 1).setValue("ufo.modelmgr.setmodelpath(getprop('/cursor'))");

	fgcommand("dialog-new", dialog[name].prop());
	gui.showDialog(name);
}


closeModelSelectDialog = func {
	var name = "ufo-model-select-dialog";
	var dlg = props.Node.new({"dialog-name": name});
	fgcommand("dialog-apply", dlg);
	fgcommand("dialog-close", dlg);
	delete(dialog, name);
}


showModelAdjustDialog = func {
	name = "ufo-cursor-dialog";

	if (contains(dialog, name)) {
		fgcommand("dialog-close", props.Node.new({ "dialog-name" : name }));
		delete(dialog, name);
		return;
	}

	adjust.center_sliders();

	dialog[name] = gui.Widget.new();
	dialog[name].set("layout", "vbox");
	dialog[name].set("name", name);
	dialog[name].set("x", -20);
	dialog[name].set("y", -20);

	# "window" titlebar
	titlebar = dialog[name].addChild("group");
	titlebar.set("layout", "hbox");
	titlebar.addChild("empty").set("stretch", 1);
	titlebar.addChild("text").set("label", "Adjust Model");
	titlebar.addChild("empty").set("stretch", 1);

	dialog[name].addChild("hrule").addChild("dummy");

	w = titlebar.addChild("button");
	w.set("pref-width", 16);
	w.set("pref-height", 16);
	w.set("legend", "");
	w.set("default", 1);
	w.set("keynum", 27);
	w.set("border", 1);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("delete(ufo.dialog, \"" ~ name ~ "\")");
	w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

	slider = func(legend, col, coarse, fine) {
		group = dialog[name].addChild("group");
		group.set("layout", "hbox");
		group.set("default-padding", 0);

		button = func(leg, step) {
			b = group.addChild("button");
			b.set("legend", leg);
			b.set("pref-width", 22);
			b.set("pref-height", 22);
			b.set("live", 1);
			b.prop().getNode("binding[0]/command", 1).setValue("nasal");
			b.prop().getNode("binding[0]/script", 1).setValue('ufo.adjust.step("'~legend~'", '~step~')');
			return b;
		}

		cl = button("<<", -coarse);
		fl = button("<", -fine);

		s = group.addChild("slider");
		s.set("property", adjust.offsetNode(legend).getPath());
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

	slider("lon", [1.0, 0.6, 0.6], 0.0002, 0.00002);
	slider("lat", [0.6, 1.0, 0.6], 0.0002, 0.00002);
	slider("elev", [0.6, 0.6, 1.0], 10, 2);

	slider("hdg", [1.0, 1.0, 0.6], 36, 6);
	slider("pitch", [1.0, 0.6, 1.0], 36, 6);
	slider("roll", [0.6, 1.0, 1.0], 36, 6);


	g = dialog[name].addChild("group");
	g.set("layout", "hbox");

	w = g.addChild("text");
	w.set("halign", "left");
	w.set("label", "Heading    ");

	w = g.addChild("text");
	w.set("halign", "center");
	w.set("label", "Sliders");

	w = g.addChild("text");
	w.set("halign", "right");
	w.set("label", "Orientation");


	g = dialog[name].addChild("group");
	g.set("layout", "hbox");
	g.set("default-padding", 2);
	var wide = 60;
	var narrow = 55;

	w = g.addChild("button");
	w.set("halign", "right");
	w.set("legend", "Reset");
	w.set("pref-height", 22);
	w.set("pref-width", wide);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("ufo.adjust.orient()");

	w = g.addChild("button");
	w.set("legend", "Sticky");
	w.set("one-shot", 0);
	w.set("pref-height", 22);
	w.set("pref-width", narrow);
	w.set("live", 1);
	w.set("property", adjust.stk_hdgN.getPath());
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	g.addChild("empty").set("stretch", 1);

	w = g.addChild("button");
	w.set("halign", "center");
	w.set("legend", "Center");
	w.set("pref-height", 22);
	w.set("pref-width", wide);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("ufo.adjust.center_sliders()");

	g.addChild("empty").set("stretch", 1);

	w = g.addChild("button");
	w.set("legend", "Sticky");
	w.set("one-shot", 0);
	w.set("pref-height", 22);
	w.set("pref-width", narrow);
	w.set("live", 1);
	w.set("property", adjust.stk_orientN.getPath());
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	w = g.addChild("button");
	w.set("halign", "left");
	w.set("legend", "Reset");
	w.set("pref-height", 22);
	w.set("pref-width", wide);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("ufo.adjust.upright()");

	fgcommand("dialog-new", dialog[name].prop());
	gui.showDialog(name);
}


showStatusDialog = func {
	name = "ufo-status-dialog";

	if (contains(dialog, name)) {
		closeModelSelectDialog();
		return;
	}

	dialog[name] = gui.Widget.new();
	dialog[name].set("layout", "vbox");
	dialog[name].set("name", name);
	dialog[name].set("x", 8);
	dialog[name].set("y", 8);
	dialog[name].set("pref-width", 300);
	dialog[name].set("default-padding", 0);
	dialog[name].setColor(0, 0, 0, 0);
	dialog[name].setFont("HELVETICA_12");

	# legend input field
	w = dialog[name].addChild("input");
	w.set("halign", "left");
	w.set("pref-width", 300);
	w.set("live", 1);
	w.set("property", adjust.legendN.getPath());
	w.setColor(0, 0, 0, 0);
	w.prop().setValues({"color-legend": {red:1, green:1, blue:1, alpha:1}});
	w.prop().setValues({"color-background": {red:0, green:0, blue:0, alpha:0}});
	w.prop().setValues({"color-highlight": {red:0, green:0, blue:0, alpha:0}});
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	# current object
	g = dialog[name].addChild("group");
	g.set("layout", "vbox");
	g.set("default-padding", 2);
	w = g.addChild("text");
	w.set("pref-width", 0);
	w.set("halign", "left");
	w.set("property", "/sim/model/ufo/status");
	w.set("live", 1);
	w.setColor(0.6, 1, 0.6, 1);

	fgcommand("dialog-new", dialog[name].prop());
	gui.showDialog(name);
}


