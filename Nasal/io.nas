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

# Generate file type test predicates for the following types:
# Usage: io.isdir(io.stat(filename)[2]);
var ifmts = {dir:4, reg:8, lnk:10, sock:12, fifo:1, blk:6, chr:2};
foreach(fmt; keys(ifmts))
    caller(0)[0]["is" ~ fmt] = _gen_ifmt_test(ifmts[fmt]);

# Removes trailing slashes, emtpy and "." elements, and expands
# all ".." elements.
var fixpath = func(d) {
    while(size(d) and d[0] == `/`) d = substr(d, 1);
    while(size(d) and d[size(d) - 1] == `/`) d = substr(d, 0, size(d) - 1);

    var stack = [];
    foreach(var e; split("/", d)) {
        if(e == "." or e == "") continue;
        elsif(e == "..") pop(stack);
        else append(stack, e);
    }
    if(!size(stack)) return "/";
    var path = "";
    foreach(var s; stack) path ~= "/" ~ s;
    return path;
}

