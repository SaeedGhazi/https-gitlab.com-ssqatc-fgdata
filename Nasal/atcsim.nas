##
# ATC Flight Simulator specific code to manipulate avionics based on
# raw switch inputs.
#

##
# Initialize property nodes via a timer, to insure the props module is
# loaded.  See notes in view.nas.
#
have_hardware = nil;

last_com1_swap = 0;
last_com1_fine = 0;
last_com1_coarse = 0;

last_com2_swap = 0;
last_com2_fine = 0;
last_com2_coarse = 0;

last_nav1_swap = 0;
last_nav1_fine = 0;
last_nav1_coarse = 0;

last_nav2_swap = 0;
last_nav2_fine = 0;
last_nav2_coarse = 0;

last_adf_fine = 0;
last_adf_coarse = 0;

last_xpdr = [ 1, 2, 0, 0 ];
xpdr = [ 1, 2, 0, 0 ];

tuners_inited = 0;

INIT = func {
    have_hardware = props.globals.getNode( "/input/atc-board[0]" );
}
settimer( INIT, 0 );


##
# convenience functions
#
adf_working = func {
    has_power = getprop("/systems/electrical/outputs/adf");
    if ( has_power == nil ) {
        return 0;
    }
    if ( has_power < 1.0 ) {
        return 0;
    }
    if ( !getprop("/radios/kr-87/inputs/power-btn") ) {
        return 0;
    }
    if ( !getprop("/instrumentation/adf/serviceable") ) {
        return 0;
    }
    return 1;
}

dme_working = func {
    if ( getprop("/systems/electrical/outputs/dme") < 1.0 ) {
        return 0;
    }
    if ( !getprop("/input/atc-board/radio-switches/raw/dme-switch-position") ) {
        return 0;
    }
    if ( !getprop("/instrumentation/dme/serviceable") ) {
        return 0;
    }
    return 1;
}

navcom1_has_power = func {
    if ( getprop("/systems/electrical/outputs/navcom[0]") < 1.0 ) {
        return 0;
    }
    if ( !getprop("/radios/comm[0]/inputs/power-btn") ) {
        return 0;
    }
    return 1;
}

navcom2_has_power = func {
    if ( getprop("/systems/electrical/outputs/navcom[1]") < 1.0 ) {
        return 0;
    }
    if ( !getprop("/radios/comm[1]/inputs/power-btn") ) {
        return 0;
    }
    return 1;
}

com1_working = func {
    if ( !navcom1_has_power() ) {
        return 0;
    }
    if ( !getprop("/instrumentation/comm[0]/serviceable") ) {
        return 0;
    }
    return 1;
}

com2_working = func {
    if ( !navcom2_has_power() ) {
        return 0;
    }
    if ( !getprop("/instrumentation/comm[1]/serviceable") ) {
        return 0;
    }
    return 1;
}

nav1_working = func {
    if ( !navcom1_has_power() ) {
        return 0;
    }
    if ( !getprop("/instrumentation/nav[0]/serviceable") ) {
        return 0;
    }
    return 1;
}

nav2_working = func {
    if ( !navcom2_has_power() ) {
        return 0;
    }
    if ( !getprop("/instrumentation/nav[1]/serviceable") ) {
        return 0;
    }
    return 1;
}


xpdr_working = func {
    has_power = getprop("/systems/electrical/outputs/transponder");
    if ( has_power == nil ) {
        return 0;
    }
    if ( has_power < 1.0 ) {
        return 0;
    }
    if ( !getprop("/radios/kt-70/inputs/func-knob") ) {
        return 0;
    }
    if ( !getprop("/radios/kt-70/inputs/serviceable") ) {
        return 0;
    }
    return 1;
}


##
# Map DME switch input
#
do_dme_inputs = func {
    # dme switch
    dme_selector
        = getprop( "/input/atc-board/radio-switches/raw/dme-switch-position" );
    if ( dme_selector == 0 ) {
        setprop( "/instrumentation/dme/switch-position", 0 );
    } elsif ( dme_selector == 2 ) {
	setprop( "/instrumentation/dme/switch-position", 1 );
        setprop( "/instrumentation/dme/frequencies/source",
                 "/radios/nav[0]/frequencies/selected-mhz" );
	freq = getprop( "/radios/nav[0]/frequencies/selected-mhz" );
        if ( freq == nil ) {
            freq = "117.30";
        }
        setprop( "/instrumentation/dme/frequencies/selected-mhz", freq );
    } elsif ( dme_selector == 1 ) {
        setprop( "/instrumentation/dme/switch-position", 3 );
        setprop( "/instrumentation/dme/frequencies/source",
                 "/radios/nav[1]/frequencies/selected-mhz" );
	freq = getprop( "/radios/nav[1]/frequencies/selected-mhz" );
        if ( freq == nil ) {
            freq = "117.30";
        }
        setprop( "/instrumentation/dme/frequencies/selected-mhz", freq );
    }
}


