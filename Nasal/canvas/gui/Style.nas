gui.Style = {
  new: func(name)
  {
    var root_node = props.globals.getNode("/sim/gui/canvas", 1)
                                 .addChild("style");
    var path = getprop("/sim/fg-root") ~ "/gui/styles/" ~ name;

    var m = {
      parents: [gui.Style],
      _path: path,
      _node: io.read_properties(path ~ "/style.xml", root_node),
      _colors: {}
    };

    # parse theme colors
    var comp_names = ["red", "green", "blue", "alpha"];
    var colors = m._node.getChild("colors");
    if( colors != nil )
    {
      foreach(var color; colors.getChildren())
      {
        var str = "rgba(";
        for(var i = 0; i < size(comp_names); i += 1)
        {
          if( i > 0 )
            str ~= ",";
          var val = color.getValue(comp_names[i]);
          if( val == nil )
            val = 1;
          if( i < 3 )
            str ~= int(val * 255 + 0.5);
          else
            str ~= int(val * 100) / 100;
        }
        m._colors[ color.getName() ] = str ~ ")";
      }
    }

    m._dir_decoration =
      m._path ~ "/" ~ (m._node.getValue("folders/decoration") or "decoration");
    m._dir_widgets =
      m._path ~ "/" ~ (m._node.getValue("folders/widgets") or "widgets");

    return m;
  },
  getColor: func(name, def = "#00ffff")
  {
    return me._colors[name] or def;
  }
};
