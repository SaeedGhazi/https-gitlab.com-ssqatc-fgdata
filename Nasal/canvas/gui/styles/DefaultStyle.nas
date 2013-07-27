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

    return factory.new(parent, me, cfg);
  },
  widgets: {}
};

# A button
DefaultStyle.widgets.button = {
  padding: [6, 8, 6, 8],
  new: func(parent, style, cfg)
  {
    var button = {
      parents: [DefaultStyle.widgets.button],
      element: parent.createChild("group", "button"),
      size: cfg.get("size", [26, 26]),
      _style: style
    };

    button._bg =
      button.element.rect( 3,
                           3,
                           button.size[0] - 6,
                           button.size[1] - 6,
                           {"border-radius": 5} );
    button._border =
      button.element.createChild("image", "button")
                    .set("slice", "10 12") #"7")
                    .setSize(button.size);
    button._label =
      button.element.createChild("text")
                    .setFont("LiberationFonts/LiberationSans-Regular.ttf")
                    .set("character-size", 14)
                    .set("alignment", "center-baseline");
    return button;
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

    me._border.set("file", file ~ ".png");
  }
};
