# Property Key Handler
# ------------------------------------------------------------------
# This is an extension mainly targeted at developers. It implements
# some useful tools for dealing with internal properties if enabled
# (Menu->Debug->Configure Development Extensions). To use this feature,
# press the '/'-key, then type a property path (using the <TAB> key to
# complete property path elements if possible), or a search string ...
#
#
# Commands:
#
#   <property>=<value><CR> -> set property to value
#   <property><CR>         -> print property and value to screen and terminal
#   <property>*            -> print property and all children to terminal
#   <property>:            -> open property browser in this property's directory
#   <string>?              -> print all properties whose path contains this string
#
#
# Keys:
#
#   <CR>              ... carriage return or enter, to confirm some operations
#   <TAB>             ... complete property path element (if possible), or
#                         cycle through available elements
#   <Shift-TAB>       ... like <TAB> but cycles backwards
#   <CurUp>/<CurDown> ... switch back/forth in the history
#   <Escape>          ... cancel the operation
#   <Shift-Backspace> ... remove last, whole path element
#
#
# Colors:
#
#   white   ... syntactically correct path to not yet existing property
#   green   ... path to existing property
#   red     ... broken path syntax  (e.g. "/foo*bar" ... '*' not allowed)
#   yellow  ... while typing in value for a valid property path
#   magenta ... while typing search string (except when first character is '/')
#
#
# For example, to open the property browser in /position/, type '/p<TAB>:'.


var listener = nil;
var input = nil;            # what is shown in the popup
var explicit_input = nil;   # what the user typed (doesn't contain unconfirmed autocompleted parts)
var state = nil;

var completion = [];
var completion_pos = -1;
var history = [];
var history_pos = -1;


var start = func {
	listener = setlistener("/devices/status/keyboard/event", func(event) {
		if (!event.getNode("pressed").getValue())
			return;
		var key = event.getNode("key");
		var shift = event.getNode("modifier/shift").getValue();
		if (handle_key(key.getValue(), shift))
			key.setValue(0);           # drop key event
	});
	state = parse_input(input = "");
	handle_key(`/`, 0);
}


var stop = func(save_history = 0) {
	removelistener(listener);
	gui.popdown();
	if (save_history) {
		append(history, input);
		history_pos = size(history);
	}
}


var handle_key = func(key, shift) {
	if (key == 357) {                  # up
		set_history(-1);

	} elsif (key == 359) {             # down
		set_history(1);

	} elsif (key == `\n` or key == `\r`) {
		if (state.error)
			return 1;
		if (state.value != nil)
			setprop(state.path, state.value);

		var n = props.globals.getNode(state.path);
		var s = state.path;
		if (n != nil) {
			print_prop(n);
			var v = n.getValue();
			s ~= " = " ~ (v == nil ? "<nil>" : v);
		} else {
			s ~= " does not exist";
		}
		screen.log.write(s, 1, 1, 1);
		stop(1);
		return 1;

	} elsif (key == 27) {              # escape -> cancel
		stop(0);
		return 1;

	} elsif (key == 9) {               # tab
		if (size(input) and input[0] == `/`) {
			input = complete(explicit_input, shift ? -1 : 1);
			build_completion(explicit_input);
			var n = call(func { props.globals.getNode(input) }, [], var err = []);
			if (!size(err) and n != nil and n.getAttribute("children") and size(completion) == 1)
				handle_key(`/`, 0);
		}

	} elsif (key == 8) {               # backspace
		if (shift) {               #     + shift: remove one path element
			explicit_input = input = state.parent.getPath();
			if (input == "")
				handle_key(`/`, 0);
		} else {
			explicit_input = input = substr(input, 0, size(input) - 1);
		}
		completion_pos = -1;

	} elsif (!string.isprint(key)) {
		return 0;                  # pass other funny events

	} elsif (key == `?` and state.value == nil) {
		print("\n-- property search: '", input, "' ----------------------------------");
		search(props.globals, input);
		print("-- done --\n");
		stop(0);
		return 1;

	} elsif (key == `*` and state.node != nil and state.value == nil) {
		debug.tree(state.node);
		stop(1);
		return 1;

	} elsif (key == `:` and state.node != nil and state.value == nil) {
		var n = state.node.getAttribute("children") ? state.node : state.parent;
		gui.property_browser(n);
		stop(1);
		return 1;

	} else {
		input ~= chr(key);
		explicit_input = input;
		completion_pos = -1;
		history_pos = size(history);
	}

	state = parse_input(input);
	build_completion(explicit_input);

	var color = nil;
	if (size(input) and input[0] != `/`)     # search mode (magenta)
		color = set_color(1, 0.4, 0.9);
	elsif (state.error)                      # error mode (red)
		color = set_color(1, 0.4, 0.4);
	elsif (state.value != nil)               # value edit mode (yellow)
		color = set_color(1, 0.8, 0);
	elsif (state.node != nil)                # existing node (green)
		color = set_color(0.7, 1, 0.7);

	gui.popupTip(input, 1000000, color);
	return 1;                                # we used the key
}


