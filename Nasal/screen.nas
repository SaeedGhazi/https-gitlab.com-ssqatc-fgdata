# screen log window
# =================
#
#
# simple use:
#
#     foo = screen.window.new()
#     foo.write("message in the middle of the screen");
#
#
# advanced use:
#
#     bar = screen.window.new(nil, -100, 3, 10);
#     bar.fg = [1, 1, 1, 1];    # choose white color
#     bar.align = "left";
#
#     bar.write("first line");
#     bar.write("second line (red)", 1, 0, 0);
#
#
#
# arguments:
#            x ... x coordinate
#            y ... y coordinate
#                  positive coords position relative to the left/lower corner,
#                  negative coords from the right/upper corner, nil centers
#     maxlines ... max number of displayed lines; if more are pushed into the
#                  screen, then the ones on top fall off
#   autoscroll ... seconds that each line should be shown; can be less if
#                  a message falls off; if 0 then don't scroll at all
#


##
# convert string for output; replaces tabs by spaces, and skips
# delimiters and the voice part in "{text|voice}" constructions
#
var sanitize = func(s) {
	var r = "";
	var skip = 0;
	for (var i = 0; i < size(s); i += 1) {
		var c = s[i];
		if (c == `\t`)
			r ~= ' ';
		elsif (c == `{`)
			nil;
		elsif (c == `|`)
			skip = 1;
		elsif (c == `}`)
			skip = 0;
		elsif (!skip)
			r ~= chr(c);
	}
	return r;
}



var dialog_id = 0;
var theme_font = nil;

var window = {
	new : func(x = nil, y = nil, maxlines = 10, autoscroll = 10) {
		var m = { parents : [window] };
		#
		# "public"
		m.x = x;
		m.y = y;
		m.maxlines = maxlines;
		m.autoscroll = autoscroll;	# display time in seconds
		m.sticky = 0;			# reopens on old place
		m.font = nil;
		m.bg = [0, 0, 0, 0];		# background color
		m.fg = [0.9, 0.4, 0.2, 1];	# default foreground color
		m.align = "center";		# "left", "right", "center"
		#
		# "private"
		m.name = "__screen_window_" ~ (dialog_id += 1) ~ "__";
		m.lines = [];
		m.skiptimer = 0;
		m.dialog = nil;
		m.namenode = props.Node.new({ "dialog-name" : m.name });
		setlistener("/sim/startup/xsize", func { m._redraw_() });
		setlistener("/sim/startup/ysize", func { m._redraw_() });
		return m;
	},
	write : func(msg, r = nil, g = nil, b = nil, a = nil) {
		if (me.namenode == nil)
			return;
		if (r == nil)
			r = me.fg[0];
		if (g == nil)
			g = me.fg[1];
		if (b == nil)
			b = me.fg[2];
		if (a == nil)
			a = me.fg[3];
		foreach (var line; split("\n", string.trim(msg))) {
			line = sanitize(string.trim(line));
			append(me.lines, [line, r, g, b, a]);
			if (size(me.lines) > me.maxlines) {
				me.lines = subvec(me.lines, 1);
				if (me.autoscroll)
					me.skiptimer += 1;
			}
			if (me.autoscroll)
				settimer(func { me._timeout_() }, me.autoscroll, 1);
		}
		me.show();
	},
	show : func {
		if (me.dialog != nil)
			me.close();

		me.dialog = gui.Widget.new();
		me.dialog.set("name", me.name);
		if (me.x != nil)
			me.dialog.set("x", me.x);
		if (me.y != nil)
			me.dialog.set("y", me.y);
		me.dialog.set("layout", "vbox");
		me.dialog.set("default-padding", 2);
		if (me.font != nil)
			me.dialog.setFont(me.font);
		elsif (theme_font != nil)
			me.dialog.setFont(theme_font);

		me.dialog.setColor(me.bg[0], me.bg[1], me.bg[2], me.bg[3]);

		foreach (var line; me.lines) {
			var w = me.dialog.addChild("text");
			w.set("halign", me.align);
			w.set("label", line[0]);
			w.setColor(line[1], line[2], line[3], line[4]);
		}

		fgcommand("dialog-new", me.dialog.prop());
		fgcommand("dialog-show", me.namenode);
	},
	close : func {
		fgcommand("dialog-close", me.namenode);
		if (me.dialog != nil and me.sticky) {
			me.x = me.dialog.prop().getNode("lastx").getValue();
			me.y = me.dialog.prop().getNode("lasty").getValue();
		}
	},
	_timeout_ : func {
		if (me.skiptimer > 0) {
			me.skiptimer -= 1;
			return;
		}
		if (size(me.lines) > 1) {
			me.lines = subvec(me.lines, 1);
			me.show();
		} else {
			me.close();
			dialog = nil;
			me.lines = [];
		}
	},
	_redraw_ : func {
		if (me.dialog != nil) {
			me.close();
			me.show();
		}
	},
};



