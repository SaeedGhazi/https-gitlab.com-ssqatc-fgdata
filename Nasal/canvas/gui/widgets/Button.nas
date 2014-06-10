gui.widgets.Button = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.Button);
    m._focus_policy = m.StrongFocus;
    m._down = 0;
    m._checkable = 0;
    m._flat = cfg.get("flat", 0);

    if( style != nil and !m._flat )
      m._setView( style.createWidget(parent, "button", cfg) );

    return m;
  },
  setText: func(text)
  {
    me._view.setText(me, text);
    return me;
  },
  setCheckable: func(checkable)
  {
    me._checkable = checkable;
    return me;
  },
  setChecked: func(checked = 1)
  {
    if( !me._checkable or me._down == checked )
      return me;

    me._trigger("clicked", {checked: checked});
    me._trigger("toggled", {checked: checked});

    me._down = checked;
    me._onStateChange();
    return me;
  },
  setDown: func(down = 1)
  {
    if( me._checkable or me._down == down )
      return me;

    me._down = down;
    me._onStateChange();
    return me;
  },
  toggle: func
  {
    if( !me._checkable )
      me._trigger("clicked", {checked: 0});
    else
      me.setChecked(!me._down);

    return me;
  },
# protected:
  _onStateChange: func
  {
    if( me._view != nil )
      me._view.update(me);
  },
  _setView: func(view)
  {
    var el = view._root;
    el.addEventListener("mousedown", func me.setDown(1));
    el.addEventListener("mouseup",   func me.setDown(0));
    el.addEventListener("click",     func me.toggle());

    el.addEventListener("mouseleave",func me.setDown(0));
    el.addEventListener("drag", func(e) e.stopPropagation());

    call(gui.Widget._setView, [view], me);
  }
};
