#-------------------------------------------------------------------------------
# modules.nas - Nasal module helper for Add-ons and re-loadable modules
# author:       jsb
# created:      12/2019
#-------------------------------------------------------------------------------
# modules.nas allowes to load and unload Nasal modules at runtime (e.g. without
# restarting Flightgear as a whole). It implements  resource tracking for 
# setlistener and maketimer to make unloading easier
#-------------------------------------------------------------------------------
# Example - generic module load:
# 
# if (modules.isAvailable("foo_bar")) {
#    modules.load("foo_bar");
# }
# 
# Example - create an aircraft nasal system as module 
#           (e.g. for rapid reload while development)
#
# var my_foo_sys = modules.Module.new("my_aircraft_foo");
# my_foo_sys.setDebug(1);
# my_foo_sys.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal");
# my_foo_sys.setMainFile("foo.nas");
# my_foo_sys.load();
#-------------------------------------------------------------------------------

var MODULES_DIR = getprop("/sim/fg-root")~"/Nasal/modules/";
var MODULES_NODE = nil;
var _modules_available = {};

# Hash storing Module objects; keep this outside Module to avoid stack overflow
# when using debug.dump
var _instances = {};    

# Class Module
# to handle a re-loadable Nasal module at runtime
var Module = {
    _orig_setlistener: setlistener,
    _orig_maketimer: maketimer,
    _orig_settimer: settimer,
    
    # id: must be a string without special characters or spaces
    # ns: optional namespace name
    # node: optional property node for module management
    new: func(id, ns = "", node = nil) {
        if (!id or typeof(id) != "scalar") {
            logprint(5, "Module.new(): id: must be a string without special characters or spaces");
            return;
        }
        if (_instances[id] != nil) {
            return _instances[id];
        }
        var obj = { 
            parents: [me],
            _listeners: [],
            _timers: [],
            _debug: 0,

            id: id,
            version: 1,
            file_path: MODULES_DIR,
            main_file: "main.nas",
            namespace: ns ? ns : id,
            node: nil,
        };
        if (isa(node, props.Node)) {
            obj.node = node
        } else {
            obj.node = MODULES_NODE.getNode(id, 1); 
        }
        obj.reloadN = obj.node.initNode("reload", 0, "BOOL");
        obj.loadedN = obj.node.initNode("loaded", 0, "BOOL");
        obj.lcountN = obj.node.initNode("listeners", 0, "INT");
        obj.tcountN = obj.node.initNode("timers", 0, "INT");
        obj.lhitN = obj.node.initNode("listener-hits", 0, "INT");
        
        obj.reloadL = setlistener(obj.reloadN, func(n) {
            if (n.getValue()) {
                n.setValue(0);
                logprint(3, "Reload listener for ", obj.id, " triggered (",
                    obj.reloadL, ")");                
                obj.reload();
            }
        });
        _instances[id] = obj;
        return obj;
    },
    
    getNode: func { return me.node; },
    getReloadNode: func { return me.reloadN; },
    getNamespaceName: func { return me.namespace; },
    getNamespace: func { return globals[me.namespace]; },
    getFilePath: func { return me.file_path; },
    
    #return variable from module namespace
    get: func(var_name) {
        return globals[me.namespace][var_name];
    },
    
    setDebug: func (debug = 1) {
        me._debug = debug;
        logprint(4, "Module "~me.id~" debug = "~debug);
    },

    setFilePath: func(path) {
        if (io.is_directory(path)) {
            if (substr(path, -1) != "/")
                path ~= "/";
            me.file_path = path;
            return 1;
        }
        return 0;
    },
    
    setMainFile: func(filename) {
        if (typeof(filename) == "scalar") {
            me.main_file = filename;
        }
        else {
            logprint("4", "setMainFile() needs a string parameter");
        }
    },
    
    setNamespace: func(ns) {
        if (typeof(ns) == "scalar") {
            me.namespace = ns;
        }
        else {
            logprint("4", "setNamespace() needs a string parameter");
        }
    },
    
    # load module 
    # if no arguments are given, the Module object will be passed to main()
    load: func(myargs...) {
        me.loadedN.setBoolValue(0);
        if (globals[me.namespace] == nil) {
            globals[me.namespace] = {};
        }
        logprint(5, "Module.load() ", me.id);
        me.lcountN.setIntValue(0);
        me.tcountN.setIntValue(0);
        me.lhitN.setIntValue(0);
        me._redirect_setlistener();
        me._redirect_maketimer();
        me._redirect_settimer();
        
        var filename = me.file_path~"/"~me.main_file;
        if (io.load_nasal(filename, me.namespace)) {
            var main = globals[me.namespace]["main"];
            if (typeof(main) == "func") {
                var module_args = [];
                if (size(myargs) == 0) module_args = [me];
                else module_args = myargs;
                var errors = [];
                call(main, module_args, errors);
                if (size(errors)) {
                    debug.printerror(errors);
                } else {
                    me.loadedN.setBoolValue(1);
                }
            } else {
                me.loadedN.setBoolValue(1);
            }
            return me;
        } 
        else { return nil; }
    },
    
    # unload a module and remove its tracked resources 
    unload: func() {
        if (!me.loadedN.getValue()) {
            logprint(5, "! ", me.id, " was not fully loaded.");
        }
        if (globals[me.namespace] != nil
            and typeof(globals[me.namespace]) == "hash") 
        {
            logprint(5, "- Removing module ", me.id);
            if (globals[me.namespace]["setlistener"] != nil)
                globals[me.namespace]["setlistener"] = func {};
            foreach (var id; me._listeners) {
                logprint(3, "Removing listener "~id);
                if (removelistener(id)) {
                    me.lcountN.setValue(me.lcountN.getValue() - 1);
                }
            }
            me._listeners = [];

            logprint(3, "Stopping timers ");
            if (globals[me.namespace]["maketimer"] != nil)
                globals[me.namespace]["maketimer"] = func {};
            foreach (var t; me._timers) {
                if (typeof(t.stop) == "func") {
                    t.stop();
                    me.tcountN.setValue(me.tcountN.getValue() - 1);
                    logprint(2, "  .");
                }
            }
            me._timers = [];

            # call clean up method if available
            # module shall release resources not handled by this framework
            if (globals[me.namespace]["unload"] != nil
                and typeof(globals[me.namespace]["unload"]) == "func") {
                var errors = [];
                call(globals[me.namespace].unload, [me], errors);
                if (size(errors)) {
                    debug.printerror(errors);
                }
            }
            me.loadedN.setBoolValue(0);
            #kill namespace (replace with empty hash and hope GC cleans up behind us)
            globals[me.namespace] = nil;
        }
    },
    
    reload: func() {
        me.unload();
        me.load();
    },
        
    printTrackedResources: func(loglevel = 3) {
        logprint(loglevel, "Tracked resources after running the main() function of " ~
                    me.id~":");
        logprint(loglevel, "#listeners: "~size(me._listeners));
        logprint(loglevel, "#timers: "~size(me._timers));
        logprint(loglevel, "Use log level DEBUG to see all calls to the " ~
                    "setlistener() and maketimer() wrappers.");        
    },
    
    # redirect setlistener() for module
    _redirect_setlistener: func() {
        globals[me.namespace].setlistener = func(p, f, start=0, runtime=0) {
            if (!isa(p, props.Node)) {
                p = props.getNode(p, 1).resolveAlias();
            }
        
            if (me._debug) {
                var f_debug = func {
                    me.lhitN.setValue(me.lhitN.getValue() + 1);
                    if (int(me._debug) > 1) {
                        print("Listener hit for: ", p.getPath());
                    }
                    call(f, arg);
                };
                append(me._listeners, Module._orig_setlistener(p, f_debug, start, runtime));
                var c = caller(1);
                if (c != nil) {
                    print(sprintf("setlistener for %s called from %s:%s", 
                        p.getPath(), io.basename(c[2]), c[3]));
                };
            } else {
                append(me._listeners, Module._orig_setlistener(p,
                    f, start, runtime));
            }        
            me.lcountN.setValue(me.lcountN.getValue() + 1);
        }
        me.setlistener = globals[me.namespace].setlistener;
    },
    
    # redirect maketimer for module
    _redirect_maketimer: func() {
        globals[me.namespace].maketimer = func() {
            if (size(arg) == 2) {
                append(me._timers, Module._orig_maketimer(arg[0], arg[1]));
            } elsif (size(arg) == 3) {
                append(me._timers, 
                    Module._orig_maketimer(arg[0], arg[1], arg[2]));
            } else {
                logprint(5, "Invalid number of arguments to maketimer()");
                return;
            }
            if (me._debug) {
                var c = caller(1);
                if (c != nil) {
                    print(sprintf("maketimer called from %s:%s", 
                        io.basename(c[2]), c[3]));
                };
            }
            me.tcountN.setValue(me.tcountN.getValue() + 1);
            return me._timers[-1];
        }
        me.maketimer = globals[me.namespace].maketimer;
    },
    
    _redirect_settimer: func() {
        globals[me.namespace].settimer = func() {
            var c = caller(1);           
            logprint(5, sprintf("\n\Unsupported settimer() call from %s:%s. "~ 
                "Use maketimer() instead.",
                io.basename(c[2]), c[3]));
        }
    },
}; # end class Module

