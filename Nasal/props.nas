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
    getNode        : func { wrap(_getNode(me._g, arg)) },

};

# Static constructor.  Accepts a hash as an argument and duplicates
# its contents in the property node.  ex:
#  Node.new({ value : 1.0, units : "ms" });
Node.new = func {
    result = wrapNode(_new());
    if(typeof(arg[0]) == "hash") {
        foreach(k; keys(arg[0])) {
            result.getNode(k, 1).setValue(arg[0][k]);
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

