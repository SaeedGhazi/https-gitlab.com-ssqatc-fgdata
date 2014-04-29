################################################################################
## MapStructure mapping/charting framework for Nasal/Canvas, by Philosopher
## See: http://wiki.flightgear.org/MapStructure
###############################################################################
var _MP_dbg_lvl = "info";
#var _MP_dbg_lvl = "alert";

var dump_obj = func(m) {
	var h = {};
	foreach (var k; keys(m))
		if (k != "parents")
			h[k] = m[k];
	debug.dump(h);
};

##
# for LOD handling (i.e. airports/taxiways/runways)
var RangeAware = {
 new: func {
	return {parents:[RangeAware] };
 },
 del: func,
 notifyRangeChange: func die("RangeAware.notifyRangeChange() must be provided by sub-class"),
};

## wrapper for each cached element
## i.e. keeps the canvas and texture map coordinates for the corresponding raster image
var CachedElement = {
	new: func(canvas_path, name, source, size, offset) {
		var m = {parents:[CachedElement] };
		if (isa(canvas_path, canvas.Canvas)) {
			canvas_path = canvas_path.getPath();
		}
		m.canvas_src = canvas_path;
		m.name = name;
		m.source = source;
		m.size = size;
		m.offset = offset;
		return m;
	}, # new()
	
	render: func(group, trans0=0, trans1=0) {
		# create a raster image child in the render target/group
		var n = 	group.createChild("image", me.name)
			.setFile( me.canvas_src )
			# TODO: fix .setSourceRect() to accept a single vector for texture map coordinates ...
			.setSourceRect(left:me.source[0],top:me.source[1],right:me.source[2],bottom:me.source[3], normalized:0)
			.setSize(me.size)
			.setTranslation(trans0,trans1);
		n.createTransform().setTranslation(me.offset);
		return n;
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
		m.canvas_texture.setColorBackground(0, 0, 0, 0); #rgba
		# add a placement
		m.canvas_texture.addPlacement( {"type": "ref"} );

		m.path = m.canvas_texture.getPath();
		m.root = m.canvas_texture.createGroup("entries");

		return m;
	},
	add: func(name, callback, draw_mode=0) {
		if (typeof(draw_mode) == 'scalar')
			var draw_mode0 = var draw_mode1 = draw_mode;
		else var (draw_mode0,draw_mode1) = draw_mode;
		# get canvas texture that we use as cache
		# get next free spot in texture (column/row)
		# run the draw callback and render into a group
		var gr = me.root.createChild("group",name);
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
			coords[i+1] += me.image_sz[i];
		foreach (var i; [0,1])
			coords[i*2+1] = me.canvas_sz[i] - coords[i*2+1];
		# get the offset we used to position correctly in the bounds of the canvas
		var offset = [-me.image_sz[0]*draw_mode0, -me.image_sz[1]*draw_mode1];

		# update next free position in cache (column/row)
		me.next_free[0] += me.image_sz[0];
		if (me.next_free[0] >= me.canvas_sz[0])
		{ me.next_free[0] = 0; me.next_free[1] += me.image_sz[1] }
		if (me.next_free[1] >= me.canvas_sz[1])
			die("SymbolCache: ran out of space after adding '"~name~"'");

		# store texture map coordinates in lookup map using the name as identifier
		return me.dict[name] = CachedElement.new(
			canvas_path: me.path,
			name: name,
			source: coords,
			size:me.image_sz,
			offset: offset,
		);
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
	# @param layer The #SymbolLayer this is a child of.
	new: func(type, group, layer, arg...) {
		var ret = call((var class = me.get(type)).new, [group, layer]~arg, class);
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

# to add support for additional ghosts, just append them to the vector below, possibly at runtime:
var supported_ghosts = ['positioned','Navaid','Fix','flightplan-leg','FGAirport'];
var is_positioned_ghost = func(obj) {
	var gt = ghosttype(obj);
	foreach(var ghost; supported_ghosts) {
		if (gt == ghost) return 1; # supported ghost was found
	}
	return 0; # not a known/supported ghost
};

# Generic getpos: get lat/lon from any object:
# (geo.Coord and positioned ghost currently)
Symbol.Controller.getpos = func(obj, p=nil) {
	if (obj == nil) die("Symbol.Controller.getpos received nil");
	if (p == nil) {
		var ret = Symbol.Controller.getpos(obj, obj);
		if (ret != nil) return ret;
		if (contains(obj, "parents")) {
			foreach (var p; obj.parents) {
				var ret = Symbol.Controller.getpos(obj, p);
				if (ret != nil) return ret;
			}
		}
		debug.dump(obj);
		die("no suitable getpos() found! Of type: "~typeof(obj));
	} else {
		if (typeof(p) == 'ghost')
			if ( is_positioned_ghost(p) )
				return getpos_fromghost(obj);
			else
				die("bad/unsupported ghost of type '"~ghosttype(obj)~"' (see MapStructure.nas Symbol.Controller.getpos() to add new ghosts)");
		if (typeof(p) == 'hash')
			if (p == geo.Coord)
				return subvec(obj.latlon(), 0, 2);
			if (p == props.Node)
				return [
					obj.getValue("position/latitude-deg")  or obj.getValue("latitude-deg"),
					obj.getValue("position/longitude-deg") or obj.getValue("longitude-deg")
				];
			if (contains(p,'lat') and contains(p,'lon'))
				return [obj.lat, obj.lon];
		return nil;
	}
};

Symbol.Controller.equals = func(l, r, p=nil) {
	if (l == r) return 1;
	if (p == nil) {
		var ret = Symbol.Controller.equals(l, r, l);
		if (ret != nil) return ret;
		if (contains(l, "parents")) {
			foreach (var p; l.parents) {
				var ret = Symbol.Controller.equals(l, r, p);
				if (ret != nil) return ret;
			}
		}
		debug.dump(obj);
		die("no suitable equals() found! Of type: "~typeof(obj));
	} else {
		if (typeof(p) == 'ghost')
			if ( is_positioned_ghost(p) )
				return l.id == r.id;
			else
				die("bad/unsupported ghost of type '"~ghosttype(l)~"' (see MapStructure.nas Symbol.Controller.getpos() to add new ghosts)");
		if (typeof(p) == 'hash')
			# Somewhat arbitrary convention:
			#   * l.equals(r)         -- instance method, i.e. uses "me" and "arg[0]"
			#   * parent._equals(l,r) -- class method, i.e. uses "arg[0]" and "arg[1]"
			if (contains(p, "equals"))
				return l.equals(r);
			if (contains(p, "_equals"))
				return p._equals(l,r);
	}
	return nil;
};


var assert_m = func(hash, member)
	if (!contains(hash, member))
		die("required field not found: '"~member~"'");
var assert_ms = func(hash, members...)
	foreach (var m; members)
		if (m != nil) assert_m(hash, m);


var DotSym = {
	parents: [Symbol], # TODO: use StyleableSymbol here to support styling and caching
	element_id: nil,
# Static/singleton:
	makeinstance: func(name, hash) {
		if (!isa(hash, DotSym))
			die("OOP error");
		return Symbol.add(name, hash);
	},
# For the instances returned from makeinstance:
	# @param group The #Canvas.Group to add this to.
	# @param layer The #SymbolLayer this is a child of.
	# @param model A correct object (e.g. positioned ghost) as
	#              expected by the .draw file that represents
	#              metadata like position, speed, etc.
	# @param controller Optional controller "glue". Each method
	#                   is called with the model as the only argument.
	new: func(group, layer, model, controller=nil) {
		if (me == nil) die();
		var m = {
			parents: [me],
			group: group,
			layer: layer,
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
		if (size(err) and err[0] != "No such member: del") # ... and either catch or rethrow
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
		# print(me.model.id, ": Position lat/lon: ", lat, "/", lon);
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
# Default implementations/values:
	df_controller: nil, # default controller
	df_priority: nil, # default priority for display sorting
	df_style: nil,
	type: nil, # type of #Symbol to add (MANDATORY)
	id: nil, # id of the group #canvas.Element (OPTIONAL)
	# @param group A group to place this on.
	# @param map The #Canvas.Map this is a member of.
	# @param controller A controller object (parents=[SymbolLayer.Controller])
	#                   or implementation (parents[0].parents=[SymbolLayer.Controller]).
	new: func(group, map, controller=nil, style=nil, options=nil) {
		#print("Creating new Layer instance");
		if (me == nil) die();
		var m = {
			parents: [me],
			map: map,
			group: group.createChild("group", me.type), # TODO: the id is not properly set, but would be useful for debugging purposes (VOR, FIXES, NDB etc)
			list: [],
			options: options,
		};
		m.setVisible();

		# print("Layer setup options:", m.options!=nil);
		# do no overwrite the default style if style is nil:
		if (style != nil and typeof(style)=='hash') {
			#print("Setting up a custom style!");
			m.style = style;
		} else m.style = me.df_style;

		# debug.dump(m.style);
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
		if (!me.getVisible()) {
			return;
		}
		# TODO: add options hash processing here 
		var updater = func {
			me.searcher.update();
			foreach (var e; me.list)
				e.update();
		}

		if (me.options != nil and me.options['update_wrapper'] !=nil) {
			me.options.update_wrapper( me, updater ); # call external wrapper (usually for profiling purposes)
			# print("calling update_wrapper!");
		}
		else	{
			# print("not using wrapper");	
			updater();
			# debug.dump(me.options);
		}
		#var start=systime();
		#var end=systime();
		# print(me.type, " layer update:", end-start);
		# HACK: hard-coded ...
		#setprop("/gui/navdisplay/layers/"~me.type~"/delay-ms", (end-start)*1000 );
	},
	##
	# useful to support checkboxes in dialogs (e.g. Map dialog)
	# so that we can show/hide layers directly by registering a listener
	# TODO: should also allow us to update the navdisplay logic WRT to visibility
	hide: func me.group.hide(),
	show: func me.group.show(),
	getVisible: func me.group.getVisible(),
	setVisible: func(visible = 1) me.group.setVisible(visible),
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
	searchCmd: func() { 
		var result = me.controller.searchCmd();
		# some hardening TODO: don't do this always - only do it once during initialization, i.e. layer creation ?
		var type=typeof(result);
		if(type != 'nil' and type != 'vector') 
			die("MapStructure: searchCmd() method MUST return a vector of valid objects or nil! (was:"~type~")");
		return result;
	},
	# Adds a symbol.
	onAdded: func(model) {
		printlog(_MP_dbg_lvl, "Adding symbol of type "~me.type);
		if (model == nil) die("Model was nil for "~debug.string(me.type));
		append(me.list, Symbol.new(me.type, me.group, me, model));
	},
	# Removes a symbol.
	onRemoved: func(model) {
		printlog(_MP_dbg_lvl, "Deleting symbol of type "~me.type);
		if (me.findsym(model, 1) == nil) die("model not found");
		call(func model.del(), nil, var err = []); # try...
		if (size(err) and err[0] != "No such member: del") # ... and either catch or rethrow
			die(err[0]);
	},
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
# Default implementations:
	run_update: func() me.layer.update(),
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

###
# set up a cache for 32x32 symbols
var SymbolCache32x32 = nil;#SymbolCache.new(1024,32);

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
		new: func(type, map, arg...) {
			var m = call((var class = me.get(type)).new, [map]~arg, class);
			if (!contains(m, "map"))
				m.map = map;
			# FIXME: fails on no member
			elsif (m.map != map and !isa(m.map, map) and (
			       	m.get_position != Map.Controller.get_position
			     or m.query_range != Map.Controller.query_range
			     or m.in_range != Map.Controller.in_range))
			{ die("m must store the map handle as .map if it uses the default method(s)"); }
		},
	# Default implementations:
		get_position: func() {
			debug.warn("get_position is deprecated");
			return me.map.getLatLon()~[me.map.getAlt()];
		},
		query_range: func() {
			debug.warn("query_range is deprecated");
			return me.map.getRange() or 30;
		},
		in_range: func(lat, lon, alt=0) {
			var range = me.map.getRange();
			if(range == nil) die("in_range: Invalid query range!");
			# print("Query Range is:", range );
			if (lat == nil or lon == nil) die("in_range: lat/lon invalid");
			var pos = geo.Coord.new();
			pos.set_latlon(lat, lon, alt or 0);
			var map_pos = me.map.getPosCoord();
			if (map_pos == nil)
				return 0; # should happen *ONLY* when map is uninitialized
			var distance_m = pos.distance_to( map_pos );
			var is_in_range = distance_m < range * NM2M;
			# print("Distance:",distance_m*M2NM," nm in range check result:", is_in_range);
			return is_in_range;
		},
	};

	####### LOAD FILES #######
	#print("loading files");
	(func {
		var FG_ROOT = getprop("/sim/fg-root");
		var load = func(file, name) {
			#print(file);
			if (name == nil)
				var name = split("/", file)[-1];
			if (substr(name, size(name)-4) == ".draw") # we don't need this anylonger, right ?
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



			# validate  
			var url = ' http://wiki.flightgear.org/MapStructure#';
			# TODO: these rules should be extended for all main files lcontroller/scontroller and symbol
			# TODO move this out of here, so that we can use these checks in other places (i.e. searchCmd validation)
			var checks = [
					{ extension:'symbol', symbol:'update', type:'func', error:' update() must not be overridden:', id:300},
					{ extension:'symbol', symbol:'draw', type:'func', required:1, error:' symbol files need to export a draw() routine:', id:301},
					{ extension:'lcontroller', symbol:'searchCmd', type:'func', required:1, error:' lcontroller without searchCmd method:', id:100},
					];


			var makeurl = func(scope, id) url ~ scope ~ ':' ~ id; 				
			var bailout = func(file, message, scope, id) die(file~message~"\n"~makeurl(scope,id) );

			var current_ext = split('.', file)[-1];
			foreach(var check; checks) {
				# check if we have any rules matching the current file extension
				if (current_ext == check.extension) {
					# check for fields that must not be overridden
					if (check['error'] != nil and 
						hash[check.symbol]!=nil and !check['required']  and 
						typeof(hash[check.symbol])==check.type ) {
						bailout(file,check.error,check.extension,check.id);
					}

					# check for required fields
					if (check['required'] != nil and 
						hash[check.symbol]==nil and
						typeof( hash[check.symbol]) != check.type) {
						bailout(file,check.error,check.extension,check.id);
					}
				}
			}
			if(file==FG_ROOT~'/Nasal/canvas/map/DME.scontroller')  {
			# var test = hash.new(nil);
			# debug.dump( id(hash.new) );
			}
			# TODO: call self tests/sanity checks here
			# and consider calling .symbol::draw() to ensure that certain APIs are NOT used, such as setGeoPosition() and setColor() etc (styling)

			return hash;
		};

		# sets up a shared symbol cache, which will be used by all MapStructure maps and layers
		# TODO: need to encode styling information as part of  the keys/hash lookup, name - so that 
		# different maps/layers do not overwrite symbols accidentally 
		# 
		canvas.SymbolCache32x32 = SymbolCache.new(1024,32);

		var load_deps = func(name) {
			load(FG_ROOT~"/Nasal/canvas/map/"~name~".lcontroller",  name);
			load(FG_ROOT~"/Nasal/canvas/map/"~name~".symbol", name);
			load(FG_ROOT~"/Nasal/canvas/map/"~name~".scontroller", name);
		}

		# add your own MapStructure layers here, see the wiki for details: http://wiki.flightgear.org/MapStructure
		foreach( var name; ['APT','VOR','FIX','NDB','DME','WPT','TFC','APS',] )
			load_deps( name );
		load(FG_ROOT~"/Nasal/canvas/map/aircraftpos.controller", name);

		# disable this for now
		if(0) {
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

			# visually verify VORs were placed:
			# var dlg2 = canvas.Window.new([1024,1024], "dialog");
			# dlg2.setCanvas(SymbolCache32x32.canvas_texture);
			
			# use one:
			# var dlg = canvas.Window.new([120,120],"dialog");
			# var my_canvas = dlg.createCanvas().setColorBackground(1,1,1,1);
			# var root = my_canvas.createGroup();

			# SymbolCache32x32.get(name:"VOR-RED").render( group: root ).setTranslation(60,60);
		}

		# STRESS TEST
		if (0) {
			#for(var i=0;i <= 1024/32*4 - 4; i+=1)
			#	SymbolCache32x32.add( "VOR-YELLOW"~i , drawVOR( color:[1, 1, 0], width: 3)   );
		}

	})();
	#print("finished loading files");
	####### TEST SYMBOL #######

	canvas.load_MapStructure = func; # @Philosopher: is this intended/needed ??

}; # load_MapStructure

setlistener("/nasal/canvas/loaded", load_MapStructure); # end ugly module init listener hack. FIXME: do smart Nasal bootstrapping, quod est callidus!
# Actually, it would be even better to support reloading MapStructure files, and maybe even MapStructure itself by calling the dtor/del method for each Map and then re-running the ctor
