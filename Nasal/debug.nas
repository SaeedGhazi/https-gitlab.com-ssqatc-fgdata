# debug.nas -- debugging helpers
#
# debug.dump(<variable>)               ... dumps full contents of variable
# debug.backtrace([<comment:string>]}  ... writes backtrace with local variables
#                                          (similar to gdb's "bt full)
# debug.exit()                         ... exits fgfs
#
# debug.bt                             ... abbreviation for debug.backtrace



# enable colors on Unix (checks second character in module path for colon)
#
if (caller(0)[2][1] != `:`) {
	_c = func(color, s) { "\x1b[" ~ color ~ "m" ~ s ~ "\x1b[m"  }
} else {
	_c = func(dummy, s) { s }
}


# for color codes see  $ man console_codes
#
_title       = func(s) { _c("33;42;1", s) }	# backtrace header
_section     = func(s) { _c("37;41;1", s) }	# backtrace frame

_nil         = func(s) { _c("32", s) }		# nil
_string      = func(s) { _c("31", s) }		# "foo"
_num         = func(s) { _c("31", s) }		# 0.0
_bracket     = func(s) { _c("", s) }		# [ ]
_brace       = func(s) { _c("", s) }		# { }
_angle       = func(s) { _c("", s) }		# < >
_vartype     = func(s) { _c("33", s) }		# func ghost
_proptype    = func(s) { _c("34", s) }		# BOOL INT LONG DOUBLE ...
_path        = func(s) { _c("36", s) }		# /some/property/path
_internal    = func(s) { _c("35", s) }		# me parents
_varname     = func(s) { _c("1", s) }		# variable_name


_dump_prop = func(p) {
	var attrib =
		(!p.getAttribute("read") ? "r" : "") ~
		(!p.getAttribute("write") ? "w" : "") ~
		(p.getAttribute("trace-read") ? "R" : "") ~
		(p.getAttribute("trace-write") ? "W" : "") ~
		(p.getAttribute("archive") ? "A" : "") ~
		(p.getAttribute("userarchive") ? "U" : "") ~
		(p.getAttribute("tied") ? "T" : "");

	var type = "(" ~ _proptype(p.getType()) ~ (size(attrib) ? ", " ~ attrib : "") ~ ")";
	return _path(p.getPath()) ~ "=" ~ _dump(p.getValue()) ~ " " ~ type;
}


_dump_var = func(v) {
	if (v == "me" or v == "parents") {
		return _internal(v);
	} else {
		return _varname(v);
	}
}


_dump = func(o) {
	var t = typeof(o);
	if (t == "nil") {
		return _nil("nil");
	} elsif (t == "scalar") {
		return num(o) == nil ? _string('"' ~ o ~ '"') : _num(o);
	} elsif (t == "vector") {
		var result = _bracket("[") ~ " ";
		forindex (var i; o) {
			result ~= (i == 0 ? "" : ", ") ~ _dump(o[i]);
		}
		return result ~ " " ~ _bracket("]");
	} elsif (t == "hash") {
		if (contains(o, "parents") and typeof(o.parents) == "vector"
				and size(o.parents) == 1 and o.parents[0] == props.Node) {
			return _angle("<") ~ _dump_prop(o) ~ _angle(">");
		}
		var k = keys(o);
		var result = _brace("{") ~ " ";
		forindex (var i; k) {
			result ~= (i == 0 ? "" : ", ") ~ _dump_var(k[i]) ~ " : " ~ _dump(o[k[i]]);
		}
		return result ~ " " ~ _brace("}");
	} else {
		return _angle("<") ~ _vartype(t) ~ _angle(">");
	}
}


dump = func(o = nil) { print(_dump(o != nil ? o : caller()[0])) }


backtrace = func(desc = nil, l = 0) {
	var v = caller(l);
	if (v == nil) {
		return;
	}
	if (l == 0) {
		var d = desc == nil ? "" : " '" ~ desc ~ "'";
		print("\n" ~ _title("\n### backtrace" ~ d ~ " ###"));
	} else {
		print(_section(sprintf("#%-2d called from %s, line %s:", l - 1, v[2], v[3])));
		dump(v[0]);
	}
	backtrace(nil, l + 1);
}
bt = backtrace;


exit = func { fgcommand("exit", props.Node.new()) }


if (getprop("/sim/logging/priority") != "alert") {
	_setlistener("/sim/signals/nasal-dir-initialized", func { print(_c("32", "** NASAL initialized **")) });
	_setlistener("/sim/signals/fdm-initialized", func { print(_c("36", "** FDM initialized **")) });
}


