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

