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
# Hackish round-to-one-decimal-place function.  Nasal needs a
# sprintf() interface, or something similar...
#
format = func {
    val = int(arg[0]);
    frac = int(10 * (arg[0] - val) + 0.5);
    return val ~ "." ~ substr("" ~ frac, 0, 1);
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
    gui.popupTip("FOV: " ~ format(val));
}

##
# Handler.  Decrease FOV by one step
#
decrease = func {
    calcMul();
    val = fovProp.getValue() / mul;
    msg = "FOV: " ~ format(val);
    if(val < min) { msg = msg ~ " (overzoom)"; }
    fovProp.setDoubleValue(val);
    gui.popupTip(msg);
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
    setprop("/sim/current-view/field-of-view",
            getprop("/sim/current-view/config/default-field-of-view-deg"))
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
