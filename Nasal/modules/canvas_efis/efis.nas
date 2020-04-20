#-------------------------------------------------------------------------------
# efis.nas
# author:       jsb
# created:      12/2017
#-------------------------------------------------------------------------------
    
# class EFIS
# manage cockpit displays (=outputs) and sources (image generators for PFD, MFD, EICAS...)
# allow redirection of sources to alternate displays (allow for simulated display fault)
var EFIS = {
    #-- static members
    _instances: [],   
    unload: func() {
        foreach (var instance; EFIS._instances) {
            instance.del();
        }
        EFIS._instances = [];
    },
    NO_SRC: -1,
    
    defaultcanvas_settings: {
        "name": "EFIS_display",
        "size": [1024,1024],
        "view": [1024,1024],
        "mipmapping": 1
    },
    
    window_size: [450,450],
    
    colors: { 
        transparent: [1,0,0,0],
        white: [1,1,1],
        red: [1,0,0],
        green : [0,1,0],
        blue : [0,0,1],
        yellow: [1,1,0],
        cyan: [0,1,1],
        magenta: [1,0,1],
        amber: [1,0.682,0],
    },
    
    del: func() {
    },

    # create EFIS object
    # display_names: vector of display names, one DisplayUnit per entry will be 
    #   created
    # object_names: vector of same size and order as display_names, containing 
    #   3D object names for canvas placement of the DisplayUnits
    new: func(display_names, object_names, canvas_settings=nil) {
        if (!isvec(display_names)) {
            logprint(DEV_ALERT, "EFIS.new: 'display_names' not a vector!");
            return;
        }
        var obj = {
            parents: [me],
            id: 0,
            display_units: [],
            sources: [],        # vector of EFISCanvas instances
            display_names: display_names,
            controls: {},
            source_records: [], # stores infos about each source
            active_sources: [],
            powerN: nil,
        };
        if (object_names != nil and isvec(object_names)
            and size(display_names) == size(object_names))
        {
            foreach (var i; display_names) {
                append(obj.active_sources, EFIS.NO_SRC);
            }
            var settings = obj.defaultcanvas_settings;
            if (canvas_settings != nil and ishash(canvas_settings)) {
                foreach (var key; keys(canvas_settings)) {
                    settings[key] = canvas_settings[key];
                }
            }
            setsize(obj.display_units, size(display_names));
            forindex (var id; display_names)
            {
                obj.display_units[id] = DisplayUnit.new(obj.display_names[id],
                        obj.defaultcanvas_settings, object_names[id]);
            }
        }
        append(EFIS._instances, obj);
        return obj;
    }, #new

    #-- private methods ----------------------

    # _setDisplaySource - switch display unit du_id to source source_id
    # count how often a source is displayed, sources not displayed stop updating themselves
    _setDisplaySource: func(du_id, source_id)
    {
        var prev_source = me.active_sources[du_id];
        #print("setDisplaySource unit "~du_id~" src "~source_id~" prev "~prev_source);
        if (prev_source >= 0) {
            if (me.source_records[prev_source] == nil)
                logprint(LOG_ALERT, "_setDisplaySource error: prev: "~prev_source~" #"~size(me.source_records));
            var n = me.source_records[prev_source].visibleN;
            n.setValue(n.getValue() - 1);
        }
        var path = "";
        if (source_id >= 0) {
            path = me.sources[source_id].getPath();
        }
        me.display_units[du_id].setSource(path);
        me.active_sources[du_id] = source_id;
        var n = me.source_records[source_id].visibleN;
        n.setValue(n.getValue() + 1);
    },
    
    # mapping can be either: 
    #  - vector of source ids, size must equal size(display_units)
    #    values nil = do nothing, 0..N select source, -1 no source
    #  - hash {<unit_name>: source_id}
    _activateRouting: func(mapping)
    {
        if (typeof(mapping) == "vector") {
            forindex (var unit_id; me.display_units)
            {
                if (mapping[unit_id] != nil)
                    me._setDisplaySource(unit_id, mapping[unit_id]);
            }
        }
        elsif (typeof(mapping) == "hash") {
            foreach (var unit_name; keys(mapping))
            {
                forindex (var unit_id; me.display_names) {
                    if (me.display_names[unit_id] == unit_name) {
                        me._setDisplaySource(unit_id, mapping[unit_name]);
                    }
                }
            }
        }
    },

    # Start/stop updates on all sources 
    _powerOnOff: func(power) {
            if (power) {
                logprint(3, "EFIS power on");
                foreach (var src; me.sources) 
                    src.startUpdates();
            }
            else {
                logprint(3, "EFIS power off.");
                foreach (var src; me.sources) 
                    src.stopUpdates();
            }
    },

    #-- public methods -----------------------
    # set power prop and add listener to start/stop all registered update functions
    # e.g. power up will start updates, loss of power will stop updates
    setPowerProp: func(path) {
        me.powerN = props.getNode(path,1);
        setlistener(me.powerN, func(n) {
            var power = n.getValue();
            me._powerOnOff(power);
        }, 1, 0);
    },
    
    setWindowSize: func(window_size) {
        if (window_size != nil and typeof(window_size) == "vector") {
            me.window_size = window_size;
        }
        else {
            logprint(5, "EFIS.setWindowSize(): Error, argument is not a vector.");
        }
    },

    boot: func() {
        me._powerOnOff(me.powerN.getValue());
    },
    
    setDUPowerProps: func(power_props, minimum_power=0) {
        if (power_props != nil and typeof(power_props) == "vector") {
            forindex (var i; me.display_names) {
                me.display_units[i].setPowerSource(power_props[i], minimum_power);
            }
        }
        else logprint(5, "EFIS.setDUPowerProps(): Error, argument is not a vector.");
    },

    # add a EFISCanvas instance as display source
    # EFIS controls updating by tracking how often source is used 
    # returns source ID that can be used in mappings
    addSource: func(efis_canvas) {
        append(me.sources, efis_canvas);
        var srcID = size(me.sources) - 1;
        var visibleN = EFIS_root_node.getNode("update/visible"~srcID,1);
        visibleN.setIntValue(0);
        efis_canvas.setUpdateN(visibleN);
        append(me.source_records, {visibleN: visibleN});
        return srcID;
    },

    # ctrl: property path to integer prop
    # mappings: vector of display mappings
    # callback: optional function that will be called with current ctrl value
    addDisplaySwapControl: func(ctrl, mappings, callback=nil)
    {
        if (me.controls[ctrl] != nil) return;
        ctrlN = props.getNode(ctrl,1);
        if (typeof(mappings) != "vector") {
            logprint(5, "EFIS addDisplayControl: mappings must be a vector.");
            return;
        }
        var listener = func(p) {
                var ctlValue = p.getValue();
                if (ctlValue >= 0 and ctlValue < size(me.controls[ctrl].mappings))
                    me._activateRouting(me.controls[ctrl].mappings[ctlValue]);
                else debug.warn("Invalid value for display selector "~ctrl~": "~ctlValue);
                if (callback != nil) {
                    call(callback, [ctlValue], nil, nil, var err = []);
                    debug.printerror(err);
                }
            }
        #print("addDisplayControl "~ctrl);
        me.controls[ctrl] = {L: setlistener(ctrlN, listener, 0, 0), mappings: mappings};
    },
    
    # selected: property (node or path) containing source number (integer)
    # target:   contains the DU number to which the source will be mapped
    # sources:  optional vector,  selected -> source ID (as returned by addSource)
    #           defaults to all registered sources
    addSourceSelector: func(selected, target, sources=nil){
        if (typeof(selected) == "scalar") {
            selected = props.getNode(selected,1);            
        }
        if (typeof(target) == "scalar") {
            target = props.getNode(target,1);
        }
        if (selected.getValue() == nil)
            selected.setIntValue(0);
        if (sources == nil) {
            for (var i = 0; i < size(me.sources); i += 1)
                append(sources, i);
        }
        setlistener(selected, func(n){
            var src = n.getValue();
            var destination = target.getValue();
            if (src >= 0 and src < size(sources))
                me._setDisplaySource(destination, sources[src]);
        });
    },

    setDefaultMapping: func(mapping) {
        if (mapping != nil and (typeof(mapping) == "vector" or typeof(mapping) == "hash")) {
            me.default_mapping = mapping;
            me._activateRouting(me.default_mapping);
        }
    },
        
    getDU: func(i) {return me.display_units[i]},
    
    #getSources: func() { return me.source_records; },
    
    getDisplayName: func(id) {
        id = num(id);
        if (id != nil and id >=0 and id < size(me.display_names))
            return me.display_names[id];
        else return "Invalid display ID.";
    },

    getDisplayID: func(name) {
        for (var id = 0; id < size(me.display_names); id += 1) {
            if (me.display_names[id] == name) return id;
        }
        return -1;
    },

    #open a canvas window for display unit <id>
    displayWindow: func(id)
    {
        id = num(id);
        if (id < 0 or id >= size(me.display_units))
        {
            debug.warn("EFIS.displayWindow: invalid id");
            return;
        }
        return me.display_units[id].asWindow(me.window_size);
    },
};
