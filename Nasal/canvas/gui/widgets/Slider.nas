# Slider.nas : show a user-draggable slider
# with optional tick marks and value display
# SPDX-FileCopyrightText: (C) 2022 James Turner <james@flightgear.org>
# SPDX-License-Identifier: GPL-2.0-or-later

gui.widgets.Slider = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.Slider);
    m._focus_policy = m.StrongFocus;
    m._down = 0;
    m._minValue = 0;
    m._maxValue = cfg.get("max-value", 100);
    m._value = 50;
    m._pageStep = cfg.get("page-step", 0);
    m._numTicks = cfg.get("tick-count", 0);

    m._tickStyle = cfg.get("ticks-style", 0);
    m._valueDisplayStyle = cfg.get("value-style", 0);

    # TODO : select where value is shown
    # TODO : select where tick marks are shown

    m._setView( style.createWidget(parent, cfg.get("type", "slider"), cfg) );
    m._view.updateRanges(m._minValue, m._maxValue, m._numTicks);

    return m;
  },

  setValue: func(val)
  {
    me._value = val;
    if( me._view != nil ) {
      me._view.setNormValue(me, me._normValue());
    }
    return me;
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
  _setView: func(view)
  {
    call(gui.Widget._setView, [view], me);

    var el = view._root;
    el.addEventListener("mousedown", func if( me._enabled ) me.setDown(1));
    el.addEventListener("mouseup",   func if( me._enabled ) me.setDown(0));
    # el.addEventListener("click",     func if( me._enabled ) me.toggle());
    el.addEventListener("mouseleave",func me.setDown(0));
    
    view._thumb.addEventListener("drag", func(e) {
      me._dragThumb(e);
      e.stopPropagation();
    });
  },

  _dragThumb: func(event)
  { 
    var vr =  me._view._root;
    var viewPosX = vr.canvasToLocal([event.clientX, event.clientY])[0];
    var width = me._size[0];

    if (viewPosX < 0) {
      me.setValue(me._minValue);
    } elsif (viewPosX > width) {
      me.setValue(me._maxValue);
    } else {
      var norm = viewPosX / width;
      me.setValue(norm * ( me._maxValue - me._minValue));
    }
  },

  # return value as its normalised equivalent
  _normValue: func
  {
    var range = me._maxValue - me._minValue;
    var v = math.clamp(me._value, me._minValue, me._maxValue) - me._minValue;
    return v / range;
  }
};
