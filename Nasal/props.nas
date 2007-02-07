##
# Node class definition.  The class methods simply wrap the
# low level exention functions which work on a "ghost" handle to a
# SGPropertyNode object stored in the _g field.
#
# Not all of the features of SGPropertyNode are supported.  There is
# no support for ties, obviously, as that wouldn't make much sense
# from a Nasal context.  The various get/set methods work only on the
# local node, there is no equivalent of the "relative path" variants
# available in C++; just use node.getNode(path).whatever() instead.
# There is no support for the "listener" interface yet.  The aliasing
# feature isn't exposed, except that you can get an "ALIAS" return
# from getType to detect them (to avoid cycles while walking the
# tree).
#
Node = {
    getType        : func { wrap(_getType(me._g, arg)) },
    getAttribute   : func { wrap(_getAttribute(me._g, arg)) },
    setAttribute   : func { wrap(_setAttribute(me._g, arg)) },
    getName        : func { wrap(_getName(me._g, arg)) },
    getIndex       : func { wrap(_getIndex(me._g, arg)) },
    getValue       : func { wrap(_getValue(me._g, arg)) },
    setValue       : func { wrap(_setValue(me._g, arg)) },
    setIntValue    : func { wrap(_setIntValue(me._g, arg)) },
    setBoolValue   : func { wrap(_setBoolValue(me._g, arg)) },
    setDoubleValue : func { wrap(_setDoubleValue(me._g, arg)) },
    getParent      : func { wrap(_getParent(me._g, arg)) },
    getChild       : func { wrap(_getChild(me._g, arg)) },
    getChildren    : func { wrap(_getChildren(me._g, arg)) },
    removeChild    : func { wrap(_removeChild(me._g, arg)) },
    removeChildren : func { wrap(_removeChildren(me._g, arg)) },
    getNode        : func { wrap(_getNode(me._g, arg)) },

    getPath : func {
        name = me.getName();
        if(me.getIndex() != 0)    { name = name ~ "[" ~ me.getIndex() ~ "]"; }
        if(me.getParent() != nil) { name = me.getParent().getPath() ~ "/" ~ name; }
        return name;
    },

    getBoolValue : func {
        val = me.getValue();
        if(me.getType() == "STRING" and val == "false") { 0 }
        elsif (val == nil) { 0 }
        else { val != 0 }
    },
};

##
# Static constructor for a Node object.  Accepts a Nasal hash
# expression to initialize the object a-la setValues().
#
Node.new = func {
    result = wrapNode(_new());
    if(size(arg) > 0 and typeof(arg[0]) == "hash") {
        result.setValues(arg[0]);
    }
    return result;
}

##
# Useful utility.  Sets a whole property tree from a Nasal hash
# object, such that scalars become leafs in the property tree, hashes
# become named subnodes, and vectors become indexed subnodes.  This
# works recursively, so you can define whole property trees with
# syntax like:
#
# dialog = {
#   name : "exit", width : 180, height : 100, modal : 0,
#   text : { x : 10, y : 70, label : "Hello World!" } };
#
Node.setValues = func {
    foreach(k; keys(arg[0])) { me._setChildren(k, arg[0][k]); }
}

##
# Private function to do the work of setValues().
# The first argument is a child name, the second a nasal scalar,
# vector, or hash.
#
Node._setChildren = func {
    name = arg[0]; val = arg[1];
    subnode = me.getNode(name, 1);
    if(typeof(val) == "scalar") { subnode.setValue(val); }
    elsif(typeof(val) == "hash") { subnode.setValues(val); }
    elsif(typeof(val) == "vector") {
        for(i=0; i<size(val); i=i+1) {
            iname = name ~ "[" ~ i ~ "]";
            me._setChildren(iname, val[i]);
        }
    }
}

##
# Useful debugging utility.  Recursively dumps the full state of a
# Node object to the console.  Try binding "props.dump(props.globals)"
# to a key for a fun hack.
#
dump = func {
    if(size(arg) == 1) { prefix = "";     node = arg[0]; }
    else               { prefix = arg[0]; node = arg[1]; }

    index = node.getIndex();
    type = node.getType();
    name = node.getName();
    val = node.getValue();

    if(val == nil) { val = "nil"; }
    name = prefix ~ name;
    if(index > 0) { name = name ~ "[" ~ index ~ "]"; }
    print(name, " {", type, "} = ", val);

    # Don't recurse into aliases, lest we get stuck in a loop
    if(type != "ALIAS") {
        children = node.getChildren();
        foreach(c; children) { dump(name ~ "/", c); }
    }
}

##
# Recursively copy property branch from source Node to
# destination Node. Doesn't copy aliases.
#
copy = func(src, dest) {
    foreach(c; src.getChildren()) {
        name = c.getName() ~ "[" ~ c.getIndex() ~ "]";
        copy(src.getNode(name), dest.getNode(name, 1));
    }
    var type = src.getType();
    var val = src.getValue();
    if(type == "ALIAS" or type == "NONE") { return; }
    elsif(type == "BOOL") { dest.setBoolValue(val); }
    elsif(type == "INT") { dest.setIntValue(val); }
    elsif(type == "DOUBLE") { dest.setDoubleValue(val); }
    else { dest.setValue(val); }
}

##
# Utility.  Turns any ghosts it finds (either solo, or in an
# array) into Node objects.
#
wrap = func {
    argtype = typeof(arg[0]);
    if(argtype == "ghost") {
        return wrapNode(arg[0]);
    } elsif(argtype == "vector") {
        v = arg[0];
        n = size(v);
        for(i=0; i<n; i=i+1) { v[i] = wrapNode(v[i]); }
        return v;
    }
    return arg[0];
}

##
# Utility.  Returns a new object with its superclass/parent set to the
# Node object and its _g (ghost) field set to the specified object.
# Nasal's literal syntax can be pleasingly terse. I like that. :)
#
wrapNode = func { { parents : [Node], _g : arg[0] } }

##
# Global property tree.  Set once at initialization.  Is that OK?
# Does anything ever call globals.set_props() from C++?  May need to
# turn this into a function if so.
#
props.globals = wrapNode(_globals());

##
# Sets all indexed property children to a single value.  arg[0]
# specifies a property name (e.g. /controls/engines/engine), arg[1] a
# path under each node of that name to set (e.g. "throttle"), arg[2]
# is the value.
#
setAll = func {
    node = props.globals.getNode(arg[0]);
    if(node == nil) { return; }
    name = node.getName();
    node = node.getParent();
    if(node == nil) { return; }
    children = node.getChildren();
    foreach(c; children) {
        if(c.getName() == name) {
            c.getNode(arg[1], 1).setValue(arg[2]); }}
}
