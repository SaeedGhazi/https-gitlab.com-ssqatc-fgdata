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

chatter_index = 2;
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
    chatter_index = int( chatter_size * rand() );
}
settimer(CHATTER_INIT, 0);


#############################################################################
# main update function to be called each frame
#############################################################################

chatter_update = func {
    if ( chatter_index >= chatter_size ) {
        chatter_index = 2;
    }

    print("update atc chatter ", chatter_list[chatter_index] );

    tmpl = { path : chatter_dir, file : chatter_list[chatter_index] };
    if ( getprop("/sim/sound/atc-chatter") ) {
        # go through the motions, but only schedule the message to play
        # if atc-chatter is enabled.
        fgcommand("play-audio-message", props.Node.new(tmpl) );
    }
    chatter_index = chatter_index + 1;

    nextChatter();
}


#############################################################################
# Use tha nasal timer to update every 10 seconds
#############################################################################

nextChatter = func {
    # schedule next message in next 10-30 seconds so we have a bit
    # of a random pacing
    settimer(chatter_update, 10 + int(rand() * 20) );
}
nextChatter();
