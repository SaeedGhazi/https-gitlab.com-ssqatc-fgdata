# test whether bit b (range 0..31) is set in integer number n
var test = func(n, b) {
	var s = buf(4);
	setfld(s, 0, 32, n);
	fld(s, b, 1);
}


# return integer number n with bit b set
var set = func(n, b) {
	var s = buf(4);
	setfld(s, 0, 32, n);
	setfld(s, b, 1, 1);
	fld(s, 0, 32);
}


# return integer number n with bit b cleared
var clear = func(n, b) {
	var s = buf(4);
	setfld(s, 0, 32, n);
	setfld(s, b, 1, 0);
	fld(s, 0, 32);
}


# return number as bit string
var string = func(n) {
	if (!n)
		return "0";
	var s = "";
	while (n) {
		s = ((var v = int(n / 2)) * 2 != n) ~ s;
		n = v;
	}
	return s;
}


