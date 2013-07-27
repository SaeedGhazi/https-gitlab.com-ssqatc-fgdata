var Config = {
  new: func(cfg)
  {
    var m = {
      parents: [Config],
      _cfg: cfg
    };
    if( typeof(m._cfg) != "hash" )
      m._cfg = {};

    return m;
  },
  get: func(key, default = nil)
  {
    var val = me._cfg[key];
    if( val != nil )
      return val;

    return default;
  }
};

gui.widgets.Button = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.Button);
    m._focus_policy = m.StrongFocus;
    m._active = 0;
    m._flat = cfg.get("flat", 0);

    if( style != nil and !m._flat )
    {
      m._button = style.createWidget(parent, "button", cfg);
      m._setRoot(m._button.element);
    }

    return m;
  },
  setText: func(text)
  {
    me._button.setText(text);
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
    if( me._button != nil )
      me._button.update(me._active, me._focused, me._hover, !me._window._focused);
  },
  _setRoot: func(el)
  {
    el.addEventListener("mousedown", func me.setActive());
    el.addEventListener("mouseup",   func me.clearActive());

    # Use 'call' to ensure 'me' is not set and can be used in the closure of
    # custom callbacks. TODO pass 'me' as argument?
    el.addEventListener("click", func call(me.onClick));

    el.addEventListener("mouseleave",func me.clearActive());
    el.addEventListener("drag", func(e) e.stopPropagation());

    call(gui.Widget._setRoot, [el], me);
  }
};

return;
