# material dialog
# ===============
#
# Usage:  material.showDialog(<path>, [<title>], [<x>], [<y>]);
#
# the path should point to a property "directory" (usually set in
# the aircraft's *-set.xml file) that contains any of
# (shininess|transparency|texture) and (diffuse|ambient|specular|emission),
# whereby the latter four are directories containing any of
# (red|green|blue|factor|offset).
#
# If <title> is omitted or nil, then the last path component is used as title.
# If <x> and <y> are undefined, then the dialog is centered.
#
#
# Example:
#   <foo>
#       <diffuse>
#           <red>1.0</red>
#           <green>0.5</green>
#           <blue>0.5</blue>
#       </diffuse>
#       <transparency>0.5</transparency>
#       <texture>bar.rgb</texture>
#   </foo>
#
#
#   material.showDialog("/sim/model/foo/", "FOO");
#
#
#
# Of course, these properties are only used if a "material" animation
# references them via <*-prop> definition.
#
# Example:
#
#  <animation>
#      <type>material</type>
#      <object-name>foo</object-name>
#      <property-base>/sim/model/foo</property-base>
#      <diffuse>
#          <red-prop>diffuse/red</red-prop>
#          <green-prop>diffuse/green</green-prop>
#          <blue-prop>diffuse/blue</blue-prop>
#      </diffuse>
#      <transparency-prop>transparency</transparency-prop>
#      <texture-prop>texture</texture-prop>
#  </animation>
#

dialog = nil;

colorgroup = func {
	parent = arg[0];  # pui parent
	name = arg[1];    # "diffuse"
	base = arg[2];
	undef = func { props.globals.getNode(base ~ name ~ "/" ~ arg[0]) == nil };

	if (undef("red") and undef("green") and undef("blue")) {
		return;
	}
	grp = parent.addChild("group");
	grp.set("layout", "hbox");
	grp.addChild("text").set("label", "_______" ~ name ~ "_______");

	foreach (color; ["red", "green", "blue", "factor"]) {
		mat(parent, color, base ~ name ~ "/" ~ color, "%.3f");
	}
	mat(parent, "offset", base ~ name ~ "/" ~ "offset", "%.3f", -1.0, 1.0);
}


mat = func {
	parent = arg[0];
	name = arg[1];
	path = arg[2];
	format = arg[3];
	if (props.globals.getNode(path) != nil) {
		grp = parent.addChild("group");
		grp.set("layout", "hbox");

		grp.addChild("empty").set("stretch", 1);
		grp.addChild("text").set("label", name);

		slider = grp.addChild("slider");
		slider.set("property", path);
		slider.set("live", 1);
		if (size(arg) == 6) {
			slider.set("min", arg[4]);
			slider.set("max", arg[5]);
		}
		slider.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

		number = grp.addChild("text");
		number.set("label", "-0.123");
		number.set("format", format);
		number.set("property", path);
		number.set("live", 1);
		number.setColor(1, 0, 0);
	}
}


showDialog = func {
	base = arg[0];
	while (size(base) and substr(base, size(base) - 1, 1) == "/") {
		base = substr(base, 0, size(base) - 1);
	}
	parentdir = "";
	b = base;
	while (size(b)) {
		c = substr(b, size(b) - 1, 1);
		if (c == "/") { break }
		b = substr(b, 0, size(b) - 1);
		parentdir = c ~ parentdir;
	}

	title = if (size(arg) > 1 and arg[1] != nil) { arg[1] } else { parentdir };
	name = "material-" ~ parentdir;
	base = base ~ "/";

	dialog = gui.Widget.new();
	dialog.set("name", name);
	if (size(arg) > 2 and arg[2] != nil) { dialog.set("x", arg[2]) }
	if (size(arg) > 3 and arg[3] != nil) { dialog.set("y", arg[3]) }
	dialog.set("layout", "vbox");

	titlebar = dialog.addChild("group");
	titlebar.set("layout", "hbox");
	w = titlebar.addChild("text");
	w.set("label", "[" ~ title ~ "]");
	w.setFont("Helvetica", 17);
	titlebar.addChild("empty").set("stretch", 1);

	w = titlebar.addChild("button");
	w.set("pref-width", 16);
	w.set("pref-height", 16);
	w.set("legend", "");
	w.set("default", 1);
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-close");

	dialog.setColor(1.0, 0.95, 0.7, 0.5);

	colorgroup(dialog, "diffuse", base);
	colorgroup(dialog, "ambient", base);
	colorgroup(dialog, "emission", base);
	colorgroup(dialog, "specular", base);

	undef = func { props.globals.getNode(base ~ arg[0]) == nil };
	if (!(undef("shininess") and undef("transparency") and undef("threshold"))) {
		w = dialog.addChild("group");
		w.set("layout", "hbox");
		w.addChild("text").set("label", "_________misc_________");

		mat(dialog, "shi", base ~ "shininess", "%.0f", 0.0, 128.0);
		mat(dialog, "trans", base ~ "transparency", "%.3f");
		mat(dialog, "thresh", base ~ "threshold", "%.3f");
	}

	if (!undef("texture")) {
		w = dialog.addChild("group");
		w.set("layout", "hbox");
		w.addChild("text").set("label", "_______texture_______");

		w = dialog.addChild("input");
		w.set("live", 1);
		w.set("pref-width", 200);
		w.set("property", base ~ "texture");
		w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
	}
	dialog.addChild("empty").set("pref-height", "3");

	fgcommand("dialog-new", dialog.prop());
	gui.showDialog(name);
}