var isAvailable = func(name) {
    return contains(_modules_available, name);
}

var _getInstance = func(name) {
    if (isAvailable(name) and _instances[name] == nil) {
        var m = Module.new(name);
        m.setFilePath(MODULES_DIR~name);
    }
    return _instances[name];
}

var setDebug = func(name, debug=1) {
    if (isAvailable(name)) {
        var module = _getInstance(name);
        module.setDebug(debug);
    }
}

var load = func(name, ns="") {
    var m = _getInstance(name);
    if (m != nil) {
        if (ns) { m.setNamespace(ns); }
        return m.load();
    }
    else return 0; 
}

# scan MODULES_DIR for subdirectories; it is assumed, that only well-formed 
# modules are stored in that directories, so no further checks right here
var _findModules = func() {
    var module_dirs = io.subdirectories(MODULES_DIR);
    _modules_available = {};
    foreach (var name; module_dirs) {
        _modules_available[name] = 1;
        MODULES_NODE.getNode(name~"/available",1).setBoolValue(1);
    }
}

#props.getNode is available only after nasal dir has been initialized
_setlistener("sim/signals/nasal-dir-initialized", func {
    MODULES_NODE = props.getNode("/nasal/modules", 1);
    _findModules();
});

var commandModuleReload = func(node)
{
    var module = node.getChild("module").getValue();
    var m = _getInstance(module);
    if (m == nil) {
        logprint(5, "Unknown module to reload: %s", module);
        return;
    }

    m.reload();
};

addcommand("nasal-module-reload", commandModuleReload);