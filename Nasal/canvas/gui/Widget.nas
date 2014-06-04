gui.Widget = {
# enum FocusPolicy:
  NoFocus: 0,
  TabFocus: 1,
  ClickFocus: 2,
  StrongFocus: 1 + 2,

  #
  new: func(derived)
  {
    return canvas.Widget.new({
      parents: [derived, gui.Widget],
      _focused: 0,
      _focus_policy: gui.Widget.NoFocus,
      _hover: 0,
      _root: nil,
      _size: [64, 64]
    });
  },
  # Move the widget to the given position (relative to its parent)
  move: func(x, y)
  {
    me._root.setTranslation(x, y);
    return me;
  },
  #
  setSize: func(w, h)
  {
    me._size[0] = w;
    me._size[1] = h;
  },
  #
  setFocus: func
  {
    if( me._focused )
      return me;

    var canvas = me.getCanvas();
    if( canvas._focused_widget != nil )
      canvas._focused_widget.clearFocus();

    me._focused = 1;
    canvas._focused_widget = me;

    me.onFocusIn();
    me._onStateChange();

    return me;
  },
  #
  clearFocus: func
  {
    if( !me._focused )
      return me;

    me._focused = 0;
    me.getCanvas()._focused_widget = nil;

    me.onFocusOut();
    me._onStateChange();

    return me;
  },
  onFocusIn: func {},
  onFocusOut: func {},
  onMouseEnter: func {},
  onMouseLeave: func {},
# protected:
  _MAX_SIZE: 32768, # size for "no size-limit"
  _onStateChange: func {},
  _setRoot: func(el)
  {
    me._root = el;

    var canvas = el.getCanvas();
    me.setCanvas(canvas);

    canvas.addEventListener("wm.focus-in", func {
      me._onStateChange();
    });
    canvas.addEventListener("wm.focus-out", func {
      me._onStateChange();
    });

    el.addEventListener("mouseenter", func {
      me._hover = 1;
      me.onMouseEnter();
      me._onStateChange();
    });
    el.addEventListener("mousedown", func {
      if( bits.test(me._focus_policy, me.ClickFocus / 2) )
        me.setFocus();
    });
    el.addEventListener("mouseleave", func {
      me._hover = 0;
      me.onMouseLeave();
      me._onStateChange();
    });
  },
  _windowFocus: func
  {
    var canvas = me.getCanvas();
    return canvas != nil ? canvas.data("focused") : 0;
  }
};
