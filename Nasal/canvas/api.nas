# Helper function to create a node with the first available index for the given
# path relative to the given node
#
var _createNodeWithIndex = func(node, path)
{
  # TODO do we need an upper limit? (50000 seems already seems unreachable)
  for(var i = 0; i < 50000; i += 1)
  {
    var p = path ~ "[" ~ i ~ "]";
    if( node.getNode(p) == nil )
      return node.getNode(p, 1);
  }
  
  debug.warn("Unable to get child (already 50000 exist)");

  return nil;
};

# Internal helper
var _createColorNodes = func(parent, name)
{
  var node = parent.getNode(name, 1);
  return [ node.getNode("red", 1),
           node.getNode("green", 1),
           node.getNode("blue", 1),
           node.getNode("alpha", 1) ];
};

var _setColorNodes = func(nodes, color)
{
  if( typeof(nodes) != "vector" )
  {
    debug.warn("This element doesn't support setting color");
    return;
  }
  
  if( size(color) == 1 )
    color = color[0];

  if( typeof(color) != "vector" )
    return debug.warn("Wrong type for color");
  
  if( size(color) < 3 or size(color) > 4 )
    return debug.warn("Color needs 3 or 4 values (RGB or RGBA)");

  for(var i = 0; i < size(color); i += 1)
    nodes[i].setDoubleValue( color[i] );

  if( size(color) == 3 )
    # default alpha is 1
    nodes[3].setDoubleValue(1);
};

var _arg2valarray = func
{
  while (    typeof(arg) == "vector"
            and size(arg) == 1 and typeof(arg[0]) == "vector" )
      arg = arg[0];
  return arg;
}

# Transform
# ==============================================================================
# A transformation matrix which is used to transform an #Element on the canvas.
# The dimensions of the matrix are 3x3 where the last row is always 0 0 1:
#
#  a c e
#  b d f
#  0 0 1
#
# See http://www.w3.org/TR/SVG/coords.html#TransformMatrixDefined for details.
#
var Transform = {
  new: func(node, vals = nil)
  {
    var m = {
      parents: [Transform],
      _node: node,
      a: node.getNode("m[0]", 1),
      b: node.getNode("m[1]", 1),
      c: node.getNode("m[2]", 1),
      d: node.getNode("m[3]", 1),
      e: node.getNode("m[4]", 1),
      f: node.getNode("m[5]", 1)
    };
    
    var use_vals = typeof(vals) == 'vector' and size(vals) == 6;
    
    # initialize to identity matrix
    m.a.setDoubleValue(use_vals ? vals[0] : 1);
    m.b.setDoubleValue(use_vals ? vals[1] : 0);
    m.c.setDoubleValue(use_vals ? vals[2] : 0);
    m.d.setDoubleValue(use_vals ? vals[3] : 1);
    m.e.setDoubleValue(use_vals ? vals[4] : 0);
    m.f.setDoubleValue(use_vals ? vals[5] : 0);
    
    return m;
  },
  setTranslation: func
  {
    var trans = _arg2valarray(arg);

    me.e.setDoubleValue(trans[0]);
    me.f.setDoubleValue(trans[1]);
    
    return me;
  },
  setRotation: func(angle)
  {
    var s = math.sin(angle);
    var c = math.cos(angle);

    me.a.setValue(c);
    me.b.setValue(s);
    me.c.setValue(-s);
    me.d.setValue(c);
    
    return me;
  },
  # Set scale (either as parameters or array)
  #
  # If only one parameter is given its value is used for both x and y
  #  setScale(x, y)
  #  setScale([x, y])
  setScale: func
  {
    var scale = _arg2valarray(arg);

    me.a.setDoubleValue(scale[0]);
    me.d.setDoubleValue(size(scale) >= 2 ? scale[1] : scale[0]);
    
    return me;
  },
  getScale: func()
  {
    # TODO handle rotation
    return [me.a.getValue(), me.d.getValue()];
  }
};

