###
# map.nas - 	provide a high level method to create typical maps in FlightGear (airports, navaids, fixes and waypoints) for both, the GUI and instruments
# 		implements the notion of a "layer" by using canvas groups and adding geo-referenced elements to a layer
#		layered maps are linked to boolean properties so that visibility can be easily toggled (GUI checkboxes or cockpit hotspots)
#		without having to redraw other layers
#
# GOALS:	have a single Nasal/Canvas wrapper for all sort of maps in FlightGear, that can be easily shared and reused for different purposes
#
# DESIGN:	... is slowly evolving, but still very much beta for the time being
#
# API:		not yet documented, but see eventually design.txt (will need to add doxygen-strings then)
#
# PERFORMANCE:	will be improved, probabaly by moving some features to C++ space and optimizing things there
#
#
# ISSUES:	just look for the FIXME and TODO strings - currently, the priority is to create an OOP/MVC design with less specialized code in XML files
#
#
# ROADMAP:	Generalize this further, so that:
#
#			- it can be easily reused
#			- use a MVC approach, where layer-specific data is provided by a Model object
#			- other dialogs can use this without tons of custom code (airports.xml, route-manager.xml, map-canvas.xml)
#			- generalize this further so that it can be used by instruments
#			- implement additional layers (tcas, wxradar, agradar) - especially expose the required data to Nasal
#			- implement better GUI support (events) so that zooming/panning via mouse can be supported
#			- make the whole thing styleable 
#
#			- keep track of things getting added here and decide if they should better move to the core canvas module or the C++ code
#
#
# C++ RFEs:
#		- overload findNavaidsWithinRange() to support an optional position argument, so that arbitrary navaids can be looked up
#		- add Nasal extension function to get scenery vector data (landclass)
#		-
#		- 
#


#FIXME: this is a hack so that dialogs can register their own
# callbacks that are automatically invoked at the end of the
# generic-canvas-map.xml file (canvas/nasal section)
var callbacks = [];
var register_callback = func(c) append(callbacks, c);
var run_callbacks = func foreach(var c; callbacks) c();

var DEBUG=0;
if (DEBUG) {
	var benchmark = debug.benchmark;
	
	}

else	{
	var benchmark = func(label, code) code(); # NOP
	}

var assert = func(label, expr) expr and die(label);

# Mapping from surface codes to #TODO: make this XML-configurable 
var SURFACECOLORS = {
  1 : { type: "asphalt",  r:0.2,  g:0.2, b:0.2 },
  2 : { type: "concrete", r:0.3,  g:0.3, b:0.3 },
  3 : { type: "turf",     r:0.2,  g:0.5, b:0.2 },
  4 : { type: "dirt",     r:0.4,  g:0.3, b:0.3 },
  5 : { type: "gravel",   r:0.35, g:0.3, b:0.3 },
#  Helipads  
  6 : { type: "asphalt",  r:0.2,  g:0.2, b:0.2 },
  7 : { type: "concrete", r:0.3,  g:0.3, b:0.3 },
  8 : { type: "turf",     r:0.2,  g:0.5, b:0.2 },
  9 : { type: "dirt",     r:0.4,  g:0.3, b:0.3 },
  0 : { type: "gravel",   r:0.35, g:0.3, b:0.3 },
};


###
# ALL LayeredMap "draws" go through this wrapper, which makes it easy to check what's going on:
var draw_layer = func(layer, callback, lod) {
	var name= layer._view.get("id");
	# print("Canvas:Draw op triggered"); # just to make sure that we are not adding unnecessary data when checking/unchecking a checkbox
	if (DEBUG and name=="taxiways") fgcommand("profiler-start"); #without my patch, this is a no op, so no need to disable
	#print("Work items:", size(layer._model._elements));
	benchmark("Drawing Layer:"~layer._view.get("id"), func 
	foreach(var element; layer._model._elements) {
		#print(typeof(layer._view));
		#debug.dump(layer._view);
		callback(layer._view, element, lod); # ISSUE here
	});
	if (! layer._model.hasData() ) print("Layer was EMPTY:", name);
	if (DEBUG and name=="taxiways") fgcommand("profiler-stop");
	layer._drawn=1; #TODO: this should be encapsulated 
}

