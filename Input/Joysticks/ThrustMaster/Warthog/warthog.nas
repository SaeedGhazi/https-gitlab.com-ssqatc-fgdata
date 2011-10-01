# HIDRAW Interface (currently Linux-only; see README)

var device = {
	new: func(path, bufsize) {
		var m = { parents: [device] };
		m.path = path;
		m.bufsize = bufsize;
		m.leds = 0;
		m.bright = 0;
		var stat = io.stat(m.path);
		if (stat == nil or stat[11] != "chr")
			m.send = func { nil };
		return m;
	},
	send: func {
		var buf = bits.buf(me.bufsize);
		buf[0] = 1;
		forindex (var i; arg)
			buf[i + 1] = arg[i];
		var file = io.open(me.path, "wb");
		io.write(file, buf);
		io.close(file);
	},
	set_leds: func(on, which...) { # on/off, list of leds (0: background, 1-5)
		foreach (var w; which)
			me.leds = bits.switch(me.leds, me._ledmap[w], on);
		me.send(6, me.leds, me.bright);
	},
	toggle_leds: func(which...) {
		foreach (var w; which)
			me.leds = bits.toggle(me.leds, me._ledmap[w]);
		me.send(6, me.leds, me.bright);
	},
	set_brightness: func(v) {
		me.send(6, me.leds, me.bright = v < 0 ? 0 : v > 5 ? 5 : v);
	},
	brighter: func {
		me.leds = bits.set(me.leds, me._ledmap[0]);
		me.set_brightness(me.bright + 1);
	},
	darker: func {
		me.leds = bits.set(me.leds, me._ledmap[0]);
		me.set_brightness(me.bright - 1);
	},
	_ledmap: {0: 3, 1: 2, 2: 1, 3: 4, 4: 0, 5: 6},
};


var joystick = device.new("/dev/input/hidraw/Thustmaster_Joystick_-_HOTAS_Warthog", 12);
var throttle = device.new("/dev/input/hidraw/Thrustmaster_Throttle_-_HOTAS_Warthog", 36);

throttle.set_brightness(1);
throttle.set_leds(1, 0);              # backlight on
throttle.set_leds(0, 1, 2, 3, 4, 5);  # other LEDs off
