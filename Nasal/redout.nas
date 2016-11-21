# Damped G value - starts at 1.
var GDamped = 1.0;
var previousG = 1.0;
var running_compression = 0;
var fdm = "jsb";

var compression_rate = nil;
var internal = nil;

var lp_black = nil;
var lp_red = nil;

var run = func {

  if (running_compression)
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

    if (GCurrent == nil)
    {
      GCurrent = 1.0;
    }

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
      if (running_compression)
      {
        # Apply any compression due to G-forces
        if (GDamped != previousG)
        {
          var current_y_offset = getprop("/sim/current-view/y-offset-m");
          setprop("/sim/current-view/y-offset-m", current_y_offset - (GDamped - previousG) * compression_rate);
          previousG = GDamped;
        }
      }
    }

    settimer(run, 0);
  }
}

var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized",
  func {
    removelistener(fdm_init_listener); # uninstall, so we're only called once
    fdm = getprop("/sim/flight-model");
    running_compression = getprop("/sim/rendering/headshake/enabled");
    internal = getprop("/sim/current-view/internal");
    lp_black = aircraft.lowpass.new(0.2);
    lp_red = aircraft.lowpass.new(0.25);

    setlistener("/sim/current-view/internal", func(n) {
      internal = n.getBoolValue();
    });

    setlistener("/sim/rendering/headshake/rate-m-g", func(n) {
      compression_rate = n.getValue();
    }, 1);

    setlistener("/sim/rendering/headshake/enabled", func(n) {
      if ((running_compression == 0) and n.getBoolValue())
      {
        running_compression = 1;
        # start new timer now
        run();
      }
      else
      {
        running_compression = n.getBoolValue();
      }
    }, 1);

    # Now we've set up the listeners (which will have triggered), run it.
    run();
  }
);
