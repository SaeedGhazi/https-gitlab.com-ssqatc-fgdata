##
## These are just GUI helper routines.  The autopilot itself is not a
## Nasal module.
##

tagSettings =
    {
        "hdg-wing"     : ["/autopilot/locks/heading",  "wing-leveler"],
        "hdg-bug"      : ["/autopilot/locks/heading",  "dg-heading-hold"],
        "hdg-true"     : ["/autopilot/locks/heading",  "true-heading-hold"],
        "hdg-nav"      : ["/autopilot/locks/heading",  "nav1-hold"],
        "vel-throttle" : ["/autopilot/locks/speed",    "speed-with-throttle"],
        "vel-pitch"    : ["/autopilot/locks/speed",    "speed-with-pitch-trim"],
        "alt-vert"     : ["/autopilot/locks/altitude", "vertical-speed-hold"],
        "alt-pitch"    : ["/autopilot/locks/altitude", "pitch-hold"],
        "alt-aoa"      : ["/autopilot/locks/altitude", "aoa-hold"],
        "alt-alt"      : ["/autopilot/locks/altitude", "altitude-hold"],
        "alt-agl"      : ["/autopilot/locks/altitude", "agl-hold"],
        "alt-gs"       : ["/autopilot/locks/altitude", "gs1-hold"]
    };

radioGroups = [["hdg-wing", "hdg-bug", "hdg-true", "hdg-nav"],
               ["vel-throttle", "vel-pitch"],
               ["alt-vert", "alt-pitch", "alt-aoa", "alt-alt",
                "alt-agl", "alt-gs"]];

# Initialize to get the types of the gui properties correct
INIT = func {
    guinode = props.globals.getNode("/autopilot/gui", 1);
    foreach(tag; keys(tagSettings)) {
        guinode.getNode(tag, 1).setBoolValue(0);
    }
    foreach(tag; ["hdg", "alt", "vel"]) {
        guinode.getNode(tag ~ "-active", 1).setBoolValue(0);
    }
}
settimer(INIT, 0);

update = func {
    # Suck out the values from the dialog
    fgcommand("dialog-apply", props.Node.new());

    # Sanitize the radio buttons such that only one is selected.  We are
    # passed a tag indicating the one that was pressed.
    if(size(arg) > 0) {
        tag = arg[0];
        foreach(group; radioGroups) {
            for(i=0; i<size(group); i = i+1) {
                if(tag == group[i]) {
                    if(getprop("/autopilot/gui", tag)) {
                        # The user just turned it on, turn the rest off...
                        for(j=0; j<size(group); j=j+1) {
                            if(j != i) {
                                setprop("/autopilot/gui", group[j], 0);
                            }
                        }
                    } else {
                        # The user tried to turn off an active radio
                        # button.  Turn it back on.
                        setprop("/autopilot/gui", tag, 1);
                    }
                }
            }
        }
    }

    # Set the actual output properties for the autopilot system
    foreach(tag; keys(tagSettings)) {
        setting = tagSettings[tag];
        if(getprop("/autopilot/gui", tag)) {
            setprop(setting[0], setting[1]);
        }
    }
    if(!getprop("/autopilot/gui/hdg-active")) {
        setprop("/autopilot/locks/heading", ""); }
    if(!getprop("/autopilot/gui/alt-active")) {
        setprop("/autopilot/locks/altitude", ""); }
    if(!getprop("/autopilot/gui/vel-active")) {
        setprop("/autopilot/locks/speed", ""); }

    # Push any changes back to the dialog
    fgcommand("dialog-update", props.Node.new());
}
