
prop = props.globals.getNode("/velocities/airspeed-kt");
walkSanta = func {

    if ( prop.getValue() < 1.0) {
        interpolate("/tmp/walk", 0, 1);
	settimer(walkSanta, 0.5);
    } else {
        time = 1-prop.getValue()/8000;
	# When we're done, start it again:
	settimer(walkSanta, 3*time);
        interpolate("/tmp/walk",
                    -0.5, time/2,
                     0.5, time, -0.5, time,
                     0.5, time, -0.5, time,
                     0.0, time/2);
    }
}

settimer(walkSanta, 0);