# Runway
#
var Runway = {
  # Create Runway from hash
  #
  # @param rwy  Hash containing runway data as returned from
  #             airportinfo().runways[ <runway designator> ]
  new: func(rwy)
  {
    return {
      parents: [Runway],
      rwy: rwy
    };
  },
  # Get a point on the runway with the given offset
  #
  # @param pos  Position along the center line
  # @param off  Offset perpendicular to the center line
  pointOffCenterline: func(pos, off = 0)
  {
    var coord = geo.Coord.new();
    coord.set_latlon(me.rwy.lat, me.rwy.lon);
    coord.apply_course_distance(me.rwy.heading, pos - 0.5 * me.rwy.length);

    if( off )
      coord.apply_course_distance(me.rwy.heading + 90, off);

    return ["N" ~ coord.lat(), "E" ~ coord.lon()];
  }
};

var make = func return {parents:arg};

##
# TODO: Create a cache to reuse layers and layer data (i.e. runways)


##
# Todo: wrap parsesvg and return a function that memoizes the created canvas group, so that svg files only need to be parsed once
#

##
# TODO: Implement a real MVC design for "LayeredMaps" that have:
# 	- a "DataProvider" (i.e. Positioned objects)
#	- a View (i.e. a Canvas)
#	- a controller (i.e. input/output properties)
#
var MapModel = {}; # navaids, waypoints, fixes etc
 MapModel.new = func make(MapModel);

var MapView = {};  # the canvas view, including a layer for each feature
 MapView.new = func make(MapView);

var MapController = {}; # the property tree interface to manipulate the model/view via properties
 MapController.new = func make(MapController);

var LazyView = {}; # Gets drawables on demand from the model - via property toggle

var DataProvider = {};
 DataProvider.new = func make(DataProvider);

###
# for airports, navaids, fixes, waypoints etc
var PositionedProvider = {};
 PositionedProvider.new = func make(DataProvider, PositionedProvider);

##
# Drawable
#

## LayerElement (UNUSED ATM):
# for runways, navaids, fixes, waypoints etc
# TODO: we should differentiate between "fairly static" vs. "dynamic" layers - i.e. navaids vs. traffic
var LayerElement = {_drawable:nil};
 LayerElement.new = func(drawable) {
	var temp = make(LayerElement);
	temp._drawable=drawable;
	return temp;
}
 # a drawable is either a Nasal callback or a scalar, i.e. a path to an SVG file
 LayerElement.draw = func(group) {
	(typeof(me._drawable)=='func') and drawable(group) or canvas.parsesvg(group,_drawable); 
 }

# For static targets like Navaids, Fixes - i.e. geographic position doesn't change
var StaticLayerElement = {}; 

# For moving targets such as aircraft, multiplayer, ai traffic etc
var DynamicLayerElement = {};

var AnimatedLayerElement = {};

# for elements whose appearance may change depending on selected range (i.e. LOD)
var RangeAwareLayerElement = {};


##
# A layer model is just a wrapper for a vector with elements
# either updated via a timer or via a listener

var LayerModel = {_elements:[], _view:, _controller: };
 LayerModel.new = func make(LayerModel);
 LayerModel.clear = func me._elements = [];
 LayerModel.push = func (e) append(me._elements, e);
 LayerModel.get = func me._elements;
 LayerModel.update = func;
 LayerModel.hasData = func size(me. _elements);
 LayerModel.setView = func(v) me._view=v;
 LayerModel.setController = func(c) me._controller=c;


var LayerController = {};
 LayerController.new = func make(LayerController);

##
# use timers to update the model/view (canvas)
var TimeBasedLayerController = {};
 LayerController.new = func make(TimeBasedLayerController);

##
# use listeners to update the model/view (canvas)
#
var ListenerBasedLayerController = {};
 ListenerBasedLayerController.new = func make(ListenerBasedLayerController);


##
# Uses, both, listeners and timers to update the model/view (canvas)
#

var HybridLayerController = {};
 HybridLayerController.new = func make(HybridLayerController);

var ModelEvents = {INIT:, RESET:, UPDATE:};
var ViewEvents = {INIT:, RESET:, UPDATE:};
var ControllerEvents = {INIT:, RESET: , UPDATE:, ZOOM:, PAN:, };


