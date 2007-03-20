#
# Functions for XML-based tutorials
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
# <init>       - Optional: Initialization section consist of one or more
#                  set nodes:
#   <set>
#     <property>  - Property to set
#     <value>     - value
#
# <step>          - Tutorial step - a segment of the tutorial, consisting of
#                   the following:
#   <message>     - Text instruction displayed when the tutorial reaches
#                   this step, and when neither the exit nor any error
#                   criteria have been fulfilled
#   <audio>       - Optional: wav filename to play when displaying
#                         instruction
#   <error> - Error conditions, causing error messages to be displayed.
#             The tutorial doesn't advance while any error conditions are
#             fulfilled. Consists of one or more check nodes:
#     <message>   - Error message to display if error criteria fulfilled.
#     <audio>     - Optional: wav filename to play when error condition fulfilled.
#     <condition> - error condition (see $FG_ROOT/Docs/README.condition)
#
#   <exit> - Exit criteria causing tutorial to progress to next step.
#     <condition> - exit condition (see $FG_ROOT/Docs/README.condition)
#
# <end>
#   <message>> - Optional: Text to display when the tutorial exits the last step.
#   <audio>    - Optional: wav filename to play when the tutorial exits the last step

#
# GLOBAL VARIABLES
#


var STEP_INTERVAL = 5;   # time between tutorial steps
var EXIT_INTERVAL = 1;   # time between fulfillment of a step and the start of the next step

var current_step = nil;
var num_errors = nil;
var tutorial = nil;
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
		if (c.getChild("name").getValue() == name) {
			tutorial = c;
			break;
		}
	}

	if (tutorial == nil) {
		screen.log.write('Unable to find tutorial "' ~ name ~ '"');
		return;
	}

	screen.log.write('Loading tutorial "' ~ name ~ '" ...');
	is_running(1);
	current_step = 0;
	num_step_runs = 0;
	num_errors = 0;

	set_properties(tutorial.getChild("init"));
	set_cursor(tutorial);
	init_nasal();
	run_nasal(tutorial);

	var dir = tutorial.getChild("audio-dir");
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
		fgcommand("timeofday", props.Node.new({"timeofday": timeofday.getValue()}));
	}

	# Pick up any weather conditions/scenarios set
	setprop("/environment/rebuild-layers", getprop("/environment/rebuild-layers") + 1);
	settimer(stepTutorial, STEP_INTERVAL);
}



var stopTutorial = func {
	is_running(0);
	set_cursor(props.Node.new());
}



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
var stepTutorial = func {
	if (!is_running()) {
		return;
	}

	var voice = nil;
	var message = nil;

	# If we've reached the end of the tutorial, simply indicate and exit
	if (current_step >= size(tutorial.getChildren("step"))) {
		message = "Tutorial finished.";

		var end = tutorial.getNode("end");
		if (end != nil) {
			var m = end.getNode("message");
			if (m != nil) {
				message = m.getValue();
			}

			var v = end.getNode("audio");
			if (v != nil) {
				voice = v.getValue();
			}
			run_nasal(end);
		}
		say(message, voice);
		say("Deviations: " ~ num_errors);
		is_running(0);
		return;
	}

	var step = tutorial.getChildren("step")[current_step];
	set_cursor(step);

	var instr = step.getChild("message");
	message = instr != nil ? instr.getValue() : "Tutorial step " ~ current_step;

	if (!num_step_runs) {
		# If this is the first time we've encountered this step :
		# - Set any values required
		# - Display any messages
		# - Play any instructions.
		#
		# We then do not go through the error or exit processing, giving the user
		# time to react to the instructions.

		var v = step.getChild("audio");
		if (v != nil) {
			voice = v.getValue();
		}

		say(message, voice);
		set_properties(step);

		num_step_runs += 1;
		settimer(stepTutorial, STEP_INTERVAL);
		return;
	}

	run_nasal(step);

	var error = 0;
	# Check for error conditions
	foreach (var e; step.getChildren("error")) {
		if (props.condition(e.getNode("condition"))) {
			error = 1;
			num_errors += 1;
			run_nasal(e);

			var m = e.getNode("message");
			if (m != nil) {
				message = m.getValue();

				var v = e.getChild("audio");
				voice = v != nil ? v.getValue() : nil;
			}
		}
	}


	# Check for exit condition, but only if we didn't hit any errors
	if (!error) {
		var e = step.getNode("exit");
		if (e != nil) {
			if (props.condition(e.getNode("condition"))) {
				run_nasal(e);
				current_step += 1;
				num_step_runs = 0;
				return settimer(stepTutorial, EXIT_INTERVAL);
			}
		} else {
			current_step += 1;
			num_step_runs = 0;
			return settimer(stepTutorial, EXIT_INTERVAL);
		}
	}

	# Display the resulting message and wait to go around again.
	say(message, voice, error);
	settimer(stepTutorial, STEP_INTERVAL);
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



var set_cursor = func(node) {
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
var say = func(msg, snd = nil, error = 0) {
	var lastmsg = getprop("/sim/tutorial/last-message");

	if (msg != lastmsg or (error == 1 and lastmsgcount == 1)) {
		# Error messages are only displayed every 10 seconds (2 iterations)
		# Other messages are only displayed if they change
		if (snd == nil) {
			# Simply set to the co-pilot channel. TTS is picked up automatically.
			setprop("/sim/messages/copilot", msg);
		} else {
			# Play the audio, and write directly to the screen-logger to avoid
			# any tts being sent to festival.
			var prop = { path : audio_dir, file : snd };
			fgcommand("play-audio-message", props.Node.new(prop));
			screen.log.write(msg, 1, 1, 1);
		}

		setprop("/sim/tutorial/last-message", msg);
		lastmsgcount = 0;
	} else {
		lastmsgcount += 1;
	}
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



# Set up the namespace for embedded Nasal.
#
var init_nasal = func {
	globals.__tutorial = {
		say : say,
		next : func { current_step += 1; num_step_runs = 0 },
		previous : func {
			if (current_step > 0) {
				current_step -= 1;
			}
			num_step_runs = 0;
		},
	};
}


var dialog = func {
	fgcommand("dialog-show", props.Node.new({ "dialog-name" : "marker-adjust" }));
}


var marker = nil;
_setlistener("/sim/signals/nasal-dir-initialized", func {
	marker = props.globals.getNode("/sim/model/marker", 1);
});