##
#
#
initialize_tuners = func {
    last_com1_fine = getprop("/radios/comm[0]/inputs/fine-tuner");
    last_com1_coarse = getprop("/radios/comm[0]/inputs/coarse-tuner");

    last_com2_fine = getprop("/radios/comm[1]/inputs/fine-tuner");
    last_com2_coarse = getprop("/radios/comm[1]/inputs/coarse-tuner");

    last_nav1_fine = getprop("/radios/nav[0]/inputs/fine-tuner");
    last_nav1_coarse = getprop("/radios/nav[0]/inputs/coarse-tuner");

    last_nav2_fine = getprop("/radios/nav[1]/inputs/fine-tuner");
    last_nav2_coarse = getprop("/radios/nav[1]/inputs/coarse-tuner");

    last_adf_fine = getprop( "/radios/adf/inputs/fine-tuner" );
    last_adf_coarse = getprop("/radios/adf/inputs/coarse-tuner");

    last_xpdr[0] = getprop( "/radios/kt-70/inputs/tuner1" );
    last_xpdr[1] = getprop( "/radios/kt-70/inputs/tuner2" );
    last_xpdr[2] = getprop( "/radios/kt-70/inputs/tuner3" );
    last_xpdr[3] = getprop( "/radios/kt-70/inputs/tuner4" );

    tuners_inited = 1;
}


##
# Com1 inputs
#
do_com1_inputs = func {
    if ( com1_working() ) {
        com1_swap = getprop( "/radios/comm[0]/inputs/freq-swap" );
        if ( com1_swap and (last_com1_swap != com1_swap) ) {
            selected = getprop( "/radios/comm[0]/frequencies/selected-mhz" );
            standby = getprop( "/radios/comm[0]/frequencies/standby-mhz" );
            setprop( "/radios/comm[0]/frequencies/selected-mhz", standby );
            setprop( "/radios/comm[0]/frequencies/standby-mhz", selected );
        }
        last_com1_swap = com1_swap;

        com1_fine = getprop("/radios/comm[0]/inputs/fine-tuner");
        com1_coarse = getprop("/radios/comm[0]/inputs/coarse-tuner");
        freq = getprop( "/radios/comm[0]/frequencies/standby-mhz" );
        coarse_freq = int( freq );
        fine_freq = int( (freq - coarse_freq) * 40 + 0.5 );
        if ( com1_fine != last_com1_fine ) {
            diff = com1_fine - last_com1_fine;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( com1_fine < last_com1_fine ) {
                    # going up
                    diff = 12 - last_com1_fine + com1_fine;
                } else {
                    # going down
                    diff = com1_fine - 12 - last_com1_fine;
                }
            }
            fine_freq = fine_freq + diff;
        }
        while ( fine_freq >= 40.0 ) { fine_freq = fine_freq - 40.0; }
        while ( fine_freq < 0.0 )  { fine_freq = fine_freq + 40.0; }

        if ( com1_coarse != last_com1_coarse ) {
            diff = com1_coarse - last_com1_coarse;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( com1_coarse < last_com1_coarse ) {
                    # going up
                    diff = 12 - last_com1_coarse + com1_coarse;
                } else {
                    # going down
                    diff = com1_coarse - 12 - last_com1_coarse;
                }
            }
            coarse_freq = coarse_freq + diff;
        }
        if ( coarse_freq < 118.0 ) { coarse_freq = coarse_freq + 19.0; }
        if ( coarse_freq > 136.0 ) { coarse_freq = coarse_freq - 19.0; }

        last_com1_fine = com1_fine;
        last_com1_coarse = com1_coarse;

        setprop( "/radios/comm[0]/frequencies/standby-mhz", 
                 coarse_freq + fine_freq / 40.0 );
    }
}


