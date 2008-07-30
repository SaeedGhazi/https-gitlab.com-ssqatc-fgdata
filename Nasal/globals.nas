##
# Returns true if the first object is an instance of the second
# (class) object.  Example: isa(someObject, props.Node)
#
var isa = func(obj, class) {
    if(typeof(obj) == "hash" and obj["parents"] != nil)
        foreach(c; obj.parents)
            if(c == class or isa(c, class))
                return 1;
    return 0;
}

##
# Invokes a FlightGear command specified by the first argument.  The
# second argument specifies the property tree to be passed to the
# command as its argument.  It may be either a props.Node object or a
# string, in which case it specifies a path in the global property
# tree.
#
var fgcommand = func(cmd, node=nil) {
    if(isa(node, props.Node)) node = node._g;
    _fgcommand(cmd, node);
}

##
# Returns the SGPropertyNode argument to the currently executing
# function. Wrapper for the internal _cmdarg function that retrieves
# the ghost handle to the argument and wraps it in a
# props.Node object.
#
var cmdarg = func { props.wrapNode(_cmdarg()) }

##
# Utility.  Does what you think it does.
#
var abs = func(v) { return v < 0 ? -v : v }

##
# Convenience wrapper for the _interpolate function.  Takes a
# single string or props.Node object in arg[0] indicating a target
# property, and a variable-length list of time/value pairs.  Example:
#
#  interpolate("/animations/radar/angle",
#              180, 1, 360, 1, 0, 0,
#              180, 1, 360, 1, 0, 0,
#              180, 1, 360, 1, 0, 0,
#              180, 1, 360, 1, 0, 0,
#              180, 1, 360, 1, 0, 0,
#              180, 1, 360, 1, 0, 0,
#              180, 1, 360, 1, 0, 0,
#              180, 1, 360, 1, 0, 0);
#
# This will swing the "radar dish" smoothly through 8 revolutions over
# 16 seconds.  Note the use of zero-time interpolation between 360 and
# 0 to wrap the interpolated value properly.
#
var interpolate = func(node, val...) {
    if(isa(node, props.Node)) node = node._g;
    elsif(typeof(node) != "scalar") return;
    _interpolate(node, val);
}


##
# Wrapper for the _setlistener function. Takes a property path string
# or props.Node object in arg[0] indicating the listened to property,
# a function in arg[1], an optional bool in arg[2], which triggers the
# function initially if true, and an optional integer in arg[3], which
# sets the listener's runtime behavior to "only trigger on change" (0),
# "always trigger on write" (1), and "trigger even when children are
# written to" (2).
#
var setlistener = func(node, fn, init = 0, runtime = 1) {
    if(isa(node, props.Node)) node = node._g;
    var id = _setlistener(node, func(chg, lst, mode, is_child) {
        fn(props.wrapNode(chg), props.wrapNode(lst), mode, is_child);
    }, init, runtime);
    if(__.log_level <= 2) {
        var c = caller(1);
        printf("setting listener #%d in %s, line %s", id, c[2], c[3]);
    }
    return id;
}


##
# Returns true if the symbol name is defined in the caller, or the
# caller's lexical namespace.  (i.e. defined("varname") tells you if
# you can use varname in an expression without a undefined symbol
# error.
#
var defined = func(sym) {
    var fn = 1;
    while((var frame = caller(fn)) != nil) {
        if(contains(frame[0], sym)) return 1;
        fn += 1;
    }
    return 0;
}


##
# Returns reference to calling function. This allows a function to
# reliably call itself from a closure, rather than the global function
# with the same name.
#
var thisfunc = func caller(1)[1];


##
# Just what it says it is.
#
var printf = func print(call(sprintf, arg));


##
# Print log messages in appropriate --log-level.
# Usage: printlog("warn", "...");
# The underscore hash prevents helper functions/variables from
# needlessly polluting the global namespace.
#
__ = {};
__.dbg_types = { none:0, bulk:1, debug:2, info:3, warn:4, alert:5 };
__.log_level = __.dbg_types[getprop("/sim/logging/priority")];
var printlog = func(level, args...) {
    if(__.dbg_types[level] >= __.log_level) call(print, args);
}


##
# Load and execute ~/.fgfs/Nasal/*.nas files in alphabetic order
# after all $FG_ROOT/Nasal/*.nas files were loaded.
#
_setlistener("/sim/signals/nasal-dir-initialized", func {
    var path = getprop("/sim/fg-home") ~ "/Nasal";
    if((var dir = directory(path)) == nil) return;
    foreach(var file; sort(dir, cmp))
        if(substr(file, -4) == ".nas")
            io.load_nasal(path ~ "/" ~ file);
});

