
prop = props.globals.getNode("/velocities/airspeed-kt");
walkSanta = func {

#    if ( prop.getValue() < 1.0) { interpolate("/tmp/walk", 0, 1); }
#    else {
        time = 1-prop.getValue()/8000;
        interpolate("/tmp/walk",
                    -0.5, time/2,
                     0.5, time, -0.5, time,
                     0.5, time, -0.5, time,
                     0.0, time/2);
#    }
    # When we're done, start it again:
    settimer(walkSanta, 5*time);
}

settimer(walkSanta, 0);
print("Done initializing Santa walk");
