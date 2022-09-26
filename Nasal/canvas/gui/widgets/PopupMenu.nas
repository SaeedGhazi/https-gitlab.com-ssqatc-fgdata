# SPDX-FileCopyrightText: (C) 2022 James Turner <james@flightgear.org>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.PopupMenu = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.Button);
    m._focus_policy = m.StrongFocus;
    m._flat = cfg.get("flat", 0);
    m._menu = nil;
    m._setView( style.createWidget(parent, cfg.get("type", "button"), cfg) );

    return m;
  },
  setText: func(text)
  {
    if( me._view != nil )
      me._view.setText(me, text);
    return me;
  },

  show: func()
  {
    # check if enabled
  },

  menu: func()
  {
    if (!me._menu) {
        # FIXME pass style
        me.menu = gui.widgets.Menu.new(cfg);
    }

    return me._menu;
  },

# convenience helper to add simple items
  addMenuItem: func(text, value) {
    # FIXME pass style
    me.menu().append(gui.widgets.MenuItem.new());
  },

# protected:
  _setView: func(view)
  {
    call(gui.Widget._setView, [view], me);

    var el = view._root;
    el.addEventListener("mousedown", func if( me._enabled ) me.setDown(1));
    el.addEventListener("mouseup",   func if( me._enabled ) me.setDown(0));
    el.addEventListener("mouseleave",func me.setDown(0));
  }
};
