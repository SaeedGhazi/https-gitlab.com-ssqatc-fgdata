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
    setprop(Locks, "rev-hold", "off");
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
    setprop(Locks, "rev-hold", "off");
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
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "apr-arm", "off");
    setprop(Annunciators, "rev", "off");
    setprop(Annunciators, "rev-arm", "off");
    setprop(Annunciators, "vs", "off");
    setprop(Annunciators, "vs-number", "off");
    setprop(Annunciators, "fpm", "off");
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "gs-arm", "off");

    flasher("ap", 1.0, 5, "off");
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
    setprop(Locks, "rev-hold", "off");
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
         getprop(Locks, "roll-mode") == "rev" or
         getprop(Locks, "roll-mode") == "rev-arm")
  {
    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "rev-hold", "off");
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
    setprop(Annunciators, "rev", "off");

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
    setprop(Locks, "rev-hold", "off");
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
  elsif (getprop(Locks, "roll-mode") == "apr" or
         getprop(Locks, "roll-mode") == "apr-arm" or
         getprop(Locks, "pitch-mode") == "gs" or
         getprop(Locks, "pitch-mode") == "gs-arm")
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
    setprop(Annunciators, "hdg", "on");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "apr-arm", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "gs-arm", "off");
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

  ##
  # If we are in HDG mode we switch to the 45 degree angle intercept NAV mode
  ##
  if (getprop(Locks, "roll-mode") == "hdg")
  {
    flasher("hdg", 0.5, 8, "off");
      
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav-arm");

    nav_arm_from_hdg();
  }
  ##
  # If we are in ROL mode we switch to the all angle intercept NAV mode.
  ##
  elsif (getprop(Locks, "roll-mode") == "rol")
  {
    flasher("hdg", 0.5, 8, "off");

    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav-arm");

    nav_arm_from_rol();
  }
  ##
  # TODO:
  # NAV mode can only be armed if we are in HDG or ROL mode.
  # Can anyone verify that this is correct?
  ##
}

nav_arm_from_hdg = func
{
  ##
  # Abort the NAV-ARM mode if something has changed the roll mode to something
  # else than NAV-ARM.
  ##
  if (getprop(Locks, "roll-mode") != "nav-arm")
  {
    setprop(Annunciators, "nav-arm", "off");
    return;
  }

  setprop(Annunciators, "nav-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    print("flashing...");
    settimer(nav_arm_from_hdg, 2.5);
    return;
  }
  ##
  # Activate the nav-hold controller and check the needle deviation.
  ##
  setprop(Locks, "nav-hold", "nav");
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    print("deviation");
    settimer(nav_arm_from_hdg, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the NAV-ARM annunciator
  # and show the NAV annunciator. End of NAV-ARM sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "nav-arm", "off");
    setprop(Annunciators, "nav", "on");
  }
}

nav_arm_from_rol = func
{
  ##
  # Abort the NAV-ARM mode if something has changed the roll mode to something
  # else than NAV-ARM.
  ##
  if (getprop(Locks, "roll-mode") != "nav-arm")
  {
    setprop(Annunciators, "nav-arm", "off");
    return;
  }
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  setprop(Annunciators, "nav-arm", "on");
  if (flash_timer > -0.5)
  {
    print("flashing...");
    setprop(Annunciators, "rol", "off");
    settimer(nav_arm_from_rol, 2.5);
    return;
  }
  ##
  # Turn the ROL annunciator back on and activate the ROL mode.
  ##
  setprop(Annunciators, "rol", "on");
  setprop(Locks, "roll-axis", "trn");
  setprop(Settings, "target-turn-rate", 0.0);
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    print("deviation");
    settimer(nav_arm_from_rol, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the NAV-ARM annunciator
  # and show the NAV annunciator. End of NAV-ARM sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "nav-arm", "off");
    setprop(Annunciators, "nav", "on");

    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "nav");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav");
  }
}

apr_button = func {
  #print("apr_button");
  ##
  # If we are in HDG mode we switch to the 45 degree intercept angle APR mode
  ##
  if (getprop(Locks, "roll-mode") == "hdg")
  {
    flasher("hdg", 0.5, 8, "off");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "apr");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "apr-arm");
    #setprop(Locks, "pitch-axis", "vs");
    #setprop(Locks, "pitch-mode", "gs");

    apr_arm_from_hdg();
  }
  elsif (getprop(Locks, "roll-mode") == "rol")
  {
    flasher("hdg", 0.5, 8, "off");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "apr-arm");
    #setprop(Locks, "pitch-axis", "vs");
    #setprop(Locks, "pitch-mode", "vs");

    apr_arm_from_rol();
  }
}

apr_arm_from_hdg = func
{
  ##
  # Abort the APR-ARM mode if something has changed the roll mode to something
  # else than APR-ARM.
  ##
  if (getprop(Locks, "roll-mode") != "apr-arm")
  {
    setprop(Annunciators, "apr-arm", "off");
    return;
  }

  setprop(Annunciators, "apr-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    print("flashing...");
    settimer(apr_arm_from_hdg, 2.5);
    return;
  }
  ##
  # Activate the apr-hold controller and check the needle deviation.
  ##
  setprop(Locks, "apr-hold", "apr");
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    print("deviation");
    settimer(apr_arm_from_hdg, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the APR-ARM annunciator
  # and show the APR annunciator. End of APR-ARM sequence. Start the GS-ARM
  # sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "apr-arm", "off");
    setprop(Annunciators, "apr", "on");
    setprop(Locks, "pitch-mode", "gs-arm");

    gs_arm();
  }
}

