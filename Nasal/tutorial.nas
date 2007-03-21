# Functions for XML-based tutorials
# ---------------------------------------------------------------------------------------
#

#
# Each tutorial consists of the following XML sections
#
# <name>        - Tutorial Name
# <description> - description
# <audio-dir>   - Optional:  Directory to pick up audio instructions from.
#                   Relative to FG_ROOT
# <timeofday>   - Optional: Time of day setting for tutorial:
#                   dawn/morning/noon/afternoon etc.
# <presets>     - Optional: set of presets to used for start position.
#                   See commit-presets and gui/dialog/location-*.xml for details.
#   <airport-id>
#   <on-ground>
#   <runway>
#   <altitude-ft>
#   <latitude-deg>
#   <longitude-deg>
#   <heading-deg>
#   <airspeed-kt>
#
# <models>
#   <model>           - scenery object definition
#     <path>          - path to model (relative to $FG_ROOT)
#     <longitude-deg>
#     <latitude-deg>
#     <elevation-ft>
#     <heading-deg>
#     <pitch-deg>
#     <roll-deg
#
# <targets>
#   <target>          - the tutorial will always keep properties
#     <longitude-deg>   /sim/tutorial/targets/target[*]/{direction-deg,distance-m}
#     <latitude-deg>    up-to-date for each <target>
#
# <init>       - Optional: Initialization section consist of one or more
#                  set nodes:
#   <set>
#     <property>  - Property to set
#     <value>     - value
#
# <step>          - Tutorial step - a segment of the tutorial, consisting of
#                   the following:
#   <message>     - Text instruction displayed when the tutorial reaches
#                   this step, and when neither the exit nor any error.
#                   criteria have been fulfilled
#   <audio>       - Optional: wav filename to play when displaying
#                   instruction
#   <nasal><script>
#
#   <error> - Error conditions, causing error messages to be displayed.
#             The tutorial doesn't advance while any error conditions are
#             fulfilled. Consists of one or more check nodes:
#     <message>   - Error message to display if error criteria fulfilled.
#     <audio>     - Optional: wav filename to play when error condition fulfilled.
#     <nasal><script>
#     <condition> - error condition (see $FG_ROOT/Docs/README.condition)
#
#   <exit> - Exit criteria causing tutorial to progress to next step.
#     <condition> - exit condition (see $FG_ROOT/Docs/README.condition)
#     <nasal><script>
#
# <end>
#   <message>> - Optional: Text to display when the tutorial exits the last step.
#   <audio>    - Optional: wav filename to play when the tutorial exits the last step
#   <nasal><script>
#
#
# NOTE: everywhere where <message> and/or <audio> is supported there can be
#       more than one <message> or <audio> entry defined, in which case one
#       is randomly chosen.
#       All <nasal><script> run in a separate Nasal namespace. There are a few
#       functions pre-defined in this namespace:
#       - next(n=1)       ... switch to next step (default) or n steps forward
#       - previous(n=1)   ... switch to previous step (default) or n steps back
#       - say("...", who="copilot", delay=1)  ... say message, with optional
#                             speaker and delay. Available speakers are "pilot",
#                             "copilot", "atc", "ai-plane", "apprach", "ground".
#                             Examples:   say("Look! There!");
#                                         say("Oh, dear ...", "pilot", 2);
#
#
# GLOBAL VARIABLES
#


var STEP_INTERVAL = 5;   # time between tutorial steps
var EXIT_INTERVAL = 1;   # time between fulfillment of a step and the start of the next step

var tutorial = nil;
var steps = [];
var loop_id = 0;
var current_step = nil;
var num_errors = nil;
var num_step_runs = nil;
var audio_dir = nil;



