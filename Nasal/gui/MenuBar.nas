# SPDX-FileCopyrightText: (C) 2023 TheFGFSEagle <thefgfseagle@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

var _addItem = func(parent, itemGhost) {
	var item = parent.createItem(itemGhost.label, itemGhost.fire, itemGhost, itemGhost.shortcut, itemGhost.enabled);
}

var _addMenu = func(parent, menuGhost) {
	var menu = parent.createMenu(menuGhost.label);
	foreach (var item; menuGhost.items) {
		_addItem(menu, item);
	}
}

var _createMenuBar = func(menubarGhost) {
	foreach (var menu; menubarGhost.menus) {
		_addMenu(canvas.gui.menubar, menu);
	}
	canvas.gui.menubar.show();
}

