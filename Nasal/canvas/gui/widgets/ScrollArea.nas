gui.widgets.ScrollArea = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.ScrollArea);
    m._focus_policy = m.StrongFocus;
    m._active = 0;
    m._pos = [0,0];
    m._size = cfg.get("size", m._size);
    m._max_scroll = [0, 0];
    m._content_size = [0, 0];

    if( style != nil )
    {
      m._scroll = style.createWidget(parent, "scroll-area", cfg);
      m._setRoot(m._scroll.element);

      m._scroll.vert.addEventListener("mousedown", func(e) m._dragStart(e));
      m._scroll.horiz.addEventListener("mousedown", func(e) m._dragStart(e));

      m._scroll.vert.addEventListener
      (
        "drag",
        func(e) m.moveTo(m._pos[0], m._drag_offsetY + e.clientY)
      );
      m._scroll.horiz.addEventListener
      (
        "drag",
        func(e) m.moveTo(m._drag_offsetX + e.clientX, m._pos[1])
      );
    }

    return m;
  },
  getContent: func()
  {
    return me._scroll.content;
  },
  # Set the background color for the content area.
  #
  # @param color  Vector of 3 or 4 values in [0, 1]
  setColorBackground: func
  {
    if( size(arg) == 1 )
      var arg = arg[0];
    me._scroll.setColorBackground(arg);
  },
  # Reset the size of the content area, e.g. on window resize.
  #
  # @param sz  Vector of [x,y] values.
  setSize: func
  {
    if( size(arg) == 1 )
      var arg = arg[0];
    var (x,y) = arg;
    me._size = [x,y];
    me.update();
  },
  # Move the scrollable area to the coordinates x,y (or as far as possible) and
  # update.
  #
  # @param x The x coordinate (positive is right)
  # @param y The y coordinate (positive is down)
  moveTo: func(x, y)
  {
    var bb = me._updateBB();

    me._pos[0] = math.max(0, math.min(x, me._max_scroll[0]));
    me._pos[1] = math.max(0, math.min(y, me._max_scroll[1]));

    me.update(bb);
  },
  # Move the scrollable area to the top-most position and update.
  moveToTop: func()
  {
    me._pos[1] = 0;

    me.update();
  },
  # Move the scrollable area to the bottom-most position and update.
  moveToBottom: func()
  {
    var bb = me._updateBB();

    me._pos[1] = me._max_scroll[1];

    me.update(bb);
  },
  # Move the scrollable area to the left-most position and update.
  moveToLeft: func()
  {
    me._pos[0] = 0;

    me.update();
  },
  # Move the scrollable area to the right-most position and update.
  moveToRight: func()
  {
    var bb = me._updateBB();

    me._pos[0] = me._max_scroll[0];

    me.update(bb);
  },
  # Update scroll bar and content area.
  #
  # Needs to be called when the size of the content changes.
  update: func(bb=nil)
  {
    if (bb == nil) bb = me._updateBB();
    if (bb == nil) return me;

    var offset = [ me._content_offset[0],
                   me._content_offset[1] ];

    if( me._max_scroll[0] > 1 )
      offset[0] -= (me._pos[0] / me._max_scroll[0])
                 * (me._content_size[0] - me._size[0]);
    if( me._max_scroll[1] > 1 )
      offset[1] -= (me._pos[1] / me._max_scroll[1])
                 * (me._content_size[1] - me._size[1]);

    me.getContent().setTranslation(offset);

    me._scroll.update(me);
    me.getContent().update();

    return me;
  },
# protected:
  _setRoot: func(el)
  {
    el.addEventListener("wheel", func(e) me.moveTo(me._pos[0], me._pos[1] - e.deltaY));

    call(gui.Widget._setRoot, [el], me);
  },
  _dragStart: func(e)
  {
    me._drag_offsetX = me._pos[0] - e.clientX;
    me._drag_offsetY = me._pos[1] - e.clientY;
  },
  _updateBB: func() {
    # TODO only update on content resize
    var bb = me.getContent().getTightBoundingBox();

    if( bb[2] < bb[0] or bb[3] < bb[1] )
      return nil;
    var w = bb[2] - bb[0];
    var h = bb[3] - bb[1];

    if( w > me._size[0] )
      me._max_scroll[0] = me._size[0] * (1 - me._size[0] / w);
    else me._max_scroll[0] = 0;
    if( h > me._size[1] )
      me._max_scroll[1] = me._size[1] * (1 - me._size[1] / h);
    else me._max_scroll[1] = 0;

    me._content_size[0] = w;
    me._content_size[1] = h;

    var cur_offset = me.getContent().getTranslation();
    me._content_offset = [cur_offset[0] - bb[0], cur_offset[1] - bb[1]];
  },
};
