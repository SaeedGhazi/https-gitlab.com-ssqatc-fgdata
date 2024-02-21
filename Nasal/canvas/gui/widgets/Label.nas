# SPDX-FileCopyrightText: (C) 2022 James Turner <james@flightgear.org>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.Label = {
  new: func(parent, style = nil, cfg = nil)
  {
    style = style or canvas.style;
    cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.Label, cfg);
    m._focus_policy = m.NoFocus;
    m._setView( style.createWidget(parent, "label", m._cfg) );

    m.setText(m._cfg.get("text", ""));

    return m;
  },
  setText: func(text)
  {
    if (me._view != nil) {
      me._view.setText(me, text);
    }
    return me;
  },
  setImage: func(img)
  {
    if (me._view != nil) {
      me._view.setImage(me, img);
    }
    return me;
  },
  setBackground: func(bg)
  {
    if (me._view != nil) {
      me._view.setBackground(me, bg);
    }
    return me;
  }
};
