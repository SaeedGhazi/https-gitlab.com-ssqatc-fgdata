# PropertyWidgets.nas - subclassed canvas widgets that are synced with a property node

# SPDX-FileCopyrightText: (C) 2022 Frederic Croix <thefgfseagle@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.PropertySwitch = {
	new: func(parent, style = nil, cfg = nil) {
		style = style or canvas.style;
		cfg = cfg or {};
		if (cfg["node"] == nil) {
			die("Missing configuration 'node' field");
		}
		if (!isa(cfg["node"], props.Node)) {
			cfg["node"] = props.globals.getNode(cfg["node"], 1);
		}
		
		var m = gui.widgets.Switch.new(parent, style, cfg);
		m._checkable = 1;
		m._node = cfg["node"];

		append(m.parents, gui.widgets.PropertySwitch);
		
		m.setChecked(m._node.getBoolValue());
		m.listen("toggled", func(e) {
			m._node.setBoolValue(int(e.detail.checked));
		});
		m._listener = setlistener(m._node, func(n) {
			m.setChecked(n.getBoolValue());
		}, 1, 0);
		
		return m;
	},
	
	del: func {
		removelistener(me._listener);
	},
};

gui.widgets.PropertyButton = {
	new: func(parent, style = nil, cfg = nil) {
		style = style or canvas.style;
		cfg = cfg or {};
		if (cfg["node"] == nil) {
			die("Missing configuration 'node' field");
		}
		if (!isa(cfg["node"], props.Node)) {
			cfg["node"] = props.globals.getNode(cfg["node"], 1);
		}
		
		var m = gui.widgets.Button.new(parent, style, cfg);
		m._checkable = 1;
		m._node = cfg["node"];

		append(m.parents, gui.widgets.PropertyButton);
		
		m.setChecked(m._node.getBoolValue());
		m.listen("toggled", func(e) {
			m._node.setBoolValue(int(e.detail.checked));
		});
		m._listener = setlistener(m._node, func(n) {
			m.setChecked(n.getBoolValue());
		}, 1, 0);
		
		return m;
	},
	
	del: func {
		removelistener(me._listener);
	},
};

gui.widgets.PropertyRadioButtonsGroup = {
	new: func(node, name = "unnamed") {
		if (!isa(node, props.Node)) {
			node = props.globals.getNode(node, 1);
		}
		var m = gui.widgets.RadioButtonsGroup.new(name);
		m.parents = [gui.widgets.PropertyRadioButtonsGroup] ~ m.parents;
		m._node = node;
		m._ignore_radio_toggles = 0;
		m._nodeListener = setlistener(node, func(n) {
			m._ignore_radio_toggles = 1;
			var value = node.getValue();
			foreach (var radio; m.radios) {
				if (value == radio.getData("property-value")) {
					radio.setChecked(1);
				} else {
					radio.setChecked(0);
				}
			}
			m._ignore_radio_toggles = 0;
		});
	},
	
	_onRadioToggled: func {
		if (me._ignore_radio_toggles) {
			return;
		}
		var checked = me.getCheckedRadio();
		foreach (var radio; me.radios) {
			radio._trigger("group-checked-radio-changed", {checkedRadio: checked});
		}
		m._node.setValue(checked != nil ? checked.getData("property-value") : nil);
	},
};

gui.widgets.PropertyRadioButton = {
	new: func(parent, style = nil, cfg = nil) {
		style = style or canvas.style;
		cfg = cfg or {};
		cfg["radioButtonGroupClass"] = gui.widgets.PropertyRadioButtonsGroup;
		if (cfg["node"] == nil) {
			die("Missing configuration 'node' field");
		}
		if (!isa(cfg["node"], props.Node)) {
			cfg["node"] = props.globals.getNode(cfg["node"], 1);
		}
		
		var m = gui.widgets.RadioButton.new(parent, style, cfg);
		m._checkable = 1;
		m._node = cfg["node"];

		append(m.parents, gui.widgets.PropertyRadioButton);
		
		m.setChecked(m._node.getBoolValue());
		m.listen("toggled", func(e) {
			m._node.setBoolValue(int(e.detail.checked));
		});
		m._listener = setlistener(m._node, func(n) {
			m.setChecked(n.getBoolValue());
		}, 1, 0);
		
		return m;
	},
	
	del: func {
		removelistener(me._listener);
	},
};

