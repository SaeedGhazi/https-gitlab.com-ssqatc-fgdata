var Symbol = {
# Static/singleton:
	registry: {},
	add: func(type, class)
		me.registry[type] = class,
	get: func(type)
		if ((var class = me.registry[type]) == nil)
			die("unknown type '"~type~"'");
		else return class,
	# Calls corresonding symbol constructor
	# @param group #Canvas.Group to place this on.
	new: func(type, group, arg...) {
		var ret = call((var class = me.get(type)).new, [group]~arg, class);
		ret.element.set("symbol-type", type);
		return ret;
	},
# Non-static:
	df_controller: nil, # default controller
	# Update the drawing of this object (position and others).
	update: func()
		die("update() not implemented for this symbol type!"),
	draw: func(group, model, lod)
		die("draw() not implemented for this symbol type!"),
	del: func()
		die("del() not implemented for this symbol type!"),
}; # of Symbol

Symbol.Controller = {
# Static/singleton:
	registry: {},
	add: func(type, class)
		registry[type] = class,
	get: func(type)
		if ((var class = me.registry[type]) == nil)
			die("unknown type '"~type~"'");
		else return class,
	# Calls corresonding symbol constructor
	# @param model Model to place this on.
	new: func(type, model, arg...)
		return call((var class = me.get(type)).new, [model]~arg, class),
# Non-static:
	# Update anything related to a particular model. Returns whether the object needs updating:
	update: func(model) return 1,
	# Initialize a controller to an object (or initialize the controller itself):
	init: func(model) ,
	# Delete an object from this controller (or delete the controller itself):
	del: func(model) ,
	# Return whether this symbol/object is visible:
	isVisible: func(model) return 1,
	# Get the position of this symbol/object:
	getpos: func(model), # default provided below
}; # of Symbol.Controller

var getpos_fromghost = func(positioned_g)
	return [positioned_g.lat, positioned_g.lon];

# Generic getpos: get lat/lon from any object:
# (geo.Coord and positioned ghost currently)
Symbol.Controller.getpos = func(obj) {
	if (typeof(obj) == 'ghost')
		if (ghosttype(obj) == 'positioned' or ghosttype(obj) == 'Navaid')
			return getpos_fromghost(obj);
		else
			die("bad ghost of type '"~ghosttype(obj)~"'");
	if (typeof(obj) == 'hash')
		if (isa(obj, geo.Coord))
			return obj.latlon();
	die("no suitable getpos() found! Of type: "~typeof(obj));
};


var assert_m = func(hash, member)
	if (!contains(hash, member))
		die("required field not found: '"~member~"'");
var assert_ms = func(hash, members...)
	foreach (var m; members)
		if (m != nil) assert_m(hash, m);


var DotSym = {
	parents: [Symbol],
	element_id: nil,
# Static/singleton:
	makeinstance: func(name, hash) {
		assert_ms(hash,
			"element_type", # type of Canvas element
			#"element_id",  # optional Canvas id
			#"init",        # initialize routine
			"draw",         # init/update routine
			#getpos",       # get position from model in [x_units,y_units] (optional)
		);
		hash.parents = [DotSym];
		return Symbol.add(name, hash);
	},
	readinstance: func(file, name=nil) {
		#print(file);
		if (name == nil)
			var name = split("/", file)[-1];
		if (substr(name, size(name)-4) == ".draw")
			name = substr(name, 0, size(name)-5);
		var code = io.readfile(file);
		var code = call(compile, [code], var err=[]);
		if (size(err)) {
			if (substr(err[0], 0, 12) == "Parse error:") { # hack around Nasal feature
				var e = split(" at line ", err[0]);
				if (size(e) == 2)
					err[0] = string.join("", [e[0], "\n  at ", file, ", line ", e[1], "\n "]);
			}
			for (var i = 1; (var c = caller(i)) != nil; i += 1)
				err ~= subvec(c, 2, 2);
			debug.printerror(err);
			return;
		}
		call(code, nil, nil, var hash = { parents:[DotSym] });
		me.makeinstance(name, hash);
	},
# For the instances returned from makeinstance:
	# @param group The Canvas group to add this to.
	# @param model A correct object (e.g. positioned ghost) as
	#              expected by the .draw file that represents
	#              metadata like position, speed, etc.
	# @param controller Optional controller "glue". Each method
	#                   is called with the model as the only argument.
	new: func(group, model, controller=nil) {
		var m = {
			parents: [me],
			group: group,
			model: model,
			controller: controller == nil ? me.df_controller : controller,
			element: group.createChild(
				me.element_type, me.element_id
			),
		};
		if (m.controller != nil) {
			#print("Initializing controller");
			m.controller.init(model);
		}
		else die("default controller not found");

		m.init();
		return m;
	},
	del: func() {
		#print("DotSym.del()");
		me.deinit();
		if (me.controller != nil)
			me.controller.del(me.model);
		call(func me.model.del(), nil, var err=[]); # try...
		if (err[0] != "No such member: del") # ... and either catch or rethrow
			die(err[0]);
		me.element.del();
	},
# Default wrappers:
	init: func() me.draw(),
	deinit: func(),
	update: func() {
		if (me.controller != nil) {
			if (!me.controller.update(me.model)) return;
			elsif (!me.controller.isVisible(me.model)) {
				me.element.hide();
				return;
			}
		} else
		me.element.show();
		me.draw();
		var pos = me.controller.getpos(me.model);
		if (size(pos) == 2)
			pos~=[nil]; # fall through
		if (size(pos) == 3)
			var (lat,lon,rotation) = pos;
		else die("bad position: "~debug.dump(pos));
		me.element.setGeoPosition(lat,lon);
		if (rotation != nil)
			me.element.setRotation(rotation);
	},
}; # of DotSym

