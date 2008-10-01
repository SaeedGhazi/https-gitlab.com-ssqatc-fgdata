var listener = nil;
var cmd = nil;
var data = nil;
var translate = { 356: '<', 357: '^', 358: '>', 359: '_' };


var start = func {
	popup(cmd = "");
	listener = setlistener("/devices/status/keyboard/event", func(event) {
		var key = event.getNode("key");
		if (!event.getNode("pressed").getValue()) {
			if (cmd == "" and key.getValue() == `;`)  # FIXME hack around kbd bug
				key.setValue(`:`);
			return;
		}
		if (handle_key(key.getValue()))
			key.setValue(-1);
	});
}


var stop = func {
	gui.popdown();
	removelistener(listener);
	listener = nil;
}


var handle_key = func(key) {
	var mode = 0;
	if (key == 27) {
		stop();
		return 1;
	} elsif (key == 8) {
		cmd = substr(cmd, 0, size(cmd) - 1);
	} elsif (key == 9) {
		#
	} elsif (key == `\n` or key == `\r`) {
		mode = 2;
	} elsif (contains(translate, key)) {
		cmd ~= translate[key];
	} elsif (!string.isprint(key)) {
		return 0;
	} else {
		cmd ~= chr(key);
	}

	var desc = __multikey._ = nil;
	var bindings = [];
	if (size(cmd)) {
		foreach (var e; data) {
			var match = string.scanf(cmd, e[0], __multikey.arg = []);
			if (match) {
				desc = e[1].getNode("desc", 1).getValue() or "";
				desc = call(sprintf, [desc] ~ __multikey.arg);
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
		popup(cmd, __multikey._ or desc);
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


var help = func {
	var (curr, title) = (0, "");
	foreach (var k; sort(data, func(a, b) cmp(a[0], b[0]))) {
		var bndg = k[1].getChildren("binding");
		var desc = k[1].getNode("desc", 1).getValue() or "??";
		if (size(k[0]) == 1 or k[0][0] == `%`)
			title = desc;
		if (!size(bndg) or size(bndg) == 1
					and bndg[0].getNode("command", 1).getValue() == "null")
			continue;
		if (string.isalnum(k[0][0]) and k[0][0] != curr) {
			curr = k[0][0];
			var line = "--------------------------------------------";
			print(debug._c("33", sprintf("\n-- %s %s", title, substr(line, size(title) + 2))));
		}
		var cmd = k[0];
		cmd = string.replace(cmd, "%u", debug._c("32", "%u"));
		cmd = string.replace(cmd, "%d", debug._c("31", "%d"));
		cmd = string.replace(cmd, "%f", debug._c("36", "%f"));
		cmd = string.replace(cmd, "&lt;", debug._c("35", "&lt;"));
		cmd = string.replace(cmd, "&gt;", debug._c("35", "&gt;"));
		cmd = string.replace(cmd, "^", debug._c("35", "^"));
		cmd = string.replace(cmd, "_", debug._c("35", "_"));
		printf("%s\t%s", cmd, desc);
	}
	print(debug._c("33", "\n-- Legend ------------------------------------"));
	printf("\t%s ... unsigned number", debug._c("32", "%u"));
	printf("\t%s ... signed number", debug._c("31", "%d"));
	printf("\t%s ... floation point number", debug._c("36", "%f"));
	printf("\t%s  ... cursor left", debug._c("35", "&lt;"));
	printf("\t%s  ... cursor right", debug._c("35", ">"));
	printf("\t%s  ... cursor up", debug._c("35", "^"));
	printf("\t%s  ... cursor down", debug._c("35", "_"));
}


var init = func {
	globals["__multikey"] = { _: };
	var tree = props.globals.getNode("/input/keyboard/multikey", 1);

	foreach (var n; tree.getChildren("nasal")) {
		n.getNode("module", 1).setValue("__multikey");
		fgcommand("nasal", n);
	}

	var add = func(node, label) {
		var name = node.getNode("name", 1).getValue();
		if (name == nil)  # 'or ""' doesn't work here, as we don't want to drop '0'
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


