# Reads and returns a complete file as a string
var readfile = func(file) {
    if((var st = stat(file)) == nil) die("Cannot stat file: " ~ file);
    var sz = st[7];
    var buf = bits.buf(sz);
    read(open(file), buf, sz);
    return buf;
}

# Generates a stat() test routine that is passed the "mode" field
# (stat(...)[2]) from a stat() call (index 2), extracts the IFMT
# subfield and compares it with the given type, assumes S_IFMT ==
# 0xf000.
var _gen_ifmt_test = func(ifmt) {
    func(stat_mode) {
        var buf = bits.buf(2);
        bits.setfld(buf, 0, 16, stat_mode);
        return ifmt == bits.fld(buf, 12, 4);
    }
}

# Generate file type test predicates isdir(), isreg(), islnk(), etc.
# Usage: var s = io.stat(filename); # nil -> doesn't exist, broken link
#        if (s != nil and io.isdir(s[2])) { ... }
var ifmts = {dir:4, reg:8, lnk:10, sock:12, fifo:1, blk:6, chr:2};
foreach(fmt; keys(ifmts))
    caller(0)[0]["is" ~ fmt] = _gen_ifmt_test(ifmts[fmt]);

# Loads Nasal file into namespace and executes it. The namespace
# (module name) is taken from the optional second argument, or
# derived from the Nasal file's name.
#
# Usage:   io.load_nasal(<filename> [, <modulename>]);
#
# Example:
#
#     io.load_nasal(getprop("/sim/fg-root") ~ "/Local/test.nas");
#     io.load_nasal("/tmp/foo.nas", "test");
#
var load_nasal = func(file, module = nil) {
    if(module == nil)
        module = split(".", split("/", file)[-1])[0];

    if(!contains(globals, module))
        globals[module] = {};

    var err = [];
    printlog("info", "loading ", file, " into namespace ", module);
    var code = call(func compile(readfile(file), file), nil, err);
    if(size(err)) {
        (func nil)(); # needed to get correct caller results (?!?)
        for(var i = 1; (var c = caller(i)) != nil; i += 1)
            err ~= subvec(c, 2, 2);
        debug.printerror(err);
        return 0;
    }
    call(bind(code, globals), nil, nil, globals[module], err);
    debug.printerror(err);
    return !size(err);
}

# Load XML file in FlightGear's native <PropertyList> format.
# If the second, optional target parameter is set, then the properties
# are loaded to this node in the global property tree. Otherwise they
# are returned as a separate props.Node tree. Returns the data as a
# props.Node on success or nil on error.
#
# Usage:   io.read_properties(<filename> [, <props.Node or property-path>]);
#
# Examples:
#
#     var target = props.globals.getNode("/sim/model");
#     io.read_properties("/tmp/foo.xml", target);
#
#     var data = io.read_properties("/tmp/foo.xml", "/sim/model");
#     var data = io.read_properties("/tmp/foo.xml");
#
var read_properties = func(path, target = nil) {
    var args = props.Node.new({ filename: path });
    if(target == nil) {
        var ret = args.getNode("data", 1);
    } elsif(isa(target, props.Node)) {
        args.getNode("targetnode", 1).setValue(target.getPath());
        var ret = target;
    } else {
        args.getNode("targetnode", 1).setValue(target);
        var ret = props.globals.getNode(target, 1);
    }
    return fgcommand("loadxml", args) ? ret : nil;
}

# Write XML file in FlightGear's native <PropertyList> format.
# Returns the filename on success or nil on error. If the source
# is a props.Node that refers to a node in the main tree, then
# the data are directly written from the tree, yielding a more
# accurate result. Otherwise the data need to be copied first,
# which may slightly change node types (FLOAT becomes DOUBLE etc.)
#
# Usage:   io.write_properties(<filename>, <props.Node or property-path>);
#
# Examples:
#
#     var data = props.Node.new({ a:1, b:2, c:{ d:3, e:4 } });
#     io.write_properties("/tmp/foo.xml", data);
#     io.write_properties("/tmp/foo.xml", "/sim/model");
#
var write_properties = func(path, prop) {
    var args = props.Node.new({ filename: path });
    # default attributes of a new node plus the lowest unused bit
    var attr = args.getAttribute() + args.getAttribute("last") * 2;
    props.globals.setAttribute(attr);
    if(isa(prop, props.Node)) {
        for(var root = prop; (var p = root.getParent()) != nil;)
            root = p;
        if(root.getAttribute() == attr)
            args.getNode("sourcenode", 1).setValue(prop.getPath());
        else
            props.copy(prop, args.getNode("data", 1), 1);
    } else {
        args.getNode("sourcenode", 1).setValue(prop);
    }
    return fgcommand("savexml", args) ? path : nil;
}

# The following two functions are for reading generic XML files into
# the property tree and for writing them from there to the disk. The
# built-in fgcommands (load, save, loadxml, savexml) are for FlightGear's
# own <PropertyList> XML files only, as they only handle a limited
# number of very specific attributes. The io.readxml() loader turns
# attributes into regular children with a configurable prefix prepended
# to their name, while io.writexml() turns such nodes back into
# attributes. The two functions have their own limitations, but can
# easily get extended to whichever needs. The underlying parsexml()
# command will handle any XML file.

