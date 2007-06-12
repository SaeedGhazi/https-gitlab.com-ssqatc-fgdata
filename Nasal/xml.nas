# XML parser that allows to parse XML files that don't follow the FlightGear standard by
# storing information in attributes, like the crappy Traffic Manager and AI definition
# files.The XML 1.0 standard isn't fully implemented.
#
# Synopsis:  xml.process_string(<xml-data:string>, <action:hash>);
#            xml.process_file(<filepath>, <action:hash>);
#
# Examples:
#            var n = xml.process_string("<foo>123<foo>", xml.tree, "__");
#            var node = xml.process_file("foo/bar.xml", xml.tree, "__");
#            if (node != nil)
#                    props.dump(node);
#
# The <action> interface (xml.tree) is a hash with function members begin(),
# end(), open(), close(), and data(). Its methods are called by the parser:
#
#     begin(...)
#         called once at the beginning; the method gets all arguments but the
#         first two from the xml.process_string() call. In the above example it
#         gets the "__" as arg[0].
#
#     end()
#         called once at the end; its return value is used as return value for
#         xml.process_string()
#
#     open(<tag:string>, <attr:hash>, <empty:bool>)
#         called for every opening tag (empty=0) or self-closing, empty tag
#         (empty=1). <tag> is the tag name, and <attr> is a hash with one
#         name/value string pair per attribute.
#
#     close(<tag:string>, <numchildren:int>)
#         called for every closing tag, with tag name and number of child
#         elements. From the latter it can be determined if the closed tag
#         is a branch or a leaf node. The close() method is also called for
#         self-closing tags, in which case <numchildren> is always 0.
#
#     data(<string>)
#         called for each data segment
#
# Example:
#
#         <foo>123<bar this='is' a="test"/>456</foo>
#
#     would cause these action interface calls:
#
#         open("foo", {}, 0);
#         data("123");
#         open("bar", { this: "is", a: "test" }, 1);
#         close("bar", 0);
#         data("456");
#         close("foo", 1);
#
#
# Predefined are two action hashes:
#
# xml.tree
#
#     Synopsis: <node> = xml.process_string(<xml-string>, xml.tree, <attr-prefix:string>);
#
#     Example:  var node = xml.process_string("<foo>bar</foo>", xml.tree, "attr__");
#
#     This parses the <xml-string> and returns it as props.Node property tree,
#     which can then be processed with the known property methods, or copied
#     to the main property tree: props.copy(node, props.globals.getNode("whatever", 1));
#     Attributes are added as regular nodes, whereby the <attr-prefix> string is
#     prepended to the attribute names. If collisions can be ruled out, then this
#     prefix can be an empty string. If it's nil, then attributes are dropped
#     altogether. FlightGear's standard attributes are *not* considered, as this
#     parser is explicitly for non-standard XML sources. Standard files can
#     easier and quicker be loaded with fgfs means.
#
# xml.dump
#
#     Example:  xml.process_string("<foo>bar</foo>", xml.dump);
#
#     This dumps the input xml data to the terminal while parsing. It's meant for
#     debugging purposes.
#
#
#
# A minimal interface hash can look like this:
#
#     var do_nothing = {
#         begin : func {},
#         end : func {},
#         open : func {},
#         close : func {},
#         data : func {},
#     };
#
# and would be used as:  xml.process_string("<foo>bar</foo>", do_nothing);


var isspace = func(c) { c == ` ` or c == `\t` or c == `\n` or c == `\r` }
var isletter = func(c) { c >= `a` and c <= `z` or c >= `A` and c <= `Z` }
var isdigit = func(c) { c >= `0` and c <= `9` }
var isalnum = func(c) { isdigit(c) or isletter(c) }

var istagfirst = func(c) { isletter(c) or c == `_` or c == `:` }
var istagother = func(c) { isalnum(c) or c == `_` or c == `:` or c == `-` or c == `.`}

var ctab = { "lt" : `<`, "gt" : `>`, "amp" : `&`, "quot" : `"`, "apos" : `'` };

var error_label = "xml.nas: ";
var error = func(msg) die(error_label ~ msg ~ scan.location());


# SCANNER =========================================================================================


