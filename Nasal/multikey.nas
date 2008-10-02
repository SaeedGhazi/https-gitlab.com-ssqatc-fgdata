var listener = nil;
var cmd = nil;
var data = nil;
var dialog = nil;
var menu = 0;
var translate = { 356: '<', 357: '^', 358: '>', 359: '_' };


var start = func {
	cmd = "";
	dialog = Dialog.new();
	handle_key(8);
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
	dialog.del();
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
		menu = !menu;
	} elsif (key == `\n` or key == `\r`) {
		mode = 2;
	} elsif (contains(translate, key)) {
		cmd ~= translate[key];
	} elsif (!string.isprint(key)) {
		return 0;
	} else {
		cmd ~= chr(key);
	}

	var bindings = [];
	var options = [];
	var desc = __multikey._ = nil;
	if ((var node = find_entry(cmd, data, __multikey.arg = [])) != nil) {
		desc = node.getNode("desc", 1).getValue() or "";
		desc = call(sprintf, [desc] ~ __multikey.arg);
		bindings = node.getChildren("binding");
		if (node.getNode("no-exit") != nil) {
			cmd = substr(cmd, 0, size(cmd) - 1);
			mode = 1;
		} elsif (node.getNode("exit") != nil) {
			mode = 2;
		}
	}

	if (mode and size(bindings)) {
		foreach (var b; bindings)
			props.runBinding(b, "__multikey");
		if (mode == 2)
			stop();
	}
	if (mode < 2)
		dialog.update(cmd, __multikey._ or desc, menu and node != nil ? node.getChildren("key") : []);
	return 1;
}


var Dialog = {
	new : func {
		var m = { parents: [Dialog] };
		m.name = "multikey";
		m.prop = props.Node.new({ "dialog-name": m.name });
		m.isopen = 0;
		m.update("", "", []);
		return m;
	},
	del : func {
		me.isopen and fgcommand("dialog-close", me.prop);
		me.isopen = 0;
	},
	update : func(cmd, title, options) {
		if (!size(cmd))
			var (title, r, g, b) = ("Command Mode", 1, 0.7, 0);
		elsif (title)
			var (r, g, b) = (0.7, 1, 0.7);
		else
			var (title, r, g, b) = ("<unknown>", 1, 0.4, 0.4);

		me.del();
		var dlg = gui.Widget.new();
		dlg.set("name", me.name);
		dlg.set("y", -80);
		dlg.set("layout", "vbox");
		dlg.set("default-padding", 5);
		var t = dlg.addChild("text");
		t.set("label", title);
		t.setColor(r, g, b);
		dlg.addChild("text").set("label", cmd);

		if (options != nil and size(options)) {
			dlg.addChild("hrule");
			var g = dlg.addChild("group");
			g.set("layout", "table");
			g.set("default-padding", 3);
			forindex (var i; options) {
				var c = g.addChild("text");
				c.set("label", options[i].getNode("name", 1).getValue());
				c.set("row", i);
				c.set("col", 0);
				var c = g.addChild("text");
				c.set("label", " ... ");
				c.set("row", i);
				c.set("col", 1);
				var c = g.addChild("text");
				c.set("label", options[i].getNode("desc", 1).getValue() or "");
				c.set("row", i);
				c.set("col", 2);
				c.set("halign", "left");
			}
		}
		fgcommand("dialog-new", dlg.prop());
		fgcommand("dialog-show", me.prop);
		me.isopen = 1;
	},
};


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
			var line = "-----------------------------------------------";
			print(debug._c("33", sprintf("\n-- %s %s", title, substr(line, size(title) + 2))));
		}
		var cmd = k[0];
		cmd = string.replace(cmd, "%u", debug._c("32", "%u"));
		cmd = string.replace(cmd, "%d", debug._c("31", "%d"));
		cmd = string.replace(cmd, "%f", debug._c("36", "%f"));
		cmd = string.replace(cmd, "<", debug._c("35", "<"));
		cmd = string.replace(cmd, ">", debug._c("35", ">"));
		cmd = string.replace(cmd, "^", debug._c("35", "^"));
		cmd = string.replace(cmd, "_", debug._c("35", "_"));
		printf("%s\t%s", cmd, desc);
	}
	print(debug._c("33", "\n-- Legend ---------------------------------------"));
	printf("\t%s ... unsigned number", debug._c("32", "%u"));
	printf("\t%s ... signed number", debug._c("31", "%d"));
	printf("\t%s ... floating point number", debug._c("36", "%f"));
	printf("\t%s  ... cursor left", debug._c("35", "<"));
	printf("\t%s  ... cursor right", debug._c("35", ">"));
	printf("\t%s  ... cursor up", debug._c("35", "^"));
	printf("\t%s  ... cursor down", debug._c("35", "_"));
}


var find_entry = func(str, data, result) {
	foreach (var c; data.children)
		if ((var n = find_entry(str, c, result)) != nil)
			return n;
	if (string.scanf(str, data.format, var res = [])) {
		foreach (var r; res)
			append(result, r);
		return data.node;
	}
	return nil;
}


var init = func {
	globals["__multikey"] = { _: };
	var tree = props.globals.getNode("/input/keyboard/multikey", 1);

	foreach (var n; tree.getChildren("nasal")) {
		n.getNode("module", 1).setValue("__multikey");
		fgcommand("nasal", n);
	}

	var scan = func(tree, format = "") {
		var d = [];
		foreach (var n; tree.getChildren("key")) {
			var name = n.getNode("name", 1).getValue();
			if (name == nil)
				continue;
			append(d, { format: format ~ name, node: n, children: scan(n, format ~ name) });
		}
		return d;
	}

	data = { format: "", node: tree, children: scan(tree) };
}


_setlistener("/sim/signals/nasal-dir-initialized", init);


