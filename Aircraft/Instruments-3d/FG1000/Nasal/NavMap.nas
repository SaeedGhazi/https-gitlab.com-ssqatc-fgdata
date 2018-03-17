# Copyright 2018 Stuart Buchanan
# This file is part of FlightGear.
#
# FlightGear is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
# Common Navigation map functions
var NavMap = {

  # Declutter levels.
  DCLTR : [ "DCLTR", "DCLTR-1", "DCLTR-2", "DCLTR-3"],

  # Airways levels.
  AIRWAYS : [ "AIRWAYS", "AIRWY ON", "AIRWY LO", "AIRWY HI"],

  new : func(page, element, center, clip="", zindex=0, vis_shift=0, static=0 )
  {
    var obj = {
      parents : [ NavMap ],
      _group : page.getGroup(),
      _svg : page.getSVG(),
      _page : page,
      _pageName : page.getPageName(),
      current_zoom : 13,
      declutter : 0,
      airways : 0,
      vis_shift : vis_shift,
    };

    element.setTranslation(center[0], center[1]);

    obj.Styles = fg1000.NavigationMapStyles.new();
    obj.Options = fg1000.NavigationMapOptions.new();

    obj.Map = element.createChild("map");
    obj.Map.setScreenRange(689/2.0);

    obj._rangeDisplay = obj._svg.getElementById(obj._pageName ~ "RangeDisplay");
    if (obj._rangeDisplay == nil) die("Unable to find element " ~ obj._pageName ~ "RangeDisplay");

    obj._orientationDisplay = obj._svg.getElementById(obj._pageName ~ "OrientationDisplay");
    if (obj._orientationDisplay == nil) die("Unable to find element " ~ obj._pageName ~ "OrientationDisplay");

    # Initialize the controllers:
    if (static) {
      obj.Map.setController("Static position", "main");
    } else {
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
      obj.Map.setController("Aircraft position", "current-pos"); # from aircraftpos.controller
    }

    if (clip != "") {
      obj.Map.set("clip-frame", canvas.Element.LOCAL);
      obj.Map.set("clip", clip);
    }

    if (zindex != 0) {
      element.setInt("z-index", zindex);
    }

    var r = func(name,on_static=1, vis=1,zindex=nil) return caller(0)[0];
    # TODO: we'll need some z-indexing here, right now it's just random
    foreach (var layer_name; obj._page.mfd.ConfigStore.getLayerNames()) {
      var layer = obj._page.mfd.ConfigStore.getLayer(layer_name);

      if ((static == 0) or (layer.static == 1)) {
        # Not all layers are displayed for all map types.  Specifically,
        # some layers are not displayed on static maps - e.g. DirectTo
        obj.Map.addLayer(
          factory: layer.factory,
          type_arg: layer_name,
          priority: layer.priority,
          style: obj.Styles.getStyle(layer_name),
          options: obj.Options.getOption(layer_name),
          visible: 0);
      }
    }

    obj.setZoom(obj.current_zoom);
    obj.setOrientation(0);
    obj.Map.setVisible(0);
    return obj;
  },

  setController : func(type, controller ) {
    me.Map.setController(type, controller);
  },

  getController : func() {
    return me.Map.getController();
  },

  toggleLayerVisible : func(name) {
      (var l = me.Map.getLayer(name)).setVisible(l.getVisible());
  },

  setLayerVisible : func(name,n=1) {
      me.Map.getLayer(name).setVisible(n);
  },

  setRange : func(range, label) {
    me.Map.setRange(range);
    me._rangeDisplay.setText(label);
  },

  setOrientation : func(orientation) {
    # TODO - implment this
    me._orientationDisplay.setText(fg1000.ORIENTATIONS[orientation].label);
  },

  setScreenRange : func(range) {
    me.Map.setScreenRange(range);
  },

  zoomIn : func() {
    me.setZoom(me.current_zoom -1);
  },

  zoomOut : func() {
    me.setZoom(me.current_zoom +1);
  },

  setZoom : func(zoom) {
    if ((zoom < 0) or (zoom > (size(fg1000.RANGES) - 1))) return;
    me.current_zoom = zoom;
    # Ranges above represent vertical ranges, but the display is a rectangle, so
    # we need to use the diagonal range of the 1024 x 689, which is 617px.
    # 617px is 1.8 x 689/2, so we need to increase the range values by x1.8
    me.setRange(fg1000.RANGES[zoom].range, fg1000.RANGES[zoom].label);
    me.updateVisibility();
  },

  updateVisibility : func() {
    # Determine which layers should be visible.
    foreach (var layer_name; me._page.mfd.ConfigStore.getLayerNames()) {
      var layer = me._page.mfd.ConfigStore.getLayer(layer_name);

      if (me.Map.getLayer(layer_name) == nil) continue;

      # Layers are only displayed if:
      # 1) the user has enabled them.
      # 2) The current zoom level is _less_ than the maximum range for the layer
      #    (i.e. as the range gets larger, we remove layers).  Note that for
      #     inset maps, the range that items are removed is lower.
      # 3) They haven't been removed due to the declutter level.
      var effective_zoom = math.clamp(me.current_zoom + me.vis_shift, 0, size(fg1000.RANGES));
      var effective_range = fg1000.RANGES[effective_zoom].range;
      if (layer.enabled and
          (effective_range <= layer.range) and
          (me.declutter <= layer.declutter)    )
      {
        me.Map.getLayer(layer_name).setVisible(1);
      } else {
        me.Map.getLayer(layer_name).setVisible(0);
      }
    }
  },

  isEnabled : func(layer) {
    return me._page.mfd.ConfigStore.isLayerEnabled(layer);
  },

  toggleLayer : func(layer) {
    me._page.mfd.ConfigStore.toggleLayerEnabled(layer);
    me.updateVisibility();
  },

  # Increment through the de-clutter levels, which impact what layers are
  # displayed.  We also need to update the declutter menu item.
  incrDCLTR : func(device, menuItem) {
    me.declutter = math.mod(me.declutter +1, 4);
    me.updateVisibility();
    return me.DCLTR[me.declutter];
  },

  getDCLTRTitle : func() {
    return me.DCLTR[me.declutter];
  },

  # Increment through the AIRWAYS levels.  At present this doesn't do anything
  # except change the label.  It should enable/disable different airways
  # information.
  incrAIRWAYS : func(device, menuItem) {
    me.airways = math.mod(me.airways +1, 4);
    me.updateVisibility();
    return me.AIRWAYS[me.airways];
  },

  getAIRWAYSTitle : func() {
    return me.AIRWAYS[me.airways];
  },

  # Set the DTO line target
  setDTOLineTarget : func(lat, lon) {
    me.Map.getLayer("DTO").controller.setTarget(lat,lon);
  },
  enableDTO : func(enable) {
    me._page.mfd.ConfigStore.setLayerEnabled("DTO", enable);
    me.updateVisibility();
  },

  handleRange : func(val)
  {
    var incr_or_decr = (val > 0) ? 1 : -1;
    me.setZoom(me.current_zoom + incr_or_decr);
  },

  getMap : func() {
    return me.Map;
  },
  show : func() {
    me.Map.show();
  },
  hide : func() {
    me.Map.hide();
  },
  setVisible : func(visible) {
    me.Map.setVisible(visible);
  }

};
