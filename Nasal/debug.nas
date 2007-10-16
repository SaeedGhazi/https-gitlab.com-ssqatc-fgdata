# debug.nas -- debugging helpers
#------------------------------------------------------------------------------
#
# debug.color(<enabled>);              ... turns terminal colors on (1) or off (0)
#
# debug.dump(<variable>)               ... dumps contents of variable to terminal;
#                                          abbreviation for print(debug.string(v))
#
# debug.local([<frame:int>])           ... dump local variables of current
#                                          or given frame
#
# debug.backtrace([<comment:string>]}  ... writes backtrace with local variables
#                                          (similar to gdb's "bt full)
#
# debug.proptrace([<property [, <time>]]) ... trace property write/add/remove
#                                          events under the <property> subtree.
#                                          Defaults are "/" and 1 second.
#
# debug.tree([<property> [, <mode>])   ... dump property tree under property path
#                                          or props.Node hash (default: root). If
#                                          <mode> is unset or 0, use flat mode
#                                          (similar to props.dump()), otherwise
#                                          use space indentation
#
# debug.exit()                         ... exits fgfs
#
# debug.bt                             ... abbreviation for debug.backtrace
#
# debug.string(<variable>)             ... returns contents of variable as string
#
# debug.load_nasal(<file> [, <module>])) ... load and run Nasal file (under namespace
#                                          <module> if defined, or the basename
#                                          otherwise)
#
# debug.benchmark(<label:string>, <func> [<args>])
#                                      ... calls function with optional args and
#                                          prints execution time in seconds,
#                                          prefixed with <label>.
#
# debug.printerror(<err-vector>)       ... prints error vector as set by call()
#
# debug.propify(<variable>)            ... turn about everything into a props.Node
#
# CAVE: this file makes extensive use of ANSI color codes. These are
#       interpreted by UNIX shells and MS Windows with ANSI.SYS extension
#       installed. If the color codes aren't interpreted correctly, then
#       set property /sim/startup/terminal-ansi-colors=0

var _c = func {}

var color = func(enabled) {
	if (enabled) {
		_c = func(color, s) { "\x1b[" ~ color ~ "m" ~ s ~ "\x1b[m" }
	} else {
		_c = func(dummy, s) { s }
	}
}


# for color codes see  $ man console_codes
#
var _title       = func(s) { _c("33;42;1", s) } # backtrace header
var _section     = func(s) { _c("37;41;1", s) } # backtrace frame
var _error       = func(s) { _c("31;1",    s) } # internal errors
var _bench       = func(s) { _c("37;45;1", s) } # benchmark info

var _nil         = func(s) { _c("32", s) }      # nil
var _string      = func(s) { _c("31", s) }      # "foo"
var _num         = func(s) { _c("31", s) }      # 0.0
var _bracket     = func(s) { _c("", s) }        # [ ]
var _brace       = func(s) { _c("", s) }        # { }
var _angle       = func(s) { _c("", s) }        # < >
var _vartype     = func(s) { _c("33", s) }      # func ghost
var _proptype    = func(s) { _c("34", s) }      # BOOL INT LONG DOUBLE ...
var _path        = func(s) { _c("36", s) }      # /some/property/path
var _internal    = func(s) { _c("35", s) }      # me parents
var _varname     = func(s) { _c("1", s) }       # variable_name

var ghosttypes = {};


##
# Turn p into props.Node (if it isn't yet), or return nil.
#
var propify = func(p, create = 0) {
	var type = typeof(p);
	if (type == "ghost" and ghosttype(p) == ghosttype(props.globals._g))
		return props.wrapNode(p);
	if (type == "scalar" and num(p) == nil)
		return props.globals.getNode(p, create);
	if (isa(p, props.Node))
		return p;
	return nil;
}


var tree = func(n = "", graph = 1) {
	n = propify(n);
	if (n == nil)
		dump(n);
	else
		_tree(n, graph);
}


var _tree = func(n, graph = 1, prefix = "", level = 0) {
	var path = n.getPath();
	var children = n.getChildren();
	var s = "";

	if (graph) {
		s = prefix ~ n.getName();
		var index = n.getIndex();
		if (index)
			s ~= "[" ~ index ~ "]";
	} else {
		s = n.getPath();
	}

	if (size(children)) {
		s ~= "/";
		if (n.getType() != "NONE")
			s ~= " = " ~ string(n.getValue()) ~ " " ~ _attrib(n)
					~ "    " ~ _section(" PARENT-VALUE ");
	} else {
		s ~= " = " ~ string(n.getValue()) ~ " " ~ _attrib(n);
	}
	print(s);

	if (n.getType() != "ALIAS")
		forindex (var i; children)
			_tree(children[i], graph, prefix ~ ".   ", level + 1);
}


var _attrib = func(p) {
	var r = p.getAttribute("read")        ? "" : "r";
	var w = p.getAttribute("write")       ? "" : "w";
	var R = p.getAttribute("trace-read")  ? "R" : "";
	var W = p.getAttribute("trace-write") ? "W" : "";
	var A = p.getAttribute("archive")     ? "A" : "";
	var U = p.getAttribute("userarchive") ? "U" : "";
	var T = p.getAttribute("tied")        ? "T" : "";
	var attr = r ~ w ~ R ~ W ~ A ~ U ~ T;
	var type = "(" ~ _proptype(p.getType());
	if (size(attr))
		type ~= ", " ~ attr;
	if (var l = p.getAttribute("listeners"))
		type ~= ", L" ~ l;
	return type ~ ")";
}


