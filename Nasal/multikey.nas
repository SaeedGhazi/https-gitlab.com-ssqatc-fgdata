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

	var options = [];
	var bindings = [];
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
		foreach (var c; node.getChildren("key"))
			if (size(c.getChildren("binding")) or size(c.getChildren("key")))
				append(options, c);
	}

	if (mode and size(bindings)) {
		foreach (var b; bindings)
			props.runBinding(b, "__multikey");
		if (mode == 2)
			stop();
	}
	if (mode < 2)
		dialog.update(cmd, __multikey._ or desc, menu ? options : []);
	return 1;
}


var Dialog = {
	new : func {
		var m = { parents: [Dialog] };
		m.name = "multikey";
		m.prop = props.Node.new({ "dialog-name": m.name });
		m.isopen = 0;
		m.firstrun = 1;
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
		var t = dlg.addChild("text");
		if (me.firstrun) {
			me.firstrun = 0;
			cmd = "Use <Tab> to toggle options!";
			t.setColor(0.5, 0.5, 0.5);
		}
		t.set("label", cmd);

		if (options != nil and size(options)) {
			dlg.addChild("hrule");
			var g = dlg.addChild("group");
			g.set("layout", "table");
			g.set("default-padding", 2);
			forindex (var i; options) {
				var name = options[i].getNode("name", 1).getValue();
				var desc = options[i].getNode("desc", 1).getValue() or "";
				if (name == "%%")
					name = '%';
				var c = g.addChild("text");
				c.set("label", name);
				c.set("row", i);
				c.set("col", 0);
				var c = g.addChild("text");
				c.set("label", " ... ");
				c.set("row", i);
				c.set("col", 1);
				var c = g.addChild("text");
				c.set("label", desc);
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
	var colorize = func(str) {
		var s = "";
		for (var i = 0; i < size(str); i += 1) {
			var c = str[i];
			if (c == `<` or c == `>` or c == `^` or c == `_`) {
				s ~= string.color("35", chr(c));
			} elsif (c == `%`) {
				if ((i += 1) < size(str) and str[i] == `%`) {
					s ~= '%';
					continue;
				}
				var f = '%';
				for (; i < size(str) and (c = str[i]) != nil and string.isdigit(c); i += 1)
					f ~= chr(c);
				if (c == `d`)
					s ~= string.color("31", f ~ 'd');
				elsif (c == `u`)
					s ~= string.color("32", f ~ 'u');
				elsif (c == `f`)
					s ~= string.color("36", f ~ 'f');
				elsif (c == `s`)
					s ~= string.color("34", f ~ 's');
			} else {
				s ~= chr(c);
			}
		}
		return s;
	}

	var list = [];
	var read_list = func(data) {
		foreach (var c; data.children)
			read_list(c);
		if (size(data.format))
			append(list, [data.format, data.node]);
	}
	read_list(data);

	var (curr, title) = (0, "");
	foreach (var k; sort(list, func(a, b) cmp(a[0], b[0]))) {
		var bndg = k[1].getChildren("binding");
		var desc = k[1].getNode("desc", 1).getValue() or "??";
		if (size(k[0]) == 1 or k[0][0] == `%`)
			title = desc;
		if (!size(bndg) or size(bndg) == 1
					and bndg[0].getNode("command", 1).getValue() == "null")
			continue;
		if (string.isalnum(k[0][0]) and k[0][0] != curr) {
			curr = k[0][0];
			var line = "---------------------------------------------------";
			print(string.color("33", sprintf("\n-- %s %s", title, substr(line, size(title) + 2))));
		}
		if (k[1].getNode("no-exit") != nil)
			desc ~= string.color("32", "  +");
		elsif (k[1].getNode("exit") != nil)
			desc ~= string.color("31", "  $");
		printf("%s\t%s", colorize(k[0]), desc);
	}
	print(string.color("33", "\n-- Legend -------------------------------------------"));
	printf("\t%s ... unsigned number", colorize("%u"));
	printf("\t%s ... signed number", colorize("%d"));
	printf("\t%s ... floating point number", colorize("%f"));
	printf("\t%s ... string", colorize("%s"));
	printf("\t%s  ... < or cursor left", colorize("<"));
	printf("\t%s  ... > or cursor right", colorize(">"));
	printf("\t%s  ... ^ or cursor up", colorize("^"));
	printf("\t%s  ... _ or cursor down", colorize("_"));
	printf("\t%s  ... repeatable action", string.color("32", "+"));
	printf("\t%s  ... immediate action", string.color("31", "$"));
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
		foreach (var key; tree.getChildren("key"))
			foreach (var name; key.getChildren("name"))
				if ((var n = name.getValue()) != nil)
					append(d, { format: format ~ n, node: key,
							children: scan(key, format ~ n) });
		return d;
	}

	data = { format: "", node: tree, children: scan(tree) };
}


_setlistener("/sim/signals/nasal-dir-initialized", init);


