##
## view.nas
##
##  Nasal code for implementing view-specific functionality.  Right
##  now, it does intelligent FOV scaling in the view.increase() and
##  view.decrease() handlers.
##

#
# This is a neat trick.  We want these globals to be initialized at
# startup, but there is no guarantee that the props.nas module will be
# loaded yet when we are run.  So set the values to nil at startup (so
# that there is a value in the lexical environment -- otherwise
# assigning them in INIT() will only make local variables),
# and then assign them from inside a timer that we set to run
# immediately *after* startup.
#
# Nifty hacks notwithstanding, this really isn't the right way to do
# this.  There ought to be an "import" mechanism we can use to resolve
# dependencies between modules.
#
fovProp = nil;
INIT = func {
    fovProp = props.globals.getNode("/sim/current-view/field-of-view");

}
settimer(INIT, 0);

# Dynamically calculate limits so that it takes STEPS iterations to
# traverse the whole range, the maximum FOV is fixed at 120 degrees,
# and the minimum corresponds to normal maximum human visual acuity
# (~1 arc minute of resolution, although apparently people vary widely
# in this ability).  Quick derivation of the math:
#
#   mul^steps = max/min
#   steps * ln(mul) = ln(max/min)
#   mul = exp(ln(max/min) / steps)
STEPS = 40;
ACUITY = 1/60; # Maximum angle subtended by one pixel (== 1 arc minute)
max = min = mul = 0;
calcMul = func {
    max = 120; # Fixed at 120 degrees
    min = getprop("/sim/startup/xsize") * ACUITY;
    mul = math.exp(math.ln(max/min) / STEPS);
}

##
# Handler.  Increase FOV by one step
#
increase = func {
    calcMul();
    val = fovProp.getValue() * mul;
    if(val == max) { return; }
    if(val > max) { val = max }
    fovProp.setDoubleValue(val);
    gui.popupTip(sprintf("FOV: %.1f", val));
}

##
# Handler.  Decrease FOV by one step
#
decrease = func {
    calcMul();
    val = fovProp.getValue() / mul;
    fovProp.setDoubleValue(val);
    gui.popupTip(sprintf("FOV: %.1f%s", val, val < min ? " (overzoom)" : ""));
}

##
# Handler.  Reset FOV to default.
#
resetFOV = func {
    setprop("/sim/current-view/field-of-view",
            getprop("/sim/current-view/config/default-field-of-view-deg"));
}

##
# Handler.  Reset view to default.
#
resetView = func {
    setprop("/sim/current-view/goal-heading-offset-deg",
            getprop("/sim/current-view/config/heading-offset-deg"));
    setprop("/sim/current-view/goal-pitch-offset-deg",
            getprop("/sim/current-view/config/pitch-offset-deg"));
    setprop("/sim/current-view/goal-roll-offset-deg",
            getprop("/sim/current-view/config/roll-offset-deg"));
    resetFOV();
}

##
# Handler.  Step to the next view.
#
stepView = func {
    curr = getprop("/sim/current-view/view-number");
    views = props.globals.getNode("/sim").getChildren("view");
    curr = curr + arg[0];
    if   (curr < 0)            { curr = size(views) - 1; }
    elsif(curr >= size(views)) { curr = 0; }
    setprop("/sim/current-view/view-number", curr);

    # And pop up a nice reminder
    gui.popupTip(views[curr].getNode("name").getValue());
}

##
# Standard view "slew" rate, in degrees/sec.
#
VIEW_PAN_RATE = 60;

##
# Pans the view horizontally.  The argument specifies a relative rate
# (or number of "steps" -- same thing) to the standard rate.
#
panViewDir = func {
    controls.slewProp("/sim/current-view/goal-heading-offset-deg",
                      arg[0] * VIEW_PAN_RATE);
}

##
# Pans the view vertically.  The argument specifies a relative rate
# (or number of "steps" -- same thing) to the standard rate.
#
panViewPitch = func {
    controls.slewProp("/sim/current-view/goal-pitch-offset-deg",
                      arg[0] * VIEW_PAN_RATE);
}





