var Dialog = {
  # Constructor
  #
  # @param size_dlg Dialog size ([width, height])
  new: func(size_dlg, id = nil)
  {
    var m = {
      parents: [Dialog, PropertyElement.new(["/sim/gui/canvas", "window"], id)]
    };
    m.setInt("size[0]", size_dlg[0]);
    m.setInt("size[1]", size_dlg[1]);

    return m;
  },
  # Create the canvas to be used for this dialog
  #
  # @return The new canvas
  createCanvas: func()
  {
    var size_dlg = [
      me.get("size[0]"),
      me.get("size[1]")
    ];

    me._canvas = new({
      size: [2 * size_dlg[0], 2 * size_dlg[1]],
      view: size_dlg,
      placement: {
        type: "window",
        index: me._node.getIndex()
      }
    });
  },
  # Set an existing canvas to be used for this dialog
  setCanvas: func(canvas_)
  {
    if( !isa(canvas_, canvas.Canvas) )
      return debug.warn("Not a canvas.Canvas");

    canvas_.addPlacement({type: "window", index: me._node.getIndex()});
    me['_canvas'] = canvas_;
  },
  # Get the displayed canvas
  getCanvas: func()
  {
    return me['_canvas'];
  },
  setPosition: func(x, y)
  {
    me.setInt("x", x);
    me.setInt("y", y);
  },
  move: func(x, y)
  {
    me.setInt("x", me.get("x", 0) + x);
    me.setInt("y", me.get("y", 0) + y);
  },
  # Raise to top of window stack
  raise: func()
  {
    me.setBool("raise-top", 1);
  }
};

var Event = {
  PUSH:    1,
  RELEASE: 2,
  DRAG:    8,
  MOVE:    16,
  SCROLL:  512,

  LEFT_MOUSE_BUTTON:   1,
  MIDDLE_MOUSE_BUTTON: 2,
  RIGHT_MOUSE_BUTTON:  4
};
