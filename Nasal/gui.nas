##
# Pop up a "tip" dialog for a moment, then remove it.  The delay in
# seconds can be specified as the second argument.  The default is 1
# second.  Note that the tip dialog is a shared resource.  If
# someone else comes along and wants to pop a tip up before your delay
# is finished, you lose. :)
#
popupTip = func {
    msg = arg[0];
    delay = if(size(arg) > 1) {arg[1]} else {DELAY};
    labelNode.setValue(msg);
    
    # The "width" value here is a hardcoded hack that assumes 9 pixels
    # as a "typical" character width and adds some extra for the
    # widgets to play with.  Bah.  Pui needs a layout engine...
    width = 9 * size(msg) + 40;
    popupNode.getNode("width").setIntValue(width);
    popupNode.getNode("x").setIntValue((screenWProp.getValue() - width)/2);
    popupNode.getNode("y").setIntValue(screenHProp.getValue() - 140);

    popdown();
    fgcommand("dialog-new", popupNode);
    fgcommand("dialog-show", tipArg);

    currTimer = currTimer + 1;
    thisTimer = currTimer;
    settimer(func { if(currTimer == thisTimer) { popdown() } }, DELAY);
}

########################################################################
# Private Stuff:
########################################################################

##
# Initialize property nodes via a timer, to insure the props module is
# loaded.  See notes in view.nas
#
screenWProp = screenHProp = popupNode = labelNode = tipArg = nil;
INIT = func {
    screenWProp = props.globals.getNode("/sim/startup/xsize");
    screenHProp = props.globals.getNode("/sim/startup/ysize");
    
    # Set up the dialog property node:
    tmpl = { name : "PopTip", modal : 0,
             x : 100, y : 100, width : 120, height : 40,
             text : { x : 10, y : 6, label : "NOTE" } };
    popupNode = props.Node.new(tmpl);
    labelNode = popupNode.getNode("text/label");
    fgcommand("dialog-new", popupNode);

    # Cache the command argument for popup/popdown
    tipArg = props.Node.new({ "dialog-name" : "PopTip" });
}
settimer(INIT, 0);

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
