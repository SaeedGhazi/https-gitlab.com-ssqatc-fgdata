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

    # arg = [child, listener_node, mode, is_child_event]
    setlistener(m._node, func m._propCallback(arg[0], arg[2]), 0, 2);

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
  },
# private:
  _propCallback: func(child, mode)
  {
    # support for CSS like position: absolute; with right and/or bottom margin
    if( child.getName() == "right" )
      me._handlePositionAbsolute(child, mode, child.getName(), 0);
    else if( child.getName() == "bottom" )
      me._handlePositionAbsolute(child, mode, child.getName(), 1);
  },
  _handlePositionAbsolute: func(child, mode, name, index)
  {
    # mode
    #   -1 child removed
    #    0 value changed
    #    1 child added

    if( mode == 0 )
      me._updatePos(index, name);
    else if( mode == 1 )
      me["_listener_" ~ name] = [
        setlistener
        (
          "/sim/gui/canvas/size[" ~ index ~ "]",
          func me._updatePos(index, name)
        ),
        setlistener
        (
          me._node.getNode("size[" ~ index ~ "]"),
          func me._updatePos(index, name)
        )
      ];
    else if( mode == -1 )
      for(var i = 0; i < 2; i += 1)
        removelistener(me["_listener_" ~ name][i]);
  },
  _updatePos: func(index, name)
  {
    me.setInt
    (
      index == 0 ? "x" : "y",
      getprop("/sim/gui/canvas/size[" ~ index ~ "]")
      - me.get(name)
      - me.get("size[" ~ index ~ "]")
    );
  }
};
