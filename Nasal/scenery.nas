###############################################################################
##
##  Support tools for multiplayer enabled scenery objects.
##
##  Copyright (C) 2011  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################

# The event channel for scenery objects.
# See mp_broadcast.EventChannel for documentation.
var events = nil;

###############################################################################
# An extended aircraft.door that transmits the door events over MP using the
# scenery.events channel.
# Use only for single instance objects (e.g. static scenery objects).
#
# Note: Currently toggle() is the only shared event.
var sharedDoor = {
    new: func(node, swingtime, pos = 0) {
        var obj = aircraft.door.new(node, swingtime, pos);
        obj.parents    = [sharedDoor] ~ obj.parents;
        obj.event_hash = mp_broadcast.Binary.stringHash
            (isa(node, props.Node) ? node.getPath() : node);
        events.register(obj.event_hash, func (msg) { obj._process(msg) });
        return obj;
    },
    toggle: func {
        events.send(me.event_hash, mp_broadcast.Binary.encodeByte(me.target));
        me.move(me.target);
    },
    destroy : func {
        events.deregister(me.event_hash);
    },
    _process : func (msg) {
        me.target = mp_broadcast.Binary.decodeByte(msg);
        me.move(me.target);
    }
};

###############################################################################
# Internals
var shared_pp = "scenery/share-events";

_setlistener("sim/signals/nasal-dir-initialized", func {
    events = mp_broadcast.EventChannel.new("scenery/events");
    if (!getprop("/sim/multiplay/online") or !getprop(shared_pp)) {
        #print("scenery.nas: stopping event sharing.");
        events.stop();
    }
    setlistener(shared_pp, func (n) {
        if (getprop("/sim/signals/reinit")) return; # Ignore resets.
        if (n.getValue() and getprop("/sim/multiplay/online")) {
            #print("scenery.nas: starting event sharing.");
            events.start();
        } else {
            #print("scenery.nas: stopping event sharing.");
            events.stop();
        }
    });
});
