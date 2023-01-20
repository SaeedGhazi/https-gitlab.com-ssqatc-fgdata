# SPDX-FileCopyrightText: (C) 2022 James Turner <james@flightgear.org>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.ComboBox = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.ComboBox);
    m._focus_policy = m.StrongFocus;
#    m._flat = cfg.get("flat", 0);
    m._menu = gui.Menu.new();
    m._setView( style.createWidget(parent, cfg.get("type", "combo-box"), cfg) );
    m._items = [];
    m._currentIndex = nil;
    m._style = style; # cache reference to style for creating items
    m._down = 0;
    
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
    return me._menu;
  },

# convenience helper to add simple items
  addMenuItem: func(text, value) {
    var index = size(me._items);
    var item = me.menu().createItem(text, func { me._itemCallback(index);}, {});
    item.menuValue = value;
    append(me._items, item);
    if (me._currentIndex == nil) {
      # select first item added, if we were previously empty
      me.setCurrentByIndex(0);
    }
  },

# helper to set the current item by passing in
# a value of an item
  setCurrentByValue: func(value) {
    var index = 0;
    foreach(var i; me._items) {
      if (i.menuValue == value) {
        setCurrentByIndex(index);
        break;
      }

      index+=1;
    }

    logprint(DEV_WARN, "Canvas.Gui ComboBox: no such value in menu:" ~ value);
  },

  setCurrentByIndex: func(index) {
    if (me._currentIndex == index)
      return;

    if (index >= size(me._items)) {
      logprint(DEV_WARN, "Canvas.Gui ComboBox: invalid index passed to setCUrrentByIndex" ~ index);
      return;
    }

    me._currentIndex = index;
    me._view.setText(me, me._items[index].text());
  },

  setDown: func(down = 1)
  {
    if (me._down == down )
      return me;

    me._down = down;
    me._onStateChange();
    return me;
  },

# protected:
  _itemCallback: func(index)
  {
    me.setCurrentByIndex(index);
  },

  _setView: func(view)
  {
    call(gui.Widget._setView, [view], me);

    var el = view._root;
    el.addEventListener("mousedown", func if( me._enabled ) { me.setDown(1); me._openMenu(); });
    el.addEventListener("mouseup",   func if( me._enabled ) me.setDown(0));
    el.addEventListener("mouseleave",func me.setDown(0));
  },

  _openMenu: func
  {
    me.menu().show();
  }
};