apr_arm_from_rol = func
{
  ##
  # Abort the APR-ARM mode if something has changed the roll mode to something
  # else than APR-ARM.
  ##
  if (getprop(Locks, "roll-mode") != "apr-arm")
  {
    setprop(Annunciators, "apr-arm", "off");
    return;
  }

  setprop(Annunciators, "apr-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    print("flashing...");
    setprop(Annunciators, "rol", "off");
    settimer(apr_arm_from_rol, 2.5);
    return;
  }
  ##
  # Turn the ROL annunciator back on and activate the ROL mode.
  ##
  setprop(Annunciators, "rol", "on");
  setprop(Locks, "roll-axis", "trn");
  setprop(Settings, "target-turn-rate", 0.0);
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    print("deviation");
    settimer(apr_arm_from_rol, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the APR-ARM annunciator
  # and show the APR annunciator. End of APR-ARM sequence. Start the GS-ARM
  # sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "apr-arm", "off");
    setprop(Annunciators, "apr", "on");

    setprop(Locks, "apr-hold", "apr");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "apr");
    setprop(Locks, "pitch-mode", "gs-arm");

    gs_arm();
  }
}


gs_arm = func {
  ##
  # Abort the GS-ARM mode if something has changed the pitch mode to something
  # else than GS-ARM.
  ##
  if (getprop(Locks, "pitch-mode") != "gs-arm")
  {
    setprop(Annunciators, "gs-arm", "off");
    return;
  }

  setprop(Annunciators, "gs-arm", "on");

  deviation = getprop("/radios/nav/gs-needle-deflection");
  ##
  # If the deflection is more than 1 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 1.0)
  {
    print("deviation");
    settimer(gs_arm, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn off the GS-ARM annunciator
  # and show the GS annunciator. Activate the GS pitch mode.
  ##
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "vs", "off");
    setprop(Annunciators, "vs-number", "off");
    setprop(Annunciators, "fpm", "off");
    setprop(Annunciators, "gs-arm", "off");
    setprop(Annunciators, "gs", "on");

    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "gs-hold", "gs");
    setprop(Locks, "pitch-mode", "gs");
    #setprop(Locks, "hdg-hold", "hdg");
    #setprop(Locks, "nav-hold", "off");
    #setprop(Locks, "roll-axis", "trn");
    #setprop(Locks, "roll-mode", "apr");
  }

}


rev_button = func {
  #print("rev_button");
  ##
  # If we are in HDG mode we switch to the 45 degree intercept angle REV mode
  ##
  if (getprop(Locks, "roll-mode") == "hdg")
  {
    flasher("hdg", 0.5, 8, "off");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "rev-arm");
    #setprop(Locks, "pitch-axis", "vs");
    #setprop(Locks, "pitch-mode", "gs");

    rev_arm_from_hdg();
  }
  elsif (getprop(Locks, "roll-mode") == "rol")
  {
    flasher("hdg", 0.5, 8, "off");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "rev-arm");
    #setprop(Locks, "pitch-axis", "vs");
    #setprop(Locks, "pitch-mode", "vs");

    rev_arm_from_rol();
  }
}


rev_arm_from_hdg = func
{
  ##
  # Abort the REV-ARM mode if something has changed the roll mode to something
  # else than REV-ARM.
  ##
  if (getprop(Locks, "roll-mode") != "rev-arm")
  {
    setprop(Annunciators, "rev-arm", "off");
    return;
  }

  setprop(Annunciators, "rev-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    print("flashing...");
    settimer(rev_arm_from_hdg, 2.5);
    return;
  }
  ##
  # Activate the rev-hold controller and check the needle deviation.
  ##
  setprop(Locks, "rev-hold", "rev");
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    print("deviation");
    settimer(rev_arm_from_hdg, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the REV-ARM annunciator
  # and show the REV annunciator. End of REV-ARM sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "rev-arm", "off");
    setprop(Annunciators, "rev", "on");
  }
}


rev_arm_from_rol = func
{
  ##
  # Abort the REV-ARM mode if something has changed the roll mode to something
  # else than REV-ARM.
  ##
  if (getprop(Locks, "roll-mode") != "rev-arm")
  {
    setprop(Annunciators, "rev-arm", "off");
    return;
  }

  setprop(Annunciators, "rev-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    print("flashing...");
    setprop(Annunciators, "rol", "off");
    settimer(rev_arm_from_rol, 2.5);
    return;
  }
  ##
  # Turn the ROL annunciator back on and activate the ROL mode.
  ##
  setprop(Annunciators, "rol", "on");
  setprop(Locks, "roll-axis", "trn");
  setprop(Settings, "target-turn-rate", 0.0);
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    print("deviation");
    settimer(rev_arm_from_rol, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the REV-ARM annunciator
  # and show the REV annunciator. End of REV-ARM sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    print("capture");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "rev-arm", "off");
    setprop(Annunciators, "rev", "on");

    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "rev");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "rev");
    #setprop(Locks, "pitch-mode", "gs-arm");
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
