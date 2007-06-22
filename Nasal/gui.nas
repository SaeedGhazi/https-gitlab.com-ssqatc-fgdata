##
# Pop up a "tip" dialog for a moment, then remove it.  The delay in
# seconds can be specified as the second argument.  The default is 1
# second.  Note that the tip dialog is a shared resource.  If
# someone else comes along and wants to pop a tip up before your delay
# is finished, you lose. :)
#
popupTip = func {
    delay = if(size(arg) > 1) {arg[1]} else {DELAY};
    tmpl = { name : "PopTip", modal : 0, layout : "hbox",
             y: screenHProp.getValue() - 140,
             text : { label : arg[0], padding : 6 } };

    popdown();
    fgcommand("dialog-new", props.Node.new(tmpl));
    fgcommand("dialog-show", tipArg);

    currTimer = currTimer + 1;
    thisTimer = currTimer;

    # Final argument is a flag to use "real" time, not simulated time
    settimer(func { if(currTimer == thisTimer) { popdown() } }, DELAY, 1);
}

showDialog = func {
    fgcommand("dialog-show",
              props.Node.new({ "dialog-name" : arg[0]}));
}

##
# Enable/disable named menu entry
#
menuEnable = func(searchname, state) {
    foreach (menu; props.globals.getNode("/sim/menubar/default").getChildren("menu")) {
        foreach (name; menu.getChildren("name")) {
            if (name.getValue() == searchname) {
                menu.getNode("enabled").setBoolValue(state);
            }
        }
        foreach (item; menu.getChildren("item")) {
            foreach (name; item.getChildren("name")) {
                if (name.getValue() == searchname) {
                    item.getNode("enabled").setBoolValue(state);
                }
            }
        }
    }
}



########################################################################
# Private Stuff:
########################################################################

##
# Initialize property nodes via a timer, to insure the props module is
# loaded.  See notes in view.nas.  Simply cache the screen height
# property and the argument for the "dialog-show" command.  This
# probably isn't really needed...
#
screenHProp = tipArg = nil;
INIT = func {
    screenHProp = props.globals.getNode("/sim/startup/ysize");
    tipArg = props.Node.new({ "dialog-name" : "PopTip" });

    props.globals.getNode("/sim/help/debug", 1).setValues(debug_keys);
    props.globals.getNode("/sim/help/basic", 1).setValues(basic_keys);
    props.globals.getNode("/sim/help/common", 1).setValues(common_aircraft_keys);

    # enable/disable menu entries
    menuEnable("fuel-and-payload", getprop("/sim/flight-model") == "yasim");
    menuEnable("autopilot", props.globals.getNode("/autopilot/KAP140/locks") == nil);
    menuEnable("tutorial-start", size(props.globals.getNode("/sim/tutorials").getChildren("tutorial")));
    menuEnable("joystick-info", size(props.globals.getNode("/input/joysticks").getChildren("js")));

    var fps = props.globals.getNode("/sim/rendering/fps-display", 1);
    setlistener(fps, fpsDisplay, 1);
    setlistener("/sim/startup/xsize",
        func { if (fps.getValue()) { fpsDisplay(0); fpsDisplay(1) } });
}
settimer(INIT, 1);


##
# Show/hide the fps display dialog.
#
fpsDisplay = func {
    var w = (caller(0)[0]["arg"] == nil) ? cmdarg().getBoolValue() : arg[0];
    fgcommand(w ? "dialog-show" : "dialog-close", props.Node.new({"dialog-name": "fps"}));
}


##
# How many seconds do we show the tip?
#
DELAY = 1.0;

##
# Pop down the tip dialog, if it is visible.
#
popdown = func { fgcommand("dialog-close", tipArg); }

# Marker for the "current" timer.  This value gets stored in the
# closure of the timer function, and is used to check that there
# hasn't been a more recent timer set that should override.
currTimer = 0;

########################################################################
# Widgets & Layout Management
########################################################################

