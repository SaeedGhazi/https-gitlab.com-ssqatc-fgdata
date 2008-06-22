var iscntrl = func(c) { c >= 1 and c <= 31 or c == 127 }
var isascii = func(c) { c >= 0 and c <= 127 }
var isupper = func(c) { c >= `A` and c <= `Z` }
var islower = func(c) { c >= `a` and c <= `z` }
var isdigit = func(c) { c >= `0` and c <= `9` }
var isblank = func(c) { c == ` ` or c == `\t` }
var ispunct = func(c) { c >= `!` and c <= `/` or c >= `:` and c <= `@`
		or c >= `[` and c <= `\`` or c >= `{` and c <= `~` }

var isxdigit = func(c) { isdigit(c) or c >= `a` and c <= `f` or c >= `A` and c <= `F` }
var isspace = func(c) { c == ` ` or c >= `\t` and c <= `\r` }
var isalpha = func(c) { isupper(c) or islower(c) }
var isalnum = func(c) { isalpha(c) or isdigit(c) }
var isgraph = func(c) { isalnum(c) or ispunct(c) }
var isprint = func(c) { isgraph(c) or c == ` ` }

var toupper = func(c) { islower(c) ? c + `A` - `a` : c }
var tolower = func(c) { isupper(c) ? c + `a` - `A` : c }


##
# trim spaces at the left (lr < 0), at the right (lr > 0), or both (lr = 0)
#
var trim = func(s, lr = 0) {
	var l = 0;
	if (lr <= 0)
		for (; l < size(s); l += 1)
			if (!isspace(s[l]))
				break;
	var r = size(s) - 1;
	if (lr >= 0)
		for (; r >= 0; r -= 1)
			if (!isspace(s[r]))
				break;
	return r < l ? "" : substr(s, l, r - l + 1);
}


##
# Join all elements of a list inserting a separator between every two of them.
#
var join = func(sep, list) {
	if (!size(list))
		return "";
	var str = list[0];
	foreach (var s; subvec(list, 1))
		str ~= sep ~ s;
	return str;
}


##
# Replace all occurrences of 'old' by 'new'.
#
var replace = func(str, old, new) {
	return join(new, split(old, str));
}


##
# return string converted to lower case letters
#
var lc = func(str) {
	var s = "";
	for (var i = 0; i < size(str); i += 1)
		s ~= chr(tolower(str[i]));
	return s;
}


##
# return string converted to upper case letters
#
var uc = func(str) {
	var s = "";
	for (var i = 0; i < size(str); i += 1)
		s ~= chr(toupper(str[i]));
	return s;
}


##
# case insensitive string compare and match functions
# (not very efficient -- converting the array to be sorted
# first is faster)
#
var icmp = func(a, b) cmp(lc(a), lc(b));
var imatch = func(a, b) match(lc(a), lc(b));


##
# check if string <str> matches shell style pattern <patt>
#
# Rules:
# ?   stands for any single character
# *   stands for any number (including zero) of arbitrary characters
# \   escapes the next character and makes it stand for itself; that is:
#     \? stands for a question mark (not the "any single character" placeholder)
# []  stands for a group of characters:
#     [abc]      stands for letters a, b or c
#     [^abc]     stands for any character but a, b, and c  (^ as first character -> inversion)
#     [1-4]      stands for digits 1 to 4 (1, 2, 3, 4)
#     [1-4-]     stands for digits 1 to 4, and the minus
#     [-1-4]     same as above
#     [1-3-6]    stands for digits 1 to 3, minus, and 6
#     [1-3-6-9]  stands for digits 1 to 3, minus, and 6 to 9
#     [][]       stands for the closing and the opening bracket (']' must be first!)
#     [^^]       stands for all characters but the caret symbol
#     [\/]       stands for a backslash or a slash  (the backslash isn't an
#                escape character in a [] character group)
#
#     Note that a minus can't be a range delimiter, as in [a--e],
#     which would be interpreted as any of a, e, or minus.
#
# Example:
#     string.match(name, "*[0-9].xml"); ... true if 'name' ends with digit followed by ".xml"
#
var match = func(str, patt) {
	var s = 0;
	for (var p = 0; p < size(patt) and s < size(str); ) {
		if (patt[p] == `\\`) {
			if ((p += 1) >= size(patt))
				return 0;  # pattern ends with backslash

		} elsif (patt[p] == `?`) {
			s += 1;
			p += 1;
			continue;

		} elsif (patt[p] == `*`) {
			for (; p < size(patt); p += 1)
				if (patt[p] != `*`)
					break;
			if (p >= size(patt))
				return 1;

			for (; s < size(str); s += 1)
				if (match(substr(str, s), substr(patt, p)))
					return 1;
			continue;

		} elsif (patt[p] == `[`) {
			setsize(var x = [], 256);
			var invert = 0;
			if ((p += 1) < size(patt) and patt[p] == `^`) {
				p += 1;
				invert = 1;
			}
			for (var i = 0; p < size(patt); p += 1) {
				if (patt[p] == `]` and i)
					break;
				x[patt[p]] = 1;
				i += 1;

				if (p + 2 < patt[p] and patt[p] != `-` and patt[p + 1] == `-`
						and patt[p + 2] != `]` and patt[p + 2] != `-`) {
					var from = patt[p];
					var to = patt[p += 2];
					for (var c = from; c <= to; c += 1)
						x[c] = 1;
				}
			}
			if (invert ? !!x[str[s]] : !x[str[s]])
				return 0;
			s += 1;
			p += 1;
			continue;
		}

		if (str[s] != patt[p])
			return 0;
		s += 1;
		p += 1;
	}
	return s == size(str) and p == size(patt);
}


##
# Removes superfluous slashes, empty and "." elements, expands
# all ".." elements, and turns all backslashes into slashes.
# The result will start with a slash if it started with a slash
# or backslash, it will end without slash. Should be applied on
# absolute property or file paths, otherwise ".." elements might
# be resolved wrongly.
#
var fixpath = func(path) {
	path = replace(path, "\\", "/");
	var prefix = path[0] == `/` ? "/" : "";
	var stack = [];

	foreach (var e; split("/", path)) {
		if (e == "." or e == "")
			continue;
		elsif (e == "..")
			pop(stack);
		else
			append(stack, e);
	}
	return size(stack) ? prefix ~ join("/", stack) : "/";
}