var property_display = {
	init : func(x, y, lines) {
		me.listener = setlistener("/sim/gui/dialogs/property-browser/selected", func(n) {
			var n = n.getValue();
			if (n != "" and getprop("/devices/status/keyboard/shift")) {
				if (getprop("/devices/status/keyboard/ctrl"))
					return me.reset();
				n = props.globals.getNode(n);
				if (!n.getAttribute("children"))
					me.add(n);
			}
		});
		me.window = window.new(x, y, lines, 0);
		me.window.align = "left";
		me.window.font = "HELVETICA_12";
		me.loopid = 0;
		me.reset();
	},
	reset : func {
		me.loopid += 1;
		me.window.close();
		me.nodes = [];
	},
	add : func(n) {
		append(me.nodes, isa(n, props.Node) ? n : props.globals.getNode(n, 1));
		me._loop_(me.loopid += 1);
	},
	update : func {
		me.window.lines = [];
		foreach (var n; me.nodes) {
			if ((val = n.getValue()) == nil)
				val = "nil";
			append(me.window.lines, [n.getName() ~ " = " ~ val, 1, 1, 0.5, 1]);
		}
		me.window.show();
	},
	_loop_ : func(id) {
		id != me.loopid and return;
		me.update();
		settimer(func { me._loop_(id) }, 0.5);
	},
};



var log = nil;

_setlistener("/sim/signals/nasal-dir-initialized", func {
	property_display.init(5, -25, 999);

	setlistener("/sim/gui/current-style", func {
		var theme = getprop("/sim/gui/current-style");
		theme_font = getprop("/sim/gui/style[" ~ theme ~ "]/fonts/message-display/name");
	}, 1);

	log = window.new(nil, -30, 10, 10);
	log.sticky = 0;  # don't turn on; makes scrolling up messages jump left and right

	var b = "/sim/screen/";
	setlistener(b ~ "black",   func(n) { log.write(n.getValue(), 0,   0,   0) });
	setlistener(b ~ "white",   func(n) { log.write(n.getValue(), 1,   1,   1) });
	setlistener(b ~ "red",     func(n) { log.write(n.getValue(), 0.8, 0,   0) });
	setlistener(b ~ "green",   func(n) { log.write(n.getValue(), 0,   0.6, 0) });
	setlistener(b ~ "blue",    func(n) { log.write(n.getValue(), 0,   0,   0.8) });
	setlistener(b ~ "yellow",  func(n) { log.write(n.getValue(), 0.8, 0.8, 0) });
	setlistener(b ~ "magenta", func(n) { log.write(n.getValue(), 0.7, 0,   0.7) });
	setlistener(b ~ "cyan",    func(n) { log.write(n.getValue(), 0,   0.6, 0.6) });
});





##############################################################################
# functions that make use of the window class (and don't belong anywhere else)
##############################################################################


