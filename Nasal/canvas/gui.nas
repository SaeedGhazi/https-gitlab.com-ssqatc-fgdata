var gui = {
  widgets: {},
  focused_window: nil
};

var gui_dir = getprop("/sim/fg-root") ~ "/Nasal/canvas/gui/";
var loadGUIFile = func(file) io.load_nasal(gui_dir ~ file, "canvas");
var loadWidget = func(name) loadGUIFile("widgets/" ~ name ~ ".nas");

loadGUIFile("Style.nas");
loadGUIFile("Widget.nas");
loadGUIFile("styles/DefaultStyle.nas");
loadWidget("Button");

var style = DefaultStyle.new("AmbianceClassic");
var WindowButton = {
  new: func(parent, name)
  {
    var m = {
      parents: [WindowButton, gui.widgets.Button.new(parent, nil, {"flat": 1})],
      _name: name
    };
    m._focus_policy = m.NoFocus;
    m._setRoot( parent.createChild("image", "WindowButton-" ~ name) );
    return m;
  },
# protected:
  _onStateChange: func
  {
    var file = style._dir_decoration ~ "/" ~ me._name;
    file ~= me._window._focused ? "_focused" : "_unfocused";

    if( me._active )
      file ~= "_pressed";
    else if( me._hover )
      file ~= "_prelight";
    else if( me._window._focused )
      file ~= "_normal";

    me._root.set("file", file ~ ".png");
  }
};

