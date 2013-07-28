gui.Widget = {
# enum FocusPolicy:
  NoFocus: 0,
  TabFocus: 1,
  ClickFocus: 2,
  StrongFocus: 1 + 2,

  #
  new: func(derived)
  {
    return {
      parents: [derived, gui.Widget],
      _focused: 0,
      _focus_policy: gui.Widget.NoFocus,
      _hover: 0,
      _root: nil
    };
  },
  # Move the widget to the given position (relative to its parent)
  move: func(x, y)
  {
    me._root.setTranslation(x, y);
    return me;
  },
  #
  setFocus: func
  {
    if( me._focused )
      return me;

    if( me._window._focused_widget != nil )
      me._window._focused_widget.clearFocus();

    me._focused = 1;
    me._window._focused_widget = me;

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
    me._window._focused_widget = nil;

    me.onFocusOut();
    me._onStateChange();

    return me;
  },
  onFocusIn: func {},
  onFocusOut: func {},
  onMouseEnter: func {},
  onMouseLeave: func {},
# protected:
  _onStateChange: func {},
  _setRoot: func(el)
  {
    me._root = el;
    el.addEventListener("mouseenter", func {
      me._hover = 1;
      me.onMouseEnter();
      me._onStateChange();
    });
    el.addEventListener("mousedown", func {
      if( bits.test(me._focus_policy, me.ClickFocus / 2) )
      {
        me.setFocus();
        me._window.setFocus();
      }
    });
    el.addEventListener("mouseleave", func {
      me._hover = 0;
      me.onMouseLeave();
      me._onStateChange();
    });
  }
};
