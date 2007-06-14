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

# Removes superfluous slashes, emtpy and "." elements, expands
# all ".." elements, and turns all backslashes into slashes.
# The result will start with a slash if it started with a slash
# or backslash, it will end without slash. Should be applied on
# absolute paths, otherwise ".." elements might be resolved wrongly.
var fixpath = func(path) {
    var d = "";
    for(var i = 0; i < size(path); i += 1) {
        if(path[i] == `\\`) d ~= "/";
        else d ~= chr(path[i]);
    }
    var prefix = path[0] == `/` ? "/" : "";
    var stack = [];
    foreach(var e; split("/", d)) {
        if(e == "." or e == "") continue;
        elsif(e == "..") pop(stack);
        else append(stack, e);
    }
    if(!size(stack)) return "/";
    path = stack[0];
    foreach(var s; subvec(stack, 1)) path ~= "/" ~ s;
    return prefix ~ path;
}