var startTutorial = func {
	var name = getprop("/sim/tutorial/current-tutorial");
	if (name == nil) {
		screen.log.write("No tutorial selected");
		return;
	}

	tutorial = nil;
	foreach (var c; props.globals.getNode("/sim/tutorial").getChildren("tutorial")) {
		if (c.getNode("name").getValue() == name) {
			tutorial = c;
			break;
		}
	}

	if (tutorial == nil) {
		screen.log.write('Unable to find tutorial "' ~ name ~ '"');
		return;
	}

	stopTutorial();
	is_running(1);
	screen.log.write('Loading tutorial "' ~ name ~ '" ...');
	current_step = 0;
	num_step_runs = 0;
	num_errors = 0;
	steps = tutorial.getChildren("step");

	set_properties(tutorial.getNode("init"));
	set_cursor(tutorial);
	set_models(tutorial.getNode("models"));
	init_nasal();
	run_nasal(tutorial);

	var dir = tutorial.getNode("audio-dir");
	if (dir != nil) {
		audio_dir = getprop("/sim/fg-root") ~ "/" ~ dir.getValue() ~ "/";
	} else {
		audio_dir = "";
	}

	var presets = tutorial.getChild("presets");
	if (presets != nil) {
		props.copy(presets, props.globals.getNode("/sim/presets"));
		fgcommand("presets-commit", props.Node.new());

		# Set the various engines to be running
		if (getprop("/sim/presets/on-ground")) {
			var eng = props.globals.getNode("/controls/engines");
			if (eng != nil) {
				foreach (var c; eng.getChildren("engine")) {
					c.getNode("magnetos", 1).setIntValue(3);
					c.getNode("throttle", 1).setDoubleValue(0.5);
				}
			}
		}
	}

	var timeofday = tutorial.getChild("timeofday");
	if (timeofday != nil) {
		fgcommand("timeofday", props.Node.new({ "timeofday" : timeofday.getValue() }));
	}

	# Pick up any weather conditions/scenarios set
	setprop("/environment/rebuild-layers", getprop("/environment/rebuild-layers") + 1);
	settimer(func { stepTutorial(loop_id += 1) }, STEP_INTERVAL);
}



var stopTutorial = func {
	loop_id += 1;
	is_running(0);
	set_cursor();
}

_setlistener("/sim/crashed", stopTutorial);



# stepTutorial
#
# This function does the actual work. It is executed every 5 seconds.
#
# Each iteration it:
# - Gets the current step node from the tutorial
# - If this is the first time the step is entered, it displays the instruction message
# - Otherwise, it
#   - Checks if the exit conditions have been met. If so, it increments the step counter.
#   - Checks for any error conditions, in which case it displays a message to the screen and
#     increments an error counter
#   - Otherwise display the instructions for the step.
# - Sets the timer for 5 seconds again.
#
var stepTutorial = func(id) {
	id == loop_id or return;

	var continue_after = func(i) { settimer(func { stepTutorial(id) }, i) }

	if (current_step >= size(steps)) {
		# end of the tutorial
		var end = tutorial.getNode("end");
		say_message(end, "Tutorial finished.");
		say_message(nil, "Deviations: " ~ num_errors);
		run_nasal(end);
		stopTutorial();
		return;
	}

	var step = steps[current_step];
	set_cursor(step);
	set_view(step.getNode("view"));
	set_targets(tutorial.getNode("targets"));

	if (num_step_runs == 0) {
		# first time we've encountered this step
		say_message(step, "Tutorial step " ~ current_step);
		set_properties(step);
		run_nasal(step);

		num_step_runs += 1;
		return continue_after(STEP_INTERVAL);
	}

	# check for error conditions in random order
	foreach (var error; shuffle(step.getChildren("error"))) {
		if (props.condition(error.getNode("condition"))) {
			num_errors += 1;
			run_nasal(error);
			say_message(error);
			return continue_after(STEP_INTERVAL);
		}
	}

	# check for exit condition
	var exit = step.getNode("exit");
	if (exit != nil) {
		if (!props.condition(exit.getNode("condition"))) {
			return continue_after(STEP_INTERVAL);
		}
		run_nasal(exit);
	}

	# success!
	current_step += 1;
	num_step_runs = 0;
	return continue_after(EXIT_INTERVAL);
}



# scan all <set> blocks and set their <property> to <value>
# <set>
#	 <property>/foo/bar</property>
#	 <value>woof</value>
# </set>
#
var set_properties = func(node) {
	node != nil or return;
	foreach (var c; node.getChildren("set")) {
		var p = c.getChild("property").getValue();
		var v = c.getChild("value").getValue();

		if (p != nil and v != nil) {
			setprop(p, v);
		}
	}
}


var set_targets = func(node) {
	node != nil or return;

	var dest = props.globals.getNode("/sim/tutorial/targets", 1);
	var aircraft = geo.aircraft_position();
	var hdg = heading.getValue() + slip.getValue();
	foreach (var t; node.getChildren("target")) {
		var lon = t.getNode("longitude-deg");
		var lat = t.getNode("latitude-deg");
		if (lon == nil or lat == nil) {
			die("target coords not defined");
		}
		var target = geo.Coord.new().set_lonlat(lon.getValue(), lat.getValue());
		var dist = int(aircraft.distance_to(target));
		var angle = geo.normdeg(aircraft.course_to(target) - hdg);
		if (angle >= 180) {
			angle -= 360;
		}

		var d = dest.getChild("target", t.getIndex(), 1);
		d.getNode("distance-m", 1).setDoubleValue(dist);
		d.getNode("direction-deg", 1).setDoubleValue(angle);
	}
}


