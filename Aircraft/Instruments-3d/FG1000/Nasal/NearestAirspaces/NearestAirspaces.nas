# NearestAirspaces
var NearestAirspaces =
{
  new : func (mfd, myCanvas, device, svg)
  {
    var obj = {
      title : "NRST - NEAREST AIRSPACES",
      _group : myCanvas.createGroup("NearestAirspacesLayer"),
      parents : [ NavMap, device.addPage("NearestAirspaces", "NearestAirspacesGroup") ],
      symbols : {},
    };

    obj.Styles = fg1000.NearestAirspacesStyles.new();
    obj.Options = fg1000.NearestAirspacesOptions.new();
    obj.device = device;
    obj.mfd = mfd;

    obj.controller = fg1000.NearestAirspacesController.new(obj, svg);

    # Dynamic elements
    var elements = [

    ];

    foreach (var element; elements) {
      obj.symbols[element] = svg.getElementById(element);
    }

    var topMenu = func(device, pg, menuitem) {
      pg.clearMenu();
      resetMenuColors(device);
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

    topMenu(device, obj, nil);

    return obj;
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
  },
  ondisplay : func() {
    me._group.setVisible(1);
    me.mfd.setPageTitle(me.title);
  },
};
