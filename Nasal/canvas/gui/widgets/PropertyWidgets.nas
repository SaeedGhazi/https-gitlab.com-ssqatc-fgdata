# PropertyWidgets.nas - subclassed canvas widgets that are synced with a property node

# SPDX-FileCopyrightText: (C) 2022 Frederic Croix <thefgfseagle@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.PropertyCheckBox = {
	new: func(node, parent, style, cfg) {
		if (!isa(node, props.Node)) {
			node = props.globals.getNode(node, 1);
		}
		
		var m = gui.widgets.CheckBox.new(parent, style, cfg);
		m._checkable = 1;
		m._node = node;

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

