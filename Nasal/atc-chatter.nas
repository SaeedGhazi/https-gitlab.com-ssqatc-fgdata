#############################################################################
#
# Simple sequenced ATC background chatter function
#
# Written by Curtis Olson
# Started 8 Jan 2006.
#
#############################################################################

#############################################################################
# Global shared variables
#############################################################################

fg_root = "";
chatter = "UK";
chatter_dir = "";

chatter_min_interval = 20.0;
chatter_max_interval = 40.0;

chatter_index = 0;
chatter_size = 0;
chatter_list = 0;


#############################################################################
# Use tha nasal timer to call the initialization function once the sim is
# up and running
#############################################################################

CHATTER_INIT = func {
    # default values
    fg_root = getprop("/sim/fg-root");
    chatter_dir = sprintf("%s/ATC/Chatter/%s", fg_root, chatter);
    chatter_list = directory( chatter_dir );
    chatter_size = size(chatter_list);
    # seed the random number generator (with time) so we don't start in
    # same place in the sequence each run.
    srand();
    chatter_index = int( chatter_size * rand() );
}
settimer(CHATTER_INIT, 0);


#############################################################################
# main update function to be called each frame
#############################################################################

chatter_update = func {
    if ( chatter_index >= chatter_size ) {
        chatter_index = 0;
    }

    if ( substr(chatter_list[chatter_index],
                size(chatter_list[chatter_index]) - 4) == ".wav" )
    {	
	var vol =getprop("/sim/sound/atc-chatter-volume");
	if(vol == nil){vol = 0.5;}
        tmpl = { path : chatter_dir, file : chatter_list[chatter_index] , volume : vol};
        if ( getprop("/sim/sound/atc-chatter") ) {
            # go through the motions, but only schedule the message to play
            # if atc-chatter is enabled.
            printlog("info", "update atc chatter ", chatter_list[chatter_index] );
	    fgcommand("play-audio-message", props.Node.new(tmpl) );
        }
    } else {
        # skip non-wav file found in directory
    }

    chatter_index = chatter_index + 1;
    nextChatter();
}


#############################################################################
# Use tha nasal timer to update every 10 seconds
#############################################################################

nextChatter = func {
    # schedule next message in next min-max interval seconds so we have a bit
    # of a random pacing
    next_interval = chatter_min_interval
       + int(rand() * (chatter_max_interval - chatter_min_interval));
    # printlog("info", "next chatter in ", next_interval, " seconds");
    settimer(chatter_update, next_interval );
}
nextChatter();
