# $Id$
print("Loading bo105.nas");
print("\tShift-C ... open/close rear door");

rearpos = "/controls/doors/rear";
rearstep = "/controls/doors/rear-state";
setprop(rearstep, 0);

reardoor = func {
	pos = getprop(rearpos);
	step = getprop(rearstep);
	if (pos == 0 or step < 0) {
		setprop(rearstep, 0.02);
	} elsif (pos == 1 or step > 0) {
		setprop(rearstep, -0.02);
	}
	settimer(MoveDoor, 0.05);
}

MoveDoor = func {
	pos = getprop(rearpos);
	step = getprop(rearstep);
	if (pos + step >= 0 and pos + step <= 1) {
		setprop(rearpos, pos + step);
		settimer(MoveDoor, 0.05);
	} else {
		if (step < 0) {
			setprop(rearpos, 0);
		} elsif (step > 0) {
			setprop(rearpos, 1);
		}
		setprop(rearstep, 0);
	}
}

print("Finished loading bo105.nas");
