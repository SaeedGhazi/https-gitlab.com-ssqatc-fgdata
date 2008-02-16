# Damped G value - starts at 1.
var GDamped = 1.0;
var running = 0;
var fdm = "jsb";

var blackout_start = nil;
var blackout_end = nil;
var redout_start = nil;
var redout_end = nil;
var internal = nil;

var lp_black = nil;
var lp_red = nil;

var run = func {

  if (running)
  {
    var GCurrent = 1.0;

    if (fdm == "jsb")
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
        GDamped = lp_red.filter(GCurrent);
    }
    else
    {
        GDamped = lp_black.filter(GCurrent);
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

    settimer(run, 0);
  }
  else
  {
    # Disabled - remove all redout/blackout
    setprop("/sim/rendering/redout/alpha",0);
  }
}

var check_params = func() {
  blackout_start = getprop("/sim/rendering/redout/parameters/blackout-onset-g");
  blackout_end = getprop("/sim/rendering/redout/parameters/blackout-complete-g");
  redout_start = getprop("/sim/rendering/redout/parameters/redout-onset-g");
  redout_end = getprop("/sim/rendering/redout/parameters/redout-complete-g");

  if ((blackout_start == nil) or
      (blackout_end == nil)   or
      (redout_start == nil)   or
      (redout_end == nil)       )
  {
    # No valid properties - no point running
    running = 0;
  }
}

_setlistener("/sim/signals/nasal-dir-initialized",
  func {
    fdm = getprop("/sim/flight-model");
    check_params();
    running = getprop("/sim/rendering/redout/enabled");
    internal = getprop("/sim/current-view/internal");
    lp_black = aircraft.lowpass.new(0.2);
    lp_red = aircraft.lowpass.new(0.25);
    run();

    setlistener("/sim/rendering/redout/enabled", func(n) {
      if ((running == 0) and n.getBoolValue())
      {
        running = 1;
        run();
      }
      else
      {
        running = n.getBoolValue();
      }
    });

    setlistener("/sim/rendering/redout/parameters", func {
      # one parameter has changed, read them all in again
      check_params();
    }, 1, 2);

    setlistener("/sim/current-view/internal", func(n) {
      internal = n.getBoolValue();
    });
  }
);