##
# Com2 inputs
#
do_com2_inputs = func {
    if ( com2_working() ) {
        com2_swap = getprop( "/radios/comm[1]/inputs/freq-swap" );
        if ( com2_swap and (last_com2_swap != com2_swap) ) {
            selected = getprop( "/radios/comm[1]/frequencies/selected-mhz" );
            standby = getprop( "/radios/comm[1]/frequencies/standby-mhz" );
            setprop( "/radios/comm[1]/frequencies/selected-mhz", standby );
            setprop( "/radios/comm[1]/frequencies/standby-mhz", selected );
        }
        last_com2_swap = com2_swap;

        com2_fine = getprop("/radios/comm[1]/inputs/fine-tuner");
        com2_coarse = getprop("/radios/comm[1]/inputs/coarse-tuner");
        freq = getprop( "/radios/comm[1]/frequencies/standby-mhz" );
        coarse_freq = int( freq );
        fine_freq = int( (freq - coarse_freq) * 40 + 0.5 );
        if ( com2_fine != last_com2_fine ) {
            diff = com2_fine - last_com2_fine;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( com2_fine < last_com2_fine ) {
                    # going up
                    diff = 12 - last_com2_fine + com2_fine;
                } else {
                    # going down
                    diff = com2_fine - 12 - last_com2_fine;
                }
            }
            fine_freq = fine_freq + diff;
        }
        while ( fine_freq >= 40.0 ) { fine_freq = fine_freq - 40.0; }
        while ( fine_freq < 0.0 )  { fine_freq = fine_freq + 40.0; }

        if ( com2_coarse != last_com2_coarse ) {
            diff = com2_coarse - last_com2_coarse;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( com2_coarse < last_com2_coarse ) {
                    # going up
                    diff = 12 - last_com2_coarse + com2_coarse;
                } else {
                    # going down
                    diff = com2_coarse - 12 - last_com2_coarse;
                }
            }
            coarse_freq = coarse_freq + diff;
        }
        if ( coarse_freq < 118.0 ) { coarse_freq = coarse_freq + 19.0; }
        if ( coarse_freq > 136.0 ) { coarse_freq = coarse_freq - 19.0; }

        last_com2_fine = com2_fine;
        last_com2_coarse = com2_coarse;

        setprop( "/radios/comm[1]/frequencies/standby-mhz", 
                 coarse_freq + fine_freq / 40.0 );
    }
}


##
# Nav1 inputs
#
do_nav1_inputs = func {
    if ( nav1_working() ) {
        nav1_swap = getprop( "/radios/nav[0]/inputs/freq-swap" );
        if ( nav1_swap and (last_nav1_swap != nav1_swap) ) {
            selected = getprop( "/radios/nav[0]/frequencies/selected-mhz" );
            standby = getprop( "/radios/nav[0]/frequencies/standby-mhz" );
            setprop( "/radios/nav[0]/frequencies/selected-mhz", standby );
            setprop( "/radios/nav[0]/frequencies/standby-mhz", selected );
        }
        last_nav1_swap = nav1_swap;

        nav1_fine = getprop("/radios/nav[0]/inputs/fine-tuner");
        nav1_coarse = getprop("/radios/nav[0]/inputs/coarse-tuner");
        freq = getprop( "/radios/nav[0]/frequencies/standby-mhz" );
        coarse_freq = int( freq );
        fine_freq = int( (freq - coarse_freq) * 20 + 0.5 );
        if ( nav1_fine != last_nav1_fine ) {
            diff = nav1_fine - last_nav1_fine;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( nav1_fine < last_nav1_fine ) {
                    # going up
                    diff = 12 - last_nav1_fine + nav1_fine;
                } else {
                    # going down
                    diff = nav1_fine - 12 - last_nav1_fine;
                }
            }
            fine_freq = fine_freq + diff;
        }
        while ( fine_freq >= 20.0 ) { fine_freq = fine_freq - 20.0; }
        while ( fine_freq < 0.0 )  { fine_freq = fine_freq + 20.0; }

        if ( nav1_coarse != last_nav1_coarse ) {
            diff = nav1_coarse - last_nav1_coarse;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( nav1_coarse < last_nav1_coarse ) {
                    # going up
                    diff = 12 - last_nav1_coarse + nav1_coarse;
                } else {
                    # going down
                    diff = nav1_coarse - 12 - last_nav1_coarse;
                }
            }
            coarse_freq = coarse_freq + diff;
        }
        if ( coarse_freq < 108.0 ) { coarse_freq = coarse_freq + 10.0; }
        if ( coarse_freq > 117.0 ) { coarse_freq = coarse_freq - 10.0; }

        last_nav1_fine = nav1_fine;
        last_nav1_coarse = nav1_coarse;

        setprop( "/radios/nav[0]/frequencies/standby-mhz", 
                 coarse_freq + fine_freq / 20.0 );
    }
}


