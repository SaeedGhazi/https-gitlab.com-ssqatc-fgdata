startEngine = func {
    sel = props.globals.getNode("/sim/input/selected");
    engs = props.globals.getNode("/controls/engines").getChildren("engine");
    for(i=0; i<size(engs); i=i+1) {
        select = sel.getChild("engine", i);
        if(select != nil and select.getValue()) {
            engs[i].getNode("starter").setBoolValue(1);
        }
    }
}

selectEngine = func {
    sel = props.globals.getNode("/sim/input/selected").getChildren("engine");
    foreach(node; sel) { node.setBoolValue(node.getIndex() == arg[0]); }
}

selectAllEngines = func {
    sel = props.globals.getNode("/sim/input/selected").getChildren("engine");
    foreach(node; sel) { node.setBoolValue(1); }
}

stepMagnetos = func {
    change = arg[0];
    engs = props.globals.getNode("/controls/engines").getChildren("engine");
    sel = props.globals.getNode("/sim/input/selected");
    for(i=0; i<size(engs); i=i+1) {
        select = sel.getChild("engine", i);
        if(select != nil and select.getValue()) {
            mag = engs[i].getNode("magnetos", 1);
            mag.setIntValue(mag.getValue() + change);
        }
    }
}

centerFlightControls = func {
    setprop("/controls/flight/elevator", 0);
    setprop("/controls/flight/aileron", 0);
    setprop("/controls/flight/rudder", 0);
}

throttleMouse = func {
    if(!getprop("/devices/status/mice/mouse[0]/button[1]")) { return; }
    val = (cmdarg().getNode("offset").getValue() * -4
           + getprop("/controls/engines/engine/throttle"));
    if(size(arg) > 0) { val = -val; }
    props.setAll("/controls/engines/engine", "throttle", val);
}

# Joystick axis handlers (uses cmdarg).  Shouldn't be called from
# other contexts.
throttleAxis = func {
    val = cmdarg().getNode("setting").getValue();
    if(size(arg) > 0) { val = -val; }
    props.setAll("/controls/engines/engine", "throttle", (1 - val)/2);
}
mixtureAxis = func {
    val = cmdarg().getNode("setting").getValue();
    if(size(arg) > 0) { val = -val; }
    props.setAll("/controls/engines/engine", "mixture", (1 - val)/2);
}
propellerAxis = func {
    val = cmdarg().getNode("setting").getValue();
    if(size(arg) > 0) { val = -val; }
    props.setAll("/controls/engines/engine", "propeller-pitch", (1 - val)/2);
}

##
# Wrapper around stepProps() which emulates the "old" flap behavior for
# configurations that aren't using the new mechanism.
#
stepFlaps = func {
    if(props.globals.getNode("/sim/flaps") != nil) {
        stepProps("/controls/flight/flaps", "/sim/flaps", arg[0]);
        return;
    }
    # Hard-coded flaps movement in 3 equal steps:
    val = 0.3333334 * arg[0] + getprop("/controls/flight/flaps");
    if(val > 1) { val = 1 } elsif(val < 0) { val = 0 }
    setprop("/controls/flight/flaps", val);
}

##
# Steps through an "array" of property settings.  The first argument
# specifies a destination property.  The second is a string containing
# a global property tree.  This tree should contain an array of
# indexed <setting> children.  This function will maintain a
# <current-setting> child, which contains the index of the currently
# active setting.  The third argument specifies an integer delta,
# indicating how many steps to move through the setting array.
# Note that because of the magic of the property system, this
# mechanism works for all scalar property types (bool, int, double,
# string).
#
# TODO: This interface could easily be extended to allow for wrapping,
# in addition to clamping, allowing a "cycle" of settings to be
# defined.  It could also be hooked up with the interpolate() call,
# which would allow the removal of the transition-time feature from
# YASim.  Finally, other pre-existing features (the views and engine
# magnetos, for instance), work similarly but not compatibly, and
# could be integrated.
#
stepProps = func {
    dst = props.globals.getNode(arg[0]);
    array = props.globals.getNode(arg[1]);
    delta = arg[2];
    if(dst == nil or array == nil) { return; }

    sets = array.getChildren("setting");

    curr = array.getNode("current-setting", 1).getValue();
    if(curr == nil) { curr = 0; }
    curr = curr + delta;
    if   (curr < 0)           { curr = 0; }
    elsif(curr >= size(sets)) { curr = size(sets) - 1; }

    array.getNode("current-setting").setIntValue(curr);
    dst.setValue(sets[curr].getValue());
}

##
# "Slews" a property smoothly, without dependence on the simulator
# frame rate.  The first argument is the property name.  The second is
# a rate, in units per second.
#
slewProp = func {
    prop = arg[0];
    delta = arg[1] * getprop("/sim/time/delta-realtime-sec");
    setprop(prop, getprop(prop) + delta);
}

# Standard trim rate, in units per second.  Remember that the full
# range of a trim axis is 2.0.  Should probably read this out of a
# property...
TRIM_RATE = 0.045;

##
# Handlers.  These are suitable for binding to repeatable button press
# events.  They are *not* good for binding to the keyboard, since (at
# least) X11 synthesizes its own key repeats.
#
elevatorTrim = func {
    slewProp("/controls/flight/elevator-trim", arg[0] * TRIM_RATE); }
aileronTrim = func {
    slewProp("/controls/flight/aileron-trim", arg[0] * TRIM_RATE); }
rudderTrim = func {
    slewProp("/controls/flight/rudder-trim", arg[0] * TRIM_RATE); }

THROTTLE_RATE = 0.33;

adjThrottle = func {
    adjEngControl("throttle", arg[0]); }
adjMixture = func {
    adjEngControl("mixture", arg[0]); }
adjPropeller = func {
    adjEngControl("propeller-pitch", arg[0]); }

adjEngControl = func {
    engs = props.globals.getNode("/controls/engines").getChildren("engine");
    delta = arg[1] * THROTTLE_RATE * getprop("/sim/time/delta-reltime-sec");
    foreach(e; engs) {
        node = e.getNode(arg[0], 1);
        node.setValue(node.getValue + delta);
    }
}

##
# Joystick axis handlers.  Don't call from other contexts.
#
elevatorTrimAxis = func { elevatorTrim(cmdarg().getNode("value").getValue()); }
aileronTrimAxis = func { aileronTrim(cmdarg().getNode("value").getValue()); }
rudderTrimAxis = func { rudderTrim(cmdarg().getNode("value").getValue()); }

