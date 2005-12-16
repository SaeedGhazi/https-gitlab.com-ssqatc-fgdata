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
menuEnable = func(name, state) {
    foreach (menu; props.globals.getNode("/sim/menubar/default").getChildren("menu")) {
        if ((n = menu.getNode("name")) != nil and n.getValue() == name) {
            menu.getNode("enabled").setBoolValue(state);
            return;
        }
        foreach (item; menu.getChildren("item")) {
            if ((n = item.getNode("name")) != nil and n.getValue() == name) {
                item.getNode("enabled").setBoolValue(state);
                return;
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
screenHProp = tipArg = fps = nil;
INIT = func {
    screenHProp = props.globals.getNode("/sim/startup/ysize");
    tipArg = props.Node.new({ "dialog-name" : "PopTip" });
    fps = props.globals.getNode("/sim/rendering/fps-display");

    props.globals.getNode("/sim/help/debug", 1).setValues(debug_keys);
    props.globals.getNode("/sim/help/basic", 1).setValues(basic_keys);
    props.globals.getNode("/sim/help/common", 1).setValues(common_aircraft_keys);

    # enable/disable menu entries
    menuEnable("fuel-and-payload", getprop("/sim/flight-model") == "yasim");
    menuEnable("autopilot", props.globals.getNode("/autopilot/KAP140/locks") == nil);

    fps_loop();
}
settimer(INIT, 0);


##
# Show/hide the fps display dialog.
#
var show_fps = 0;
fps_loop = func {
    var i = fps.getValue();
    if (i != show_fps) {
        fgcommand(i ? "dialog-show" : "dialog-close",
                props.Node.new({"dialog-name": "fps"}));
        show_fps = i;
    }
    settimer(fps_loop, 1);
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
};



########################################################################
# GUI theming
########################################################################

nextStyle = func {
    numStyles = size(props.globals.getNode("/sim").getChildren("gui"));
    curr = getprop("/sim/current-gui") + 1;
    if (curr >= numStyles) {
        curr = 0;
    }
    setprop("/sim/current-gui", curr);
    fgcommand("gui-redraw", props.Node.new());
}



########################################################################
# Dialog Boxes
########################################################################

dialog = {};


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

    dialog[name].addChild("hrule").set("pref-height", 1);

    if (props.globals.getNode("/yasim") == nil) {
        msg = dialog[name].addChild("text");
        msg.set("label", "Not supported for this aircraft");
        cancel = dialog[name].addChild("button");
        cancel.set("legend", "Cancel");
        cancel.prop().getNode("binding[0]/command", 1).setValue("dialog-close");
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
    ok.set("keynum", 27);
    ok.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");
    ok.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

    # Temporary helper function
    tcell = func {
        cell = arg[0].addChild(arg[1]);
        cell.set("row", arg[2]);
        cell.set("col", arg[3]);
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
        if(cap < 1) { continue; }

        title = tcell(fuelTable, "text", i+1, 0);
        title.set("label", tname);
        title.set("halign", "right");

        sel = tcell(fuelTable, "checkbox", i+1, 1);
        sel.set("property", tankprop ~ "/selected");
        sel.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

        slider = tcell(fuelTable, "slider", i+1, 2);
        slider.set("property", tankprop ~ "/level-gal_us");
        slider.set("min", 0);
        slider.set("max", cap);
        slider.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

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
        w = wgts[i];
        wname = w.getNode("name", 1).getValue();
        max = w.getNode("max-lb", 1).getValue();
        wprop = "/sim/weight[" ~ i ~ "]/weight-lb";

        title = tcell(weightTable, "text", i+1, 0);
        title.set("label", wname);
        title.set("halign", "right");

        slider = tcell(weightTable, "slider", i+1, 1);
        slider.set("property", wprop);
        slider.set("min", 0);
        slider.set("max", max);
        slider.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

        lbs = tcell(weightTable, "text", i+1, 2);
        lbs.set("property", wprop);
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

    dialog[name] = gui.Widget.new();
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
    w.set("keynum", 27);
    w.prop().getNode("binding[0]/command", 1).setValue("nasal");
    w.prop().getNode("binding[0]/script", 1).setValue("delete(gui.dialog, \"" ~ name ~ "\")");
    w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

    dialog[name].addChild("hrule").addChild("empty");

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
            dialog[name].addChild("hrule").addChild("empty");
            dialog[name].addChild("empty").set("pref-height", 4);
        }

        g = dialog[name].addChild("group");
        g.set("layout", "vbox");
        g.set("default-padding", 1);
        foreach (l; lines) {
            w = g.addChild("text");
            w.set("halign", "left");
            w.set("label", " " ~ l.getValue() ~ " ");
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
        w.set("halign", "center");
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