##
# A "widget" class that wraps a property node.  It provides useful
# helper methods that are difficult or tedious with the raw property
# API.  Note especially the slightly tricky addChild() method.
#
Widget = {
    set : func { me.node.getNode(arg[0], 1).setValue(arg[1]); },
    prop : func { return me.node; },
    new : func { return { parents : [Widget], node : props.Node.new() } },
    addChild : func {
        type = arg[0];
        idx = size(me.node.getChildren(type));
        name = type ~ "[" ~ idx ~ "]";
        newnode = me.node.getNode(name, 1);
        return { parents : [Widget], node : newnode };
    },
    setColor : func(r, g, b, a = 1) {
        me.node.setValues({ color : { red:r, green:g, blue:b, alpha:a } });
    },
    setFont : func(n, s = 13, t = 0) {
        me.node.setValues({ font : { name:n, "size":s, slant:t } });
    },
    setBinding : func(cmd, carg = nil) {
        var idx = size(me.node.getChildren("binding"));
        var node = me.node.getChild("binding", idx, 1);
        node.getNode("command", 1).setValue(cmd);
        if (cmd == "nasal") {
            node.getNode("script", 1).setValue(carg);
        } elsif (carg != nil and (cmd == "dialog-apply" or cmd == "dialog-update")) {
            node.getNode("object-name", 1).setValue(carg);
        }
    },
};



##
# Dialog class. Maintains one XML dialog.
#
# SYNOPSIS:
# (B) Dialog.new(<dialog-name>);   ... use dialog from $FG_ROOT/gui/dialogs/
#
# (A) Dialog.new(<prop>, <path> [, <dialog-name>]);
#                                  ... load aircraft specific dialog from
#                                      <path> under property <prop> and under
#                                      name <dialog-name>; if no name is given,
#                                      then it's taken from the XML dialog
#
#         prop        ... target node (name must be "dialog")
#         path        ... file path relative to $FG_ROOT
#         dialog-name ... dialog <name> of dialog in $FG_ROOT/gui/dialogs/
#
# EXAMPLES:
#
#     var dlg = gui.Dialog.new("/sim/gui/dialogs/foo-config/dialog",
#                              "Aircraft/foo/foo_config.xml");
#     dlg.open();
#     dlg.close();
#
#     var livery_dialog = gui.Dialog.new("livery-select");
#     livery_dialog.toggle();
#
Dialog = {
    new : func(prop, path = nil, name = nil) {
        var m = { parents : [Dialog] };
        m.state = 0;
        if (path == nil) { # global dialog in $FG_ROOT/gui/dialogs/
            m.name = prop;
            m.prop = props.Node.new({ "dialog-name" : prop });
        } else {           # aircraft dialog with given path
            m.name = name;
            m.path = path;
            m.prop = isa(prop, props.Node) ? prop : props.globals.getNode(prop, 1);
            if (m.prop.getName() != "dialog")
                die("Dialog class: node name must end with '/dialog'");

            m.listener = setlistener("/sim/signals/reinit-gui", func { m.load() }, 1);
        }
        return Dialog.instance[m.name] = m;
    },
    # doesn't need to be called explicitly, but can be used to force a reload
    load : func {
        var state = me.state;
        if (state)
            me.close();

        me.prop.removeChildren();
        fgcommand("loadxml", props.Node.new({"filename": getprop("/sim/fg-root") ~ "/" ~ me.path,
                "targetnode": me.prop.getPath()}));

        var n = me.prop.getNode("name");
        if (n == nil)
            die("Dialog class: XML dialog must have <name>");

        if (me.name == nil)
            me.name = n.getValue();
        else
            n.setValue(me.name);

        me.prop.getNode("dialog-name", 1).setValue(me.name);
        fgcommand("dialog-new", me.prop);
        if (state)
            me.open();
    },
    # allows access to dialog-embedded Nasal variables/functions
    namespace : func {
        var ns = "__dlg:" ~ me.name;
        me.state and contains(globals, ns) ? globals[ns] : nil;
    },
    open : func {
        fgcommand("dialog-show", me.prop);
        me.state = 1;
    },
    close : func {
        fgcommand("dialog-close", me.prop);
        me.state = 0;
    },
    toggle : func {
        me.state ? me.close() : me.open();
    },
    is_open : func {
        me.state;
    },
    instance : {},
};