##
# virtual base class: must be derived, adding get() and put()
#
var Scanner = {
	new : func {
		var m = { parents : [Scanner] };
		m.line = 1;
		m.column = 0;
		m.source = " in";
		return m;
	},
	get : func die("get() method not implemented"),
	put : func die("put() method not implemented"),
	skip : func(w, skipspaces = 1) {
		var revert = [];
		if (skipspaces) {
			while (isspace(var c = scan.get()))
				revert = [c] ~ revert;
			scan.put(c);
		}
		for (var i = 0; i < size(w); i += 1) {
			var c = me.get();
			revert = [c] ~ revert;
			if (c != w[i]) {
				foreach (var r; revert)
					me.put(r);
				return 0;
			}
		}
		return 1;
	},
	getname : func {
		var s = "";
		var c = me.get();
		if (!istagfirst(c)) {
			me.put(c);
			return nil;
		}
		s ~= chr(c);
		while (1) {
			c = me.get();
			if (!istagother(c))
				break;
			s ~= chr(c);
		}
		me.put(c);
		return s;
	},
	getassign : func {
		me.skip_spaces();
		if (me.get() != `=`)
			error("equal sign expected in assignment");
		me.skip_spaces();
		var s = me.getstring();
		if (s == nil)
			error("quoted string expected in assignment");
		return s;
	},
	getstring : func(spc = 1) {
		spc and me.skip_spaces();
		var delim = me.get();
		if (delim != `"` and delim != `'`) {
			me.put(delim);
			return nil;
		}
		var s = "";
		while ((var c = me.get()) != nil and c != delim)
			s ~= chr(c == `&` ? me.special() : c);
		if (c != delim)
			error("string not closed with " ~ chr(delim));
		return s;
	},
	special : func {
		var s = "";
		var c = me.get();
		var n = nil;
		if (c == `#`) {
			while ((c = me.get()) != nil and isdigit(c) and c != `;`)
				s ~= chr(c);
			n = num(s);
		} else {
			me.put(c);
			while ((c = me.get()) != nil and c != `;`)
				s ~= chr(c);
		}
		if (c != `;`)
			error("entity reference not closed with ;");
		if (n != nil)
			return n;
		if (!contains(ctab, s))
			error("unknown entity reference");
		return ctab[s];
	},
	skip_spaces : func {
		var n = 0;
		while (isspace(var c = me.get()))
			n += 1;
		me.put(c);
		return n;
	},
	setmark : func(c) {
		if (c == `\n`) {
			me.line += 1;
			me.column = 0;
		} else {
			me.column += 1;
		}
	},
	location : func {
		return me.source ~ " line " ~ me.line ~ ", column " ~ me.column;
	},
	dump : func {
		var s = "";
		while ((var c = me.get()) != nil)
			s ~= chr(c);
		error("REST={" ~ s ~ "}");
	},
};


##
# child class of Scanner class; knows how to read characters from a string,
# and how to push them back for later use
#
var StringScanner = {
	new : func(s) {
		var m = Scanner.new();
		m.parents = [StringScanner] ~ m.parents;
		m.string = s;
		m.pos = 0;
		m.stack = [];
		return m;
	},
	get : func {
		if (size(me.stack))
			return pop(me.stack);
		if (me.pos >= size(me.string))
			return nil;
		var c = me.string[me.pos];
		me.pos += 1;
		me.setmark(c);
		return c;
	},
	put : func {
		foreach (var c; arg)
			append(me.stack, c);
	},
};


# PARSER ==========================================================================================

var parse_document = func(arg...) {
	call(action.begin, arg, action);
	parse_prolog();
	if (!parse_element()) {
		var c = scan.get();
		if (c == nil)
			error("document doesn't contain any data");
		scan.put();
		error("garbage");
	}

	parse_misc();
	scan.skip_spaces();
	if (scan.get() != nil)
		error("trailing garbage");

	return action.end();
}


var parse_prolog = func {
	parse_xmldecl();
	parse_misc();
	parse_doctype();
	parse_misc();
}


var parse_xmldecl = func {
	if (!scan.skip("<?"))
		return;
	if (!scan.skip("xml") or !scan.skip_spaces())
		error("prolog with invalid identifier. xml: expected");
	if (!scan.skip("version"))
		error("prolog without version statement");
	scan.getassign();	# returns lvalue
	if (scan.skip("encoding")) {
		scan.getassign();
	}
	if (scan.skip("standalone")) {
		var s = scan.getassign();
		if (s != "yes" and s != "no")
			error("standalone value must be 'yes' or 'no'");
	}
	if (!scan.skip("?>"))
		error("prolog not closed with ?>");
}


var parse_misc = func {
	while (parse_comment() or parse_pi()) {
	}
}


var parse_comment = func {
	if (!scan.skip("<!--"))
		return 0;
	while (1) {
		if (scan.skip("-->"))
			return 1;
		if (scan.skip("--"))
			error("illegal use of -- in comment");
		scan.get();
	}
	error("unfinished comment");
}


var parse_pi = func {
	if (!scan.skip("<?"))
		return 0;
	while (1) {
		if (scan.skip("?>"))
			return 1;
		scan.get();
	}
	error("unfinished 'processing instruction'");
}