##
# Nav2 inputs
#
do_nav2_inputs = func {
    if ( nav2_working() ) {
        nav2_swap = getprop( "/radios/nav[1]/inputs/freq-swap" );
        if ( nav2_swap and (last_nav2_swap != nav2_swap) ) {
            selected = getprop( "/radios/nav[1]/frequencies/selected-mhz" );
            standby = getprop( "/radios/nav[1]/frequencies/standby-mhz" );
            setprop( "/radios/nav[1]/frequencies/selected-mhz", standby );
            setprop( "/radios/nav[1]/frequencies/standby-mhz", selected );
        }
        last_nav2_swap = nav2_swap;

        nav2_fine = getprop("/radios/nav[1]/inputs/fine-tuner");
        nav2_coarse = getprop("/radios/nav[1]/inputs/coarse-tuner");
        freq = getprop( "/radios/nav[1]/frequencies/standby-mhz" );
        coarse_freq = int( freq );
        fine_freq = int( (freq - coarse_freq) * 20 + 0.5 );
        if ( nav2_fine != last_nav2_fine ) {
            diff = nav2_fine - last_nav2_fine;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( nav2_fine < last_nav2_fine ) {
                    # going up
                    diff = 12 - last_nav2_fine + nav2_fine;
                } else {
                    # going down
                    diff = nav2_fine - 12 - last_nav2_fine;
                }
            }
            fine_freq = fine_freq + diff;
        }
        while ( fine_freq >= 20.0 ) { fine_freq = fine_freq - 20.0; }
        while ( fine_freq < 0.0 )  { fine_freq = fine_freq + 20.0; }

        if ( nav2_coarse != last_nav2_coarse ) {
            diff = nav2_coarse - last_nav2_coarse;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( nav2_coarse < last_nav2_coarse ) {
                    # going up
                    diff = 12 - last_nav2_coarse + nav2_coarse;
                } else {
                    # going down
                    diff = nav2_coarse - 12 - last_nav2_coarse;
                }
            }
            coarse_freq = coarse_freq + diff;
        }
        if ( coarse_freq < 108.0 ) { coarse_freq = coarse_freq + 10.0; }
        if ( coarse_freq > 117.0 ) { coarse_freq = coarse_freq - 10.0; }

        last_nav2_fine = nav2_fine;
        last_nav2_coarse = nav2_coarse;

        setprop( "/radios/nav[1]/frequencies/standby-mhz", 
                 coarse_freq + fine_freq / 20.0 );
    }
}


##
# ADF inputs
#
do_adf_inputs = func {
    if ( adf_working() ) {
        adf_fine = getprop( "/radios/adf/inputs/fine-tuner" );
        adf_coarse = getprop( "/radios/adf/inputs/coarse-tuner" );
        adf_count_mode = getprop( "/radios/kr-87/modes/count" );
        adf_stby_mode = getprop( "/radios/kr-87/modes/stby" );
        if ( adf_count_mode == 2 ) {
            # tune count down timer
            value = getprop( "/radios/kr-87/outputs/elapsed-timer" );
        } else {
            # tune frequency
            if ( adf_stby_mode == 1 ) {
                value = getprop( "/radios/kr-87/outputs/selected-khz" );
            } else {
                value = getprop( "/radios/kr-87/outputs/standby-khz" );
            }
        }

        if ( adf_fine != last_adf_fine ) {
            diff = adf_fine - last_adf_fine;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( adf_fine < last_adf_fine ) {
                    # going up
                    diff = 12 - last_adf_fine + adf_fine;
                } else {
                    # going down
                    diff = adf_fine - 12 - last_adf_fine;
                }
            }
            value = value + diff;
        }

        if ( adf_coarse != last_adf_coarse ) {
            diff = adf_coarse - last_adf_coarse;
            if ( globals.abs(diff) > 4 ) {
                # roll over
                if ( adf_coarse < last_adf_coarse ) {
                    # going up
                    diff = 12 - last_adf_coarse + adf_coarse;
                } else {
                    # going down
                    diff = adf_coarse - 12 - last_adf_coarse;
                }
            }
            if ( adf_count_mode == 2 ) {
                value = value + 60 * diff;
            } else {
                value = value + 25 * diff;
            }
        }
        if ( adf_count_mode == 2 ) {
            if ( value < 0 ) { value = value + 3600; }
            if ( value > 3599 ) { value = value - 3600; }
        } else {
            if ( value < 200 ) { value = value + 1600; }
            if ( value > 1799 ) { value = value - 1600; }
        }
 
        last_adf_fine = adf_fine;
        last_adf_coarse = adf_coarse;

        if ( adf_count_mode == 2 ) {
            setprop( "/radios/kr-87/outputs/elapsed-timer", value );
        } else {
            if ( adf_stby_mode == 1 ) {
                setprop( "/radios/kr-87/outputs/selected-khz", value );
            } else {
                setprop( "/radios/kr-87/outputs/standby-khz", value );
            }
        }
    }
}


