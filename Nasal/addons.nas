##
# Initialize addons configured with --addon=foobar command line switch:
# - get the list of registered add-ons
# - load the addon-main.nas file of each add-on into namespace
#   __addon[ADDON_ID]__
# - call function main() from every such addon-main.nas with the add-on ghost
#   as argument (an addons.Addon instance).

# Example:
#
# fgfs --addon=/foo/bar/baz
#
# - AddonManager.cxx parses /foo/bar/baz/addon-metadata.xml
# - AddonManager.cxx creates prop nodes under /addons containing add-on metadata
# - AddonManager.cxx loads /foo/bar/baz/addon-config.xml into the Property Tree
# - AddonManager.cxx adds /foo/bar/baz to the list of aircraft paths (to get
#   permissions to read files from there)
# - this script loads /foo/bar/baz/addon-main.nas into namespace
#   __addon[ADDON_ID]__
# - this script calls main(addonGhost) from /foo/bar/baz/addon-main.nas.
# - the add-on ghost can be used to retrieve most of the add-on metadata, for
#   instance:
#      addonGhost.id                   the add-on identifier
#      addonGhost.name                 the add-on name
#      addonGhost.version.str()        the add-on version as a string
#      addonGhost.basePath             the add-on base path (realpath() of
#                                      "/foo/bar/baz" here)
#      etc.
#
# For more details, see $FG_ROOT/Docs/README.add-ons.

# hashes to store listeners and timers per addon ID
var _listeners = {};
var _timers = {};
var _orig_setlistener = nil;
var _orig_maketimer = nil;

var getNamespaceName = func(a) {
    return "__addon[" ~ a.id ~ "]__";
}

var load = func(a) {
    var main_nas = a.basePath ~ "/addon-main.nas";
    var namespace = getNamespaceName(a);
    var loaded = a.node.getNode("loaded", 1);
    loaded.setBoolValue(0);

    if (globals[namespace] == nil) {
        globals[namespace] = {};
    }

    _listeners[a.id] = [];
    _timers[a.id] = [];

    # redirect setlistener() for addon
    globals[namespace].setlistener = func(p, f, start=0, runtime=1) {
        # listeners won't work on aliases so find real node
        if (typeof(p) == "scalar") {
            p = props.getNode(p, 1);
            while (p.getAttribute("alias")) {
                p = p.getAliasTarget();
            }
        }
        append(_listeners[a.id], _orig_setlistener(p, f, start, runtime));
        logprint(2, "setlistener " ~ p.getPath() ~ " (" ~
                    size(_listeners[a.id]) ~ " listener(s) tracked for " ~
                    a.id ~ ")");
    }

    # redirect maketimer for addon
    globals[namespace].maketimer = func() {
        if (size(arg) == 2) {
            append(_timers[a.id], _orig_maketimer(arg[0], arg[1]));
        } elsif (size(arg) == 3) {
            append(_timers[a.id], _orig_maketimer(arg[0], arg[1], arg[2]));
        } else {
            logprint(5, "Invalid number of arguments to maketimer()");
            return;
        }
        logprint(2, size(_timers[a.id]) ~ " timer(s) tracked for " ~ a.id);
        return _timers[a.id][-1];
    }

    if (io.load_nasal(main_nas, namespace)) {
        logprint(5, "[OK] '" ~ a.name ~ "' (V. " ~ a.version.str() ~
                    ") loaded.");
        var addon_main = globals[namespace]["main"];
        var addon_main_args = [a];
        var errors = [];
        call(addon_main, addon_main_args, errors);
        if (size(errors)) {
            debug.printerror(errors);
        } else {
            loaded.setBoolValue(1);
        }
        logprint(3, "Tracked resources after running the main() function of " ~
                    a.id ~ ":");
        logprint(3, "#listeners: " ~ size(_listeners[a.id]));
        logprint(3, "#timers: " ~ size(_timers[a.id]));
        logprint(3, "Use log level DEBUG to see all calls to the " ~
                    "setlistener() and maketimer() wrappers.");
    } else {
        logprint(5, "Failed loading addon-main.nas for " ~ a.id);
    }
}


var remove = func(a) {
    if (!a.node.getChild("loaded").getValue()) {
        logprint(5, "! ", a.id, " was not fully loaded.");
    }

    logprint(5, "- Removing add-on ", a.id);
    var namespace = getNamespaceName(a);
    foreach (var id; _listeners[a.id]) {
        logprint(3, "Removing listener " ~ id);
        removelistener(id);
    }
    _listeners[a.id] = [];

    logprint(3, "Stopping timers ");
    foreach (var t; _timers[a.id]) {
        if (typeof(t.stop) == "func") {
            t.stop();
            logprint(2, "  .");
        }
    }
    _timers[a.id] = [];

    # call clean up method if available
    # addon shall release resources not handled by addon framework
    if (globals[namespace]["unload"] != nil
        and typeof(globals[namespace]["unload"]) == "func") {
        globals[namespace].unload(a);
    }
    globals[namespace] = {};
}

var _reloadFlags = {};

var reload = func(a) {
    addons.remove(a);
    addons.load(a);
}

var init = func {
    foreach (var addon; addons.registeredAddons()) {
        addons._reloadFlags[addon.id] = addon.node.getNode("reload", 1);
        addons._reloadFlags[addon.id].setBoolValue(0);
        var makeListener = func(a) {
            return func(n) {
                if (n.getValue()) {
                    n.setValue(0);
                    addons.reload(a);
                }
            };
        }
        setlistener(addons._reloadFlags[addon.id], makeListener(addon));
        addons.load(addon);
    }
}

var id = _setlistener("/sim/signals/fdm-initialized", func {
    removelistener(id);
    _orig_setlistener = setlistener;
    _orig_maketimer = maketimer;
    addons.init();
})
