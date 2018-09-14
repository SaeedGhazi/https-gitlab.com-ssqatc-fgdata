seaportLoop = func {
			var typ = getprop("/sim/type");
			var lat = getprop("/position/latitude-deg");
			var lon = getprop("/position/longitude-deg");
			var g = geodinfo(lat, lon);
			if ((g != nil and g[1] != nil and g[1].solid) and (typ == "seaplane") )
				fgcommand("dialog-show", props.Node.new({ "dialog-name": "seaport" }));
		};
seaportTimer = maketimer(8, seaportLoop);
seaportTimer.simulatedTime = 1;

_setlistener("/sim/signals/nasal-dir-initialized", func {
	_setlistener("/sim/presets/latitude-deg", func {
		printlog("info", "*** NEW LOCATION ***");
        seaportTimer.restart(8);

	}, 1);
});