gui.widgets.PropertyList = {
	new: func(parent, style = nil, cfg = nil) {
		if (cfg["node"] == nil) {
			die("Missing configuration 'node' field");
		}
		if (!isa(cfg["node"], props.Node)) {
			cfg["node"] = props.globals.getNode(cfg["node"], 1);
		}
		
		var m = gui.widgets.List.new(parent, style, cfg);
		m._checkable = 1;
		m._node = cfg["node"];

		append(m.parents, gui.widgets.PropertyList);
		
		if (str(m.findItemByData(m._node.getValue()))) {
			m.setItemSelection(m.findItemByData("property-value", m._node.getValue()));
		}
		m.listen("selection-changed", func(e) {
			m._node.setValue(m.getSelectedItems()[0].getData("property-value"));
		});
		m._listener = setlistener(m._node, func(n) {
			if (str(m.findItemByData("property-value", n.getValue()))) {
				m.setItemSelection(m.findItemByData("property-value", n.getValue()));
			}
		}, 1, 0);
		
		return m;
	},
	
	del: func {
		removelistener(me._listener);
	},
};

gui.widgets.PropertyLabel = {
	new: func(parent, style = nil, cfg = nil) {
		style = style or canvas.style;
		cfg = cfg or {};
		if (cfg["node"] == nil) {
			die("Missing configuration 'node' field");
		}
		if (!isa(cfg["node"], props.Node)) {
			cfg["node"] = props.globals.getNode(cfg["node"], 1);
		}
		var m = gui.widgets.Label.new(parent, style, cfg);
		m._checkable = 1;
		m._node = cfg["node"];
		
		append(m.parents, gui.widgets.PropertyLabel);
		
		m.setText(m._node.getValue());
		m._listener = setlistener(m._node, func(n) {
			m.setText(n.getValue());
		}, 1, 0);
	}
};


gui.widgets.PropertyLineEdit = {
	new: func(parent, style = nil, cfg = nil) {
		style = style or canvas.style;
		cfg = cfg or {};
		if (cfg["node"] == nil) {
			die("Missing configuration 'node' field");
		}
		if (!isa(cfg["node"], props.Node)) {
			cfg["node"] = props.globals.getNode(cfg["node"], 1);
		}
		var m = gui.widgets.LineEdit.new(parent, style, cfg);
		m._checkable = 1;
		m._node = cfg["node"];
		
		append(m.parents, gui.widgets.PropertyLineEdit);
		
		m.setText(m._node.getValue());
		m.listen("text-changed", func(e) {
			m._node.setValue(m.getText());
		});
		m._listener = setlistener(m._node, func(n) {
			m.setText(n.getValue());
		}, 1, 0);
	}
};

gui.widgets.PropertyCheckBox = {
	new: func(parent, style = nil, cfg = nil) {
		style = style or canvas.style;
		cfg = cfg or {};
		if (cfg["node"] == nil) {
			die("Missing configuration 'node' field");
		}
		if (!isa(cfg["node"], props.Node)) {
			cfg["node"] = props.globals.getNode(cfg["node"], 1);
		}
		
		var m = gui.widgets.CheckBox.new(parent, style, cfg);
		m._checkable = 1;
		m._node = cfg["node"];

		append(m.parents, gui.widgets.PropertyCheckBox);
		
		m.setChecked(m._node.getBoolValue());
		m.listen("toggled", func(e) {
			m._node.setBoolValue(int(e.detail.checked));
		});
		m._listener = setlistener(m._node, func(n) {
			m.setChecked(n.getBoolValue());
		}, 1, 0);
		
		return m;
	},
	
	del: func {
		removelistener(me._listener);
	},
};

