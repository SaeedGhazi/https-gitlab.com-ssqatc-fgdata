var _bits = [var _ = 1];
for (var i = 1; i < 32; i += 1)
	append(_bits, _ += _);


# returns number <n> as bit string: bits.string(6) -> "110"
#
var string = func(n) {
	if (!n)
		return '0';
	var s = "";
	while (n) {
		s = ((var v = int(n / 2)) + v != n) ~ s;
		n = v;
	}
	return s;
}

# checks whether bit <b> is set in number <n>
#
var test = func(n, b) {
	while (b) {
		n /= 2;
		b -= 1;
	}
	int(n) != int(n / 2) * 2;
}


# returns number <n> with bit <b> set
#
var set = func(n, b) test(n, b) ? n : n + _bits[b];


# returns number <n> with bit <b> cleared
#
var clear = func(n, b) test(n, b) ? n - _bits[b] : n;
