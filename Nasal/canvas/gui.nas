var Window = {
  # Constructor
  #
  # @param size ([width, height])
  new: func(size, type = nil, id = nil)
  {
    var ghost = _newWindowGhost(id);
    var m = {
      parents: [Window, PropertyElement, ghost],
      _node: props.wrapNode(ghost._node_ghost)
    };

    m.setInt("size[0]", size[0]);
    m.setInt("size[1]", size[1]);

    # TODO better default position
    m.move(0,0);

    # arg = [child, listener_node, mode, is_child_event]
    setlistener(m._node, func m._propCallback(arg[0], arg[2]), 0, 2);
    if( type )
      m.set("type", type);

    return m;
  },
  # Destructor
  del: func
  {
    me._node.remove();
    if( me["_canvas"] != nil )
      me._canvas.del();
  },
  # Create the canvas to be used for this Window
  #
  # @return The new canvas
  createCanvas: func()
  {
    var size = [
      me.get("size[0]"),
      me.get("size[1]")
    ];

    me._canvas = new({
      size: [2 * size[0], 2 * size[1]],
      view: size,
      placement: {
        type: "window",
        index: me._node.getIndex()
      }
    });

    me._canvas.addEventListener("mousedown", func me.raise());
    return me._canvas;
  },
  # Set an existing canvas to be used for this Window
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
  getCanvasDecoration: func()
  {
    return wrapCanvas(me._getCanvasDecoration());
  },
  setPosition: func(x, y)
  {
    me.setInt("tf/t[0]", x);
    me.setInt("tf/t[1]", y);
  },
  move: func(x, y)
  {
    me.setInt("tf/t[0]", me.get("tf/t[0]", 10) + x);
    me.setInt("tf/t[1]", me.get("tf/t[1]", 30) + y);
  },
  # Raise to top of window stack
  raise: func()
  {
    me.setBool("raise-top", 1);
  },
# private:
  _propCallback: func(child, mode)
  {
    if( !me._node.equals(child.getParent()) )
      return;
    var name = child.getName();

    # support for CSS like position: absolute; with right and/or bottom margin
    if( name == "right" )
      me._handlePositionAbsolute(child, mode, name, 0);
    else if( name == "bottom" )
      me._handlePositionAbsolute(child, mode, name, 1);

    # update decoration on type change
    else if( name == "type" )
    {
      if( mode == 0 )
        settimer(func me._updateDecoration(), 0);
    }
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
      "tf/t[" ~ index ~ "]",
      getprop("/sim/gui/canvas/size[" ~ index ~ "]")
      - me.get(name)
      - me.get("size[" ~ index ~ "]")
    );
  },
  _updateDecoration: func()
  {
    var border_radius = 9;
    me.set("decoration-border", "25 1 1");
    me.set("shadow-inset", int((1 - math.cos(45 * D2R)) * border_radius + 0.5));
    me.set("shadow-radius", 5);

    var canvas_deco = me.getCanvasDecoration();
    canvas_deco.addEventListener("mousedown", func me.raise());
    canvas_deco.set("blend-source-rgb", "src-alpha");
    canvas_deco.set("blend-destination-rgb", "one-minus-src-alpha");
    canvas_deco.set("blend-source-alpha", "one");
    canvas_deco.set("blend-destination-alpha", "one");

    var group_deco = canvas_deco.getGroup("decoration");
    var title_bar = group_deco.createChild("group", "title_bar");
    title_bar.addEventListener("drag", func(e) { me.move(e.deltaX, e.deltaY); });
    title_bar
      .rect( 0, 0,
             me.get("size[0]"),
             me.get("size[1]"), #25,
             {"border-top-radius": border_radius} )
      .setColorFill(0.25,0.24,0.22)
      .setStrokeLineWidth(0);

    var style_dir = "gui/styles/AmbianceClassic/";

    # close icon
    var x = 10;
    var y = 3;
    var w = 19;
    var h = 19;
    var ico = title_bar.createChild("image", "icon-close")
                       .set("file", style_dir ~ "close_focused_normal.png")
                       .setTranslation(x,y);
    ico.addEventListener("click", func me.del());
    ico.addEventListener("mouseover", func ico.set("file", style_dir ~ "close_focused_prelight.png"));
    ico.addEventListener("mousedown", func ico.set("file", style_dir ~ "close_focused_pressed.png"));
    ico.addEventListener("mouseout",  func ico.set("file", style_dir ~ "close_focused_normal.png"));

    # title
    me._title = title_bar.createChild("text", "title")
                         .set("alignment", "left-center")
                         .set("character-size", 14)
                         .set("font", "LiberationFonts/LiberationSans-Bold.ttf")
                         .setTranslation( int(x + 1.5 * w + 0.5),
                                          int(y + 0.5 * h + 0.5) );

    var title = me.get("title", "Canvas Dialog");
    me._node.getNode("title", 1).alias(me._title._node.getPath() ~ "/text");
    me.set("title", title);
  }
};