# A layer that manages a list of symbols (using delta positioned handling).
var SymbolLayer = {
# Static/singleton:
	registry: {},
	add: func(type, class)
		me.registry[type] = class,
	get: func(type)
		if ((var class = me.registry[type]) == nil)
			die("unknown type '"~type~"'");
		else return class,
# Non-static:
	df_controller: nil, # default controller
	df_priority: nil, # default priority for display sorting
	type: nil, # type of #Symbol to add (MANDATORY)
	id: nil, # id of the group #canvas.Element (OPTIONAL)
	# @param group A group to place this on.
	# @param controller A controller object (parents=[SymbolLayer.Controller])
	#                   or implementation (parents[0].parents=[SymbolLayer.Controller]).
	new: func(group, controller=nil) {
		var m = {
			parents: [me],
			group: group.createChild("group", me.id), # TODO: the id is not properly set, but would be useful for debugging purposes (VOR, FIXES, NDB etc)
			list: [],
		};
		# FIXME: hack to expose type of layer:
		if (caller(1)[1] == Map.addLayer) {
			var this_type = caller(1)[0].type_arg;
			if (this_type != nil)
				m.group.set("symbol-layer-type", this_type);
		}
		if (controller == nil)
			#controller = SymbolLayer.Controller.new(me.type, m);
			controller = me.df_controller;
		assert_m(controller, "parents");
		if (controller.parents[0] == SymbolLayer.Controller)
			controller = controller.new(m);
		assert_m(controller, "parents");
		assert_m(controller.parents[0], "parents");
		if (controller.parents[0].parents[0] != SymbolLayer.Controller)
			die("OOP error");
		m.controller = controller;
		m.searcher = geo.PositionedSearch.new(me.searchCmd, me.onAdded, me.onRemoved, m);
		m.update();
		return m;
	},
	update: func() {
		me.searcher.update();
		foreach (var e; me.list)
			e.update();
	},
	del: func() {
		#print("SymbolLayer.del()");
		me.controller.del();
		foreach (var e; me.list)
			e.del();
	},
	findsym: func(positioned_g, del=0) {
		forindex (var i; me.list) {
			var e = me.list[i];
			if (geo.PositionedSearch._equals(e.model, positioned_g)) {
				if (del) {
					# Remove this element from the list
					var prev = subvec(me.list, 0, i);
					var next = subvec(me.list, i+1);
					me.list = prev~next;
				}
				return e;
			}
		}
		return nil;
	},
	searchCmd: func() me.controller.searchCmd(),
	# Adds a symbol.
	onAdded: func(positioned_g)
		append(me.list, Symbol.new(me.type, me.group, positioned_g)),
	# Removes a symbol
	onRemoved: func(positioned_g)
		me.findsym(positioned_g, 1).del(),
}; # of SymbolLayer

