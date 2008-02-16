# Damped G value - starts at 1.
var GDamped = 1.0;

var blackout = func {

    var enabled = getprop("/sim/rendering/redout/enabled");
    
    if (enabled)
    {
      var blackout_start = getprop("/sim/rendering/redout/blackout-onset-g");
      var blackout_end = getprop("/sim/rendering/redout/blackout-complete-g");
      var redout_start = getprop("/sim/rendering/redout/redout-onset-g");
      var redout_end = getprop("/sim/rendering/redout/redout-complete-g");
      var internal = getprop("/sim/current-view/internal");
      
      if ((blackout_start == nil) or 
          (blackout_end == nil)   or
          (redout_start == nil)   or
          (redout_end == nil)       )
      {
        # No valid properties - no point running
        return;
      }
      
      var GCurrent = 1.0;
      
      if (getprop("/sim/flight-model") == "jsb")
      {
        GCurrent = getprop("/accelerations/pilot/z-accel-fps_sec");
        if (GCurrent != nil) GCurrent = - GCurrent / 32;
      }
      else
      {
        GCurrent = getprop("/accelerations/pilot-g[0]");
      }
      

      if (GCurrent == nil) { GCurrent = 1.0; }

      # Updated the GDamped using a filter.
      if (GDamped < 0)
      {
          # Redout happens faster and clears quicker
          GDamped = GDamped * 0.75 + GCurrent * 0.25;
      }
      else
      {
          GDamped = GDamped * 0.8 + GCurrent * 0.2;
      }

      setprop("/accelerations/pilot-gdamped", GDamped);

      if (internal)
      {
        if (GDamped > blackout_start) 
        {
            # Blackout 
            setprop("/sim/rendering/redout/red",0);
            setprop("/sim/rendering/redout/alpha",
              (GDamped - blackout_start) / (blackout_end - blackout_start));
        }
        elsif (GDamped < redout_start) 
        {
            # Redout
            setprop("/sim/rendering/redout/red",1);
            setprop("/sim/rendering/redout/alpha", 
              abs((GDamped - redout_start) / (redout_end - redout_start)));
        }
        else 
        {
            setprop("/sim/rendering/redout/alpha",0);
        }
      }
      else
      {
         # Not in cockpit view - remove all redout/blackout
         setprop("/sim/rendering/redout/alpha",0);
      }
    }    
    else
    {
       # Disabled - remove all redout/blackout
       setprop("/sim/rendering/redout/alpha",0);
    }
    
    settimer(blackout, 0.1);
}

_setlistener("/sim/signals/nasal-dir-initialized", func { blackout(); });
