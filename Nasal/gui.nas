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
    settimer(func { if(currTimer == thisTimer) { popdown() } }, DELAY);
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