var Window = {
  # Constructor
  #
  # @param size ([width, height])
  new: func(size, type = nil, id = nil)
  {
    var ghost = _newWindowGhost(id);
    var m = {
      parents: [Window, PropertyElement, ghost],
      _node: props.wrapNode(ghost._node_ghost),
      _focused: 0,
      _focused_widget: nil,
      _widgets: []
    };

    m.setInt("content-size[0]", size[0]);
    m.setInt("content-size[1]", size[1]);

    # TODO better default position
    m.move(0,0);
    m.setFocus();

    # arg = [child, listener_node, mode, is_child_event]
    setlistener(m._node, func m._propCallback(arg[0], arg[2]), 0, 2);
    if( type )
      m.set("type", type);

    return m;
  },
  # Destructor
  del: func
  {
    me.clearFocus();

    if( me["_canvas"] != nil )
    {
      var placements = me._canvas.texture.getChildren("placement");
      # Do not remove canvas if other placements exist
      if( size(placements) > 1 )
        foreach(var p; placements)
        {
          if(     p.getValue("type") == "window"
              and p.getValue("id") == me.get("id") )
            p.remove();
        }
      else
        me._canvas.del();
      me._canvas = nil;
    }

    me._node.remove();
    me._node = nil;
  },
  # Create the canvas to be used for this Window
  #
  # @return The new canvas
  createCanvas: func()
  {
    var size = [
      me.get("content-size[0]"),
      me.get("content-size[1]")
    ];

    me._canvas = new({
      size: [2 * size[0], 2 * size[1]],
      view: size,
      placement: {
        type: "window",
        id: me.get("id")
      },

      # Standard alpha blending
      "blend-source-rgb": "src-alpha",
      "blend-destination-rgb": "one-minus-src-alpha",

      # Just keep current alpha (TODO allow using rgb textures instead of rgba?)
      "blend-source-alpha": "zero",
      "blend-destination-alpha": "one"
    });

    me._canvas.addEventListener("mousedown", func me.raise());
    return me._canvas;
  },
  # Set an existing canvas to be used for this Window
  setCanvas: func(canvas_)
  {
    if( !isa(canvas_, canvas.Canvas) )
      return debug.warn("Not a canvas.Canvas");

    canvas_.addPlacement({type: "window", "id": me.get("id")});
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
  addWidget: func(w)
  {
    append(me._widgets, w);
    w._window = me;
    if( size(me._widgets) == 2 )
      w.setFocus();
    w._onStateChange();
    return me;
  },
  #
  setFocus: func
  {
    if( me._focused )
      return me;

    if( gui.focused_window != nil )
      gui.focused_window.clearFocus();

    me._focused = 1;
#    me.onFocusIn();
    me._onStateChange();
    gui.focused_window = me;
    return me;
  },
  #
  clearFocus: func
  {
    if( !me._focused )
      return me;

    me._focused = 0;
#    me.onFocusOut();
    me._onStateChange();
    gui.focused_window = nil;
    return me;
  },
  setPosition: func(x, y)
  {
    me.setInt("tf/t[0]", x);
    me.setInt("tf/t[1]", y);
  },
  setSize: func(w, h)
  {
    me.set("content-size[0]", w);
    me.set("content-size[1]", h);
  },
  move: func(x, y)
  {
    me.setInt("tf/t[0]", me.get("tf/t[0]", 10) + x);
    me.setInt("tf/t[1]", me.get("tf/t[1]", 30) + y);
  },
  # Raise to top of window stack
  raise: func()
  {
    # on writing the z-index the window always is moved to the top of all other
    # windows with the same z-index.
    me.setInt("z-index", me.get("z-index", 0));

    me.setFocus();
  },
# protected:
  _onStateChange: func
  {
    if( me._getCanvasDecoration() != nil )
    {
      # Stronger shadow for focused windows
      me.getCanvasDecoration()
        .set("image[1]/fill", me._focused ? "#000000" : "rgba(0,0,0,0.5)");

      var suffix = me._focused ? "" : "-unfocused";
      me._title_bar_bg.set("fill", style.getColor("title" ~ suffix));
      me._title.set(       "fill", style.getColor("title-text" ~ suffix));
      me._top_line.set(  "stroke", style.getColor("title-highlight" ~ suffix));
    }

    foreach(var w; me._widgets)
      w._onStateChange();
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
          me._node.getNode("content-size[" ~ index ~ "]"),
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
      - me.get("content-size[" ~ index ~ "]")
    );
  },
  _updateDecoration: func()
  {
    var border_radius = 9;
    me.set("decoration-border", "25 1 1");
    me.set("shadow-inset", int((1 - math.cos(45 * D2R)) * border_radius + 0.5));
    me.set("shadow-radius", 5);
    me.setBool("update", 1);

    var canvas_deco = me.getCanvasDecoration();
    canvas_deco.addEventListener("mousedown", func me.raise());
    canvas_deco.set("blend-source-rgb", "src-alpha");
    canvas_deco.set("blend-destination-rgb", "one-minus-src-alpha");
    canvas_deco.set("blend-source-alpha", "one");
    canvas_deco.set("blend-destination-alpha", "one");

    var group_deco = canvas_deco.getGroup("decoration");
    var title_bar = group_deco.createChild("group", "title_bar");
    me._title_bar_bg =
      title_bar.rect( 0, 0,
                      me.get("size[0]"),
                      me.get("size[1]"),
                      {"border-top-radius": border_radius} );
    me._top_line = title_bar.createChild("path", "top-line")
                            .moveTo(border_radius - 2, 2)
                            .lineTo(me.get("size[0]") - border_radius + 2, 2);

    # close icon
    var x = 10;
    var y = 3;
    var w = 19;
    var h = 19;

    var button_close = WindowButton.new(title_bar, "close")
                                   .move(x, y);
    button_close.onClick = func me.del();
    me.addWidget(button_close);

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

    title_bar.addEventListener("drag", func(e) me.move(e.deltaX, e.deltaY));
    me._onStateChange();
  }
};

# Provide old 'Dialog' for backwards compatiblity (should be removed for 3.0)
var Dialog = {
  new: func(size, type = nil, id = nil)
  {
    debug.warn("'canvas.Dialog' is deprectated! (use canvas.Window instead)");
    return Window.new(size, type, id);
  }
};
