# This is a script that controls a target aircraft for various target/tracking
# tasks.


printlog("info", "Target Lead script loading ...");

# script defaults (configurable if you like)
default_update_period = 0.05;
default_goal_range_nm = 0.2;
default_target_root = "/ai/models/aircraft[0]";
default_target_task = "straight";

# master enable switch
lead_target_enable = 0;

# update period
update_period = default_update_period;

# goal range to acheive when following target
goal_range_nm = 0;

# Target property tree root
target_root = "";

# Target task (straight, turns, pitch, both)
target_task = default_target_task;
base_alt = 3000;
tgt_alt = base_alt;
tgt_hdg = 20;
tgt_pitch = 0;
tgt_roll = 0;
tgt_speed = 280;
tgt_lat_mode = "roll";
tgt_lon_mode = "alt";
next_turn = 0;
next_pitch = 0;
last_time = 0;


# Calculate new lon/lat given starting lon/lat, and offset radial, and
# distance.  NOTE: starting point is specifed in radians, distance is
# specified in meters (and converted internally to radians)
# ... assumes a spherical world.
# @param orig lon specified in polar coordinates
# @param orig lat specified in polar coordinates
# @param course offset radial
# @param dist offset distance
# @return destination point in polar coordinates

# define some global constants
SG_METER_TO_NM = 0.0005399568034557235;
SG_NM_TO_RAD   = 0.00029088820866572159;
SG_EPSILON     = 0.0000001;
SGD_PI         = 3.14159265358979323846;
SGD_2PI        = 6.28318530717958647692;
SGDTR          = SGD_PI / 180.0;
fmod = func(x, y) { x - y * int(x/y) }
asin = func(y) { math.atan2(y, math.sqrt(1-y*y)) }

CalcGClonlat = func( lon_rad, lat_rad, hdg_rad, dist_m ) {
    result = [0, 0];

    # sanity check
    while ( hdg_rad < 0 ) { hdg_rad += SGD_2PI; }
    while ( hdg_rad >= SGD_2PI ) { hdg_rad -= SGD_2PI; }

    print("lon = ", lon_rad, " lat = ", lat_rad, " hdg = ", hdg_rad, " dist = ",
          dist_m);

    # lat=asin(sin(lat1)*cos(d)+cos(lat1)*sin(d)*cos(tc))
    # IF (cos(lat)=0)
    #   lon=lon1      // endpoint a pole
    # ELSE
    #   lon=mod(lon1-asin(sin(tc)*sin(d)/cos(lat))+pi,2*pi)-pi
    # ENDIF

    dist_rad = dist_m * SG_METER_TO_NM * SG_NM_TO_RAD;

    result[1] = asin( math.sin(lat_rad) * math.cos(dist_rad) +
                      math.cos(lat_rad) * math.sin(dist_rad) *
                      math.cos(hdg_rad) );

    if ( math.cos(result[1]) < SG_EPSILON ) {
        result[0] = lon_rad;      # endpoint a pole
    } else {
        result[0] = 
            fmod(lon_rad - asin( (math.sin(hdg_rad) *
                                 math.sin(dist_rad)) /
                                 math.cos(result[1]) )
                      + SGD_PI, SGD_2PI) - SGD_PI;
    }

    print("new lon = ", result[0], " new lat = ", result[1]);

    return result;
}


# Initialize target tracking
LeadTargetInit = func {
    # seed the random number generator with time
    srand();

    lead_target_enable = getprop("/autopilot/lead-target/enable");
    if ( lead_target_enable == nil ) {
        lead_target_enable = 0;
        setprop("/autopilot/lead-target/enable", lead_target_enable);
    }

    target_task = getprop("/autopilot/lead-target/task");
    if ( target_task == nil ) {
        target_task = default_target_task;
        setprop("/autopilot/lead-target/task", target_task);
    }

    update_period = getprop("/autopilot/lead-target/update-period");
    if ( update_period == nil ) {
        update_period = default_update_period;
        setprop("/autopilot/lead-target/update-period", update_period);
    }

    goal_range_nm = getprop("/autopilot/lead-target/goal-range-nm");
    if ( goal_range_nm == nil ) {
        goal_range_nm = default_goal_range_nm;
        setprop("/autopilot/lead-target/goal-range-nm", goal_range_nm);
    }

    target_root = getprop("/autopilot/lead-target/target-root");
    if ( target_root == nil ) {
        target_root = default_target_root;
        setprop("/autopilot/lead-target/target-root", target_root);
    }
}
settimer(LeadTargetInit, 0);