var parse_input = func(expr) {
	var path = expr;
	var value = nil;

	if ((var pos = find("=", expr)) >= 0) {
		path = substr(expr, 0, pos);
		value = substr(expr, pos + 1);
	}

	# split argument in parent and name
	var last = 0;
	while ((var pos = find("/", path, last + 1)) > 0)
		last = pos;
	var parent = substr(path, 0, last); # without trailing /
	var raw_name = substr(path, last + 1);
	var name = raw_name;
	if ((var pos = find("[", name)) >= 0)
		name = substr(name, 0, pos);
	var node = nil;

	# run dangerous operations in cage (the paths might be invalid)
	call(func {
		parent = props.globals.getNode(parent);
		node = props.globals.getNode(path);
	}, [], var error = []);

	return {
		error: size(error),
		path: path,
		value: value,
		raw_name: raw_name,  # "binding[1"
		name: name,          # "binding"
		parent: parent,
		node: node,
	};
}


var build_completion = func(in) {
	completion = [];
	var s = parse_input(in);
	if (s.parent == nil)
		return;

	foreach (var c; s.parent.getChildren()) {
		var index = c.getIndex();
		var name = c.getName();
		var fullname = name;
		if (index > 0)
			fullname ~= "[" ~ index ~ "]";
		if (substr(fullname, 0, size(s.raw_name)) == s.raw_name) {
			if (size(s.parent.getChildren(name)) > 1 and index != 0)
				append(completion, [fullname, name, index]);
			else
				append(completion, [fullname, name, -1]);
		}
	}
	completion = sort(completion, func(a, b) cmp(a[1], b[1]) or a[2] - b[2]);
	#print(debug.string([completion_pos, completion]), "\n");
}


var complete = func(in, step) {
	if (state.parent == nil or state.value != nil)
		return in;     # can't complete broken path or assignment

	completion_pos += step;
	if (completion_pos < 0)
		completion_pos = size(completion) - 1;
	elsif (completion_pos >= size(completion))
		completion_pos = 0;

	if (completion_pos < size(completion))
		in = state.parent.getPath() ~ "/" ~ completion[completion_pos][0];

	return in;
}


var set_history = func(step) {
	# eliminate identical subsequent entries
	var new_history = [];
	var last = "";
	foreach (var h; history) {
		if (h == last)
			history_pos -= 1;
		else
			append(new_history, h);
		last = h;
	}
	history = new_history;

	history_pos += step;
	if (history_pos < 0) {
		history_pos = 0;
	} elsif (history_pos >= size(history)) {
		history_pos = size(history);
		input = "";
	} else {
		input = history[history_pos];
	}
	explicit_input = input;
}


var set_color = func(r, g, b) {
	return { text: { color: { red: r, green: g, blue: b } }};
}


var print_prop = func(n) {
	print(n.getPath(), " = ", debug.string(n.getValue()),
			"  ", debug.attributes(n));
}


var search = func(n, s) {
	if (find(s, n.getPath()) >= 0)
		print_prop(n);
	foreach (var c; n.getChildren())
		search(c, s);
}


