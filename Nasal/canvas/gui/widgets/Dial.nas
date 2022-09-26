# SPDX-FileCopyrightText: (C) 2022 James Turner <james@flightgear.org>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.Dial = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.Dial);
    m._focus_policy = m.StrongFocus;
    m._down = 0;
    m._minValue = 0;
    m._maxValue = cfg.get("max-value", 100);
    m._value = 50;

    m._wraps = cfg.get("wrap", 0);
    m._pageStep = cfg.get("page-step", 0);
    m._numTicks = cfg.get("tick-count", 0);
    m._tickStyle = cfg.get("ticks-style", 0);

    # todo : optional value display in the center

    if( style != nil ) {
      m._setView( style.createWidget(parent, cfg.get("type", "slider"), cfg) );
      m._view.updateRanges(m._minValue, m._maxValue, m._numTicks);
    }

    return m;
  },

  setValue: func(val)
  {
    if( me._view != nil ) {
      me._view.setNormValue(me._normValue());
    }
    return me;
  },

  

# protected:
  _setView: func(view)
  {
    call(gui.Widget._setView, [view], me);

    # var el = view._root;
    # el.addEventListener("mousedown", func if( me._enabled ) me.setDown(1));
    # el.addEventListener("mouseup",   func if( me._enabled ) me.setDown(0));
    # el.addEventListener("click",     func if( me._enabled ) me.toggle());

    # el.addEventListener("mouseleave",func me.setDown(0));
    # el.addEventListener("drag", func(e) e.stopPropagation());
  },

  # return value as its normalised equivalent
  _normValue: func
  {
    var range = me._maxValue - me._minValue;
    var v = math.clamp(me._value, me._minValue, me._maxValue) - me._minValue;
    return v / range;
  }
};
