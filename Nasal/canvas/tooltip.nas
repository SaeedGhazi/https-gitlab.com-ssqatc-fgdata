var Tooltip = {
  # Constructor
  #
  # @param size ([width, height])
  new: func(size, id = nil)
  {
    var m = {
      parents: [Tooltip, PropertyElement.new(["/sim/gui/canvas", "window"], id)],
      _listener: nil,
      _property: nil,
      _mapping: "",
      _width: 0,
      _height: 0,
      _tipId: nil,
      _slice: 17,
      _measureText: nil,
      _measureBB: nil
    };
    m.setInt("size[0]", size[0]);
    m.setInt("size[1]", size[1]);
    m.setBool("visible", 0);

    # arg = [child, listener_node, mode, is_child_event]
   # setlistener(m._node, func m._propCallback(arg[0], arg[2]), 0, 2);

    return m;
  },
  # Destructor
  del: func
  {
    me.parents[1].del();
    if( me["_canvas"] != nil )
      me._canvas.del();
  },
  # Create the canvas to be used for this Tooltip
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

    # don't do anything with mouse events ourselves
    me.set("capture-events", 0);
    me.set("fill", "rgba(255,255,255,0.8)");

    # transparent background
    me._canvas.setColorBackground(0.0, 0.0, 0.0, 0.0);

    var root = me._canvas.createGroup();
    me._root = root;

    me._frame =
      root.createChild("image", "background")
          .set("file", "gui/images/tooltip.png")
          .set("slice", me._slice ~ " fill")
          .setSize(size);

    me._text =
      root.createChild("text", "tooltip-caption")
          .setText("Aircraft Help")
          .setAlignment("left-top")
          .setFontSize(14)
          .setFont("LiberationFonts/LiberationSans-Bold.ttf")
          .setColor(1,1,1)
          .setDrawMode(Text.TEXT)
          .setTranslation(me._slice, me._slice)
          .setMaxWidth(size[0]);

    return me._canvas;
  },

  setLabel: func(msg)
  {
    me._label = msg;
    me._updateText();
  },

  setProperty: func(prop)
  {
    if (me._property != nil)
      removelistener(me._listener);

    me._property = prop;
    if (me._property != nil)
      me._listener = setlistener(me._property, func { me._updateText(); });

    me._updateText();
  },

  # specify a string used to compute the width of the tooltip
  setWidthText: func(txt)
  {
    me._measureBB = me._text.setText(txt)
                            .update()
                            .getBoundingBox();
    me._updateBounds();
  },

  _updateText: func
  {
    var msg = me._label;
    if (me._property != nil) {
      var val = me._remapValue(me._property.getValue());
      msg = sprintf(me._label, val);
    }

    me._text.setText(msg);
    me._updateBounds();
  },

  _updateBounds: func
  {
    var max_width = me.get("size[0]") - 2 * me._slice;
    me._text.setMaxWidth(max_width);

    # compute the bounds
    var text_bb = me._text.update().getBoundingBox();
    var width = text_bb[2];
    var height = text_bb[3];

    if( me._measureBB != nil )
    {
      width = math.max(width, me._measureBB[2]);
      height = math.max(height, me._measureBB[3]);
    }

    if( width > max_width )
      width = max_width;

    me._width = width + 2 * me._slice;
    me._height = height + 2 * me._slice;
    me._frame.setSize(me._width, me._height)
             .update();
  },

  _remapValue: func(val)
  {
    if (me._mapping == "") return val;
    if (me._mapping == "percent") return int(val * 100);
    # TODO - translate me!
    if (me._mapping == "on-off") return (val == 1) ? "ON" : "OFF";
    if (me._mapping == "arm-disarm") return (val == 1) ? "ARMED" : "DISARMED";
    # provide both 'senses' of the flag here
    if (me._mapping == "up-down") return (val == 1) ? "UP" : "DOWN";
    if (me._mapping == "down-up") return (val == 1) ? "DOWN" : "UP";
    if (me._mapping == "heading") return geo.normdeg(val);

    return val;
  },

  setMapping: func(mapping)
  {
    me._mapping = mapping;
    me._updateText();
  },

  setTooltipId: func(tipId)
  {
    me._tipId = tipId;
  },

  getTooltipId: func { me._tipId; },

  # Get the displayed canvas
  getCanvas: func()
  {
    return me['_canvas'];
  },

  setPosition: func(x, y)
  {
    me.setInt("x", x + 10);
    me.setInt("y", y + 10);
  },

  show: func()
  {
    # don't show if undefined
    if (me._tipId == nil) return;
    me.setBool("visible", 1);
  },

  hide: func()
  {
    me.setBool("visible", 0);
  },

  isVisible: func
  {
    return me.getBool("visible");
  },

  fadeIn: func()
  {
    me.show();
  },

  fadeOut: func()
  {
    me.hide();
  }

# private:

};

var tooltip = canvas.Tooltip.new([300, 100]);
    tooltip.createCanvas();

var setTooltip = func(node)
{
  var tipId = cmdarg().getNode('tooltip-id').getValue();
  if (tooltip.getTooltipId() == tipId) {
    return; # nothing more to do
  }

  var x = cmdarg().getNode('x').getValue();
  var y = cmdarg().getNode('y').getValue();

   var screenHeight = getprop('/sim/startup/ysize');
   tooltip.setPosition(x, screenHeight - y);
   tooltip.setTooltipId(tipId);

   tooltip.setLabel(cmdarg().getNode('label').getValue());
   var measure = cmdarg().getNode('measure-text');
   if (measure != nil) {
       tooltip.setWidthText(measure.getValue());
   } else {
       tooltip.setWidthText(nil);
   }

   var nodePath = cmdarg().getNode('property');
   if (nodePath != nil) {
     var n = props.globals.getNode(nodePath.getValue());
     tooltip.setProperty(n);

     # mapping modes allow some standard conversion of the property
     # value to a human readable form.
     var mapping = cmdarg().getNode('mapping');
     tooltip.setMapping(mapping == nil ? "" : mapping.getValue());
   } else {
     tooltip.setProperty(nil);
     tooltip.setMapping(nil);
  }

  # don't actually show here, we do that response to tooltip-timeout
  # so this is just getting ready
}

var showTooltip = func(node)
{
  var r = node.getNode("reason");
  if ((r != nil) and (r.getValue() == "click")) {
    # click triggering tooltip, show immediately
    tooltip.show();
  } else {
    tooltip.fadeIn();
  }
}

var updateHover = func(node)
{
  tooltip.setTooltipId(nil);

  # if not shown, nothing to do here
  if (!tooltip.isVisible()) return;

  # reset cursor to standard
  tooltip.fadeOut();

}

addcommand("update-hover", updateHover);
addcommand("set-tooltip", setTooltip);
addcommand("tooltip-timeout", showTooltip);