# Element
# ==============================================================================
# Baseclass for all elements on a canvas
#
var Element = {
  # Constructor
  #
  # @param parent   Parent node (In the property tree)
  # @param type     Type string (Used as node name)
  # @param name     Name (Should be unique)
  new: func(parent, type, name)
  {
    var m = {
      parents: [Element],
      _node: _createNodeWithIndex(parent, type),
    };
    
    if( name != nil )
      m._node.getNode("name", 1).setValue(name);

    return m;
  },
  # Destructor (has to be called manually!)
  del: func()
  {
    me._node.remove();
  },
  # Trigger an update of the element
  # 
  # Elements are automatically updated once a frame, with a delay of one frame.
  # If you wan't to get an element updated in the current frame you have to use
  # this method.
  update: func()
  {
    me._node.getNode("update", 1).setValue(1);
  },
  #
  setGeoPosition: func(lat, lon)
  {
    me._getTf()._node.getNode("m-geo[4]", 1).setValue("N" ~ lat);
    me._getTf()._node.getNode("m-geo[5]", 1).setValue("E" ~ lon);
  },
  # Create a new transformation matrix
  #
  # @param vals Default values (Vector of 6 elements)
  createTransform: func(vals = nil)
  {
    var node = _createNodeWithIndex(me._node, "tf");
    return Transform.new(node, vals);
  },
  # Shortcut for setting translation
  setTranslation: func me._getTf().setTranslation(arg),
  # Shortcut for setting rotation
  setRotation: func(rot) me._getTf().setRotation(rot),
  # Shortcut for setting scale
  setScale: func me._getTf().setScale(arg),
  # Shortcut for getting scale
  getScale: func me._getTf().getScale(),
  # Set the line/text color
  #
  # @param color  Vector of 3 or 4 values in [0, 1]
  setColor: func _setColorNodes(me.color, arg),
  # Set the fill/background/boundingbox color
  #
  # @param color  Vector of 3 or 4 values in [0, 1]
  setColorFill: func _setColorNodes(me.color_fill, arg),
  # Internal Transform for convenience transform functions
  _getTf: func
  {
    if( me['_tf'] == nil )
      me['_tf'] = me.createTransform();
    return me._tf;
  },
};

# Group
# ==============================================================================
# Class for a group element on a canvas
#
var Group = {
  new: func(parent, name, type = "group")
  {
    return { parents: [Group, Element.new(parent, type, name)] };
  },
  # Create a child of given type with specified name.
  # type can be group, text
  createChild: func(type, name = nil)
  {
    var factory = me._element_factories[type];
    
    if( factory == nil )
    {
      debug.dump("canvas.Group.createChild(): unknown type (" ~ type ~ ")");
      return nil;
    }
    
    return factory(me._node, name);
  },
  # Remove all children
  removeAllChildren: func()
  {
    foreach(var type; keys(me._element_factories))
      me._node.removeChildren(type, 0);
  }
};

# Group
# ==============================================================================
# Class for a group element on a canvas
#
var Map = {
  new: func(parent, name)
  {
    return { parents: [Map, Group.new(parent, name, "map")] };
  }
  # TODO
};