##
# FileSelector class (derived from Dialog class).
#
# SYNOPSIS: FileSelector.new(<callback>, <title>, <button> [, <pattern> [, <dir> [, <file> [, <dotfiles>]]]])
#
#         callback ... callback function that gets return value as cmdarg().getValue()
#         title    ... dialog title
#         button   ... button text (should say "Save", "Load", etc. and not just "OK")
#         pattern  ... array with shell pattern or nil (which is equivalent to "*")
#         dir      ... starting dir ($FG_ROOT if unset)
#         file     ... pre-selected default file name
#         dotfiles ... flag that decids whether UNIX dotfiles should be shown (1) or not (0)
#
# EXAMPLE:
#
#     var report = func { print("file ", cmdarg().getValue(), " selected") }
#     var selector = gui.FileSelector.new(
#             report,                 # callback function
#             "Save Flight",          # dialot title
#             "Save",                 # button text
#             ["*.sav", "*.xml"],     # pattern for displayed files
#             "/tmp",                 # start dir
#             "flight.sav");          # default file name
#     selector.open();
#
#     selector.close();
#     selector.set_title("Save Another Flight");
#     selector.open();
#
var FileSelector = {
    new : func(callback, title, button, pattern = nil, dir = "", file = "", dotfiles = 0) {
        var name = "file-select-";
        var data = props.globals.getNode("/sim/gui/dialogs/", 1);
        var i = nil;
        for (i = 1; 1; i += 1)
            if (data.getNode(name ~ i, 0) == nil)
                break;
        data = data.getNode(name ~= i, 1);

        var m = Dialog.new(data.getNode("dialog", 1), "gui/dialogs/file-select.xml", name);
        m.parents = [FileSelector, Dialog];
        m.data = data;
        m.set_title(title);
        m.set_button(button);
        m.set_directory(dir);
        m.set_file(file);
        m.set_dotfiles(dotfiles);
        m.set_pattern(pattern);
        m.cblistener = setlistener(data.getNode("path", 1), callback);
        return m;
    },
    # setters only take effect after the next call to open()
    set_title     : func(title) { me.data.getNode("title", 1).setValue(title) },
    set_button    : func(button) { me.data.getNode("button", 1).setValue(button) },
    set_directory : func(dir) { me.data.getNode("directory", 1).setValue(dir) },
    set_file      : func(file) { me.data.getNode("selection", 1).setValue(file) },
    set_dotfiles  : func(dot) { me.data.getNode("dotfiles", 1).setBoolValue(dot) },
    set_pattern   : func(pattern) {
        me.data.removeChildren("pattern");
        if (pattern != nil)
            forindex (var i; pattern)
                me.data.getChild("pattern", i, 1).setValue(pattern[i]);
    },
    del : func {
        me.close();
        delete(me.instance, me.name);
        removelistener(me.cblistener);
        props.globals.getNode("/sim/gui/dialogs", 1).removeChildren(me.name);
    },
};


##
# Open property browser with given target path.
#
var property_browser = func(dir = "/") {
    var dlgname = "property-browser";
    foreach (var module; keys(globals)) {
        if (find("__dlg:" ~ dlgname, module) == 0) {
            globals[module].clone(dir);
            return;
        }
    }
    setprop("/sim/gui/dialogs/" ~ dlgname ~ "/last", dir);
    fgcommand("dialog-show", props.Node.new({"dialog-name": dlgname}));
}


##
# Open one property browser per /browser[] property, where each contains
# the target path. On the command line use  --prop:browser=orientation
#
settimer(func {
    foreach (var b; props.globals.getChildren("browser")) {
        var path = b.getValue();
        if (path != nil and size(path))
            property_browser(path);
    }
    props.globals.removeChildren("browser");
}, 0);


##
# Apply whole dialog or list of widgets. This copies the widgets'
# visible contents to the respective <property>.
#
var dialog_apply = func(dialog, objects...) {
    var n = props.Node.new({ "dialog-name" : dialog });
    if (!size(objects)) {
        return fgcommand("dialog-apply", n);
    }
    var name = n.getNode("object-name", 1);
    foreach (var o; objects) {
        name.setValue(o);
        fgcommand("dialog-apply", n);
    }
}