var _dump_prop = func(p) {
	_path(p.getPath()) ~ " = " ~ string(p.getValue()) ~ " " ~ _attrib(p);
}


var _dump_var = func(v) {
	if (v == "me" or v == "parents")
		return _internal(v);
	else
		return _varname(v);
}


var string = func(o) {
	var t = typeof(o);
	if (t == "nil") {
		return _nil("nil");
	} elsif (t == "scalar") {
		return num(o) == nil ? _string('"' ~ o ~ '"') : _num(o);
	} elsif (t == "vector") {
		var s = "";
		forindex (var i; o)
			s ~= (i == 0 ? "" : ", ") ~ string(o[i]);

		return _bracket("[") ~ " " ~ s ~ " " ~ _bracket("]");
	} elsif (t == "hash") {
		if (contains(o, "parents") and typeof(o.parents) == "vector"
				and size(o.parents) == 1 and o.parents[0] == props.Node)
			return _angle("<") ~ _dump_prop(o) ~ _angle(">");

		var k = keys(o);
		var s = "";
		forindex (var i; k)
			s ~= (i == 0 ? "" : ", ") ~ _dump_var(k[i]) ~ " : " ~ string(o[k[i]]);

		return _brace("{") ~ " " ~ s ~ " " ~ _brace("}");
	} elsif (t == "ghost") {
		var gt = ghosttype(o);
		if (contains(ghosttypes, gt))
			return _angle("<") ~ _nil(ghosttypes[gt]) ~ _angle(">");
		else
			return _angle("<") ~ _nil(gt) ~ _angle(">");
	} else {
		return _angle("<") ~ _vartype(t) ~ _angle(">");
	}
}


var dump = func { size(arg) ? print(string(arg[0])) : local(1) }


var local = func(frame = 0) {
	var v = caller(frame + 1);
	print(v == nil ? _error("<no such frame>") : string(v[0]));
	return v;
}


var backtrace = func(desc = nil) {
	var d = desc == nil ? "" : " '" ~ desc ~ "'";
	print("\n" ~ _title("\n### backtrace" ~ d ~ " ###"));
	for (var i = 1; 1; i += 1) {
		v = caller(i);
		if (v == nil)
			return;
		print(_section(sprintf("#%-2d called from %s, line %s:", i - 1, v[2], v[3])));
		dump(v[0]);
	}
}
var bt = backtrace;


var proptrace = func(root = "/", time = 1) {
	var i = 0;
	var mark = setlistener("/sim/signals/frame", func {
		print("-------------------- FRAME --------------------");
	});
	var trace = setlistener(propify(root), func(this, base, type) {
		i += 1;
		if (type > 0)
			print("ADD ", this.getPath());
		elsif (type < 0)
			print("DEL ", this.getPath());
		else
			print("SET ", this.getPath(), " = ", string(this.getValue()), " ", _attrib(this));
	}, 0, 2);
	settimer(func {
		removelistener(trace);
		removelistener(mark);
		print("proptrace: stop (", i, " calls)");
	}, time, 1);
}


##
# Executes function f with optional arguments and prints execution
# time in seconds. Examples:
#
#     var test = func(n) { for (var i = 0; i < n; i +=1) { print(i) }
#     debug.benchmark("test()/1", test, 10);
#     debug.benchmark("test()/2", func { test(10) });
#
var benchmark = func(label, f, arg...) {
	var start = systime();
	call(f, arg);
	print(_bench(sprintf(" %s --> %.6f s ", label, systime() - start)));
}


var exit = func { fgcommand("exit") }


# print error vector as set by call(). By using call() one can execute
# code that catches "exceptions" (by a die() call or errors). The Nasal
# code doesn't abort in this case. Example:
#
#     call(func { possibly_buggy() }, nil, var err = []);
#     debug.printerror(err);
#
var printerror = func(err) {
	if (!size(err))
		return;

	print(sprintf("%s at %s line %d", err[0], err[1], err[2]));
	for (var i = 3; i < size(err); i += 2)
		print(sprintf("  called from %s line %d", err[i], err[i + 1]));
}


if (getprop("/sim/logging/priority") != "alert") {
	_setlistener("/sim/signals/nasal-dir-initialized", func { print(_c("32", "** NASAL initialized **")) });
	_setlistener("/sim/signals/fdm-initialized", func { print(_c("36", "** FDM initialized **")) });
}



##
# Loads Nasal file into namespace and executes it. The namespace
# (module name) is taken from the optional second argument, or
# derived from the Nasal file's name.
#
# Usage:   debug.load_nasal(<filename> [, <modulename>]);
#
# Example:
#
#     debug.load_nasal(getprop("/sim/fg-root") ~ "/Local/test.nas");
#     debug.load_nasal("/tmp/foo.nas", "test");
#
var load_nasal = func(file, module = nil) {
	if (module == nil)
		module = split(".", split("/", file)[-1])[0];

	if (!contains(globals, module))
		globals[module] = {};

	printlog("info", "loading ", file, " into namespace ", module);
	call(compile(io.readfile(file), file), nil, nil, globals[module]);
}


_setlistener("/sim/signals/nasal-dir-initialized", func {
	ghosttypes[ghosttype(props._globals())] = "PropertyNode";
	ghosttypes[ghosttype(io.stderr)] = "FileHandle";

	setlistener("/sim/startup/terminal-ansi-colors", func(n) {
		color(n.getBoolValue());
	}, 1);
});