##
# ADF inputs
#
do_xpdr_inputs = func {
    # map the function knob
    raw_knob = getprop( "/radios/kt-70/inputs/raw-func-knob" );
    if ( raw_knob == 0 ) {
        setprop( "/radios/kt-70/inputs/func-knob", 0 );
    } elsif ( raw_knob == 1 ) {
        setprop( "/radios/kt-70/inputs/func-knob", 1 );
    } elsif ( raw_knob == 2 ) {
        setprop( "/radios/kt-70/inputs/func-knob", 2 );
    } elsif ( raw_knob == 4 ) {
        setprop( "/radios/kt-70/inputs/func-knob", 3 );
    } elsif ( raw_knob == 8 ) {
        setprop( "/radios/kt-70/inputs/func-knob", 4 );
    } elsif ( raw_knob == 16 ) {
        setprop( "/radios/kt-70/inputs/func-knob", 5 );
    }

    if ( xpdr_working() ) {

        xpdr[0] = getprop( "/radios/kt-70/inputs/tuner1" );
        xpdr[1] = getprop( "/radios/kt-70/inputs/tuner2" );
        xpdr[2] = getprop( "/radios/kt-70/inputs/tuner3" );
        xpdr[3] = getprop( "/radios/kt-70/inputs/tuner4" );

        id_code = getprop( "/radios/kt-70/outputs/id-code" );

        place = 1000;
        digit = [ 0, 0, 0, 0 ];
        for ( i = 0; i < 4; i = i + 1 ) {
            digit[i] = int( id_code / place );
            id_code = id_code - digit[i] * place;
            place = place / 10;
        }

        for ( i = 0; i < 4; i = i + 1 ) {
            if ( xpdr[i] != last_xpdr[i] ) {
                diff = xpdr[i] - last_xpdr[i];
                if ( globals.abs(diff) > 4 ) {
                    # roll over
                    if ( xpdr[i] < last_xpdr[i] ) {
                        # going up
                        diff = 16 - last_xpdr[i] + xpdr[i];
                    } else {
                        # going down
                        diff = xpdr[i] - 16 - last_xpdr[i];
                    }
                }
                digit[i] = digit[i] + diff;
            }
            while ( digit[i] >= 8 ) { digit[i] = digit[i] - 8; }
            while ( digit[i] < 0 )  { digit[i] = digit[i] + 8; }
        }

        setprop( "/radios/kt-70/inputs/digit1", digit[0] );
        setprop( "/radios/kt-70/inputs/digit2", digit[1] );
        setprop( "/radios/kt-70/inputs/digit3", digit[2] );
        setprop( "/radios/kt-70/inputs/digit4", digit[3] );

        for ( i = 0; i < 4; i = i + 1 ) {
            last_xpdr[i] = xpdr[i];
        }
    }
}


##
# This is the main function.  I don't know the best way to trigger it
# each frame so I register it to run in the very near future, and at
# the end of running, I register it again.  Setting the time to 0
# seems to cause it to execute immediately which produces an infinite
# loop. :-(
#
do_hardware = func {
    # only execute if atcflightsim hardware is present and configured
    if ( have_hardware != nil ) {
        if ( ! tuners_inited ) {
            initialize_tuners();
        }
        do_dme_inputs();
        do_com1_inputs();
        do_com2_inputs();
        do_nav1_inputs();
        do_nav2_inputs();
        do_adf_inputs();
        do_xpdr_inputs();
    }
}


