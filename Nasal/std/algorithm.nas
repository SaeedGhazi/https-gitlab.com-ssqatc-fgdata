
# SPDX-FileCopyrightText: (C) 2023 Frederic Croix <thefgfseagle@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

var all = func(obj, key=nil) {
	if (!size(obj)) {
		return 0;
	}
	var res = 1;
	foreach (var o; obj) {
		if (key) {
			res &= key(o);
		} else {
			res &= o;
		}
		if (res == 0) {
			break;
		}
	}
	return res;
};

var any = func(obj, key=nil) {
	var res = 0;
	foreach (var o; obj) {
		if (key) {
			res |= key(o);
		} else {
			res |= o;
		}
		if (res == 1) {
			break;
		}
	}
	return res;
};

var map = func(f, obj) {
	var res = [];
	foreach (var o; obj) {
		append(res, f(o));
	}
	return res;
};

var filter = func(f, obj) {
	var res = [];
	foreach (var o; obj) {
		if (f) {
			if (f(o)) {
				append(res, o);
			}
		} elsif (o) {
			append(res, o);
		}
	}
	return res;
};