##
# A layer is mapped to a canvas group
# Layers are linked to a single boolean property to toggle them on/off
var Layer = { 				_model: , 
					_view:  ,
					_controller: ,
					_drawn:0,
		};

 Layer.new = func(group, name, model) {
	#print("Setting up new Layer:", name);
	var m 	= 	make(Layer);
	m._model = model.new();
	#print("Model name is:", m._model.name);
 	m._view	=	group.createChild("group",name);
	m.name = name; #FIXME: not needed, there's already _view.get("id")
	return m;
}

 Layer.hide = func me._view.setVisible(0);
 Layer.show = func me._view.setVisible(1);
 #TODO: Unify toggle and update methods - and support lazy drawing (make it optional!)
 Layer.toggle = func { 
	# print("Toggling layer");
	var checkbox = getprop(me.display_layer);
	if(checkbox and !me._drawn) { 
		# print("Lazy drawing");
		me.draw();
	}
	
	#var state= me._view.getBool("visible");
	#print("Toggle layer visibility ",me.display_layer," checkbox is", checkbox);
	#print("Layer id is:", me._view.get("id"));
	#print("Drawn is:", me._drawn);
	checkbox?me._view.setVisible(1) : me._view.setVisible(0);
	}
 Layer.reset = func {
  me._view.removeAllChildren(); # clear the "real" canvas drawables
  me._model.clear(); # the vector is used for lazy rendering
  assert("Model not emptied during layer reset!", me._model.hasData() );
  me._drawn = 0;
 }
 #TODO: Unify toggle and update
 Layer.update = func {
  # print("Layer update: Check if layer is visible, if so, draw");
  if (! getprop(me.display_layer)) return; # checkbox for layer not set
  if (!me._model.hasData() ) return; # no data available
  # print("Trying to draw");
  me.draw();
}

Layer.setDraw = func(callback) me.draw = callback; 
Layer.setController = func(c) me._controller=c; # TODO: implement
Layer.setModel = func(m) nil; # TODO: implement


##TODO: differentiate between layers with a single object (i.e. aircraft) and multiple objects (airports)

##
# We may need to display some stuff that isn't strictly a geopgraphic feature, but just a chart feature
#
var CartographicLayer = {};

#TODO:
var InteractiveLayer = {};

###
# PositionedLayer
#
# layer of positioned objects (i.e. have lat,lon,alt)
#
var PositionedLayer = {};
 PositionedLayer.new = func() {
	make( Layer.new() , PositionedLayer );
 }


###
# CachedLayer
#
# when re-centering on an airport already loaded, we don't want to reload it
# but change the reference point and load missing airports

var CachedLayer = {};

##
#
var AirportProvider = {};
 AirportProvider.new = func make(AirportProvider);
 AirportProvider.get = func {
  return airportinfo("ksfo");
}

### Data Providers (preparation for MVC version):
# TODO: should use the LayerModel class
#

##
# Manage a bunch of layers
#

var LayerManager = {};

# WXR ?

# TODO: Stub
var MapBehavior = {};
 MapBehavior.new = make(MapBehavior);
 MapBehavior.zoom = func;
 MapBehavior.center = func;

##
# A layered map consists of several layers
# TODO: Support nested LayeredMaps, where a LayeredMap may contain other LayeredMaps
# TODO: use MapBehavior here and move the zoom/refpos methods there, so that map behavior can be easily customized 
var LayeredMap = { 	ranges:[], 
			zoom_property:nil, listeners:[], 
			update_property:nil, layers:[],		
		};
 LayeredMap.new = func(parent, name) 
			return make(LayeredMap, parent.createChild("map",name) );

 LayeredMap.listen = func(p,c) { #FIXME: listening should be managed by each m/v/c separately
	# print("Setting up LayeredMap-managed listener:", p);
	append(me.listeners, setlistener(p, c));
	}

 LayeredMap.initializeLayers = func {
	# print("initializing all layers and updating");
	foreach(var l; me.layers)
		l.update();
 }

 LayeredMap.setRefPos = func(lat, lon) {
  # print("RefPos set");
  me._node.getNode("ref-lat", 1).setDoubleValue(lat);
  me._node.getNode("ref-lon", 1).setDoubleValue(lon);
  me; # chainable
 }
 LayeredMap.setHdg = func(hdg) { 
	me._node.getNode("hdg",1).setDoubleValue(hdg); 
	me; # chainable
	}

 LayeredMap.updateZoom = func {
	var z = me.zoom_property.getValue() or 0;
	z = math.max(0, math.min(z, size(me.ranges) - 1));
	me.zoom_property.setIntValue(z);
        var zoom = me.ranges[size(me.ranges) - 1 - z];
	# print("Setting zoom range to:", zoom);
	benchmark("Zooming map:"~zoom, func
	{
		me._node.getNode("range", 1).setDoubleValue(zoom);
		# TODO update center/limit translation to keep airport always visible
	});
	me; #chainable
 }

 # this is a huge hack at the moment, we need to encapsulate the setRefPos/setHdg methods, so that they are exposed to XML space
 #
