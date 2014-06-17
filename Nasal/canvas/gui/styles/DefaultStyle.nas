var DefaultStyle = {
  new: func(name, name_icon_theme)
  {
    return {
      parents: [ gui.Style.new(name, name_icon_theme),
                 DefaultStyle ]
    };
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
    me._root = parent.createChild("group", "button");
    me._bg =
      me._root.createChild("path");
    me._border =
      me._root.createChild("image", "button")
              .set("slice", "10 12"); #"7")
    me._label =
      me._root.createChild("text")
              .set("font", "LiberationFonts/LiberationSans-Regular.ttf")
              .set("character-size", 14)
              .set("alignment", "center-baseline");
  },
  setSize: func(model, w, h)
  {
    me._bg.reset()
          .rect(3, 3, w - 6, h - 6, {"border-radius": 5});
    me._border.setSize(w, h);
  },
  setText: func(model, text)
  {
    me._label.set("text", text);

    # TODO get real font metrics
    model.setMinimumSize([size(text) * 5 + 6, 16]);
    model.setSizeHint([size(text) * 8 + 16, 32]);

    return me;
  },
  update: func(model)
  {
    var backdrop = !model._windowFocus();
    var (w, h) = model._size;
    var file = me._style._dir_widgets ~ "/";

    # TODO unify color names with image names
    var bg_color_name = "button_bg_color";
    if( backdrop )
      bg_color_name = "button_backdrop_bg_color";
    else if( !model._enabled )
      bg_color_name = "button_bg_color_insensitive";
    else if( model._down )
      bg_color_name = "button_bg_color_down";
    else if( model._hover )
      bg_color_name = "button_bg_color_hover";
    me._bg.set("fill", me._style.getColor(bg_color_name));

    if( backdrop )
    {
      file ~= "backdrop-";
      me._label.set("fill", me._style.getColor("backdrop_fg_color"));
    }
    else
      me._label.set("fill", me._style.getColor("fg_color"));
    file ~= "button";

    if( model._down )
    {
      file ~= "-active";
      me._label.setTranslation(w / 2 + 1, h / 2 + 6);
    }
    else
      me._label.setTranslation(w / 2, h / 2 + 5);

    if( model._enabled )
    {
      if( model._focused and !backdrop )
        file ~= "-focused";

      if( model._hover and !model._down )
        file ~= "-hover";
    }
    else
      file ~= "-disabled";

    me._border.set("src", file ~ ".png");
  }
};

# A label
DefaultStyle.widgets.label = {
  new: func(parent, cfg)
  {
    me._root = parent.createChild("group", "label");
  },
  setSize: func(model, w, h)
  {
    if( me['_bg'] != nil )
      me._bg.reset().rect(0, 0, w, h);
    if( me['_img'] != nil )
      me._img.set("size[0]", w)
             .set("size[1]", h);
    if( me['_text'] != nil )
    {
      # TODO different alignment
      me._text.setTranslation(2, 2 + h / 2);
      me._text.set(
        "max-width",
        model._cfg.get("wordWrap", 0) ? (w - 4) : 0
      );
    }
    return me;
  },
  setText: func(model, text)
  {
    if( text == nil or size(text) == 0 )
    {
      model.setHeightForWidthFunc(nil);
      return me._deleteElement('text');
    }

    me._createElement("text", "text")
      .set("text", text)
      .set("fill", "black");

    if( model._cfg.get("wordWrap", 0) )
    {
      var m = me;
      model.setHeightForWidthFunc(func(w) m.heightForWidth(w));
    }
    else
    {
      # TODO get real font metrics
      model.setMinimumSize([size(text) * 5 + 4, 14]);
      model.setSizeHint([size(text) * 5 + 14, 24]);
    }

    return me;
  },
  setImage: func(model, img)
  {
    if( img == nil or size(img) == 0 )
      return me._deleteElement('img');

    me._createElement("img", "image")
      .set("src", img)
      .set("preserveAspectRatio", "xMidYMid slice");

    return me;
  },
  # @param bg CSS color or 'none'
  setBackground: func(model, bg)
  {
    if( bg == nil or bg == "none" )
      return me._deleteElement("bg");

    me._createElement("bg", "path")
      .set("fill", bg);

    me.setSize(model, model._size[0], model._size[1]);
    return me;
  },
  heightForWidth: func(w)
  {
    if( me['_text'] == nil )
      return -1;

    return math.max(14, me._text.heightForWidth(w - 4));
  },
# protected:
  _createElement: func(name, type)
  {
    var mem = '_' ~ name;
    if( me[ mem ] == nil )
    {
      me[ mem ] = me._root.createChild(type, "label-" ~ name);

      if( type == "text" )
      {
         me[ mem ].set("font", "LiberationFonts/LiberationSans-Regular.ttf")
                  .set("character-size", 14)
                  .set("alignment", "left-center");
      }
    }
    return me[ mem ];
  },
  _deleteElement: func(name)
  {
    name = '_' ~ name;
    if( me[ name ] != nil )
    {
      me[ name ].del();
      me[ name ] = nil;
    }
    return me;
  }
};

# ScrollArea
DefaultStyle.widgets["scroll-area"] = {
  new: func(parent, cfg)
  {
    me._root = parent.createChild("group", "scroll-area");

    me._bg     = me._root.createChild("path", "background")
                         .set("fill", "#e0e0e0");
    me.content = me._root.createChild("group", "scroll-content")
                         .set("clip-frame", Element.PARENT);
    me.vert  = me._newScroll(me._root, "vert");
    me.horiz = me._newScroll(me._root, "horiz");
  },
  setColorBackground: func
  {
    if( size(arg) == 1 )
    	  var arg = arg[0];
    	me._bg.setColorFill(arg);
  },
  update: func(model)
  {
    me.horiz.reset();
    if( model._max_scroll[0] > 1 )
      # only show scroll bar if horizontally scrollable
      me.horiz.moveTo(model._scroll_pos[0], model._size[1] - 2)
              .horiz(model._size[0] - model._max_scroll[0]);

    me.vert.reset();
    if( model._max_scroll[1] > 1 )
      # only show scroll bar if vertically scrollable
      me.vert.moveTo(model._size[0] - 2, model._scroll_pos[1])
             .vert(model._size[1] - model._max_scroll[1]);

    me._bg.reset()
          .rect(0, 0, model._size[0], model._size[1]);
    me.content.set(
      "clip",
      "rect(0, " ~ model._size[0] ~ ", " ~ model._size[1] ~ ", 0)"
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
