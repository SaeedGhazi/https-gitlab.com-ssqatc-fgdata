##
# Bendix/King KAP140 Two Axis Autopilot System
##

Locks = "/autopilot/KAP140/locks";
Settings = "/autopilot/KAP140/settings";
Annunciators = "/autopilot/KAP140/annunciators";
Internal = "/autopilot/internal";

annunciator = "";
annunciator_state = "";
flash_interval = 0.0;
flash_count = 0.0;
flash_timer = -1.0;



flasher = func {
  annunciator = arg[0];
  flash_interval = arg[1];
  flash_count = arg[2] + 1;
  annunciator_state = arg[3];

  flash_timer = 0.0;

  flash_annunciator();
}

flash_annunciator = func {
  #print(annunciator);
  #print(flash_interval);
  #print(flash_count);

  ##
  # If flash_timer is set to -1 then flashing is aborted
  if (flash_timer < -0.5)
  {
    setprop(Annunciators, annunciator, "off");
    return;
  }

  if (flash_timer < flash_count)
  {
    #flash_timer = flash_timer + 1.0;
    if (getprop(Annunciators, annunciator) == "on")
    {
      setprop(Annunciators, annunciator, "off");
      settimer(flash_annunciator, flash_interval / 2.0);
    }
    else
    #elsif (getprop(Annunciators, annunciator) == "off")
    {
      flash_timer = flash_timer + 1.0;
      setprop(Annunciators, annunciator, "on");
      settimer(flash_annunciator, flash_interval);
    }
  }
  else
  {
    flash_timer = -1.0;
    setprop(Annunciators, annunciator, annunciator_state);
  }
}

ap_button = func {
  #print("ap_button");

  ##
  # Engages the autopilot in Wings level mode (ROL) and Vertical speed hold
  # mode (VS).
  ##
  if (getprop(Locks, "roll-mode") == "off" and
      getprop(Locks, "pitch-mode") == "off")
  {
    flash_timer = -1.0;

    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "rol");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");

    setprop(Annunciators, "rol", "on");
    setprop(Annunciators, "vs", "on");
    setprop(Annunciators, "fpm", "on");
    setprop(Annunciators, "vs-number", "on");

    setprop(Settings, "target-turn-rate", 0.0);
    setprop(Settings, "target-pressure-rate", getprop(Internal,
    "pressure-rate"));
  }
  ##
  # Disengages all modes.
  ##
  elsif (getprop(Locks, "roll-mode") != "off" and
         getprop(Locks, "pitch-mode") != "off")
  {
    flash_timer = -1.0;

    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "off");
    setprop(Locks, "roll-mode", "off");
    setprop(Locks, "pitch-axis", "off");
    setprop(Locks, "pitch-mode", "off");

    setprop(Settings, "target-alt-pressure", 0.0);
    setprop(Settings, "target-intercept-angle", 0.0);
    setprop(Settings, "target-pressure-rate", 0.0);
    setprop(Settings, "target-turn-rate", 0.0);

    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "hdg", "off");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "nav-arm", "off");
    setprop(Annunciators, "vs", "off");
    setprop(Annunciators, "vs-number", "off");
    setprop(Annunciators, "fpm", "off");
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");

    flasher("ap", 1.0, 5, "off");

    setprop(Internal, "ft", 0.1);
  }
}


hdg_button = func {
  #print("hdg_button");

  ##
  # Engages the heading mode (HDG) and vertical speed hold mode (VS). The
  # commanded vertical speed is set to the vertical speed present at button
  # press.
  ##
  if (getprop(Locks, "roll-mode") == "off" and
      getprop(Locks, "pitch-mode") == "off")
  {
    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "hdg");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");

    setprop(Annunciators, "hdg", "on");
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "vs", "on");
    setprop(Annunciators, "vs-number", "on");
    setprop(Annunciators, "fpm", "on");

    setprop(Settings, "target-intercept-angle", 0.0);
    setprop(Settings, "target-pressure-rate", getprop(Internal,
    "pressure-rate"));
  }
  ##
  # Switch to HDG mode, but don't change pitch mode.
  ##
  elsif (getprop(Locks, "roll-mode") == "rol" or
         getprop(Locks, "roll-mode") == "nav" or
	 getprop(Locks, "roll-mode") == "nav-arm" or
         getprop(Locks, "roll-mode") == "rev")
  {
    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "hdg");
    #setprop(Locks, "pitch-axis", "off");
    #setprop(Locks, "pitch-mode", "off");

    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "hdg", "on");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "rol", "off");

    setprop(Settings, "target-intercept-angle", 0.0);
  }
  ##
  # If we already are in HDG mode switch to ROL mode. Again don't touch pitch
  # mode.
  ##
  elsif (getprop(Locks, "roll-mode") == "hdg")
  {
    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "rol");
    #setprop(Locks, "pitch-axis", "off");
    #setprop(Locks, "pitch-mode", "off");

    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "hdg", "off");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "rol", "on");

    setprop(Settings, "target-turn-rate", 0.0);
  }
  ##
  # If we are in APR mode we also have to change pitch mode.
  # TODO: Should we switch to VS or ALT mode? (currently VS)
  ##
  elsif (getprop(Locks, "roll-mode") == "apr" and
         getprop(Locks, "pitch-mode") == "gs")
  {
    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "hdg");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");

    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "hdg", "on");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "vs", "on");
    setprop(Annunciators, "vs-number", "on");
    setprop(Annunciators, "fpm", "on");

    setprop(Settings, "target-intercept-angle", 0.0);
    setprop(Settings, "target-pressure-rate", getprop(Internal,
    "pressure-rate"));
  }
}