##
# Update whole dialog or list of widgets. This makes the widgets
# adopt and display the value of their <property>.
#
var dialog_update = func(dialog, objects...) {
    var n = props.Node.new({ "dialog-name" : dialog });
    if (!size(objects)) {
        return fgcommand("dialog-update", n);
    }
    var name = n.getNode("object-name", 1);
    foreach (var o; objects) {
        name.setValue(o);
        fgcommand("dialog-update", n);
    }
}


########################################################################
# GUI theming
########################################################################

nextStyle = func {
    numStyles = size(props.globals.getNode("/sim/gui").getChildren("style"));
    curr = getprop("/sim/gui/current-style") + 1;
    if (curr >= numStyles) {
        curr = 0;
    }
    setprop("/sim/gui/current-style", curr);
    fgcommand("gui-redraw");
}



########################################################################
# Dialog Boxes
########################################################################

dialog = {};

var setWeight = func(wgt, opt) {
    var lbs = opt.getNode("lbs", 1).getValue();
    wgt.getNode("weight-lb", 1).setValue(lbs);

    # Weights can have "tank" indices which set the capacity of the
    # corresponding tank.  This code should probably be moved to
    # something like fuel.setTankCap(tank, gals)...
    if(wgt.getNode("tank") == nil) { return 0; }
    var ti = wgt.getNode("tank").getValue();
    var gn = opt.getNode("gals");
    var gals = gn == nil ? 0 : gn.getValue();
    var tn = props.globals.getNode("consumables/fuel/tank["~ti~"]", 1);
    var ppg = tn.getNode("density-ppg", 1).getValue();
    var lbs = gals * ppg;
    var curr = tn.getNode("level-gal_us", 1).getValue();
    curr = curr > gals ? gals : curr;
    tn.getNode("capacity-gal_us", 1).setValue(gals);
    tn.getNode("level-gal_us", 1).setValue(curr);
    tn.getNode("level-lbs", 1).setValue(curr * ppg);
    return 1;
}

# Checks the /sim/weight[n]/{selected|opt} values and sets the
# appropriate weights therefrom.
var setWeightOpts = func {
    var tankchange = 0;
    foreach(w; props.globals.getNode("sim").getChildren("weight")) {
        var selected = w.getNode("selected");
        if(selected != nil) {
            foreach(opt; w.getChildren("opt")) {
                if(opt.getNode("name", 1).getValue() == selected.getValue()) {
                    if(setWeight(w, opt)) { tankchange = 1; }
                    break;
                }
            }
        }
    }
    return tankchange;
}
# Run it at startup and on reset to make sure the tank settings are correct
_setlistener("/sim/signals/fdm-initialized", func { settimer(setWeightOpts, 0) });
_setlistener("/sim/signals/reset", func { cmdarg().getBoolValue() or setWeightOpts() });


# Called from the F&W dialog when the user selects a weight option
var weightChangeHandler = func {
    var tankchanged = setWeightOpts();

    # This is unfortunate.  Changing tanks means that the list of
    # tanks selected and their slider bounds must change, but our GUI
    # isn't dynamic in that way.  The only way to get the changes on
    # screen is to pop it down and recreate it.
    if(tankchanged) {
        var p = props.Node.new({"dialog-name" : "WeightAndFuel"});
        fgcommand("dialog-close", p);
        showWeightDialog();
    }
}