var parse_doctype = func {
	if (!scan.skip("<!"))
		return 0;
	while (1) {
		parse_doctype();

		if (scan.skip(">"))
			return 1;
		scan.get();
	}
	error("unfinished doctype");
}


var parse_rawdata = func {
	var c = scan.get();
	if (c == `<`) {
		scan.put(c);
		return nil;
	}
	
	var s = chr(c);
	while ((c = scan.get()) != `<` and c != nil)
		s ~= chr(c == `&` ? scan.special() : c);
	scan.put(c);
	return s;
}


var parse_cdsect = func {
	if (!scan.skip("<![CDATA["))
		return nil;
	var s = "";
	while (1) {
		if (scan.skip("]]>"))
			return s;
		var c = scan.get();
		if (c == nil)
			break;
		s ~= chr(c == `&` ? scan.special() : c);
	}
	error("unfinished CDATA section");
}


var parse_element = func {
	var open = parse_opening_tag();
	if (open == nil)
		return 0;
	if (open[2]) {
		action.close(open[0], 0);
		return 1;	# tag was self-closing
	}

	var children = 0;
	while (1) {
		if ((var close = parse_closing_tag()) != nil)
			break;
		parse_comment();
		if ((var d = parse_cdsect()) != nil)
			action.data(d);
		if ((var d = parse_rawdata()) != nil)
			action.data(d);
		children += parse_element();
	}
	if (open[0] != close)
		error("<" ~ open[0] ~ "> closed with <" ~ close ~ ">");
	action.close(close, children);
	return 1;
}


var parse_opening_tag = func {
	if (!scan.skip("<"))
		return nil;
	var c = scan.get();
	if (!istagfirst(c)) {
		scan.put(c, `<`);
		return nil;
	}
	scan.put(c);
	var name = scan.getname();	# can't be nil
	var attr = {};
	while (1) {
		scan.skip_spaces();
		var n = scan.getname();
		if (n == nil)
			break;
		var v = scan.getassign();
		attr[n] = v;
	}
	if (scan.skip("/>"))
		selfclosing = 1;
	elsif (scan.skip(">"))
		selfclosing = 0;
	else
		error("garbage in opening tag");
	action.open(name, attr, selfclosing);
	return [name, attr, selfclosing];
}


var parse_closing_tag = func {
	if (!scan.skip("</"))
		return nil;
	var name = scan.getname();
	if (name == nil)
		error("closing tag without name");
	if (!scan.skip(">"))
		error("closing tag not ended with >");
	return name;
}


# ACTION HASHES ===================================================================================

var tree = {
	begin : func(prefix) {
		me.prefix = prefix;
		me.stack = [];
		me.node = props.Node.new();
	},
	end : func {
		return me.node;
	},
	open : func(name, attr) {
		append(me.stack, "");
		var index = size(me.node.getChildren(name));
		me.node = me.node.getChild(name, index, 1);
		if (me.prefix != nil)
			foreach (var n; keys(attr))
				me.node.getNode(me.prefix ~ n, 1).setValue(attr[n]);
	},
	close : func(name, children) {
		var buf = pop(me.stack);
		if (!children and size(buf))
			me.node.setValue(buf);
		me.node = me.node.getParent();
	},
	data : func(d) {
		me.stack[-1] ~= d;
	},
};


var dump = {
	begin : func(prefix = "__") {
		me.prefix = prefix;
		me.level = 0;
	},
	end : func {
	},
	open : func(name, attr) {
		me.print("<", name, ">");
		me.level += 1;
		foreach (var n; sort(keys(attr), cmp))
			me.print("<", , me.prefix, n, ">", attr[n], "</", me.prefix, n, ">");
	},
	close : func(name) {
		me.level -= 1;
		me.print("</", name, ">");
	},
	data : func(data) {
		for (var i = 0; i < size(data); i += 1)
			if (!isspace(data[i]))
				return me.print("'", data, "'");
	},
	print : func {
		var s = "";
		for (var i = 0; i < me.level; i += 1)
			s ~= "\t";
		call(print, [s] ~ arg);
	},
};


var process = func(arg...) {
	var err = [];
	var ret = call(parse_document, arg, err);
	if (!size(err))
		return ret;
	if (substr(err[0], 0, size(error_label)) != error_label)
		die(err[0]);  # rethrow

	print(err[0]);
	return nil;
}


var scan = nil;
var action = nil;


# INTERFACE =======================================================================================

var process_string = func(string, act, arg...) {
	scan = StringScanner.new(string);
	action = act;
	return call(process, arg);
}


var process_file = func(file, act, arg...) {
	scan = StringScanner.new(io.readfile(file));
	scan.source = "\n  in file " ~ file ~ ",";
	action = act;
	return call(process, arg);
}


