# AirportInfo
var AirportInfo =
{
  SURFACE_TYPES : {
    1 : "HARD SURFACE",  # Asphalt
    2 : "HARD SURFACE", # Concrete
    3 : "TURF",
    4 : "DIRT",
    5 : "GRAVEL",
    #  Helipads
    6 : "HARD SURFACE",  # Asphalt
    7 : "HARD SURFACE", # Concrete
    8 : "TURF",
    9 : "DIRT",
    0 : "GRAVEL",
  },


  new : func (mfd, myCanvas, device, svg)
  {
    var obj = {
      title : "WPT - AIRPORT INFORMATION",
      _group : myCanvas.createGroup("AirportInfoLayer"),
      parents : [ AirportInfo, device.addPage("AirportInfo", "AirportInfoGroup") ],
      symbols : {},
    };

    obj.Styles = fg1000.AirportInfoStyles.new();
    obj.Options = fg1000.AirportInfoOptions.new();
    obj.device = device;
    obj.mfd = mfd;

    # Need to display this underneath the softkeys, EIS, header.
    obj._group.set("z-index", -10.0);
    obj._group.setVisible(0);

    # Dynamic text elements in the SVG file.  In the SVG these have an "AirportInfo" prefix.
    var textelements = [
      "ID",
      "Usage",
      "Name",
      "City",
      "Region",
      "Alt",
      "Lat",
      "Lon",
      "Fuel",
      "TZ",
      "Runway",
      "RwyDimensions",
      "RwySurface",
      "RwyLighting",
      "FreqLabel1", "Freq1",
      "FreqLabel2", "Freq2",
      "FreqLabel3", "Freq3",
      "FreqLabel4", "Freq4",
      "FreqLabel5", "Freq5",
      "FreqLabel6", "Freq6",
      "FreqLabel7", "Freq7",
      "FreqLabel8", "Freq8",
      "Zoom"
    ];

    foreach (var element; textelements) {
      obj.symbols[element] = svg.getElementById("AirportInfo" ~ element);
      obj.symbols[element].setText("");
    }

    # The Airport Chart
    obj.AirportChart = obj._group.createChild("map");
    obj.AirportChart.setController("Static position", "main");
    var controller = obj.AirportChart.getController();

    # Initialize a range and screen resolution.  Setting a range
    # to 4nm means we pick up a good set of surrounding fixes
    # We will use the screen range for zooming.  If we use range
    # then as we zoom in the airport center goes out of range
    # and all the runways disappear.
    obj.AirportChart.setRange(4.0);
    obj.AirportChart.setScreenRange(fg1000.MAP_PARTIAL.HEIGHT);
    obj.AirportChart.setTranslation(
      fg1000.MAP_PARTIAL.CENTER.X,
      fg1000.MAP_PARTIAL.CENTER.Y
    );

    var r = func(name,vis=1,zindex=nil) return caller(0)[0];
    foreach(var type; [r('TAXI'),r('RWY')] ) {
        obj.AirportChart.addLayer(canvas.SymbolLayer,
                               type.name,
                               4,
                               obj.Styles.getStyle(type.name),
                               obj.Options.getOption(type.name),
                               type.vis );
    }


    obj.controller = fg1000.AirportInfoController.new(obj, svg);

    # Softkey menus
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
    me.controller.offdisplay();
  },
  ondisplay : func() {
    me._group.setVisible(1);
    me.mfd.setPageTitle(me.title);
    me.controller.ondisplay();
  },
  displayAirport : func(apt_info) {
    # Display a given airport
    me.AirportChart.getController().setPosition(apt_info.lat,apt_info.lon);
    me.symbols["ID"].setText(apt_info.id);
    me.symbols["Usage"].setText("PUBLIC");
    me.symbols["Name"].setText(string.uc(apt_info.name));
    me.symbols["City"].setText("CITY");
    me.symbols["Region"].setText("REGION");
    me.symbols["Alt"].setText(sprintf("%ift", 3.28 * apt_info.elevation));

    if (apt_info.lat < 0.0) {
      me.symbols["Lat"].setText(sprintf("S %.4f", -apt_info.lat));
    } else {
      me.symbols["Lat"].setText(sprintf("N %.4f", apt_info.lat));
    }

    if (apt_info.lon < 0.0) {
      me.symbols["Lon"].setText(sprintf("W%3.4f", -apt_info.lon));
    } else {
      me.symbols["Lon"].setText(sprintf("E%3.4f", apt_info.lon));
    }

    me.symbols["Fuel"].setText("AVGAS");
    me.symbols["TZ"].setText("UTC-6");

    # Display the comms frequencies for this airport
    var fcount = 1;

    if (size(apt_info.comms()) > 0) {
      # Airport has one or more frequencies assigned to it.
      var freqs = {};
      var comms = apt_info.comms();

      foreach (var c; comms) {
        freqs[c.ident] = sprintf("%.3f", c.frequency);;
      }

      foreach (var c; sort(keys(freqs), string.icmp)) {
        me.symbols["FreqLabel" ~ fcount].setText(c);
        me.symbols["Freq" ~ fcount].setText(freqs[c]);
        fcount += 1;
      }
    }

    while (fcount < 9) {
      # zero remaining comms channels
      me.symbols["FreqLabel" ~ fcount].setText("");
      me.symbols["Freq" ~ fcount].setText("");
      fcount += 1;
    }
  },
  displayRunway : func(rwy_info) {
    var lbl = rwy_info.id ~ "-" ~ rwy_info.reciprocal.id;
    me.symbols["Runway"].setText(lbl);

    var dim = sprintf("%ift x %ift", 3.28 * rwy_info.length, 3.28 * rwy_info.width);
    me.symbols["RwyDimensions"].setText(dim);

    me.symbols["RwySurface"].setText(me.SURFACE_TYPES[rwy_info.surface]);
    #me.symbols["RwyLighting"].setText(rwy_info.surface);
  },
  setZoom : func(zoom, label) {
    # Set the zoom level for the airport chart display
    me.AirportChart.setScreenRange(zoom);
    me.symbols["Zoom"].setText(label);
  },
  highlightElement : func(element) {
    var sym = me.symbols[element];
    sym.setDrawMode(canvas.Text.TEXT + canvas.Text.FILLEDBOUNDINGBOX);
    sym.setColorFill(fg1000.HIGHLIGHT_COLOR);
    sym.setColor(fg1000.HIGHLIGHT_TEXT_COLOR);
  },
  unhighlightElement : func(element) {
    var sym = me.symbols[element];
    sym.setDrawMode(canvas.Text.TEXT);
    sym.setColor(fg1000.NORMAL_TEXT_COLOR);
  },

};
