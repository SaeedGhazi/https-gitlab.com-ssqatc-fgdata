# SPDX-FileCopyrightText: (C) 2022 James Turner <james@flightgear.org>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.Menu = {

  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.Menu);
    m._focus_policy = m.StrongFocus;

    # m._flat = cfg.get("flat", 0);
    # m._isDefault = cfg.get("default", 0);
    # m._destructive = cfg.get("destructive", 0);

    m._setView( style.createWidget(parent, cfg.get("type", "menu"), cfg) );
    return m;
  },




# protected:
  _setView: func(view)
  {
    call(gui.Widget._setView, [view], me);
    var el = view._root;
  }
};

