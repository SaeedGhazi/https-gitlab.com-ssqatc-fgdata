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
screenProp = nil;
popupNode = nil;
labelNode = nil;
fovDialog = nil;
INIT = func {
    print("view.INIT()");

    fovProp = props.globals.getNode("/sim/current-view/field-of-view");
    screenProp = props.globals.getNode("/sim/startup/xsize");
    
    # Set up the dialog property node:
    tmpl = { name : "fov", modal : 0, width : "120", height : "40",
             text : { x : 10, y : 6, label : "FOV:" } };
    popupNode = props.Node.new(tmpl);
    text = popupNode.getNode("text", 1);
    labelNode = popupNode.getNode("text/label");

    fgcommand("dialog-new", popupNode);

    # Cache the FGCommand argument
    fovDialog = props.Node.new({ "dialog-name" : "fov" });
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
    min = screenProp.getValue() * ACUITY;
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
    popup(val);
}

##
# Handler.  Decrease FOV by one step
#
decrease = func {
    calcMul();
    val = fovProp.getValue() / mul;
    if(val == min) { return; }
    if(val < min) { val = min }
    fovProp.setDoubleValue(val);
    popup(val);
}

##
# Pop up the "fov" dialog for a moment.
#
popdown = func { fgcommand("dialog-close", fovDialog); }
popup = func {
    fov = arg[0];
    fov = format(fov);

    labelNode.setValue("FOV: " ~ fov);

    # Create it, show it
    popdown();
    fgcommand("dialog-show", fovDialog);
                  
    # And kill it automatically after a second
    settimer(popdown, 1);
}