# Text
# ==============================================================================
# Class for a text element on a canvas
#
var Text = {
  new: func(parent, name)
  {
    var m = {
      parents: [Text, Element.new(parent, "text", name)]
    };
    m.color = _createColorNodes(m._node, "color");
    m.color_fill = _createColorNodes(m._node, "color-fill");
    return m;
  },
  # Set the text
  setText: func(text)
  {
    # add space because osg seems to remove last character if its a space
    me._node.getNode("text", 1).setValue(typeof(text) == 'scalar' ? text ~ ' ' : "");
  },
  # Set alignment
  #
  #  @param algin String, one of:
  #   left-top
  #   left-center
  #   left-bottom
  #   center-top
  #   center-center
  #   center-bottom
  #   right-top
  #   right-center
  #   right-bottom
  #   left-baseline
  #   center-baseline
  #   right-baseline
  #   left-bottom-baseline
  #   center-bottom-baseline
  #   right-bottom-baseline
  #
  setAlignment: func(align)
  {
    me._node.getNode("alignment", 1).setValue(align);
  },
  # Set the font size
  setSize: func(size, aspect = 1)
  {
    me._node.getNode("character-size", 1).setDoubleValue(size);
    me._node.getNode("character-aspect-ratio", 1).setDoubleValue(aspect);
  },
  # Set font (by name of font file)
  setFont: func(name)
  {
    me._node.getNode("font", 1).setValue(name);
  },
  # Enumeration of values for drawing mode:
  TEXT:               1, # The text itself
  BOUNDINGBOX:        2, # A bounding box (only lines)
  FILLEDBOUNDINGBOX:  4, # A filled bounding box
  ALIGNMENT:          8, # Draw a marker (cross) at the position of the text
  # Set draw mode. Binary combination of the values above. Since I haven't found
  # a bitwise or we have to use a + instead.
  #
  #  eg. my_text.setDrawMode(Text.TEXT + Text.BOUNDINGBOX);
  setDrawMode: func(mode)
  {
    me._node.getNode("draw-mode", 1).setValue(mode);
  },
  # Set bounding box padding
  setPadding: func(pad)
  {
    me._node.getNode("padding", 1).setValue(pad);
  },
  #
  getBoundingBox: func()
  {
    var bb = me._node.getNode("bounding-box");
    return [ bb.getChild("min-x").getValue(),
              bb.getChild("min-y").getValue(),
              bb.getChild("max-x").getValue(),
              bb.getChild("max-y").getValue() ];
  }
};

# Path
# ==============================================================================
# Class for an (OpenVG) path element on a canvas
#
var Path = {
  # Path segment commands (VGPathCommand)
  VG_CLOSE_PATH:     0,
  VG_MOVE_TO:        2,
  VG_MOVE_TO_ABS:    2,
  VG_MOVE_TO_REL:    3,
  VG_LINE_TO:        4,
  VG_LINE_TO_ABS:    4,
  VG_LINE_TO_REL:    5,
  VG_HLINE_TO:       6,
  VG_HLINE_TO_ABS:   6,
  VG_HLINE_TO_REL:   7,
  VG_VLINE_TO:       8,
  VG_VLINE_TO_ABS:   8,
  VG_VLINE_TO_REL:   9,
  VG_QUAD_TO:       10,
  VG_QUAD_TO_ABS:   10,
  VG_QUAD_TO_REL:   11,
  VG_CUBIC_TO:      12,
  VG_CUBIC_TO_ABS:  12,
  VG_CUBIC_TO_REL:  13,
  VG_SQUAD_TO:      14,
  VG_SQUAD_TO_ABS:  14,
  VG_SQUAD_TO_REL:  15,
  VG_SCUBIC_TO:     16,
  VG_SCUBIC_TO_ABS: 16,
  VG_SCUBIC_TO_REL: 17,
  VG_SCCWARC_TO:    18,
  VG_SCCWARC_TO_ABS:18,
  VG_SCCWARC_TO_REL:19,
  VG_SCWARC_TO:     20,
  VG_SCWARC_TO_ABS: 20,
  VG_SCWARC_TO_REL: 21,
  VG_LCCWARC_TO:    22,
  VG_LCCWARC_TO_ABS:22,
  VG_LCCWARC_TO_REL:23,
  VG_LCWARC_TO:     24,
  VG_LCWARC_TO_ABS: 24,
  VG_LCWARC_TO_REL: 25,
  
  # Number of coordinates per command
  num_coords: {
    0:  0, # VG_CLOSE_PATH
    2:  2, # VG_MOVE_TO
    4:  2, # VG_LINE_TO
    6:  1, # VG_HLINE_TO
    8:  1, # VG_VLINE_TO
    10: 4, # VG_QUAD_TO
    12: 6, # VG_CUBIC_TO
    14: 2, # VG_SQUAD_TO
    16: 4, # VG_SCUBIC_TO
    18: 5, # VG_SCCWARC_TO
    20: 5, # VG_SCWARC_TO
    22: 5, # VG_LCCWARC_TO
    24: 5  # VG_LCWARC_TO
  },

  #
  new: func(parent, name)
  {
    var m = {
      parents: [Path, Element.new(parent, "path", name)]
    };
    m.color = _createColorNodes(m._node, "color");
    m.color_fill = _createColorNodes(m._node, "color-fill");
    return m;
  },
  # Set the path data (commands and coordinates)
  setData: func(cmds, coords)
  {
    me._node.removeChildren('cmd', 0);
    me._node.removeChildren('coord', 0);
    me._node.setValues({cmd: cmds, coord: coords});
  },
  setDataGeo: func(cmds, coords)
  {
    me._node.removeChildren('cmd', 0);
    me._node.removeChildren('coord', 0);
    me._node.removeChildren('coord-geo', 0);
    me._node.setValues({cmd: cmds, 'coord-geo': coords});
  },
  setStrokeLineWidth: func(width)
  {
    me._node.getNode('stroke-width', 1).setDoubleValue(width);
  },
  setStrokeDashPattern: func(pattern)
  {
    me._node.removeChildren('stroke-dasharray');

    if( typeof(pattern) == 'vector' )
      me._node.setValues({'stroke-dasharray': pattern});
    else
      debug.warn("setStrokeDashPattern: vector expected!");
  },
  setFill: func(fill)
  {
    me._node.getNode("fill", 1).setValue(fill);
  }
};

