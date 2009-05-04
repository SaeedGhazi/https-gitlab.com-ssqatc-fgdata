# Properties under /sim/model/pushback:
# + position-norm    - Position of pushback. 1 if connected.

# =====
# Pushback
# =====

Pushback = {};

Pushback.new = func {
   obj = { parents : [Pushback],
           pushback : aircraft.door.new("sim/model/pushback", 10.0),
         };
   return obj;
};
Pushback.pushbackexport = func {
   me.pushback.toggle();
}


# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
pushbacksystem = Pushback.new();
