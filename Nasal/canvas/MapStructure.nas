var _MP_dbg_lvl = "info";

var dump_obj = func(m) {
	var h = {};
	foreach (var k; keys(m))
		if (k != "parents")
			h[k] = m[k];
	debug.dump(h);
};

##
# must be either of:
# 1) draw* callback, 2) SVG filename, 3) Drawable class (with styling/LOD support)
var SymbolDrawable = {
	new: func() {
	},
};

## wrapper for each element
## i.e. keeps the canvas and texture map coordinates
var CachedElement = {
	new: func(canvas_path, name, source, offset) {
		var m = {parents:[CachedElement] };
		m.canvas_src = canvas_path;
		m.name = name;
		m.source = source;
		m.offset = offset;
		return m;
	}, # new()
	render: func(group) {
		# create a raster image child in the render target/group
		return
		group.createChild("image", me.name)
			.setFile( me.canvas_src )
			# TODO: fix .setSourceRect() to accept a single vector for coordinates ...
			.setSourceRect(left:me.source[0],top:me.source[1],right:me.source[2],bottom:me.source[3] , normalized:0)
			.setTranslation(me.offset); # FIXME: make sure this stays like this and isn't overridden
	}, # render()
}; # of CachedElement

var SymbolCache = {
	# We can draw symbols either with left/top, centered,
	# or right/bottom alignment. Specify two in a vector
	# to mix and match, e.g. left/centered would be
	#  [SymbolCache.DRAW_LEFT_TOP,SymbolCache.DRAW_CENTERED]
	DRAW_LEFT_TOP:     0.0,
	DRAW_CENTERED:     0.5,
	DRAW_RIGHT_BOTTOM: 1.0,
	new: func(dim...) {
		var m = { parents:[SymbolCache] };
		# to keep track of the next free caching spot (in px)
		m.next_free = [0, 0];
		# to store each type of symbol
		m.dict = {};
		if (size(dim) == 1 and typeof(dim[0]) == 'vector')
			dim = dim[0];
		# Two sizes: canvas and symbol
		if (size(dim) == 2) {
			var canvas_x = var canvas_y = dim[0];
			var image_x = var image_y = dim[1];
		# Two widths (canvas and symbol) and then height/width ratio
		} else if (size(dim) == 3) {
			var (canvas_x,image_x,ratio) = dim;
			var canvas_y = canvas_x * ratio;
			var image_y = image_x * ratio;
		# Explicit canvas and symbol widths/heights
		} else if (size(dim) == 4) {
			var (canvas_x,canvas_y,image_x,image_y) = dim;
		}
		m.canvas_sz = [canvas_x, canvas_y];
		m.image_sz = [image_x, image_y];

		# allocate a canvas
		m.canvas_texture = canvas.new( {
			"name": "SymbolCache"~canvas_x~'x'~canvas_y,
			"size": m.canvas_sz,
			"view": m.canvas_sz,
			"mipmapping": 1
		});

		# add a placement
		m.canvas_texture.addPlacement( {"type": "ref"} );

		return m;
	},
	add: func(name, callback, draw_mode=0) {
		if (typeof(draw_mode) == 'scalar')
			var draw_mode0 = var draw_mode1 = draw_mode;
		else var (draw_mode0,draw_mode1) = draw_mode;
		# get canvas texture that we use as cache
		# get next free spot in texture (column/row)
		# run the draw callback and render into a group
		var gr = me.canvas_texture.createGroup();
		gr.setTranslation( me.next_free[0] + me.image_sz[0]*draw_mode0,
				           me.next_free[1] + me.image_sz[1]*draw_mode1);
		#settimer(func debug.dump ( gr.getTransformedBounds() ), 0); # XXX: these are only updated when rendered
		#debug.dump ( gr.getTransformedBounds() );
		gr.update(); # apparently this doesn't result in sane output from .getTransformedBounds() either
		#debug.dump ( gr.getTransformedBounds() );
		# draw the symbol
		callback(gr);
		# get the bounding box, i.e. coordinates for texture map, or use the .setTranslation() params
		var coords = me.next_free~me.next_free;
		foreach (var i; [0,1])
			coords[i+2] += me.image_sz[i];
		# get the offset we used to position correctly in the bounds of the canvas
		var offset = [me.image_sz[0]*draw_mode0, me.image_sz[1]*draw_mode1];
		# store texture map coordinates in lookup map using the name as identifier
		me.dict[name] = CachedElement.new(me.canvas_texture.getPath(), name, coords, offset );
		# update next free position in cache (column/row)
		me.next_free[0] += me.image_sz[0];
		if (me.next_free[0] >= me.canvas_sz[0])
		{ me.next_free[0] = 0; me.next_free[1] += me.image_sz[1] }
		if (me.next_free[1] >= me.canvas_sz[1])
			die("SymbolCache: ran out of space after adding '"~name~"'");
	}, # add()
	get: func(name) {
		if(!contains(me.dict,name)) die("No SymbolCache entry for key:"~ name);
		return me.dict[name];
	}, # get()
};

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
		me.registry[type] = class,
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
	getpos: func(model) , # default provided below
}; # of Symbol.Controller

var getpos_fromghost = func(positioned_g)
	return [positioned_g.lat, positioned_g.lon];

