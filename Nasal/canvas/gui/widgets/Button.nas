gui.widgets.Button = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.Button);
    m._focus_policy = m.StrongFocus;
    m._active = 0;
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
  setActive: func
  {
    if( me._active )
      return me;

    me._active = 1;
    me._onStateChange();
    return me;
  },
  clearActive: func
  {
    if( !me._active )
      return me;

    me._active = 0;
    me._onStateChange();
    return me;
  },
  onClick: func {},
# protected:
  _onStateChange: func
  {
    if( me._view != nil )
      me._view.update(me);
  },
  _setView: func(view)
  {
    var el = view._root;
    el.addEventListener("mousedown", func me.setActive());
    el.addEventListener("mouseup",   func me.clearActive());

    # Use 'call' to ensure 'me' is not set and can be used in the closure of
    # custom callbacks. TODO pass 'me' as argument?
    el.addEventListener("click", func call(me.onClick));

    el.addEventListener("mouseleave",func me.clearActive());
    el.addEventListener("drag", func(e) e.stopPropagation());

    call(gui.Widget._setView, [view], me);
  }
};