# Class to manage controlling a #SymbolLayer.
# Currently handles:
#  * Searching for new symbols (positioned ghosts or other objects with unique id's).
#  * Updating the layer (e.g. on an update loop or on a property change).
SymbolLayer.Controller = {
# Static/singleton:
	registry: {},
	add: func(type, class)
		me.registry[type] = class,
	get: func(type)
		if ((var class = me.registry[type]) == nil)
			die("unknown type '"~type~"'");
		else return class,
	# Calls corresonding controller constructor
	# @param layer The #SymbolLayer this controller is responsible for.
	new: func(type, layer, arg...)
		return call((var class = me.get(type)).new, [layer]~arg, class),
# Non-static:
	run_update: func() {
		me.layer.update();
	},
	# @return List of positioned objects.
	searchCmd: func()
		die("searchCmd() not implemented for this SymbolLayer.Controller type!"),
}; # of SymbolLayer.Controller

settimer(func {
Map.Controller = {
# Static/singleton:
	registry: {},
	add: func(type, class)
		me.registry[type] = class,
	get: func(type)
		if ((var class = me.registry[type]) == nil)
			die("unknown type '"~type~"'");
		else return class,
	# Calls corresonding controller constructor
	# @param map The #SymbolMap this controller is responsible for.
	new: func(type, layer, arg...)
		return call((var class = me.get(type)).new, [map]~arg, class),
};

####### LOAD FILES #######
#print("loading files");
(func {
	var FG_ROOT = getprop("/sim/fg-root");
	var load = func(file, name) {
		#print(file);
		if (name == nil)
			var name = split("/", file)[-1];
		if (substr(name, size(name)-4) == ".draw")
			name = substr(name, 0, size(name)-5);
		#print("reading file");
		var code = io.readfile(file);
		#print("compiling file");
		# This segfaults for some reason:
		#var code = call(compile, [code], var err=[]);
		var code = call(func compile(code, file), [code], var err=[]);
		if (size(err)) {
			#print("handling error");
			if (substr(err[0], 0, 12) == "Parse error:") { # hack around Nasal feature
				var e = split(" at line ", err[0]);
				if (size(e) == 2)
					err[0] = string.join("", [e[0], "\n  at ", file, ", line ", e[1], "\n "]);
			}
			for (var i = 1; (var c = caller(i)) != nil; i += 1)
				err ~= subvec(c, 2, 2);
			debug.printerror(err);
			return;
		}
		#print("calling code");
		call(code, nil, nil, var hash = {});
		#debug.dump(keys(hash));
		return hash;
	};
	load(FG_ROOT~"/Nasal/canvas/map/VOR.lcontroller", "VOR");
	DotSym.readinstance(FG_ROOT~"/Nasal/canvas/map/VOR.symbol", "VOR");
	load(FG_ROOT~"/Nasal/canvas/map/VOR.scontroller", "VOR");
	load(FG_ROOT~"/Nasal/canvas/map/aircraftpos.controller", "VOR");
})();
#print("finished loading files");
####### TEST SYMBOL #######

if (0)
settimer(func {
	if (caller(0)[0] != globals.canvas)
		return call(caller(0)[1], arg, nil, globals.canvas);

	print("Running MapStructure test code");
	var TestCanvas = canvas.new({
		"name": "Map Test",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	var dlg = canvas.Window.new([400, 400], "dialog");
	dlg.setCanvas(TestCanvas);
	var TestMap = TestCanvas.createGroup().createChild("map"); # we should not directly use a canvas here, but instead a LayeredMap.new() 
	TestMap.addLayer(factory: SymbolLayer, type_arg: "VOR"); # the ID should be also exposed in the property tree for each group (layer), i.e. better debugging
	# Center the map's origin:
	TestMap.setTranslation(512,512); # FIXME: don't hardcode these values, but read in canvas texture dimensions, otherwise it will break once someone uses non 1024x1024 textures ...
	# Initialize a range (TODO: LayeredMap.Controller):
	TestMap.set("range", 100);
	# Little cursor of current position:
	TestMap.createChild("path").rect(-5,-5,10,10).setColorFill(1,1,1).setColor(0,1,0);
	# And make it move with our aircraft:
	TestMap.setController("Aircraft position"); # from aircraftpos.controller
	dlg.del = func() {
		TestMap.del();
		# call inherited 'del'
		delete(me, "del");
		me.del();
	};
}, 1);
}, 0); # end ugly module init timer hack

