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

# Reads an XML file from an absolute path and returns it as property
# tree. All nodes are of type STRING. Data are only written to leafs.
# Attributes are written as regular nodes with the optional prefix
# prepended to the name. If the prefix is nil, then attributes are
# ignored. Returns nil on error.
#
# NOTE: this function is meant for importing 'foreign' XML files, *not*
# for reading FlighGear's standard "PropertyList" XML files. For those
# we have better means, like the loadxml/savexml fgcommands. This
# function does neither interpret the "type" nor the "n" (index) or
# "archive" attribute.
#
var readxml = func(file, prefix = "") {
    var stack = [[{}, ""]];
    var node = props.Node.new();
    var tree = node;           # prevent GC
    var start = func(name, attr) {
        var index = stack[-1][0];
        if (!contains(index, name))
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


