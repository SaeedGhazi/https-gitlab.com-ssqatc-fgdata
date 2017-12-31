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

    obj.cursorElements = [
      obj.airportEntry,
#      obj.getTextElement("Name"),
      obj.runwaySelect,
      obj.getTextElement("Freq1"),
      obj.getTextElement("Freq2"),
      obj.getTextElement("Freq3"),
      obj.getTextElement("Freq4"),
      obj.getTextElement("Freq5"),
      obj.getTextElement("Freq6"),
      obj.getTextElement("Freq7"),
      obj.getTextElement("Freq8")
    ];

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
    var fcount = 1;

    if (size(apt_info.comms()) > 0) {
      # Airport has one or more frequencies assigned to it.
      var freqs = {};
      var comms = apt_info.comms();

      foreach (var c; comms) {
        freqs[c.ident] = sprintf("%.3f", c.frequency);;
      }

      foreach (var c; sort(keys(freqs), string.icmp)) {
        me.setTextElement("FreqLabel" ~ fcount, c);
        me.setTextElement("Freq" ~ fcount, freqs[c]);
        fcount += 1;
      }
    }

    while (fcount < 9) {
      # zero remaining comms channels
      me.setTextElement("FreqLabel" ~ fcount, "");
      me.setTextElement("Freq" ~ fcount, "");
      fcount += 1;
    }
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
  moveCRSR : func(val) {
    var incr_or_decr = (val > 0) ? 1 : -1;

    if (me.cursorElements[me.crsrIdx].isInEdit()) {
      # We're editing an element, so let the element handle the movement itself
      me.cursorElements[me.crsrIdx].incrLarge(val);
    } else {
      # We're not currently editing an element, so move to the next cursor position.
      me.cursorElements[me.crsrIdx].unhighlightElement();
      print("Old cursor index " ~ me.crsrIdx);
      me.crsrIdx = math.mod(me.crsrIdx + incr_or_decr, size(me.cursorElements));

      while ((me.cursorElements[me.crsrIdx].getValue() == nil) or
             (me.cursorElements[me.crsrIdx].getValue() == "" )) {
        # Handle case where we have blank frequencies by skipping them.
        me.crsrIdx = math.mod(me.crsrIdx + incr_or_decr, size(me.cursorElements));
      }

      print("New cursor index " ~ me.crsrIdx ~ " " ~ size(me.cursorElements));
      me.cursorElements[me.crsrIdx].highlightElement();
    }
  },
  incrSmall : func(val) {
    me.cursorElements[me.crsrIdx].incrSmall(val);
    var ret = {};
    ret.name  = me.cursorElements[me.crsrIdx].getName();
    ret.value = me.cursorElements[me.crsrIdx].getValue();
    return ret;
  },
  handleEnter : func() {
    me.cursorElements[me.crsrIdx].enterElement();
    var ret = {};
    ret.name  = me.cursorElements[me.crsrIdx].getName();
    ret.value = me.cursorElements[me.crsrIdx].getValue();
    return ret;
  },
  handleClear : func() {
    me.cursorElements[me.crsrIdx].clearElement();
  },
  showCRSR : func() {
    me.cursorElements[me.crsrIdx].highlightElement();
  },
  hideCRSR : func() {
    me.cursorElements[me.crsrIdx].unhighlightElement();
    me.crsrIdx = 0;
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
