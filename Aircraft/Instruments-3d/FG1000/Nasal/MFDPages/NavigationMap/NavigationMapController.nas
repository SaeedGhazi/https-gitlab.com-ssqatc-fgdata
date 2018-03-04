# Copyright 2018 Stuart Buchanan
# This file is part of FlightGear.
#
# Foobar is free software: you can redistribute it and/or modify
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
# Navigation Map Controller
var NavigationMapController =
{


  # TODO: Add STAMEN topo layer, which is visible on all levels as opposed to
  # roads, railways, boundaries, cities which are only visible on declutter 0.

  # Declutter levels.
  DCLTR : [ "DCLTR", "DCLTR-1", "DCLTR-2", "DCLTR-3"],

  # Airways levels.
  AIRWAYS : [ "AIRWAYS", "AIRWY ON", "AIRWY LO", "AIRWY HI"],

  new : func (page, svg)
  {
    var obj = { parents : [ NavigationMapController, MFDPageController.new(page) ] };
    obj.current_zoom = 13;
    obj.declutter = 0;
    obj.airways = 0;
    obj.page = page;
    obj.setZoom(obj.current_zoom);
    obj.setOrientation(fg1000.ORIENTATIONS[0]);

    return obj;
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
    me.page.setRange(fg1000.RANGES[zoom].range, fg1000.RANGES[zoom].label);
    me.updateVisibility();
  },
  setOrientation : func(orientation) {
    me.page.setOrientation(orientation.label);
  },
  updateVisibility : func() {
    # Determine which layers should be visible.
    foreach (var layer_name; me.page.mfd.ConfigStore.getLayerNames()) {
      var layer = me.page.mfd.ConfigStore.getLayer(layer_name);
      if (layer.enabled and
          (fg1000.RANGES[me.current_zoom].range <= layer.range) and
          (me.declutter <= layer.declutter)   )
      {
        me.page.MFDMap.getLayer(layer_name).setVisible(1);
      } else {
        me.page.MFDMap.getLayer(layer_name).setVisible(0);
      }
    }
  },
  isEnabled : func(layer) {
    return me.page.mfd.ConfigStore.isLayerEnabled(layer);
  },
  toggleLayer : func(layer) {
    me.page.mfd.ConfigStore.toggleLayerEnabled(layer);
    me.updateVisibility();
  },

  # Increment through the de-clutter levels, which impact what layers are
  # displayed.  We also need to update the declutter menu item.
  incrDCLTR : func(device, menuItem) {
    me.declutter = math.mod(me.declutter +1, 4);
    menuItem.title = me.DCLTR[me.declutter];
    device.updateMenus();
    me.updateVisibility();
  },

  getDCLTRTitle : func() {
    return me.DCLTR[me.declutter];
  },

  # Increment through the AIRWAYS levels.  At present this doesn't do anything
  # except change the label.  It should enable/disable different airways
  # information.
  incrAIRWAYS : func(device, menuItem) {
    me.airways = math.mod(me.airways +1, 4);
    menuItem.title = me.AIRWAYS[me.airways];
    device.updateMenus();
    me.updateVisibility();
  },
  getAIRWAYSTitle : func() {
    return me.AIRWAYS[me.airways];
  },

  # Set the DTO line target
  setDTOLineTarget : func(lat, lon) {
    me.page.MFDMap.getLayer("DTO").controller.setTarget(lat,lon);
  },
  enableDTO : func(enable) {
    me.page.mfd.ConfigStore.setLayerEnabled("DTO", enable);
    me.updateVisibility();
  },

  handleRange : func(val)
  {
    var incr_or_decr = (val > 0) ? 1 : -1;
    me.setZoom(me.current_zoom + incr_or_decr);
  },

  # Reset controller if required when the page is displayed or hidden
  ondisplay : func() {
    me.RegisterWithEmesary();
  },
  offdisplay : func() {
    me.DeRegisterWithEmesary();
  },

};
