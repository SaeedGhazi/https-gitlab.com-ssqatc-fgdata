##
# Returns true if the first object is an instance of the second
# (class) object.  Example: isa(someObject, props.Node)
#
isa = func {
    obj = arg[0]; class = arg[1];
    if(!contains(obj, "parents")) { return 0; }
    foreach(c; obj.parents) {
        if(c == class)     { return 1; }
        elsif(isa(obj, c)) { return 1; }
    }
    return 0;
}

##
# Invokes a FlightGear command specified by the first argument.  The
# second argument specifies the property tree to be passed to the
# command as its argument.  It may be either a props.Node object or a
# string, in which case it specifies a path in the global property
# tree.
#
fgcommand = func {
    if(isa(arg[1], props.Node)) { _fgcommand(arg[0], arg[1]._g) }
    _fgcommand(arg[0], propTree);
}

##
# Returns the SGPropertyNode argument to the currently executing
# function. Wrapper for the internal _cmdarg function that retrieves
# the ghost handlet to the argument and wraps it in a
# props.Node object.
#
cmdarg = func { props.wrapNode(_cmdarg()) }
