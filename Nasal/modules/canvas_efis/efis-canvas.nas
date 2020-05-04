#------------------------------------------
# efis-canvas.nas - Canvas EFIS framework
# author:       jsb
# created:      12/2017
#------------------------------------------

#--  EFISCanvas - base class to create canvas displays / pages --
# * manages a canvas
# * can load a SVG file and create clipping from <name>_clip elements
# * allows to register multiple update functions with individual update intervals
# * update functions can be en-/disabled by a single property that should
#   reflect the visibility of the canvas
# * several listener factories for common animations

var EFISCanvas = {
    # static members
    _instances: [],
    unload: func() {
        print("-- Removing EFISCanvas instances --");
        foreach (var instance; EFISCanvas._instances) {
            print("  - "~instance.name);
            instance.del();
        }
        EFISCanvas._instances = [];
    },

    # destructor
    del: func() {
        me._canvas.del();
        foreach (var timer; me._timers) {
            timer.stop();
        }
        me._timers = [];
    },

    colors: EFIS.colors,
    defaultcanvas_settings: EFIS.defaultcanvas_settings,

    new: func(name, svgfile=nil) {
        var obj = {
            parents: [me],
            _id: size(EFISCanvas._instances), # internal ID for EFIS window mgmt.
            id: 0,                            # instance id e.g. for PFD/MFD
            name: name,
            # for reload support while efis development
            _timers: [],
            _canvas: nil,
            _root: nil,
            svg_keys: [],
            updateN: nil,       # to be used in update() to pause updates
            _instr_props: {},
        };
        append(EFISCanvas._instances, obj);
        obj.updateCountN = EFIS_root_node.getNode("update/count-"~name, 1);
        obj.updateCountN.setIntValue(0);
        var settings = obj.defaultcanvas_settings;
        settings["name"] = name;
        obj._canvas = canvas.new(settings);
        obj._root = obj._canvas.createGroup();
        if (svgfile != nil) {
            obj.loadsvg(svgfile);
        }
        return obj;
    },

    #used by EFIS._setDisplaySource()
    getPath: func {
        return me._canvas.getPath();
    },

    getCanvas: func {
        return me._canvas;
    },

    getRoot: func {
        return me._root;
    },

    #set node that en-/dis-ables canvas updates
    setUpdateN: func(n) {
        me.updateN = n;
    },

    loadsvg: func(file) {
        logprint(LOG_INFO, "EFIS loading "~file);
        var options = {
            "default-font-family": "LiberationSans",
            "default-font-weight": "",
            "default-font-style": "",
        };
        canvas.parsesvg(me._root, file, options);

        # create nasal variables for SVG elements;
        # in a class derived from EFISCanvas, add IDs to the svg_keys member in the constructor (new)
        var svg_keys = me.svg_keys;
        foreach (var key; svg_keys) {
            me[key] = me._root.getElementById(key);
            if (me[key] != nil) {
                me._updateClip(key);
            }
            #else print("    loadsvg: invalid key ",key);
        }
        return me;
    },

    # register an update function with a certain update interval
    # f: function 
    # f_me: if there is any "me" reference in "f", you can set "me" with this
    #       defaults to EFISCanvas instance calling this method, useful if "f" 
    #       is a member of the EFISCanvas instance
    addUpdateFunction: func(f, interval, f_me = nil) {
        if (!isfunc(f)) {
            logprint(DEV_ALERT, "EFISCanvas.addUpdateFunction: argument is not a function.");
            return;
        }
        interval = num(interval);
        f_me = (f_me == nil) ? me : f_me;
        if (interval != nil and interval >= 0) {
            var timer = maketimer(interval, me, func {
                if (me.updateN != nil and me.updateN.getValue()) {
                    var err = [];
                    call(f, [], f_me, nil, err);
                    if (size(err))
                        debug.printerror(err);
                    # debug/performance monitoring
                    me.updateCountN.increment();
                }
            });
            append(me._timers, timer);
            return timer;
        }
    },

    # start all registered update functions
    startUpdates: func() {
        foreach (var t; me._timers)
            t.start();
    },

    # stop all registered update functions
    stopUpdates: func() {
        foreach (var t; me._timers) {
            t.stop();
        }
    },

    # getInstr - get props from /instrumentation/<sys>[i]/<prop>
    # creates prop node objects for efficient access
    # sys: the instrument name (path) (me.id is appended as index!!)
    # prop: the property(path)
    getInstr: func(sys, prop, default=0, id=nil) {
        if (me._instr_props[sys] == nil)
            me._instr_props[sys] = {};
        if (me._instr_props[sys][prop] == nil) {
            if (id == nil) { id = me.id; }
            me._instr_props[sys][prop] =
                props.getNode("/instrumentation/"~sys~"["~id~"]/"~prop, 1);
        }
        var value = me._instr_props[sys][prop].getValue();
        if (value != nil) return value;
        else return default;
    },

    updateTextElement: func(svgkey, text, color = nil) {
        if (me[svgkey] == nil or me[svgkey].setText == nil){
            print("updateTextElement(): Invalid argument ", svgkey);
            return;
        }
        me[svgkey].setText(text);
        if (color != nil and me[svgkey].setColor != nil) {
            if (isvec(color)) me[svgkey].setColor(color);
            else me[svgkey].setColor(me.colors[color]);
        }
    },

    ## private methods, to be used in this and derived classes only
    _updateClip: func(key) {
        var clip_elem = me._root.getElementById(key ~ "_clip");
        if (clip_elem != nil) {
            clip_elem.setVisible(0);
            me[key].setClipByElement(clip_elem);
        }
    },

    # returns generic listener to show/hide element(s)
    # svgkeys: can be a string referring to a single element
    #          or vector of strings referring to SVG elements
    #         (hint: putting elements in a SVG group (if possible) might be easier)
    # value: optional value to trigger show(); otherwise node.value will be implicitly treated as bool
    _makeListener_showHide: func(svgkeys, value=nil) {
        if (value == nil) {
            if (isvec(svgkeys)) {
                return func(n) {
                    if (n.getValue())
                        foreach (var key; svgkeys) me[key].show();
                    else
                        foreach (var key; svgkeys) me[key].hide();
                }
            }
            else {
                return func(n) {
                    if (n.getValue()) me[svgkeys].show();
                    else me[svgkeys].hide();
                }
            }
        }
        else {
            if (isvec(svgkeys)) {
                return func(n) {
                    if (n.getValue() == value)
                        foreach (var key; svgkeys) me[key].show();
                    else
                        foreach (var key; svgkeys) me[key].hide();
                };
            }
            else {
                return func(n) {
                    if (n.getValue() == value) me[svgkeys].show();
                    else me[svgkeys].hide();
                };
            }
        }
    },

    # returns listener to set rotation of element(s)
    # svgkeys: can be a string referring to a single element
    #          or vector of strings referring to SVG elements
    # factors: optional, number (if svgkeys is a single key) or hash of numbers
    #          {"svgkey" : factor}, missing keys will be treated as 1
    _makeListener_rotate: func(svgkeys, factors=nil) {
        if (factors == nil) {
            if (isvec(svgkeys)) {
                return func(n) {
                    var value = n.getValue() or 0;
                    foreach (var key; svgkeys) {
                        me[key].setRotation(value);
                    }
                }
            }
            else {
                return func(n) {
                    var value = n.getValue() or 0;
                    me[svgkeys].setRotation(value);
                }
            }
        }
        else {
            if (isvec(svgkeys)) {
                return func(n) {
                    var value = n.getValue() or 0;
                    foreach (var key; svgkeys) {
                        var factor = factors[key] or 1;
                        me[key].setRotation(value * factor);
                    }
                };
            }
            else {
                return func(n) {
                    var value = n.getValue() or 0;
                    var factor = num(factors) or 1;
                    me[svgkeys].setRotation(value * factor);
                };
            }
        }
    },

    # returns listener to set translation of element(s)
    # svgkeys: can be a string referring to a single element
    #          or vector of strings referring to SVG elements
    # factors: number (if svgkeys is a single key) or hash of numbers
    #          {"svgkey" : factor}, missing keys will be treated as 0 (=no op)
    _makeListener_translate: func(svgkeys, fx, fy) {
        if (isvec(svgkeys)) {
            var x = num(fx) or 0;
            var y = num(fy) or 0;
            if (ishash(fx) or ishash(fy)) {
                return func(n) {
                    foreach (var key; svgkeys) {
                        var value = n.getValue() or 0;
                        if (ishash(fx)) x = fx[key] or 0;
                        if (ishash(fy)) y = fy[key] or 0;
                        me[key].setTranslation(value * x, value * y);
                    }
                };
            }
            else {
                return func(n) {
                    foreach (var key; svgkeys) {
                        var value = n.getValue() or 0;
                        me[key].setTranslation(value * x, value * y);
                    }
                };
            }
        }
        else {
            if (num(fx) == nil or num(fy) == nil) {
                print("EFISCanvas._makeListener_translate(): Error, factor not a number.");
                return func ;
            }
            return func(n) {
                var value = n.getValue() or 0;
                if (num(value) == nil)
                    value = 0;
                me[svgkeys].setTranslation(value * fx, value * fy);
            };
        }
    },
    # returns generic listener to change element color
    # svgkeys: can be a string referring to a single element
    #          or vector of strings referring to SVG elements
    #         (hint: putting elements in a SVG group (if possible) might be easier)
    # colors can be either a vector e.g. [r,g,b] or "name" from me.colors
    _makeListener_setColor: func(svgkeys, color_true, color_false) {
        var col_0 = isvec(color_false) ? color_false : me.colors[color_false];
        var col_1 = isvec(color_true) ? color_true : me.colors[color_true];
        if (isvec(svgkeys) )  {
            return func(n) {
                if (n.getValue())
                    foreach (var key; svgkeys) me[key].setColor(col_1);
                else
                    foreach (var key; svgkeys) me[key].setColor(col_0);
            };
        }
        else {
            return func(n) {
                if (n.getValue()) me[svgkeys].setColor(col_1);
                else me[svgkeys].setColor(col_0);
            };
        }
    },

    _makeListener_updateText: func(svgkeys, format="%s", default="") {
        if (isvec(svgkeys)) {
            return func(n) {
                foreach (var key; svgkeys) {
                    me.updateTextElement(key, sprintf(format, n.getValue() or default));
                }
            };
        }
        else {
            return func(n) {
                me.updateTextElement(svgkeys, sprintf(format, n.getValue() or default));
            };
        }
    },
};
