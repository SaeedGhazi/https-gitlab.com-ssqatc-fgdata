# Navigation Map
var NavMap =
{
  new : func (mfd, myCanvas, device, svg)
  {
    var obj = {
      title : "MAP - NAVIGATION MAP",
      _group : myCanvas.createGroup("NavigationMapLayer"),
      parents : [ NavMap, device.addPage("NavigationMap", "NavigationMapGroup") ]
    };

    obj.Styles = fg1000.NavMapStyles.new();
    obj.Options = fg1000.NavMapOptions.new();
    obj.MFDMap = obj._group.createChild("map");
    obj.device = device;
    obj.mfd = mfd;

    # Need to display this underneath the softkeys, EIS, header.
    obj._group.set("z-index", -10.0);
    obj._group.setVisible(0);


    # Initialize the controller:
    var ctrl_ns = canvas.Map.Controller.get("Aircraft position");
    var source = ctrl_ns.SOURCES["current-pos"];
    if (source == nil) {
        # TODO: amend
        var source = ctrl_ns.SOURCES["current-pos"] = {
            getPosition: func subvec(geo.aircraft_position().latlon(), 0, 2),
            getAltitude: func getprop('/position/altitude-ft'),
            getHeading:  func {
                if (me.aircraft_heading)
                    getprop('/orientation/heading-deg')
                else 0
            },
            aircraft_heading: 1,
        };
    }
    setlistener("/sim/gui/dialogs/map-canvas/aircraft-heading-up", func(n) {
      source.aircraft_heading = n.getBoolValue();
    }, 1);
    # Make it move with our aircraft:
    obj.MFDMap.setController("Aircraft position", "current-pos"); # from aircraftpos.controller

    # Center the map's origin, modified to take into account the surround.
    obj.MFDMap.setTranslation(
      fg1000.MAP_FULL.CENTER.X,
      fg1000.MAP_FULL.CENTER.Y
    );

    var r = func(name,vis=1,zindex=nil) return caller(0)[0];
    # TODO: we'll need some z-indexing here, right now it's just random
    foreach(var type; [r('GRID'),r('TFC',0),r('APT'),r('DME'),r('VOR'),r('NDB'),r('FIX',0),r('RTE'),r('WPT'),r('FLT'),r('WXR',0),r('APS')] ) {
        obj.MFDMap.addLayer(factory: canvas.SymbolLayer, type_arg: type.name,
                         visible: type.vis, priority: 4,
                         style: obj.Styles.getStyle(type.name),
                         options: obj.Options.getOption(type.name) );
    }

    foreach(var type; [ r('STAMEN_terrain'),r('STAMEN'), r('OpenAIP') ]) {
        obj.MFDMap.addLayer(factory: canvas.OverlayLayer, type_arg: type.name,
                         visible: 0, priority: 1,
                         style: obj.Styles.getStyle(type.name),
                         options: obj.Options.getOption(type.name) );
    }

    obj.controller = fg1000.NavMapController.new(obj, svg, "RangeDisplay", 8);

    var topMenu = func(device, pg, menuitem) {
      pg.clearMenu();
      resetMenuColors(device);
      pg.addMenuItem(0, "ENGINE", pg, engineMenu);
      pg.addMenuItem(2, "MAP", pg, mapMenu);
      pg.addMenuItem(8, "DCLTR", pg, func(dev, pg, mi) { obj.controller.incrDCLTR(dev, mi); } );
      #pg.addMenuItem(9, "SHW CHRT", pg);  # Optional
      #pg.addMenuItem(10, "CHKLIST", pg);  # Optional
      device.updateMenus();
    };

    var engineMenu = func(device, pg, menuitem) {
      pg.clearMenu();
      resetMenuColors(device);
      pg.addMenuItem(0, "ENGINE", pg, engineMenu);
      pg.addMenuItem(1, "LEAN", pg, leanMenu);
      pg.addMenuItem(2, "SYSTEM", pg, systemMenu);
      pg.addMenuItem(8, "BACK", pg, topMenu);
      device.updateMenus();
    };


    # Display map toggle softkeys which change color depending
    # on whether a particular layer is enabled or not.
    var display_toggle = func(device, svg, mi, layer) {
      var bg_name = sprintf("SoftKey%d-bg",mi.menu_id);
      if (obj.controller.isEnabled(layer)) {
        device.svg.getElementById(bg_name).setColorFill(0.5,0.5,0.5);
        svg.setColor(0.0,0.0,0.0);
      } else {
        device.svg.getElementById(bg_name).setColorFill(0.0,0.0,0.0);
        svg.setColor(1.0,1.0,1.0);
      }
      svg.setText(mi.title);
      svg.setVisible(1); # display function
    };

    # Function to undo any colors set by display_toggle when loading a new menu
    var resetMenuColors = func(device) {
      for(var i = 0; i < 12; i +=1) {
        var name = sprintf("SoftKey%d",i);
        device.svg.getElementById(name ~ "-bg").setColorFill(0.0,0.0,0.0);
        device.svg.getElementById(name).setColor(1.0,1.0,1.0);
      }
    }

    var mapMenu = func(device, pg, menuitem) {
      pg.clearMenu();
      resetMenuColors(device);
      pg.addMenuItem(0, "TRAFFIC", pg,
        func(dev, pg, mi) { obj.controller.toggleLayer("TFC"); device.updateMenus(); }, # callback
        func(svg, mi) { display_toggle(device, svg, mi, "TFC"); }
      );

      pg.addMenuItem(1, "PROFILE", pg);
      pg.addMenuItem(2, "TOPO", pg,
        func(dev, pg, mi) { obj.controller.toggleLayer("STAMEN"); device.updateMenus(); }, # callback
        func(svg, mi) { display_toggle(device, svg, mi, "STAMEN"); }
      );

      pg.addMenuItem(3, "TERRAIN", pg,
        func(dev, pg, mi) { obj.controller.toggleLayer("STAMEN_terrain"); device.updateMenus(); }, # callback
        func(svg, mi) { display_toggle(device, svg, mi, "STAMEN_terrain"); }
      );

      pg.addMenuItem(4, "AIRWAYS", pg, func(dev, pg, mi) { obj.controller.incrAIRWAYS(dev, mi); } );
      #pg.addMenuItem(5, "STRMSCP", pg); Optional
      #pg.addMenuItem(6, "PRECIP", pg); Optional, or NEXRAD
      #pg.addMenuItem(7, "XM LTNG", pg); Optional, or DL LTNG
      #pg.addMenuItem(8, "METAR", pg);
      #pg.addMenuItem(9, "LEGEND", pg); Optional - only available with NEXRAD/XM LTNG/METAR/PROFILE selected
      pg.addMenuItem(10, "BACK", pg, topMenu);  # Or should this just be the next button?
      device.updateMenus();
    };

    var leanMenu = func(device, pg, menuitem) {
        pg.clearMenu();
        resetMenuColors(device);
        pg.addMenuItem(0, "ENGINE", pg, engineMenu);
        pg.addMenuItem(1, "LEAN", pg, leanMenu);
        pg.addMenuItem(2, "SYSTEM", pg, systemMenu);
        pg.addMenuItem(3, "CYL SELECT", pg);
        pg.addMenuItem(4, "ASSIST", pg);
        pg.addMenuItem(9, "BACK", pg, engineMenu);
        device.updateMenus();
    };

    var systemMenu = func(device, pg, menuitem) {
        pg.clearMenu();
        resetMenuColors(device);
        pg.addMenuItem(0, "ENGINE", pg, engineMenu);
        pg.addMenuItem(1, "LEAN", pg, leanMenu);
        pg.addMenuItem(2, "SYSTEM", pg, systemMenu);
        pg.addMenuItem(3, "RST FUEL", pg);
        pg.addMenuItem(4, "GAL REM", pg, galRemMenu);
        pg.addMenuItem(5, "BACK", pg, engineMenu);
        device.updateMenus();
    };

    var galRemMenu = func(device, pg, menuitem) {
      pg.clearMenu();
      resetMenuColors(device);
      pg.addMenuItem(0, "ENGINE", pg, engineMenu);
      pg.addMenuItem(1, "LEAN", pg, leanMenu);
      pg.addMenuItem(2, "SYSTEM", pg, systemMenu);
      pg.addMenuItem(3, "-10 GAL", pg);
      pg.addMenuItem(4, "-1 GAL", pg);
      pg.addMenuItem(5, "+1 GAL", pg);
      pg.addMenuItem(6, "+10 GAL", pg);
      pg.addMenuItem(7, "44 GAL", pg);
      pg.addMenuItem(8, "BACK", pg, engineMenu);
      device.updateMenus();
    };

    topMenu(device, obj, nil);

    return obj;
  },
  toggleLayerVisible : func(name) {
      (var l = me.MFDMap.getLayer(name)).setVisible(l.getVisible());
  },
  setLayerVisible : func(name,n=1) {
      me.MFDMap.getLayer(name).setVisible(n);
  },
  setRange : func(range) {
    me.MFDMap.setRange(range);
  },
  setScreenRange : func(range) {
    me.MFDMap.setScreenRange(range);
  },
  offdisplay : func() {
    me._group.setVisible(0);

    # Reset the menu colours.  Shouldn't have to do this here, but
    # there's not currently an obvious other location to do so.
    for(var i = 0; i < 12; i +=1) {
      var name = sprintf("SoftKey%d",i);
      me.device.svg.getElementById(name ~ "-bg").setColorFill(0.0,0.0,0.0);
      me.device.svg.getElementById(name).setColor(1.0,1.0,1.0);
    }
    me.controller.offdisplay();
  },
  ondisplay : func() {
    me._group.setVisible(1);
    me.mfd.setPageTitle(me.title);
    me.controller.ondisplay();
  },
};
