# update_loop.nas - Generic Nasal update loop for implementing sytems,
# instruments or physics simulation.
#
# Copyright (C) 2014 Anton Gomez Alvedro
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

# Component
#
# The update loop accepts a vector of Components that it will update at regular
# intervals. In order to make custom components, you should add Component to
# the parents vector of your object:
#
# var CustomComponent = {
#	parents: [Component],
#   ...
# };
#
# Your component shall then implement an "update" and a "reset" methods that
# the UpdateLoop will call when needed.

var Component = {
	reset: func { },
	update: func(dt) { },
};

##
# Helper generator for updating a property on every element update
#
# Example:
#
# var needle = Dampener.new(
#	input: probe,
#	dampening: 2.8,
#	on_update: update_prop("/instrumentation/variometer/te-reading-mps"));
#
# See Aircraft/Instruments-3d/glider/vario/ilec-sc7.nas and
# Aircraft/Generic/soaring-instrumentation-sdk.nas for usage examples.
# You can also refer to the soaring sdk wiki page.

var update_prop = func(property) {
	func(value) { setprop(property, value) }
};

# UpdateLoop
# Wraps a set of components and updates them periodically.
# Takes care of critical sim signals (reinit, fdm-initialized, speed-up).

var UpdateLoop = {

	# UpdateLoop.new(components, [update_period], [enable])
	#
	# components:    Vector of components to update on every iteration.
	# update_period: Time in seconds between updates (optional).
	# enable:        Enable the loop immediately after creation (optional).

	new: func(components, update_period = 0, enable = 1) {

		var m = { parents: [UpdateLoop] };
		m.initialized = 0;
		m.enabled = enable;
		m.update_period = update_period;
		m.time_last = 0;
		m.sim_speed = 1;
		m.components = (components != nil)? components : [];

		m.timer = maketimer(update_period,
			func { call(me._update, [], m) });

		m.lst = [];

		append(m.lst, setlistener("/sim/speed-up",
			func(n) { m.sim_speed = n.getValue() }, 1, 0));

		append(m.lst, setlistener("sim/signals/reinit", func {
			m.timer.stop();
			m.initialized = 0;
		}));

		append(m.lst, setlistener("sim/signals/fdm-initialized", func {
			if (m.timer.isRunning) m.timer.stop();
			call(me.reset, [], m);
			if (m.enabled) m.timer.start();
		}));

		return m;
	},

	del: func {
		foreach (var l; me.lst) removelistener(l);
	},

	##
	# Resets internal state for all components controlled by the loop.
	# It is of course responsibility of every component to clean their internal
	# state appropriately.

	reset: func {
		me.time_last = getprop("/sim/time/elapsed-sec");

		foreach (var component; me.components)
			component.reset();

		me.initialized = 1;
	},

	##
	# Enables the loop if it was disabled, i.e. the loop will start updating
	# the components under control

	enable: func {
		if (me.initialized) me.timer.start();
		me.enabled = 1;
	},

	##
	# Disables the loop if it was enabled, i.e. the loop will freeze and its
	# components will not get updates until enabled again

	disable: func {
		me.timer.stop();
		me.enabled = 0;
	},

	_update: func {
		var time_now = getprop("/sim/time/elapsed-sec");
		var dt = (time_now - me.time_last) * me.sim_speed;
		if (dt == 0) return;

		me.time_last = time_now;

		foreach (var component; me.components)
			component.update(dt);
	},
};