# Generic getpos: get lat/lon from any object:
# (geo.Coord and positioned ghost currently)
Symbol.Controller.getpos = func(obj) {
	if (typeof(obj) == 'ghost')
		if (ghosttype(obj) == 'positioned' or ghosttype(obj) == 'Navaid' or ghosttype(obj)=='Fix' or ghosttype(obj)=='flightplan-leg')
			return getpos_fromghost(obj);
		else
			die("bad ghost of type '"~ghosttype(obj)~"'");
	if (typeof(obj) == 'hash')
		if (isa(obj, geo.Coord))
			return obj.latlon();
		if (isa(obj, props.Node))
			return [
				obj.getValue("position/latitude-deg")  or obj.getValue("latitude-deg"),
				obj.getValue("position/longitude-deg") or obj.getValue("longitude-deg")
			];
		if (contains(obj,'lat') and contains(obj,'lon'))
			return [obj.lat, obj.lon];

	debug.dump(obj);
	die("no suitable getpos() found! Of type: "~typeof(obj));
};

Symbol.Controller.equals = func(l, r) {
	if (l == r) return 1;
	var t = typeof(l);
	if (t == 'ghost')
		return 0;#l.id == r.id;
	if (t == 'hash')
		if (isa(l, props.Node))
			return l.equals(r);
		else {
			foreach (var k; keys(l))
				if (l[k] != r[k]) return 0;
			return 1;
		}
	die("bad types");
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
		if (!isa(hash, DotSym))
			die("OOP error");
		#assert_ms(hash,
		#	"element_type", # type of Canvas element
		#	#"element_id",  # optional Canvas id
		#	#"init",        # initialize routine
		#	"draw",         # init/update routine
		#	#getpos",       # get position from model in [x_units,y_units] (optional)
		#);
		return Symbol.add(name, hash);
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
			temp = m.controller.new(m.model,m);
			if (temp != nil)
				m.controller = temp;
			m.controller.init(model);
		}
		else die("default controller not found");

		m.init();
		return m;
	},
	del: func() {
		printlog(_MP_dbg_lvl, "DotSym.del()");
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
		m.searcher = geo.PositionedSearch.new(me.searchCmd, me.onAdded, me.onRemoved, m);
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
		m.update();
		return m;
	},
	update: func() {
		me.searcher.update();
		foreach (var e; me.list)
			e.update();
	},
	del: func() {
		printlog(_MP_dbg_lvl, "SymbolLayer.del()");
		me.controller.del();
		foreach (var e; me.list)
			e.del();
	},
	findsym: func(model, del=0) {
		forindex (var i; me.list) {
			var e = me.list[i];
			if (Symbol.Controller.equals(e.model, model)) {
				if (del) {
					# Remove this element from the list
					# TODO: maybe C function for this? extend pop() to accept index?
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
	onAdded: func(model)
		append(me.list, Symbol.new(me.type, me.group, model)),
	# Removes a symbol.
	onRemoved: func(model)
		me.findsym(model, 1).del(),
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

var AnimatedLayer = {
};

var CompassLayer = {
};

var AltitudeArcLayer = {
};

var load_MapStructure = func {
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

		var load_deps = func(name) {
		load(FG_ROOT~"/Nasal/canvas/map/"~name~".lcontroller",  name);
		load(FG_ROOT~"/Nasal/canvas/map/"~name~".symbol", name);
		load(FG_ROOT~"/Nasal/canvas/map/"~name~".scontroller", name);
		}

		foreach( var name; ['VOR','FIX','NDB','DME','WPT','TFC'] )
			load_deps( name );
		load(FG_ROOT~"/Nasal/canvas/map/aircraftpos.controller", name);

		###
		# set up a cache for 32x32 symbols
		var SymbolCache32x32 = SymbolCache.new(1024,32);

		var drawVOR = func(color, width=3) return func(group) {
				# print("drawing vor");
				var bbox = group.createChild("path")
					.moveTo(-15,0)
					.lineTo(-7.5,12.5)
					.lineTo(7.5,12.5)
					.lineTo(15,0)
					.lineTo(7.5,-12.5)
					.lineTo(-7.5,-12.5)
					.close()
					.setStrokeLineWidth(width)
					.setColor( color );
				# debug.dump( bbox.getBoundingBox() );
		};

		var cachedVOR1 = SymbolCache32x32.add( "VOR-BLUE", drawVOR( color:[0, 0.6, 0.85], width:3), SymbolCache.DRAW_CENTERED );
		var cachedVOR2 = SymbolCache32x32.add( "VOR-RED" , drawVOR( color:[1.0, 0, 0], width: 3),   SymbolCache.DRAW_CENTERED );
		var cachedVOR3 = SymbolCache32x32.add( "VOR-GREEN" , drawVOR( color:[0, 1, 0], width: 3),   SymbolCache.DRAW_CENTERED );
		var cachedVOR4 = SymbolCache32x32.add( "VOR-WHITE" , drawVOR( color:[1, 1, 1], width: 3),   SymbolCache.DRAW_CENTERED );

		# STRESS TEST
		if (0) {
			for(var i=0;i <= 1024/32*4 - 4; i+=1)
				SymbolCache32x32.add( "VOR-YELLOW"~i , drawVOR( color:[1, 1, 0], width: 3)   );

			var dlg = canvas.Window.new([640,320],"dialog");
			var my_canvas = dlg.createCanvas().setColorBackground(1,1,1,1);
			var root = my_canvas.createGroup();

			SymbolCache32x32.get(name:"VOR-BLUE").render( group: root ).setGeoPosition(getprop("/position/latitude-deg"),getprop("/position/longitude-deg"));
		}

	})();
	#print("finished loading files");
	####### TEST SYMBOL #######

	canvas.load_MapStructure = func;

}; # load_MapStructure

setlistener("/nasal/canvas/loaded", load_MapStructure); # end ugly module init listener hack
