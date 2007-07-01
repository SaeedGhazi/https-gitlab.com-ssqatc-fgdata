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
var readxml = func(file, prefix = "___") {
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
    var data = func(d) {
        stack[-1][1] ~= d;
    }
    return parsexml(file, start, end, data) == nil ? nil : tree;
}

# Writes a property tree as returned by readxml() to a file. Chidren
# with name starting with <prefix> are again turned into attributes of
# their parent. <node> must contain exactly one child, which will
# become the XML file's outmost element.
#
var writexml = func(file, node, indent = "\t", prefix = "___") {
    var root = node.getChildren();
    if(!size(root)) die("writexml(): tree doesn't have a root node");
    if(substr(file, -4) != ".xml") file ~= ".xml";
    var fh = open(file, "w");
    var pre = size(prefix);
    write(fh, "<?xml version=\"1.0\"?>\n\n");
    var writenode = func(n, ind = "") {
        var name = n.getName();
        var name_attr = name;
        var children = [];
        foreach(var c; n.getChildren()) {
            var aname = c.getName();
            if(substr(aname, 0, pre) == prefix)
                name_attr ~= " " ~ substr(aname, pre) ~ '="' ~  c.getValue() ~ '"';
            else
                append(children, c);
        }
        if(size(children)) {
            write(fh, ind ~ "<" ~ name_attr ~ ">\n");
            foreach(var c; children)
                writenode(c, ind ~ indent);
            write(fh, ind ~ "</" ~ name ~ ">\n");
        } elsif((var value = n.getValue()) != nil) {
            write(fh, ind ~ "<" ~ name_attr ~ ">" ~ value ~ "</" ~ name ~ ">\n");
        } else {
            write(fh, ind ~ "<" ~ name_attr ~ "/>\n");
        }
    }
    writenode(root[0]);
    close(fh);
    if(size(root) != 1) die("writexml(): tree has more than one root node");
}