LayeredMap.updateState = func {
 # center map on airport TODO: should be moved to a method and wrapped with a controller so that behavior can be customizeda
 #var apt = me.layers[0]._model._elements[0];
 # FIXME:
 #me.setRefPos(lat:me._refpos.lat, lon:me._refpos.lon);
 
 me.setHdg(0.0);
 me.updateZoom();
}

#
# TODO: this is currently GUI specific and not re-usable for instruments 
 LayeredMap.setupZoom = func(dialog) {
   	var dlgroot =  dialog.getNode("features/dialog-root").getValue();#FIXME: GUI specific - needs to be re-implemented for instruments
	me.zoom_property = props.globals.getNode(dlgroot ~"/"~dialog.getNode("features/range-property").getValue(), 1); #FIXME: this doesn't belong here, need to be in ctor instead !!!
	ranges=dialog.getNode("features/ranges").getChildren("range");
	if( size(me.ranges) == 0 )
		# TODO check why this gets called everytime the dialog is opened
		foreach(var r; ranges)
			append(me.ranges, r.getValue() );

	# print("Setting up Zoom Ranges:", size(ranges)-1);
	me.listen(me.zoom_property, func me.updateZoom() );
	me.updateZoom();
	me; #chainable
	}
 LayeredMap.setZoom = func {} #TODO

 LayeredMap.resetLayers = func {

 benchmark("Resetting LayeredMap", func
            foreach(var l; me.layers) { #TODO: hide all layers, hide map
                l.reset();
                }
                );


}

 #FIXME: listener management should be done at the MVC level, for each component - not as part of the LayeredMap!
 LayeredMap.cleanup_listeners = func {
  # print("Cleaning up listeners");
  foreach(var l; me.listeners) 
	removelistener(l);
	# TODO check why me.listeners = []; doesn't work. Maybe this is a Nasal bug
	#      and the old vector is somehow used again.
  setsize(me.listeners, 0);
 }

###
# GenericMap: A generic map is a layered map that puts all supported features on a different layer (canvas group) so that 
# they can be individually toggled on/off so that unnecessary updates are avoided, there are methods to link layers to boolean properties
# so that they can be easily associated with GUI properties (checkboxes) or cockpit hotspots
# TODO: generalize the XML-parametrization and move it to a helper class

var GenericMap = { };
 GenericMap.new = func(parent, name) make(LayeredMap.new(parent:parent, name:name), GenericMap);

 GenericMap.setupLayer = func(layer, property) {
  var l = MAP_LAYERS[layer].new(me, layer); # Layer.new(me, layer);
  l.display_layer = property; #FIXME: use controller object instead here and this overlaps with update_property
  #print("Set up layer with toggle property=", property);
  l._view.setVisible( getprop(property) ) ;
  append(me.layers, l);
  return l;
 }

 # features are layers - so this will do layer setup and then register listeners for each layer
 GenericMap.setupFeature = func(layer, property, init ) {
		var l=me.setupLayer( layer, property ); 
		me.listen(property, func l.toggle() );  #TODO: should use the controller object here !

		l._model._update_property=property; #TODO: move somewhere else - this is the property that is mapped to the CHECKBOX
		l._model._view_handle = l; #FIXME: very crude, set a handle to the view(group), so that the model can notify it (for updates)
		l._model._map_handle = me; #FIXME: added here so that layers can send update requests to the parent map
		#print("Setting up layer init for property:", init);

		l._model._input_property = init; # FIXME: init property = input property - needs to be improved!
		me.listen(init, func l._model.init() ); #TODO: makes sure that the layer's init method for the MODEL is invoked 
		me; #chainable
};

 # This will read in the config and procedurally instantiate all requested layers and link them to toggle properties
 # FIXME: this is currently GUI specific and doesn't yet support instrument use, i.e. needs to be generalized further
 GenericMap.pickupFeatures = func(DIALOG_CANVAS) {
 var dlgroot = DIALOG_CANVAS.getNode("features/dialog-root").getValue();
 # print("Picking up features for:", DIALOG_CANVAS.getPath() );
 var layers=DIALOG_CANVAS.getNode("features").getChildren("layer");
 foreach(var n; layers) {
   var name = n.getNode("name").getValue();
   var toggle = n.getNode("property").getValue();
   var init = n.getNode("init-property").getValue();
   init = dlgroot ~"/"~init;
   var property = dlgroot ~"/"~toggle;
   # print("Adding layer:",n.getNode("name").getValue() );
   me.setupFeature(name, property, init);
 }
 me;
}

 # NOT a method, cmdarg() is no longer meaningful when the canvas nasal block is executed
 # so this needs to be called in the dialog's OPEN block instead - TODO: generalize
 #FIXME: move somewhere else, this is a GUI helper  and should probably be generalized and moved to gui.nas