##
# Dynamically generates a weight & fuel configuration dialog specific to
# the aircraft.
#
showWeightDialog = func {
    name = "WeightAndFuel";
    title = "Weight and Fuel Settings";

    #
    # General Dialog Structure
    #
    dialog[name] = Widget.new();
    dialog[name].set("name", name);
    dialog[name].set("layout", "vbox");

    header = dialog[name].addChild("text");
    header.set("label", title);

    dialog[name].addChild("hrule");

    if (props.globals.getNode("/yasim") == nil) {
        msg = dialog[name].addChild("text");
        msg.set("label", "Not supported for this aircraft");
        cancel = dialog[name].addChild("button");
        cancel.set("legend", "Cancel");
        cancel.setBinding("dialog-close");
        fgcommand("dialog-new", dialog[name].prop());
        showDialog(name);
        return;
    }


    contentArea = dialog[name].addChild("group");
    contentArea.set("layout", "hbox");

    grossWgt = props.globals.getNode("/yasim/gross-weight-lbs");
    if(grossWgt != nil) {
        gwg = dialog[name].addChild("group");
        gwg.set("layout", "hbox");
        gwg.addChild("empty").set("stretch", 1);
        gwg.addChild("text").set("label", "Gross Weight:");
        txt = gwg.addChild("text");
        txt.set("label", "0123456789");
        txt.set("format", "%.0f lb");
        txt.set("property", "/yasim/gross-weight-lbs");
        txt.set("live", 1);
        gwg.addChild("empty").set("stretch", 1);
    }

    buttonBar = dialog[name].addChild("group");
    buttonBar.set("layout", "hbox");
    buttonBar.set("default-padding", 10);

    ok = buttonBar.addChild("button");
    ok.set("legend", "OK");
    ok.set("key", "esc");
    ok.setBinding("dialog-apply");
    ok.setBinding("dialog-close");

    # Temporary helper function
    tcell = func(parent, type, row, col) {
        cell = parent.addChild(type);
        cell.set("row", row);
        cell.set("col", col);
        return cell;
    }

    #
    # Fill in the content area
    #
    fuelArea = contentArea.addChild("group");
    fuelArea.set("layout", "vbox");
    fuelArea.addChild("text").set("label", "Fuel Tanks");

    fuelTable = fuelArea.addChild("group");
    fuelTable.set("layout", "table");

    fuelArea.addChild("empty").set("stretch", 1);

    tcell(fuelTable, "text", 0, 0).set("label", "Tank");
    tcell(fuelTable, "text", 0, 3).set("label", "Pounds");
    tcell(fuelTable, "text", 0, 4).set("label", "Gallons");

    tanks = props.globals.getNode("/consumables/fuel").getChildren("tank");
    for(i=0; i<size(tanks); i+=1) {
        t = tanks[i];

        tname = i ~ "";
        tnode = t.getNode("name");
        if(tnode != nil) { tname = tnode.getValue(); }

        tankprop = "/consumables/fuel/tank["~i~"]";

        cap = t.getNode("capacity-gal_us", 1).getValue();

        # Hack, to ignore the "ghost" tanks created by the C++ code.
        if(cap == nil or cap < 1) { continue; }

        title = tcell(fuelTable, "text", i+1, 0);
        title.set("label", tname);
        title.set("halign", "right");

        sel = tcell(fuelTable, "checkbox", i+1, 1);
        sel.set("property", tankprop ~ "/selected");
        sel.set("live", 1);
        sel.setBinding("dialog-apply");

        slider = tcell(fuelTable, "slider", i+1, 2);
        slider.set("property", tankprop ~ "/level-gal_us");
        slider.set("live", 1);
        slider.set("min", 0);
        slider.set("max", cap);
        slider.setBinding("dialog-apply");

        lbs = tcell(fuelTable, "text", i+1, 3);
        lbs.set("property", tankprop ~ "/level-lbs");
        lbs.set("label", "0123456");
        lbs.set("format", "%.3f");
        lbs.set("live", 1);

        gals = tcell(fuelTable, "text", i+1, 4);
        gals.set("property", tankprop ~ "/level-gal_us");
        gals.set("label", "0123456");
        gals.set("format", "%.3f");
        gals.set("live", 1);
    }

    weightArea = contentArea.addChild("group");
    weightArea.set("layout", "vbox");
    weightArea.addChild("text").set("label", "Payload");

    weightTable = weightArea.addChild("group");
    weightTable.set("layout", "table");

    weightArea.addChild("empty").set("stretch", 1);

    tcell(weightTable, "text", 0, 0).set("label", "Location");
    tcell(weightTable, "text", 0, 2).set("label", "Pounds");

    wgts = props.globals.getNode("/sim").getChildren("weight");
    for(i=0; i<size(wgts); i+=1) {
        var w = wgts[i];
        var wname = w.getNode("name", 1).getValue();
        var wprop = "/sim/weight[" ~ i ~ "]";

        title = tcell(weightTable, "text", i+1, 0);
        title.set("label", wname);
        title.set("halign", "right");

        if(w.getNode("opt") != nil) {
            var combo = tcell(weightTable, "combo", i+1, 1);
            combo.set("property", wprop ~ "/selected");
            combo.set("pref-width", 300);

            # Simple code we'd like to use:
            #foreach(opt; w.getChildren("opt")) {
            #	var ent = combo.addChild("value");
            #	ent.prop().setValue(opt.getNode("name", 1).getValue());
            #}

            # More complicated workaround to move the "current" item
            # into the first slot, because dialog.cxx doesn't set the
            # selected item in the combo box.
            var opts = [];
            var curr = w.getNode("selected");
            curr = curr == nil ? "" : curr.getValue();
            foreach(opt; w.getChildren("opt")) {
                append(opts, opt.getNode("name", 1).getValue());
            }
            forindex(oi; opts) {
                if(opts[oi] == curr) {
                    var tmp = opts[0];
                    opts[0] = opts[oi];
                    opts[oi] = tmp;
                    break;
                }
            }
            foreach(opt; opts) {
                combo.addChild("value").prop().setValue(opt);
            }

            combo.setBinding("dialog-apply");
            combo.setBinding("nasal", "gui.weightChangeHandler()");
        } else {
            var slider = tcell(weightTable, "slider", i+1, 1);
            slider.set("property", wprop ~ "/weight-lb");
            var min = w.getNode("min-lb", 1).getValue();
            var max = w.getNode("max-lb", 1).getValue();
            slider.set("min", min != nil ? min : 0);
            slider.set("max", max != nil ? max : 100);
            slider.set("live", 1);
            slider.setBinding("dialog-apply");
        }

        lbs = tcell(weightTable, "text", i+1, 2);
        lbs.set("property", wprop ~ "/weight-lb");
        lbs.set("label", "0123456");
        lbs.set("format", "%.0f");
        lbs.set("live", 1);
    }

    # All done: pop it up
    fgcommand("dialog-new", dialog[name].prop());
    showDialog(name);
}