# update target task
do_target_task = func {
    time = getprop("/sim/time/elapsed-sec");
    dt = time - last_time;
    last_time = time;

    target_task = getprop("/autopilot/lead-target/task");

    if ( target_task == "straight" ) {
        tgt_lat_mode = "roll";
        tgt_lon_mode = "alt";
        tgt_roll = 0;
        tgt_alt = base_alt;
    } else {
        if ( target_task == "turns" or target_task == "both" ) {
            next_turn -= dt;
            if ( next_turn < 0 ) {
                if ( tgt_roll > 0 ) {
                    # new roll between [-45 - -15]
                    tgt_roll = -45.0 + rand() * 30.0;
                } else {
                    # new roll between [15 - 45]
                    tgt_roll = rand() * 30.0 + 15.0;
                }
                # next turn between 5 - 15 seconds
                next_turn = rand() * 10.0 + 5.0;

                # roll to zero if tgt_speed < 50 so we don't spin in mid air
                if ( tgt_speed < 50 ) { tgt_roll = 0; }
            }
            tgt_lat_mode = "roll";
        }
        if ( target_task == "pitch" or target_task == "both" ) {
            next_pitch -= dt;
            if ( next_pitch < 0 ) {
                if ( tgt_alt > base_alt ) {
                    # new alt between [2000 - 2500]
                    tgt_alt = base_alt - 1000.0 + rand() * 500.0;
                } else {
                    # new alt between [3500 - 4000]
                    tgt_alt = base_alt + 500.0 + rand() * 500.0;
                }
                # next pitch between 5 - 15 seconds
                next_pitch = rand() * 10.0 + 5.0;
                print("--> alt = ", tgt_alt, " next in ", next_pitch, " secs");

                # ??? (fixme?)
                # pitch to zero if tgt_speed < 50 so we don't porpoise in
                # mid air
                # if ( tgt_speed < 50 ) { tgt_pitch = 0; }
            }
            tgt_lon_mode = "alt";
        }
        # fixed altitude if in turns mode
        if ( target_task == "turns" ) {
            tgt_lon_mode = "alt";
            tgt_alt = base_alt;
        }
        # zero roll if in pitch mode
        if ( target_task == "pitch" ) {
            tgt_lat_mode = "roll";
            tgt_roll = 0;
        }
    }

    tgt_lat_prop = sprintf("%s/controls/flight/lateral-mode",
                           target_root );
    setprop(tgt_lat_prop, tgt_lat_mode);

    tgt_lon_prop = sprintf("%s/controls/flight/longitude-mode",
                           target_root );
    setprop(tgt_lon_prop, tgt_lon_mode);


    if ( tgt_lat_mode == "roll" ) {
        tgt_roll_prop = sprintf("%s/controls/flight/target-roll", target_root );
        setprop(tgt_roll_prop, tgt_roll);
    } else {
        tgt_hdg_prop = sprintf("%s/controls/flight/target-hdg", target_root );
        setprop(tgt_hdg_prop, tgt_hdg);
    }

    if ( tgt_lon_mode == "alt" ) {
        tgt_alt_prop = sprintf("%s/controls/flight/target-alt", target_root );
        setprop(tgt_alt_prop, tgt_alt);
    } else {
        tgt_pitch_prop = sprintf("%s/controls/flight/target-pitch",
                                 target_root );
        setprop(tgt_pitch_prop, tgt_pitch);
    }
}


