gui.widgets.ScrollArea = {
  new: func(parent, style, cfg)
  {
    var cfg = Config.new(cfg);
    var m = gui.Widget.new(gui.widgets.ScrollArea);
    m._focus_policy = m.StrongFocus;
    m._active = 0;
    m._pos = [0,0];
    m._size = cfg.get("size", m._size);

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
  moveTo: func(x, y)
  {
    me._pos[0] = math.max(0, math.min(x, me._max_scroll[0]));
    me._pos[1] = math.max(0, math.min(y, me._max_scroll[1]));

    me.update();
  },
  update: func()
  {
    # TODO only update on content resize
    var bb = me.getContent().getTightBoundingBox();

    if( bb[2] < bb[0] or bb[3] < bb[1] )
      # Do nothing with invalid bounding box (probably no content yet)
      return me;

    var w = bb[2] - bb[0];
    var h = bb[3] - bb[1];

    me._max_scroll = [0, 0];
    if( w > me._size[0] )
      me._max_scroll[0] = me._size[0] * (1 - me._size[0] / w);
    if( h > me._size[1] )
      me._max_scroll[1] = me._size[1] * (1 - me._size[1] / h);

    me._content_size = [w, h];

    var cur_offset = me.getContent().getTranslation();
    me._content_offset = [cur_offset[0] - bb[0], cur_offset[1] - bb[1]];

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
  }
};