# Reads an XML file from an absolute path and returns it as property
# tree. All nodes will be of type STRING. Data are only written to
# leafs. Attributes are written as regular nodes with the optional
# prefix prepended to the name. If the prefix is nil, then attributes
# are ignored. Returns nil on error.
#
var readxml = func(path, prefix = "___") {
    var stack = [[{}, ""]];
    var node = props.Node.new();
    var tree = node;           # prevent GC
    var start = func(name, attr) {
        var index = stack[-1][0];
        if(!contains(index, name))
            index[name] = 0;

        node = node.getChild(name, index[name], 1);
        if(prefix != nil)
            foreach(var n; keys(attr))
                node.getNode(prefix ~ n, 1).setValue(attr[n]);

        index[name] += 1;
        append(stack, [{}, ""]);
    }
    var end = func(name) {
        var buf = pop(stack);
        if(!size(buf[0]) and size(buf[1]))
            node.setValue(buf[1]);
        node = node.getParent();
    }
    var data = func(d) stack[-1][1] ~= d;
    return parsexml(path, start, end, data) == nil ? nil : tree;
}

# Writes a property tree as returned by readxml() to a file. Children
# with name starting with <prefix> are again turned into attributes of
# their parent. <node> must contain exactly one child, which will
# become the XML file's outermost element.
#
var writexml = func(path, node, indent = "\t", prefix = "___") {
    var root = node.getChildren();
    if(!size(root))
        die("writexml(): tree doesn't have a root node");
    if(substr(path, -4) != ".xml")
        path ~= ".xml";
    var file = open(path, "w");
    write(file, "<?xml version=\"1.0\"?>\n\n");
    var writenode = func(n, ind = "") {
        var name = n.getName();
        var name_attr = name;
        var children = [];
        foreach(var c; n.getChildren()) {
            var a = c.getName();
            if(substr(a, 0, size(prefix)) == prefix)
                name_attr ~= " " ~ substr(a, size(prefix)) ~ '="' ~  c.getValue() ~ '"';
            else
                append(children, c);
        }
        if(size(children)) {
            write(file, ind ~ "<" ~ name_attr ~ ">\n");
            foreach(var c; children)
                writenode(c, ind ~ indent);
            write(file, ind ~ "</" ~ name ~ ">\n");
        } elsif((var value = n.getValue()) != nil) {
            write(file, ind ~ "<" ~ name_attr ~ ">" ~ value ~ "</" ~ name ~ ">\n");
        } else {
            write(file, ind ~ "<" ~ name_attr ~ "/>\n");
        }
    }
    writenode(root[0]);
    close(file);
    if(size(root) != 1)
        die("writexml(): tree has more than one root node");
}

# Redefine io.open() such that files can only be opened under authorized directories.
#
_setlistener("/sim/signals/nasal-dir-initialized", func {
    var root = string.fixpath(getprop("/sim/fg-root"));
    var home = string.fixpath(getprop("/sim/fg-home"));
    var config = "Nasal/IOrules";

    var rules_file = nil;
    var read_rules = [];
    var write_rules = [];

    var load_rules = func(path) {
        if(stat(path) == nil)
            return nil;
        printlog("info", "using io.open() rules from ", path);
        read_rules = [];
        write_rules = [];
        var file = open(path, "r");
        for(var no = 1; (var line = readln(file)) != nil; no += 1) {
            if(!size(line) or line[0] == `#`)
                continue;

            var f = split(" ", line);
            if(size(f) < 3 or f[0] != "READ" and f[0] != "WRITE" or f[1] != "DENY" and f[1] != "ALLOW") {
                printlog("alert", "ERROR: invalid io.open() rule in ", path, ", line ", no, ": ", line);
                read_rules = write_rules = [];
                break;
            }
            var pattern = f[2];
            foreach(var p; subvec(f, 3))
                pattern ~= " " ~ p;
            if(substr(pattern, 0, 9) == "$FG_ROOT/")
                pattern = root ~ "/" ~ substr(pattern, 9);
            elsif(substr(pattern, 0, 9) == "$FG_HOME/")
                pattern = home ~ "/" ~ substr(pattern, 9);
            append(f[0] == "READ" ? read_rules : write_rules, [pattern, f[1] == "ALLOW"]);
        }
        close(file);
        return path;
    }

    # catch exceptions so that a die() doesn't ruin everything
    var rules_file = call(func load_rules(home ~ "/" ~ config)
            or load_rules(root ~ "/" ~ config), nil, var err = []);
    if(size(err)) {
        debug.printerror(err);
        read_rules = write_rules = [];
    }

    read_rules = [["*/" ~ config, 0]] ~ read_rules;
    write_rules = [["*/" ~ config, 0]] ~ write_rules;
    if(__.log_level <= 3) {
        print("io.open()/READ:  ", debug.string(read_rules));
        print("io.open()/WRITE: ", debug.string(write_rules));
    }

    var valid = func(path, rules) {
        var fpath = string.fixpath(path);
        foreach(var d; rules)
            if(string.match(fpath, d[0]))
                return d[1] ? fpath : nil;
        return nil;
    }

    var _open = io.open;
    io.open = func(path, mode = "rb") {
        var rules = write_rules;
        if(mode == "r" or mode == "rb" or mode == "br")
            rules = read_rules;

        if(var vpath = valid(path, rules))
            return _open(vpath, mode);

        die("io.open(): opening file '" ~ path ~ "' denied (unauthorized access)\n ");
    }

    # validation listeners for loadxml/savexml (see utils.cxx:fgValidatePath)
    var v = props.globals.getNode("/sim/paths/validate", 1);
    setlistener(v.getNode("read", 1), func(n) n.setValue(valid(n.getValue(), read_rules) or ""));
    setlistener(v.getNode("write", 1), func(n) n.setValue(valid(n.getValue(), write_rules) or ""));
    v.remove();
});