# reset target aircraft position and heading relative to the "ownship".
reset_target_aircraft = func {
    print("Reseting target aircraft position");

    my_lon = getprop("/position/longitude-deg");
    my_lat = getprop("/position/latitude-deg");
    my_alt = getprop("/position/altitude-ft");
    my_hdg = getprop("/orientation/heading-deg");
    my_spd = getprop("/velocities/airspeed-kt");

    result = CalcGClonlat( my_lon*SGDTR, my_lat*SGDTR, -my_hdg*SGDTR,
                           0.5/SG_METER_TO_NM );

    target_root = getprop("/autopilot/lead-target/target-root");

    target_prop = sprintf("%s/position/longitude-deg", target_root );
    setprop(target_prop, result[0]/SGDTR);

    target_prop = sprintf("%s/position/latitude-deg", target_root );
    setprop(target_prop, result[1]/SGDTR);

    target_prop = sprintf("%s/position/altitude-ft", target_root );
    setprop(target_prop, my_alt);

    target_prop = sprintf("%s/orientation/true-heading-deg", target_root );
    setprop(target_prop, my_hdg);

    target_prop = sprintf("%s/velocities/true-airspeed-kt", target_root );
    setprop(target_prop, my_spd);

    base_alt = my_alt;
}


# If enabled, update our AP target values based on the target range,
# bearing, and speed
LeadTargetUpdate = func {
    lead_target_enable = props.globals.getNode("/autopilot/lead-target/enable");
    update_period = getprop("/autopilot/lead-target/update-period");

    if ( lead_target_enable.getBoolValue() ) {
        # refresh user configurable values
        goal_range_nm = getprop("/autopilot/lead-target/goal-range-nm");
        target_root = getprop("/autopilot/lead-target/target-root");

        # force radar debug-mode on (forced radar calculations even if
        # no radar instrument and ai aircraft are out of range
        setprop("/instrumentation/radar/debug-mode", 1);

        # update target task
        do_target_task();

        my_hdg = getprop("/orientation/heading-deg");

        alt = getprop("/position/altitude-ft");
        if ( alt == nil ) { alt = 0; }
    
        speed = getprop("/velocities/airspeed-kt");
        if ( speed == nil ) { speed = 0; }
    
        range_prop = sprintf("%s/radar/range-nm", target_root );
        range = getprop(range_prop);
        if ( range == nil ) {
            print("bad property path: ", range_prop);
            return;
        }
        if ( range > 3.0 ) {
            # if range is greater than threshold, then reset the target
            # aircraft back in range/view.
            reset_target_aircraft();
        }
    
        h_offset_prop = sprintf("%s/radar/h-offset", target_root );
        h_offset = getprop(h_offset_prop);
        if ( h_offset == nil ) {
            print("bad property path: ", h_offset_prop);
            return;
        }

        if ( h_offset > -90 and h_offset < 90 ) {
            # in front of us
            range_error = goal_range_nm - range;
        } else {
            # behind us
            range_error = goal_range_nm + range;
        }
        if ( range_error < 0 ) {
            # slow the target down
            tgt_speed = speed + range_error * 300.0;
        } else {
            # speed the target up agressively
            tgt_speed = speed + range_error * 2000.0;
        }
        if ( tgt_speed < 0 ) { tgt_speed = 0; }

        # print("speed = ", speed, " range err = ", range_error,
        #       " target spd = ", tgt_speed);

        speed_prop = sprintf("%s/controls/flight/target-spd", target_root );
        setprop( speed_prop, tgt_speed );
    }

    # last thing to do before we return from this function
    registerTimer();
}


select_task_dialog = func {
    var dlg = props.globals.getNode("/sim/gui/dialogs/NTPS/config/dialog", 1);
    gui.loadXMLDialog(dlg, "gui/dialogs/NTPS_target_task.xml");
    fgcommand("dialog-show", dlg);
}


# timer handling to cause our update function to be called periodially
registerTimer = func {
    settimer(LeadTargetUpdate, update_period );
}
registerTimer();