##
# Dynamically generates a dialog from a help node.
#
# gui.showHelpDialog([<path> [, toggle]])
#
# path   ... path to help node
# toggle ... decides if an already open dialog should be closed
#            (useful when calling the dialog from a key binding; default: 0)
#
# help node
# =========
# each of <title>, <key>, <line>, <text> is optional; uses
# "/sim/description" or "/sim/aircraft" if <title> is omitted;
# only the first <text> is displayed
#
#
# <help>
#     <title>dialog title<title>
#     <key>
#         <name>g/G</name>
#         <desc>gear up/down</desc>
#     </key>
#
#     <line>one line</line>
#     <line>another line</line>
#
#     <text>text in
#           scrollable widget
#     </text>
# </help>
#
showHelpDialog = func {
    node = props.globals.getNode(arg[0]);
    if (arg[0] == "/sim/help" and size(node.getChildren()) < 4) {
        node = node.getChild("common");
    }

    name = node.getNode("title", 1).getValue();
    if (name == nil) {
        name = getprop("/sim/description");
        if (name == nil) {
            name = getprop("/sim/aircraft");
        }
    }
    toggle = size(arg) > 1 and arg[1] != nil and arg[1] > 0;
    if (toggle and contains(dialog, name)) {
        fgcommand("dialog-close", props.Node.new({ "dialog-name" : name }));
        delete(dialog, name);
        return;
    }

    dialog[name] = Widget.new();
    dialog[name].set("layout", "vbox");
    dialog[name].set("default-padding", 0);
    dialog[name].set("name", name);

    # title bar
    titlebar = dialog[name].addChild("group");
    titlebar.set("layout", "hbox");
    titlebar.addChild("empty").set("stretch", 1);
    titlebar.addChild("text").set("label", name);
    titlebar.addChild("empty").set("stretch", 1);

    w = titlebar.addChild("button");
    w.set("pref-width", 16);
    w.set("pref-height", 16);
    w.set("legend", "");
    w.set("default", 1);
    w.set("key", "esc");
    w.setBinding("nasal", "delete(gui.dialog, \"" ~ name ~ "\")");
    w.setBinding("dialog-close");

    dialog[name].addChild("hrule");

    # key list
    keylist = dialog[name].addChild("group");
    keylist.set("layout", "table");
    keylist.set("default-padding", 2);
    keydefs = node.getChildren("key");
    n = size(keydefs);
    row = col = 0;
    foreach (key; keydefs) {
        if (n >= 60 and row >= n / 3 or n >= 16 and row >= n / 2) {
            col += 1;
            row = 0;
        }

        w = keylist.addChild("text");
        w.set("row", row);
        w.set("col", 2 * col);
        w.set("halign", "right");
        w.set("label", " " ~ key.getNode("name").getValue());

        w = keylist.addChild("text");
        w.set("row", row);
        w.set("col", 2 * col + 1);
        w.set("halign", "left");
        w.set("label", "... " ~ key.getNode("desc").getValue() ~ "  ");
        row += 1;
    }

    # separate lines
    lines = node.getChildren("line");
    if (size(lines)) {
        if (size(keydefs)) {
            dialog[name].addChild("empty").set("pref-height", 4);
            dialog[name].addChild("hrule");
            dialog[name].addChild("empty").set("pref-height", 4);
        }

        g = dialog[name].addChild("group");
        g.set("layout", "vbox");
        g.set("default-padding", 1);
        foreach (var lin; lines) {
            foreach (var l; split("\n", lin.getValue())) {
                w = g.addChild("text");
                w.set("halign", "left");
                w.set("label", " " ~ l ~ " ");
            }
        }
    }

    # scrollable text area
    if (node.getNode("text") != nil) {
        dialog[name].addChild("empty").set("pref-height", 10);

        width = [640, 800, 1152][col];
        height = screenHProp.getValue() - (100 + (size(keydefs) / (col + 1) + size(lines)) * 28);
        if (height < 200) {
            height = 200;
        }

        w = dialog[name].addChild("textbox");
        w.set("halign", "fill");
        w.set("slider", 20);
        w.set("pref-width", width);
        w.set("pref-height", height);
        w.set("editable", 0);
        w.set("property", node.getPath() ~ "/text");
    } else {
        dialog[name].addChild("empty").set("pref-height", 8);
    }
    fgcommand("dialog-new", dialog[name].prop());
    showDialog(name);
}