var msg_repeat = func {
	if (getprop("/sim/tutorials/running")) {
		var last = getprop("/sim/tutorials/last-message");
		if (last == nil)
			return;

		setprop("/sim/messages/pilot", "Say again ...");
		settimer(func { setprop("/sim/messages/copilot", last) }, 1.5);

	} else {
		var last = atc.getValue();
		if (last == nil)
			return;

		setprop("/sim/messages/pilot", "This is " ~ callsign.getValue() ~ ". Say again, over.");
		settimer(func {
			atc.setValue(atclast.getValue());
		}, 6);
	}
}


var atc = nil;
var callsign = nil;
var atclast = nil;
var listener = {};

_setlistener("/sim/signals/nasal-dir-initialized", func {
	# set /sim/screen/nomap=true to prevent default message mapping
	var nomap = getprop("/sim/screen/nomap");
	if (nomap != nil and nomap)
		return;

	callsign = props.globals.getNode("/sim/user/callsign", 1);
	atc = props.globals.getNode("/sim/messages/atc", 1);
	atclast = props.globals.getNode("/sim/messages/atc-last", 1);
	atclast.setValue("");

	# let ATC tell which runway was automatically chosen after startup/teleportation
	settimer(func {
		setlistener("/sim/atc/runway", func(n) { # set in src/Main/fg_init.cxx
			var rwy = n.getValue();
			if (rwy == nil)
				return;
			if (getprop("/sim/presets/airport-id") == "KSFO" and rwy == "28R")
				return;
			if ((var agl = getprop("/position/altitude-agl-ft")) != nil and agl > 100)
				return;
			screen.log.write("You are on runway " ~ rwy, 0.7, 1.0, 0.7);
		}, 1);
	}, 5);

	setlistener("/gear/launchbar/state", func(n) {
		if (n.getValue() == "Engaged")
			setprop("/sim/messages/copilot", "Engaged!");
	}, 0, 0);

	# map ATC messages to the screen log and to the voice subsystem
	var map = func(type, msg, r, g, b) {
		setprop("/sim/sound/voices/" ~ type, msg);
		screen.log.write(msg, r, g, b);
		printlog("info", "{", type, "} ", msg);

		# save last ATC message for user callsign, unless this was already
		# a repetition; insert "I say again" appropriately
		if (type == "atc") {
			var cs = callsign.getValue();
			if (find(", I say again: ", atc.getValue()) < 0
					and (var pos = find(cs, msg)) >= 0) {
				var m = substr(msg, 0, pos + size(cs));
				msg = substr(msg, pos + size(cs));

				if ((pos = find("Tower, ", msg)) >= 0) {
					m ~= substr(msg, 0, pos + 7);
					msg = substr(msg, pos + 7);
				} else {
					m ~= ", ";
				}
				m ~= "I say again: " ~ msg;
				atclast.setValue(m);
				printlog("debug", "ATC_LAST_MESSAGE: ", m);
			}
		}
	}

	var m = "/sim/messages/";
	listener["atc"] = setlistener(m ~ "atc",
			func(n) { map("atc",      n.getValue(), 0.7, 1.0, 0.7) });
	listener["approach"] = setlistener(m ~ "approach",
			func(n) { map("approach", n.getValue(), 0.7, 1.0, 0.7) });
	listener["ground"] = setlistener(m ~ "ground",
			func(n) { map("ground",   n.getValue(), 0.7, 1.0, 0.7) });

	listener["pilot"] = setlistener(m ~ "pilot",
			func(n) { map("pilot",    n.getValue(), 1.0, 0.8, 0.0) });
	listener["copilot"] = setlistener(m ~ "copilot",
			func(n) { map("copilot",  n.getValue(), 1.0, 1.0, 1.0) });
	listener["ai-plane"] = setlistener(m ~ "ai-plane",
			func(n) { map("ai-plane", n.getValue(), 0.9, 0.4, 0.2) });
});