GenericMap.setupGUI = func (dialog, group) {
   var group = gui.findElementByName(cmdarg() , group);

   var layers=dialog.getNode("features").getChildren("layer");
   var template = dialog.getNode("checkbox-toggle-template");
   var dlgroot =  dialog.getNode("features/dialog-root").getValue(); 
   var zoom = dlgroot ~"/"~ dialog.getNode("features/range-property").getValue();
   var i=0;
   foreach(var n; layers) {
     var name = n.getNode("name").getValue();
     var toggle = dlgroot ~ "/" ~ n.getNode("property").getValue();
     var label  = n.getNode("description",1).getValue() or name;

     var default = n.getNode("default",1).getValue();
     default = (default=="enabled")?1:0;
     #print("Layer default for", name ," is:", default);
     setprop(toggle, default); # set the checkbox to its default setting

     var hide_checkbox = n.getNode("hide-checkbox",1).getValue();
     hide_checkbox = (hide_checkbox=="true")?1:0;

     var checkbox = group.getChild("checkbox",i, 1); #FIXME: compute proper offset dynamically, will currently overwrite other existing checkboxes!

     props.copy(template, checkbox);
     checkbox.getNode("name").setValue("display-"~name);
     checkbox.getNode("label").setValue(label);
     checkbox.getNode("property").setValue(toggle);
     checkbox.getNode("binding/object-name").setValue("display-"~name);
     checkbox.getNode("enabled",1).setValue(!hide_checkbox);
     i+=1;
 }

 	#add zoom buttons procedurally:
        var template = dialog.getNode("zoom-template");
	template.getNode("button[0]/binding[0]/property[0]").setValue(zoom);
	template.getNode("text[0]/property[0]").setValue(zoom);
	template.getNode("button[1]/binding[0]/property[0]").setValue(zoom);
	template.getNode("button[1]/binding[0]/max[0]").setValue( i ); 
	props.copy(template, group);
 }

###
# TODO: StylableGenericMap (colors, fonts, symbols)
#

var AirportMap = {};
 AirportMap.new = func(parent,name) make(GenericMap.new(parent,name), AirportMap);
 #TODO: Use real MVC (DataProvider/PositionedProvider) here


# this is currently "directly" invoked via a listener, needs to be changed
# to use the controller object instead
# TODO: adopt real MVC here
# FIXME: this must currently be explicitly called by the model, we need to use a wrapper to call it automatically instead!
LayerModel.notifyView  = func () {
 # print("View notified");
 me._view_handle.update(); # update the layer/group
 me._map_handle.updateState(); # update the map
}

# ID
var SingleAirportProvider = {};

# inputs: position, range
var MultiAirportProvider = {};

#TODO: remove and unify with update() 
AirportMap.init = func {
        me.resetLayers();
	me.updateState();
}

# MultiObjectLayer:
#	- Airports
#	- Traffic (MP/AI)
#	- Navaids
# 	

# TODO: a "MapLayer" is a full MVC implementation that is owned by a "LayeredMap"

var MAP_LAYERS = {};
var register_layer = func(name, layer) MAP_LAYERS[name]=layer;

var MVC_FOLDER = getprop("/sim/fg-root") ~ "/Nasal/canvas/map/";
var load_modules = func(vec) foreach(var file; vec) io.load_nasal(MVC_FOLDER~file, "canvas");

# TODO: read in the file names dynamically: *.draw, *.model, *.layer

var DRAWABLES = ["navaid.draw",  "parking.draw",  "runways.draw",  "taxiways.draw",  "tower.draw"];
load_modules(DRAWABLES);

var MODELS = ["airports.model", "navaids.model",];
load_modules(MODELS);

var LAYERS = ["runways.layer", "taxiways.layer", "parking.layer", "tower.layer", "navaids.layer","test.layer",];
load_modules(LAYERS);

#TODO: Implement!
var CONTROLLERS = [];
load_modules(CONTROLLERS);