debug_keys = {
    title : "Development Keys",
    key : [
       #{ name : "Ctrl-U",    desc : "add 1000 ft of emergency altitude" },
        { name : "F2",        desc : "force tile cache reload" },
        { name : "F4",        desc : "force lighting update" },
        { name : "F8",        desc : "cycle fog type" },
        { name : "F9",        desc : "toggle textures" },
        { name : "Shift-F3",  desc : "load panel" },
        { name : "Shift-F4",  desc : "reload global preferences" },
        { name : "Shift-F9",  desc : "toggle FDM data logging" },
        { name : "Shift-Space", desc : "open property browser" },
    ],
};

basic_keys = {
    title : "Basic Keys",
    key : [
        { name : "?",         desc : "show/hide aircraft help dialog" },
       #{ name : "Tab",       desc : "show/hide aircraft config dialog" },
        { name : "Esc",       desc : "quit FlightGear" },
        { name : "Shift-Esc", desc : "reset FlightGear" },
        { name : "a/A",       desc : "increase/decrease speed-up" },
        { name : "c",         desc : "toggle 3D/2D cockpit" },
        { name : "Ctrl-C",    desc : "toggle clickable panel hotspots" },
        { name : "p",         desc : "pause/continue sim" },
        { name : "r",         desc : "activate instant replay system" },
        { name : "Ctrl-R",    desc : "show radio setting dialog" },
        { name : "t/T",       desc : "increase/decrease warp delta" },
        { name : "v/V",       desc : "cycle views (forward/backward)" },
        { name : "Ctrl-V",    desc : "select cockpit view" },
        { name : "w/W",       desc : "increase/decrease warp" },
        { name : "x/X",       desc : "zoom in/out" },
        { name : "Ctrl-X",    desc : "reset zoom to default" },
        { name : "z/Z",       desc : "increase/decrease visibility" },
        { name : "'",         desc : "display ATC setting dialog" },
        { name : "+",         desc : "let ATC/instructor repeat last message" },
        { name : "F1",        desc : "load flight" },
        { name : "F3",        desc : "capture screen" },
        { name : "F10",       desc : "toggle menubar" },
        { name : "Shift-F2",  desc : "save flight" },
        { name : "Shift-F10", desc : "cycle through GUI styles" },
    ],
};