#-- view manager --------------------------------------------------------------
#
# Saves/restores/moves the view point (position, orientation, field-of-view).
# Moves are interpolated with sinusoidal characteristic. There's only one
# instance of this class, available as "view.point".
#
# Usage:
#    view.point.save();        ... save current view and return reference to
#                                  saved values in the form of a props.Node
#
#    view.point.restore();     ... restore saved view parameters
#
#    view.point.move(<prop> [, <time>]);
#                              ... set view parameters from a props.Node with
#                                  optional move time in seconds. <prop> may be
#                                  nil, in which case nothing happens.
#
# A parameter set as expected by set() and returned by save() is a props.Node
# object containing any (or none) of these children:
#
#   <heading-offset-deg>
#   <pitch-offset-deg>
#   <roll-offset-deg>
#   <x-offset-m>
#   <y-offset-m>
#   <z-offset-m>
#   <field-of-view>
#   <move-time-sec>
#
# The <move-time> isn't really a property of the view, but is available
# for convenience. The time argument in the move() method overrides it.


##
# Normalize angle to  -180 <= angle < 180
#
var normdeg = func(a) {
    while (a >= 180) {
        a -= 360;
    }
    while (a < -180) {
        a += 360;
    }
    return a;
}


##
# Manages one translation/rotation axis. (For simplicity reasons the
# field-of-view parameter is also managed by this class.)
#
var ViewAxis = {
    new : func(prop) {
        var m = { parents : [ViewAxis] };
        m.prop = props.globals.getNode(prop, 1);
        if (m.prop.getType() == "NONE") {
            m.prop.setDoubleValue(0);
        }
        m.from = m.to = m.prop.getValue();
        return m;
    },
    reset : func {
        me.from = me.to = normdeg(me.prop.getValue());
    },
    target : func(v) {
        me.to = normdeg(v);
    },
    move : func(blend) {
        me.prop.setValue(me.from + blend * (me.to - me.from));
    },
};


var ViewManager = {
    new : func {
        var m = { parents : [ViewManager] };
        m.axes = {
            "heading-offset-deg" : ViewAxis.new("/sim/current-view/goal-heading-offset-deg"),
            "pitch-offset-deg" : ViewAxis.new("/sim/current-view/goal-pitch-offset-deg"),
            "roll-offset-deg" : ViewAxis.new("/sim/current-view/goal-roll-offset-deg"),
            "x-offset-m" : ViewAxis.new("/sim/current-view/x-offset-m"),
            "y-offset-m" : ViewAxis.new("/sim/current-view/y-offset-m"),
            "z-offset-m" : ViewAxis.new("/sim/current-view/z-offset-m"),
            "field-of-view" : ViewAxis.new("/sim/current-view/field-of-view"),
        };
        m.storeN = props.Node.new();
        m.dtN = props.globals.getNode("/sim/time/delta-realtime-sec", 1);
        m.currviewN = props.globals.getNode("/sim/current-view", 1);
        m.blend = 0;
        m.loop_id = 0;
        props.copy(props.globals.getNode("/sim/view/config"), m.storeN);
        return m;
    },
    save : func {
        me.storeN = props.Node.new();
        props.copy(me.currviewN, me.storeN);
        return me.storeN;
    },
    restore : func {
        me.move(me.storeN);
    },
    move : func(prop, time = nil) {
        prop != nil or return;
        foreach (var a; keys(me.axes)) {
            var n = prop.getNode(a);
            me.axes[a].reset();
            if (n != nil) {
                me.axes[a].target(n.getValue());
            }
        }
        var m = prop.getNode("move-time-sec");
        if (m != nil) {
            time = m.getValue();
        }
        if (time == nil) {
            time = 1;
        }
        me.blend = -1;   # range -1 .. 1
        me._loop_(me.loop_id += 1, time);
    },
    _loop_ : func(id, time) {
        me.loop_id == id or return;
        me.blend += me.dtN.getValue() / time;
        if (me.blend > 1) {
            me.blend = 1;
        }
        var b = (math.sin(me.blend * math.pi / 2) + 1) / 2; # range 0 .. 1
        foreach (var a; keys(me.axes)) {
            me.axes[a].move(b);
        }
        if (me.blend < 1) {
            settimer(func { me._loop_(id, time) }, 0);
        }
    },
};


var point = nil;

_setlistener("/sim/signals/nasal-dir-initialized", func {
    point = ViewManager.new();
    ViewManager.new = nil;
});

