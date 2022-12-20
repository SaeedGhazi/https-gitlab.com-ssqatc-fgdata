# TabWidget.nas - widget with a tabs bar and a content area which always displays
# exactly one of its tabs

# SPDX-FileCopyrightText: (C) 2022 Frederic Croix <thefgfseagle@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later


gui.widgets.TabWidgetTabButton = {
	new: func(parent, style, cfg) {
		var cfg = Config.new(cfg);
		var m = gui.Widget.new(gui.widgets.TabWidgetTabButton);
		m._focus_policy = m.StrongFocus;
		m._selected = 0;

		m._setView(style.createWidget(parent, "tab-widget-tab-button", cfg));

		return m;
	},
	setText: func(text) {
		me._view.setText(me, text);
		
		return me;
	},
	setSelected: func(selected = 1) {
		if (me._selected == selected) {
			return me;
		}

		me._selected = selected;
		me._trigger("toggled", {selected: selected});
		me._onStateChange();
		me._view.update(me);
		return me;
	},
	_setView: func(view) {
		call(gui.Widget._setView, [view], me);

		var el = view._root;
		#el.addEventListener("mousedown", func me.dragStart());
		#el.addEventListener("mouseup", func me.dragStop());
		el.addEventListener("click", func me.setSelected());

		el.addEventListener("drag", func(e) { e.stopPropagation() });
		#el.addEventListener("drag", me.drag);
	}
};

gui.widgets.TabWidget = {
	new: func(parent, style, cfg) {
		var m = gui.Widget.new(gui.widgets.TabWidget);
		m._cfg = Config.new(cfg);
		m._focus_policy = m.NoFocus;
		m._setView(style.createWidget(parent, "tab-widget", m._cfg));
		m._layout = VBoxLayout.new();
		m._layout.setCanvas(m._view._root.getCanvas());
		m._tabBar = HBoxLayout.new();
		m._layout.addItem(m._tabBar);
		m._currentTab = nil;
		m._currentTabId = nil;
		m._tabs = {};
		m._tabButtons = {};
		
		m.setLayoutMinimumSize([50, 30]);
		m.setLayoutSizeHint([100, 30]);
		
		return m;
	},
	
	hasTab: func(id) {
		return me._tabs[id] != nil;
	},
	
	getTab: func(id) {
		if (!me.hasTab(id)) {
			die("tab with id '" ~ id ~ "' does not exist");
		}
		
		return me._tabs[id];
	},
	
	addTab: func(id, label, widget) {
		if (me.hasTab(id)) {
			die("cannot add multiple tabs with the same id: " ~ id);
		}
		
		me._tabButtons[id] = gui.widgets.TabWidgetTabButton.new(me._view._root, canvas.style, {})
								.setText(label)
								.listen("toggled", func (e) {
									if (e.detail.selected and id != me._currentTabId) {
										me.setCurrentTab(id);
									}
								});
		
		me._tabBar.addItem(me._tabButtons[id]);
		me._tabs[id] = widget;
		me._layout.addItem(widget);
		me.setCurrentTab(keys(me._tabs)[0]);
		
		return me;
	},
	
	removeTab: func(id) {
		if (!me.hasTab(id)) {
			die("tab with id '" ~ id ~ "' does not exist");
		}
		
		me._tabs[id].setVisible(0);
		me._layout.removeItem(me._tabs[id]);
		delete(me._tabs, id);
		me._tabBar.removeItem(me._tabButtons[id]);
		delete(me._tabButtons, id);
		if (size(keys(me._tabs)) > 0) {
			me.setCurrentTab(keys(me._tabs)[-1]);
		}
		
		return me;
	},
	
	setCurrentTab: func(id) {
		if (!me.hasTab(id)) {
			die("tab with id '" ~ id ~ "' does not exist");
		}
		
		if (me._currentTabId) {
			me._tabButtons[me._currentTabId].setSelected(0);
		}
		me._tabButtons[id].setSelected();
		foreach (var tabid; keys(me._tabs)) {
			me._tabs[tabid].setVisible(0);
		}
		me._tabs[id].setVisible(1);
		me._currentTabId = id;
		me._currentTab = me._tabs[id];
		
		return me.update();
	},
	
	setSize: func {
		if (size(arg) == 1) {
			var arg = arg[0];
		}
		var (x, y) = arg;
		me._size = [x, y];
		return me.update();
	},
	
	# Needs to be called when the size of the content changes.
	update: func() {
		if(me._layout.getParent() == nil) {
			me._layout.setParent(me);
		}
		
		me._tabBar.setGeometry([0, 0, me._size[0], me._view.tabBarHeight]);
		if (me._currentTab) {
			me._currentTab.setGeometry([0, me._view.tabBarHeight, me._size[0], me._size[1] - me._view.tabBarHeight]);
		}

		me._view.update(me);

		return me;
	},
};