nav_button = func {
  #print("nav_button");
  if (getprop(Locks, "roll-mode") == "hdg")
  {
    flasher("hdg", 0.5, 8, "off");
      
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav-arm");

    nav_arm_from_hdg();
  }
  elsif (getprop(Locks, "roll-mode") == "rol")
  {
    flasher("hdg", 0.5, 8, "off");

    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav-arm");

    nav_arm_from_rol();
  }
  elsif (getprop(Locks, "roll-mode") == "apr" and
         getprop(Locks, "pitch-mode") == "gs")
  {
    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "nav");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");

    setprop(Settings, "target-pressure-rate", getprop(Internal,
    "pressure-rate"));
  }
}

nav_arm_from_hdg = func
{
  if (getprop(Locks, "roll-mode") != "nav-arm")
  {
    setprop(Annunciators, "nav-arm", "off");
    return;
  }

  setprop(Annunciators, "nav-arm", "on");
  if (flash_timer > -0.5)
  {
    print("flashing...");
    settimer(nav_arm_from_hdg, 2.5);
    return;
  }

  setprop(Locks, "nav-hold", "nav");
  deviation = getprop("/radios/nav/heading-needle-deflection");
  if (abs(deviation) > 3.0)
  {
    print("deviation");
    settimer(nav_arm_from_hdg, 5);
    return;
  }
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "nav-arm", "off");
    setprop(Annunciators, "nav", "on");
  }
}

nav_arm_from_rol = func
{
  if (getprop(Locks, "roll-mode") != "nav-arm")
  {
    setprop(Annunciators, "nav-arm", "off");
    return;
  }

  setprop(Annunciators, "nav-arm", "on");
  if (flash_timer > -0.5)
  {
    print("flashing...");
    setprop(Annunciators, "rol", "off");
    settimer(nav_arm_from_rol, 2.5);
    return;
  }

  setprop(Annunciators, "rol", "on");
  setprop(Locks, "roll-axis", "trn");
  setprop(Settings, "target-turn-rate", 0.0);
  deviation = getprop("/radios/nav/heading-needle-deflection");
  if (abs(deviation) > 3.0)
  {
    print("deviation");
    settimer(nav_arm_from_rol, 5);
    return;
  }
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "nav-arm", "off");
    setprop(Annunciators, "nav", "on");

    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "nav");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav");
  }
}

apr_button = func {
  #print("apr_button");
  if (getprop(Locks, "roll-mode") == "hdg" or
      getprop(Locks, "roll-mode") == "rol" or
      getprop(Locks, "roll-mode") == "rev" or
      #getprop(Locks, "roll-mode") == "apr" or
      getprop(Locks, "pitch-mode") == "nav")
  {
    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "apr");
    setprop(Locks, "gs-hold", "gs");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "apr");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "gs");
  }
  elsif (getprop(Locks, "roll-mode") == "apr" and
         getprop(Locks, "pitch-mode") == "gs")
  {
    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "nav");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");

    setprop(Settings, "target-pressure-rate", getprop(Internal,
    "pressure-rate"));
  }
}


alt_button = func {
  #print("alt_button");
  if (getprop(Locks, "pitch-mode") == "alt")
  {
    setprop(Locks, "alt-hold", "off");
    #setprop(Locks, "apr-hold", "apr");
    #setprop(Locks, "gs-hold", "gs");
    #setprop(Locks, "hdg-hold", "off");
    #setprop(Locks, "nav-hold", "off");
    #setprop(Locks, "roll-axis", "trn");
    #setprop(Locks, "roll-mode", "apr");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");
    
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "vs", "on");    
    setprop(Annunciators, "vs-number", "on");
    setprop(Annunciators, "fpm", "on");

    setprop(Settings, "target-pressure-rate", getprop(Internal,
    "pressure-rate"));
  }
  elsif (getprop(Locks, "pitch-mode") == "vs")
  {
    setprop(Locks, "alt-hold", "alt");
    #setprop(Locks, "apr-hold", "off");
    #setprop(Locks, "gs-hold", "off");
    #setprop(Locks, "hdg-hold", "hdg");
    #setprop(Locks, "nav-hold", "nav");
    #setprop(Locks, "roll-axis", "trn");
    #setprop(Locks, "roll-mode", "nav");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "alt");

    setprop(Annunciators, "alt", "on");
    setprop(Annunciators, "vs", "off");
    setprop(Annunciators, "vs-number", "off");
    setprop(Annunciators, "fpm", "off");


    setprop(Settings, "target-alt-pressure",
    getprop("/systems/static/pressure-inhg"));
  }
}


dn_button = func {
  #print("dn_button");
  if (getprop(Locks, "pitch-mode") == "vs")
  {
    Target_VS = getprop(Settings, "target-pressure-rate");
    setprop(Settings, "target-pressure-rate", Target_VS +
    0.0017241379310345);
  }
  elsif (getprop(Locks, "pitch-mode") == "alt")
  {
    Target_Pressure = getprop(Settings, "target-alt-pressure");
    setprop(Settings, "target-alt-pressure", Target_Pressure + 0.0206);
  }
}


up_button = func {
  #print("up_button");
  if (getprop(Locks, "pitch-mode") == "vs")
  {
    Target_VS = getprop(Settings, "target-pressure-rate");
    setprop(Settings, "target-pressure-rate", Target_VS -
    0.0017241379310345);
  }
  elsif (getprop(Locks, "pitch-mode") == "alt")
  {
    Target_Pressure = getprop(Settings, "target-alt-pressure");
    setprop(Settings, "target-alt-pressure", Target_Pressure - 0.0206);
  }
}

ap_button();