common_aircraft_keys = {
    title : "Common Aircraft Keys",
    key : [
        { name : "Enter",     desc : "move rudder right" },
        { name : "0/Insert",  desc : "move rudder left" },
        { name : "1/End",     desc : "decrease elevator trim" },
        { name : "2/Up",      desc : "increase elevator or AP altitude" },
        { name : "3/PgDn",    desc : "decr. throttle or AP autothrottle" },
        { name : "4/Left",    desc : "move aileron left or adj. AP hdg." },
        { name : "5/KP5",     desc : "center aileron, elev., and rudder" },
        { name : "6/Right",   desc : "move aileron right or adj. AP hdg." },
        { name : "7/Home",    desc : "increase elevator trim" },
        { name : "8/Down",    desc : "decrease elevator or AP altitude" },
        { name : "9/PgUp",    desc : "incr. throttle or AP autothrottle" },
        { name : "Space",     desc : "fire starter on selected eng." },
        { name : "!/@/#/$",   desc : "select engine 1/2/3/4" },
        { name : "b",         desc : "apply all brakes" },
        { name : "B",         desc : "toggle parking brake" },
       #{ name : "Ctrl-B",    desc : "toggle speed brake" },
        { name : "g/G",       desc : "gear up/down" },
        { name : "h",         desc : "cycle HUD (head up display)" },
        { name : "H",         desc : "cycle HUD brightness" },
        { name : "i/Shift-i", desc : "normal/minimal HUD" },
       #{ name : "j",         desc : "decrease spoilers" },
       #{ name : "k",         desc : "increase spoilers" },
        { name : "l",         desc : "toggle tail-wheel lock" },
        { name : "m/M",       desc : "mixture richer/leaner" },
        { name : "n/N",       desc : "propeller finer/coarser" },
        { name : "P",         desc : "toggle 2D panel" },
        { name : "s",         desc : "swap panels" },
        { name : ", .",       desc : "left/right brake (comma, period)" },
        { name : "~",         desc : "select all engines (tilde)" },
        { name : "[ ]",       desc : "flaps up/down" },
        { name : "{ }",       desc : "decr/incr magneto on sel. eng." },
        { name : "Ctrl-A",    desc : "AP: toggle altitude lock" },
        { name : "Ctrl-G",    desc : "AP: toggle glide slope lock" },
        { name : "Ctrl-H",    desc : "AP: toggle heading lock" },
        { name : "Ctrl-N",    desc : "AP: toggle NAV1 lock" },
        { name : "Ctrl-P",    desc : "AP: toggle pitch hold" },
        { name : "Ctrl-S",    desc : "AP: toggle auto-throttle" },
        { name : "Ctrl-T",    desc : "AP: toggle terrain lock" },
        { name : "Ctrl-W",    desc : "AP: toggle wing leveler" },
        { name : "F6",        desc : "AP: toggle heading mode" },
        { name : "F11",       desc : "pop up autopilot (AP) dialog" },
        { name : "Shift-F5",  desc : "scroll 2D panel down" },
        { name : "Shift-F6",  desc : "scroll 2D panel up" },
        { name : "Shift-F7",  desc : "scroll 2D panel left" },
        { name : "Shift-F8",  desc : "scroll 2D panel right" },
    ],
};