# Element factories used by #Group elements to create children
Group._element_factories = {
  "group": Group.new,
  "map": Map.new,
  "text": Text.new,
  "path": Path.new
};

# Canvas
# ==============================================================================
# Class for a canvas
#
var Canvas = {
  # Place this canvas somewhere onto the object. Pass criterions for placement
  # as a hash, eg:
  #
  #  my_canvas.addPlacement({
  #    "texture": "EICAS.png",
  #    "node": "PFD-Screen",
  #    "parent": "Some parent name"
  #  });
  # 
  # Note that we can choose whichever of the three filter criterions we use for
  # matching the target object for our placement. If none of the three fields is
  # given every texture of the model will be replaced.
  addPlacement: func(vals)
  {
    var placement = _createNodeWithIndex(me.texture, "placement");
    placement.setValues(vals);
    return placement;
  },
  # Create a new group with the given name
  #
  # @param name Option name for the group
  createGroup: func(name = nil)
  {
    return Group.new(me.texture, name);
  },
  # Set the background color
  #
  # @param color  Vector of 3 or 4 values in [0, 1]
  setColorBackground: func _setColorNodes(me.color, arg)
};

# Create a new canvas. Pass parameters as hash, eg:
#
#  var my_canvas = canvas.new({
#    "name": "PFD-Test",
#    "size": [512, 512],
#    "view": [768, 1024],
#    "mipmapping": 1
#  });
var new = func(vals)
{
  var m = { parents: [Canvas] };

  m.texture = _createNodeWithIndex
  (
    props.globals.getNode("canvas", 1),
    "texture"
  );
  m.color = _createColorNodes(m.texture, "color-background");
  m.texture.setValues(vals);

  return m;
};

# Get the first existing canvas with the given name
#
# @param name Name of the canvas
# @return #Canvas, if canvas with #name exists
#         nil, otherwise
var get = func(name)
{
  var node_canvas = nil;
  if( isa(name, props.Node) )
    node_canvas = name;
  else if( typeof(name) == 'scalar' )
  {
    var canvas_root = props.globals.getNode("canvas");
    if( canvas_root == nil )
      return nil;

    foreach(var c; canvas_root.getChildren("texture"))
    {
      if( c.getValue("name") == name )
        node_canvas = c;
    }
  }
  
  if( node_canvas == nil )
  {
    debug.warn("Canvas not found: " ~ name);
    return nil;
  }
  
  return {
    parents: [Canvas],
    texture: node_canvas,
    color: _createColorNodes(node_canvas, "color-background")
  };
};
