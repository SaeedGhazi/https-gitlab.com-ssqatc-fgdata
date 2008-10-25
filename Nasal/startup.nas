var set_runway_from_metar_wind = func {
	if (!getprop("/environment/metar/real-metar"))
		return printlog("info", "metar-rwy: no live weather");
	if (!getprop("/sim/startup/options/airport"))
		return printlog("info", "metar-rwy: no airport requested");
	if (getprop("/sim/startup/options/runway"))
		return printlog("info", "metar-rwy: won't override explicit runway");
	if (getprop("/sim/startup/options/heading-deg") < 9990.0)
		return printlog("info", "metar-rwy: won't override explicit heading");
	if (!getprop("/sim/presets/onground"))
		return printlog("info", "metar-rwy: we aren't on ground");
	if (getprop("/environment/metar/base-wind-speed-kt") < 1)
		return;

	var from = getprop("/environment/metar/base-wind-range-from");
	var to = getprop("/environment/metar/base-wind-range-to");
	var wind_from = (from + to) * 0.5;

	printlog("info", "metar-rwy: setting new target heading ", wind_from);
	setprop("/sim/presets/heading-deg", wind_from);
	setprop("/sim/presets/longitude-deg", -9999);
	setprop("/sim/presets/latitude-deg", -9999);
	fgcommand("presets-commit");
	printlog("info", "metar-rwy: selected runway: ", getprop("/sim/atc/runway"));
}


_setlistener("/sim/signals/nasal-dir-initialized", func {
	set_runway_from_metar_wind();
	delete(globals, "startup");
});