var models = [];
var set_models = func(node) {
	node != nil or return;

	var manager = props.globals.getNode("/models", 1);
	foreach (var src; node.getChildren("model")) {
		var i = 0;
		for (; 1; i += 1) {
			if (manager.getChild("model", i, 0) == nil) {
				break;
			}
		}
		var dest = manager.getChild("model", i, 1);
		props.copy(src, dest);
		dest.getNode("load", 1);  # makes the modelmgr load the model
		dest.removeChildren("load");
		append(models, dest);
	}
}


var remove_models = func {
	foreach (var m; models) {
		m.getParent().removeChild(m.getName(), m.getIndex());
	}
	models = [];
}


var set_view = func(node = nil) {
	node != nil or return;
	if (!size(node.getChildren())) {
		var name = node.getValue();
		node = tutorial.getNode("views");
		node != nil or die("<view>name</view>, but no <views> group");
		node = node.getNode(name);
		node != nil or die("<view>name</view> refers to non existing <views> group");
	}
	props.copy(node, props.globals.getNode("/sim/current-view"));
}


var set_cursor = func(node = nil) {
	node != nil or return;
	var loc = node.getNode("marker");
	if (loc == nil) {
		marker.getNode("arrow-enabled", 1).setBoolValue(0);
		return;
	}

	var s = loc.getNode("scale");
	marker.setValues({
		"x/value": loc.getNode("x", 1).getValue(),
		"y/value": loc.getNode("y", 1).getValue(),
		"z/value": loc.getNode("z", 1).getValue(),
		"scale/value": s != nil ? s.getValue() : 1,
		"arrow-enabled": 1,
	});
}


# Set and return running state. Disable/enable stop menu.
#
var is_running = func(which = nil) {
	var prop = "/sim/tutorial/running";
	if (which != nil) {
		setprop(prop, which);
		gui.menuEnable("tutorial-stop", which);
	}
	return getprop(prop);
}


# Output the message and optional sound recording.
#
var lastmsgcount = 0;
var say_message = func(node, default = nil) {
	var msg = default;
	var audio = nil;
	var is_error = 0;

	if (node != nil) {
		is_error = node.getName() == "error";

		# choose random message/audio, but make sure that in the first
		# run of a step, the first ones are used
		var m = node.getChildren("message");
		if (size(m)) {
			msg = m[rand() * size(m)].getValue();
		}

		var a = node.getChildren("audio");
		if (size(a)) {
			audio = a[rand() * size(a)].getValue();
		}
	}

	if (msg != last_message.getValue() or (is_error and lastmsgcount == 1)) {
		# Error messages are only displayed every 10 seconds (2 iterations)
		# Other messages are only displayed if they change
		if (audio != nil) {
			var prop = { path : audio_dir, file : audio };
			fgcommand("play-audio-message", props.Node.new(prop));
			screen.log.write(msg, 1, 1, 1);
		} else {
			setprop("/sim/messages/copilot", msg);
		}

		last_message.setValue(msg);
		lastmsgcount = 0;
	} else {
		lastmsgcount += 1;
	}
}


var shuffle = func(vec) {
	var s = size(vec);
	forindex (var i; vec) {
		var j = rand() * s;
		var swap = vec[j];
		vec[j] = vec[i];
		vec[i] = swap;
	}
	return vec;
}


var run_nasal = func(node) {
	node != nil or return;
	foreach (var n; node.getChildren("nasal")) {
		if (n.getNode("module") == nil) {
			n.getNode("module", 1).setValue("__tutorial");
		}
		fgcommand("nasal", n);
	}
}


var say = func(what, who = "copilot", delay = 0) {
	settimer(func { setprop("/sim/messages/", who, what) }, delay);
}


# Set up namespace "__tutorial" for embedded Nasal.
#
var init_nasal = func {
	globals.__tutorial = {
		say : say,   # just exporting tutorial.say as __turorial.say
		next : func(n = 1) { current_step += n; num_step_runs = 0 },
		previous : func(n = 1) {
			current_step -= n;
			num_step_runs = 0;
			if (current_step < 0) {
				current_step = 0;
			}
		},
	};
}


var dialog = func {
	fgcommand("dialog-show", props.Node.new({ "dialog-name" : "marker-adjust" }));
}


var marker = nil;
var heading = nil;
var slip = nil;
var last_message = nil;

_setlistener("/sim/signals/nasal-dir-initialized", func {
	marker = props.globals.getNode("/sim/model/marker", 1);
	heading = props.globals.getNode("/orientation/heading-deg", 1);
	slip = props.globals.getNode("/orientation/side-slip-deg", 1);
	last_message = props.globals.getNode("/sim/tutorial/last-message", 1);
});

