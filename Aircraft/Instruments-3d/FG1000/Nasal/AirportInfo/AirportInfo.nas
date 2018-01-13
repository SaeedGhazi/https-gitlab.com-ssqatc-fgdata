# AirportInfo
var AirportInfo =
{
  new : func (mfd, myCanvas, device, svg)
  {
    var obj = {
      parents : [
        AirportInfo,
        MFDPage.new(mfd, myCanvas, device, svg, "AirportInfo", "WPT - AIRPORT INFORMATION")
      ],
      symbols : {},
    };

    obj.crsrIdx = 0;

    # Dynamic text elements in the SVG file.  In the SVG these have an "AirportInfo" prefix.
    textelements = [
      "Usage",
      "Name",
      "City",
      "Region",
      "Alt",
      "Lat",
      "Lon",
      "Fuel",
      "TZ",
      "RwyDimensions",
      "RwySurface",
      "RwyLighting",
      "Zoom"
    ];

    obj.addTextElements(textelements);

    # Data Entry information.  Keyed from the name of the element, which must
    # be one of the textelements above.  Each data element maps to a set of
    # text elements in the SVG of the form [PageName][TextElement]{0...n}, each
    # representing a single character for data entry.
    #
    # .size is the number of characters of data entry
    # .chars is the set of characters, used to scroll through using the small
    # FMS knob.
    obj.airportEntry = PFD.DataEntryElement.new(obj.pageName, svg, "ID", "", 4, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");

    # TODO: Implement search by name - not currently supported.
    # obj.airportNameEntry = PFD.DataEntryElement.new(obj.pageName, svg, "Name", ???, "ABCDEFGHIJKLMNOPQRSTUVWXYZ ");

    obj.runwaySelect = PFD.ScrollElement.new(obj.pageName, svg, "Runway", ["36","18"]); # Dummy values

    obj.freqSelect = PFD.GroupElement.new(
      obj.pageName,
      svg,
      ["FreqLabel", "Freq"],
      7,
      "Freq",
      0,
      "FreqScrollBar",
      "FreqScroll",
      150
    );

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

    obj.topMenu(device, obj, nil);

    return obj;
  },
  displayAirport : func(apt_info) {
    # Display a given airport
    me.AirportChart.getController().setPosition(apt_info.lat,apt_info.lon);
    me.airportEntry.setValue(apt_info.id);
    me.setTextElement("Usage", "PUBLIC");
    me.setTextElement("Name", string.uc(apt_info.name));
    me.setTextElement("City", "CITY");
    me.setTextElement("Region", "REGION");
    me.setTextElement("Alt", sprintf("%ift", M2FT * apt_info.elevation));

    if (apt_info.lat < 0.0) {
      me.setTextElement("Lat", sprintf("S %.4f", -apt_info.lat));
    } else {
      me.setTextElement("Lat", sprintf("N %.4f", apt_info.lat));
    }

    if (apt_info.lon < 0.0) {
      me.setTextElement("Lon", sprintf("W%3.4f", -apt_info.lon));
    } else {
      me.setTextElement("Lon", sprintf("E%3.4f", apt_info.lon));
    }

    me.setTextElement("Fuel", "AVGAS, AVTUR");
    me.setTextElement("TZ", "UTC-6");

    # Set up the runways list, but ignoring reciprocals so we don't get
    # runways displayed twice.
    var rwys = [];
    var recips = {};
    foreach(var rwy; sort(keys(apt_info.runways), string.icmp)) {
      var rwy_info = apt_info.runways[rwy];
      if (recips[rwy_info.id] == nil) {
        var lbl = rwy_info.id ~ "-" ~ rwy_info.reciprocal.id;
        append(rwys, lbl);
        recips[rwy_info.reciprocal.id] = 1;
      }
    }

    me.runwaySelect.setValues(rwys);
    if (size(rwys) > 0) {
      me.displayRunway(apt_info.runways[keys(apt_info.runways)[0]]);
    } else {
      me.displayRunway(nil);
    }

    # Display the comms frequencies for this airport
    var freqarray = [];

    if (size(apt_info.comms()) > 0) {
      # Airport has one or more frequencies assigned to it.
      var freqs = {};
      var comms = apt_info.comms();

      foreach (var c; comms) {
        freqs[c.ident] = sprintf("%.3f", c.frequency);;
      }

      foreach (var c; sort(keys(freqs), string.icmp)) {
        append(freqarray, {FreqLabel: c, Freq: freqs[c]});
      }
    }

    # Add any ILS frequencies as well
    foreach(var rwy; sort(keys(apt_info.runways), string.icmp)) {
      var rwy_info = apt_info.runways[rwy];
      if (rwy_info.ils_frequency_mhz != nil) {
        var label = "ILS " ~ rwy_info.id;
        var freq  = sprintf("%.3f", rwy_info.ils_frequency_mhz);
        append(freqarray, {FreqLabel: label, Freq: freq});
      }
    }

    me.freqSelect.setValues(freqarray);

  },
  displayRunway : func(rwy_info) {
    if (rwy_info == nil) {
      me.setTextElement("RwyDimensions", "");
      me.setTextElement("RwySurface", "");
    } else {
      var dim = sprintf("%ift x %ift", 3.28 * rwy_info.length, 3.28 * rwy_info.width);
      me.setTextElement("RwyDimensions", dim);

      me.setTextElement("RwySurface", SURFACE_TYPES[rwy_info.surface]);
      #me.setTextElement("RwyLighting", rwy_info.surface);
    }
  },
  setZoom : func(zoom, label) {
    # Set the zoom level for the airport chart display
    me.AirportChart.setScreenRange(zoom);
    me.setTextElement("Zoom", label);
  },

  # Clear any cursor, highlights.  Used when exiting from CRSR mode
  resetCRSR : func() {
    me.airportEntry.unhighlightElement();
    me.runwaySelect.unhighlightElement();
    me.freqSelect.hideCRSR();
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
  # Softkey menus
  topMenu : func(device, pg, menuitem) {
    pg.clearMenu();
    pg.resetMenuColors();
    device.updateMenus();
  },
};
