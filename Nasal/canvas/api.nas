#
# FlightGear canvas API
# Namespace:    canvas
#
# Classes included:
#   Transform
#   Element
#   Group
#   Map
#   Text
#   Path
#   Image
#   Canvas
#
# see also gui.nas
var include_path = "Nasal/canvas/api/";

# log level for debug output
var _API_dbg_level = DEV_WARN;

io.include(include_path~"colors.nas");
io.include(include_path~"helpers.nas");
io.include(include_path~"transform.nas");
io.include(include_path~"element.nas");
io.include(include_path~"group.nas");
io.include(include_path~"map.nas");
io.include(include_path~"text.nas");
io.include(include_path~"path.nas");
io.include(include_path~"image.nas");
io.include(include_path~"svgcanvas.nas");

# Element factories used by #Group elements to create children
Group._element_factories = {
  "group": Group.new,
  "map": Map.new,
  "text": Text.new,
  "path": Path.new,
  "image": Image.new
};

io.include(include_path~"canvas.nas");

# @param g Canvas ghost
var wrapCanvas = func(g) {
    if (g != nil and g._impl == nil) {
        g._impl = Canvas._new(g);
    }
    return g;
}

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
  var m = wrapCanvas(_newCanvasGhost());
  m._node.setValues(vals);
  return m;
};

# Get the first existing canvas with the given name
#
# @param name Name of the canvas
# @return #Canvas, if canvas with #name exists
#         nil, otherwise
var get = func(arg)
{
  if( isa(arg, props.Node) )
    var node = arg;
  else if (ishash(arg))
    var node = props.Node.new(arg);
  else {
    die("canvas.get: Invalid argument.");
  }

  return wrapCanvas(_getCanvasGhost(node._g));
};

# subclass of Group representing the desktop
var Desktop = {
    _CLASS: "canvas.Desktop",

    new: func(ghost) {
        var obj = {
            parents: [Desktop, Group.new(ghost)],
            _sizeChangedCallbacks: [],
            _xsizeNode: nil,
            _ysizeNode: nil
        };

        obj._xsizeNode = props.globals.getNode("/sim/startup/xsize", 1);
        obj._ysizeNode = props.globals.getNode("/sim/startup/ysize", 1);

        setlistener(obj._xsizeNode, func { obj._callSizeChangedCallbacks(); }, 1);
        setlistener(obj._ysizeNode, func { obj._callSizeChangedCallbacks(); }, 1);
        return obj;
    },

    addResizedCallback: func(cb)
    {
      if (!isfunc(cb)) {
            die("Cannot add callback for main window size changes: callback is not callable !");
      }

      append(me._sizeChangedCallbacks, cb);
      cb(me._xsizeNode.getValue(), me._ysizeNode.getValue());
    },

    removeResizedCallback: func(cb)
    {
      remove(me._sizeChangedCallbacks, cb);
    },

    # @private
    # @description Helper function that calls all callbacks in @m _sizeChangedCallbacks in the order they were added.
    _callSizeChangedCallbacks: func {
        var newXSize = me._xsizeNode.getValue();
        var newYSize = me._ysizeNode.getValue();
        foreach (var cb; me._sizeChangedCallbacks) {
            cb(newXSize, newYSize);
        }
    }
};

var getDesktop = func()
{
  return Desktop.new(_getDesktopGhost());
};


## /canvas/by-name 
# store nodes we create in /canvas/by-name for easy removal
var _canvasByName = {};
var _canvasCreateDeleteListener = setlistener("/canvas/by-index", func(changed, listened_to, op, is_child) {
  # trigger if a texture/name
  if (changed.getName() == "name") {
    var t = changed.getParent();
    if (t.getName() != "texture")
      return;
    #debug.dump(t, changed);

    var path = t.getPath();
    var index = t.getIndex();

    # texture/name created but appears to be empty on create so we monitor it
    var _listener = setlistener(changed, func(c,l,o) {
      removelistener(_listener);
      debug.dump(c);
      var name = c.getValue();
      if (!name) return;
      # child add
      if (op == 1) {
        var n = props.getNode("/canvas/by-name", 1).addChild(name);
        n.alias(path);
        #n.setValue(path);
        _canvasByName[index] = n;
      }
    }, 0, 1);

  }
  elsif (changed.getName() == "texture") {
    # child remove
    if (op == -1) {
      var index = changed.getIndex();
      debug.dump("remove", changed, index);
      if (_canvasByName[index])
        _canvasByName[index].remove();
    }
  }
  #else {debug.dump(".");} # show how often this listener is fired.
}, 1, 2); # _canvasCreateDeleteListener

var unload = func
{
  unloadTooltips();
  unloadErrorNotification();
  unloadGUI();
  removelistener(_canvasCreateDeleteListener);
  logprint(LOG_INFO, "Unloaded canvas Nasal module");
};
