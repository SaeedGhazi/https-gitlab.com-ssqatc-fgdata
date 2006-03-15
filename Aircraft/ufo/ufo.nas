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


var clon = props.globals.getNode("/models/model/cursor/longitude-deg");
var clat = props.globals.getNode("/models/model/cursor/latitude-deg");
var celev = props.globals.getNode("/models/model/cursor/elevation-ft");

setlistener("/sim/input/click/longitude-deg", func { clon.setValue(cmdarg().getValue()) });
setlistener("/sim/input/click/latitude-deg", func { clat.setValue(cmdarg().getValue()) });
setlistener("/sim/input/click/elevation-ft", func { celev.setValue(cmdarg().getValue()) });


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


tilepath = func(lon, lat) {
	var lon_floor = floor(lon);
	var lat_floor = floor(lat);
	var lon_chunk = floor(lon / 10.0) * 10;
	var lat_chunk = floor(lat / 10.0) * 10;
	var tile = getprop("/environment/current-tile-id");
	format(lon_chunk, lat_chunk) ~ "/" ~ format(lon_floor, lat_floor) ~ "/" ~ tile ~ ".stg";
}


dump_coords = func {
	var ce = celev.getValue();
	print("\n--------------------------- Cursor ---------------------------");
	print(sprintf("Longitude:    %.6f deg", clon.getValue()));
	print(sprintf("Latitude:     %.6f deg", clat.getValue()));
	print(sprintf("Altitude:     %.4f m (%.4f ft)", ft2m(ce), ce));

	var lon = getprop("/position/longitude-deg");
	var lat = getprop("/position/latitude-deg");
	var alt_ft = getprop("/position/altitude-ft");
	var elev_m = getprop("/position/ground-elev-m");
	var heading = getprop("/orientation/heading-deg");
	var agl_ft = alt_ft - m2ft(elev_m);

	print("\n---------------------------- UFO -----------------------------");
	print(sprintf("Longitude:    %.6f deg", lon));
	print(sprintf("Latitude:     %.6f deg", lat));
	print(sprintf("Altitude ASL: %.4f m (%.4f ft)", ft2m(alt_ft), alt_ft));
	print(sprintf("Altitude AGL: %.4f m (%.4f ft)", ft2m(agl_ft), agl_ft));
	print(sprintf("Heading:      %.1f deg", normdeg(heading)));
	print(sprintf("Ground Elev:  %.4f m (%.4f ft)", elev_m, m2ft(elev_m)));
	print("");
	print(tilepath(lon, lat));
	print(sprintf("OBJECT_S %.6f %.6f %.4f %.1f", lon, lat, elev_m, normdeg(360 - heading)));
	print("--------------------------------------------------------------");
	print("\n");
}

