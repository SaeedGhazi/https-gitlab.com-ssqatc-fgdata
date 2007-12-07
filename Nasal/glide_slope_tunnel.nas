# Draw 3 degree glide slope tunnel for the nearest airport's most suitable runway
# considering wind direction and runway size.
# Activate with  --prop:sim/rendering/glide-slope-tunnel=1

var MARKER = "Models/Geometry/square.xml";	# tunnel marker
var DIST = 1000;				# distance between markers
var NUM = 30;					# number of tunnel markers
var ANGLE = 3 * math.pi / 180;			# glide slope angle in radian
var HOFFSET = 274;				# distance between begin of runway and touchdown area (900 ft)
var INTERVAL = 5;				# check for nearest airport

var voffset = DIST * math.sin(ANGLE) / math.cos(ANGLE);
var apt = nil;
var tunnel = [];
setsize(tunnel, NUM);


var normdeg = func(a) {
	while (a >= 180)
		a -= 360;
	while (a < -180)
		a += 360;
	return a;
}


# For each runway complement the opposite end, as airportinfo() returns only one end.
#
var complement_runways = func(apt) {
	foreach (var rwy; keys(apt.runways)) {
		if (!string.isdigit(rwy[0]))
			continue;

		var number = math.mod(num(substr(rwy, 0, 2)) + 18, 36);
		var side = substr(rwy, 2, 1);
		var comp = sprintf("%02d%s", number, side == "R" ? "L" : side == "L" ? "R" : side);
		var r = apt.runways[rwy];
		apt.runways[comp] = { lat: r.lat, lon: r.lon, length: r.length,
				width: r.width, heading: math.mod(r.heading + 180, 360),
				threshold1: r.threshold2,
				#threshold2: r.threshold1
				#stopway1: r.stopway2, stopway2: r.stopway1,
		};
	}
}


# Find best runway for current wind direction (or 270), also considering length and width.
#
var best_runway = func(apt) {
	var wind_speed = getprop("/environment/wind-speed-kt");
	var wind_from = wind_speed ? getprop("/environment/wind-from-heading-deg") : 270;
	var max = -1;
	var rwy = nil;

	foreach (var r; keys(apt.runways)) {
		var curr = apt.runways[r];
		var deviation = math.abs(normdeg(wind_from - curr.heading)) + 1e-20;
		var v = (0.01 * curr.length + 0.01 * curr.width) / deviation;

		if (v > max) {
			max = v;
			rwy = curr;
		}
	}
	return rwy;
}


# Draw 3 degree glide slope tunnel.
#
var draw_tunnel = func(rwy) {
	var m = geo.Coord.new().set_latlon(rwy.lat, rwy.lon);
	m.apply_course_distance(rwy.heading + 180, rwy.length / 2 - rwy.threshold1 - HOFFSET);

	var g = geodinfo(m.lat(), m.lon());
	var elev = g != nil ? g[0] : apt.elevation;
	forindex (var i; tunnel) {
		if (tunnel[i] != nil)
			tunnel[i].remove();

		m.set_alt(elev);
		tunnel[i] = geo.put_model(MARKER, m, rwy.heading);
		m.apply_course_distance(rwy.heading + 180, DIST);
		elev += voffset;
	}
}


var loop = func(id) {
	id == loopid or return;
	var a = airportinfo();
	if (apt == nil or apt.id != a.id) {
		apt = a;
		var is_heliport = 1;
		foreach (var rwy; keys(apt.runways))
			if (rwy[0] != `H`)
				is_heliport = 0;

		if (is_heliport) {
			#print(apt.id, " -- \"", apt.name, "\"  --> heliport; ignored");
		} else {
			complement_runways(apt);
			draw_tunnel(best_runway(apt));
			#print(apt.id, " -- \"", apt.name, "\"");
		}
	}
	settimer(func { loop(id) }, INTERVAL);
}


var loopid = 0;

settimer(func {
	var top = props.globals.getNode("/sim/model/geometry/square/top", 1);
	if (top.getType() == "NONE")
		top.setBoolValue(1);  # remove top bar unless otherwise specified

	setlistener("/sim/rendering/glide-slope-tunnel", func(n) {
		loopid += 1;
		if (n.getValue()) {
			apt = nil;
			loop(loopid);
		} else {
			forindex (var i; tunnel) {
				if (tunnel[i] != nil) {
					tunnel[i].remove();
					tunnel[i] = nil;
				}
			}
		}

	}, 1);
}, 0);


