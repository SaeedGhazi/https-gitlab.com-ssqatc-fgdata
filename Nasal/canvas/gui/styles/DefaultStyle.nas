var DefaultStyle = {
  new: func(name)
  {
    return { parents: [gui.Style.new(name), DefaultStyle] };
  },
  createWidget: func(parent, type, cfg)
  {
    var factory = me.widgets[type];
    if( factory == nil )
    {
      debug.warn("DefaultStyle: unknown widget type (" ~ type ~ ")");
      return nil;
    }

    var w = {
      parents: [factory],
      _style: me
    };
    call(factory.new, [parent, cfg], w);
    return w;
  },
  widgets: {}
};

# A button
DefaultStyle.widgets.button = {
  padding: [6, 8, 6, 8],
  new: func(parent, cfg)
  {
    me.element = parent.createChild("group", "button");
    me.size = cfg.get("size", [26, 26]);

    me._bg =
      me.element.rect( 3,
                       3,
                       me.size[0] - 6,
                       me.size[1] - 6,
                       {"border-radius": 5} );
    me._border =
      me.element.createChild("image", "button")
                .set("slice", "10 12") #"7")
                .setSize(me.size);
    me._label =
      me.element.createChild("text")
                .setFont("LiberationFonts/LiberationSans-Regular.ttf")
                .set("character-size", 14)
                .set("alignment", "center-baseline");
  },
  setText: func(text)
  {
    me._label.set("text", text);
  },
  update: func(active, focused, hover, backdrop)
  {
    var file = me._style._dir_widgets ~ "/";
    if( backdrop )
    {
      file ~= "backdrop-";
      me._label.set("fill", me._style.getColor("backdrop_fg_color"));
    }
    else
      me._label.set("fill", me._style.getColor("fg_color"));
    file ~= "button";

    if( active )
    {
      file ~= "-active";
      me._label.setTranslation(me.size[0] / 2 + 1, me.size[1] / 2 + 6);
    }
    else
      me._label.setTranslation(me.size[0] / 2, me.size[1] / 2 + 5);


    if( focused and !backdrop )
      file ~= "-focused";

    if( hover and !active )
    {
      file ~= "-hover";
      me._bg.set("fill", me._style.getColor("button_bg_color_hover"));
    }
    else
      me._bg.set("fill", me._style.getColor("button_bg_color"));

    me._border.set("src", file ~ ".png");
  }
};

# ScrollArea
DefaultStyle.widgets["scroll-area"] = {
  new: func(parent, cfg)
  {
    me.element = parent.createChild("group", "scroll-area");

    me._bg    = me.element.createChild("path", "background")
                          .set("fill", "#e0e0e0");
    me.content = me.element.createChild("group", "scroll-content")
                           .set("clip-frame", Element.PARENT);
    me.vert  = me._newScroll(me.element, "vert");
    me.horiz = me._newScroll(me.element, "horiz");
  },
  setColorBackground: func
  {
    if( size(arg) == 1 )
    	  var arg = arg[0];
    	me._bg.setColorFill(arg);
  },
  update: func(widget)
  {
    me.horiz.reset();
    if( widget._max_scroll[0] > 1 )
      # only show scroll bar if horizontally scrollable
      me.horiz.moveTo(widget._pos[0], widget._size[1] - 2)
              .horiz(widget._size[0] - widget._max_scroll[0]);

    me.vert.reset();
    if( widget._max_scroll[1] > 1 )
      # only show scroll bar if vertically scrollable
      me.vert.moveTo(widget._size[0] - 2, widget._pos[1])
             .vert(widget._size[1] - widget._max_scroll[1]);

    me._bg.reset()
          .rect(0, 0, widget._size[0], widget._size[1]);
    me.content.set(
      "clip",
      "rect(0, " ~ widget._size[0] ~ ", " ~ widget._size[1] ~ ", 0)"
    );
  },
# private:
  _newScroll: func(el, orient)
  {
    return el.createChild("path", "scroll-" ~ orient)
             .set("stroke", "#f07845")
             .set("stroke-width", 4);
  }
};
