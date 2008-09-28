var listener = nil;
var cmd = nil;
var data = nil;
var trans = { 356: '<', 357: '^', 358: '>', 359: '_' };


var start = func {
	popup(cmd = "");
	listener = setlistener("/devices/status/keyboard/event", func(event) {
		if (!event.getNode("pressed").getValue())
			return;
		var key = event.getNode("key");
		if (handle_key(key.getValue()))
			key.setValue(-1);
	});
}


var stop = func {
	removelistener(listener);
	gui.popdown();
}


var handle_key = func(key) {
	var mode = 0;
	if (key == 27) {
		stop();
		return 1;
	} elsif (key == 8) {
		cmd = substr(cmd, 0, size(cmd) - 1);
	} elsif (key == `\n` or key == `\r`) {
		mode = 2;
	} elsif (contains(trans, key)) {
		cmd ~= trans[key];
	} elsif (!string.isprint(key)) {
		return 0;
	} else {
		cmd ~= chr(key);
	}

	var desc = __multikey.desc = nil;
	var bindings = [];
	if (size(cmd)) {
		foreach (var e; data) {
			var r = string.scanf(cmd, e[0]);
			if (r != nil and r[0]) {
				__multikey.arg = size(r) > 1 ? subvec(r, 1) : [];
				desc = call(sprintf, [e[1].getNode("desc", 1).getValue() or ""] ~ __multikey.arg);
				bindings = e[1].getChildren("binding");
				if (e[1].getNode("no-exit") != nil) {
					cmd = substr(cmd, 0, size(cmd) - 1);
					mode = 1;
				} elsif (e[1].getNode("exit") != nil) {
					mode = 2;
				}
				break;
			}
		}
	}

	if (mode and size(bindings)) {
		foreach (var b; bindings)
			props.runBinding(b, "__multikey");
		if (mode == 2)
			stop();
	}
	if (mode < 2)
		popup(cmd, __multikey.desc or desc);
	return 1;
}


var popup = func(cmd, title = nil) {
	if (!size(cmd))
		var (title, r, g, b) = ("Command Mode", 1, 0.7, 0);
	elsif (title)
		var (r, g, b) = (0.7, 1, 0.7);
	else
		var (title, r, g, b) = ("<unknown>", 1, 0.4, 0.4);

	gui.popupTip("", 1e9, { layout: "vbox", text:
			[{ label: title, color: { red: r, green: g, blue: b } },
			{ label: cmd }] });
}


var init = func {
	globals["__multikey"] = { desc: };
	var tree = props.globals.getNode("/input/keyboard/multikey", 1);

	foreach (var n; tree.getChildren("nasal")) {
		n.getNode("module", 1).setValue("__multikey");
		fgcommand("nasal", n);
	}

	var add = func(node, label) {
		var name = node.getNode("name", 1).getValue();
		if (name == nil)	# 'or ""' doesn't work here, as '-' is false
			name = "";
		foreach (var key; node.getChildren("key"))
			add(key, label ~ name);
		if (size(name))
			append(data, [label ~ name, node]);
	}

	data = [];
	add(tree, "");
	data = sort(data, func(a, b) -cmp(a[0], b[0]));
}


_setlistener("/sim/signals/nasal-dir-initialized", init);

