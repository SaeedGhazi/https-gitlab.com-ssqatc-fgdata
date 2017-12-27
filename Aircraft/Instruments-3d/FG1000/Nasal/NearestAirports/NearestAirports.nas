# NearestAirports
var NearestAirports =
{
  new : func (mfd, myCanvas, device, svg)
  {
    var obj = {
      parents : [
        NearestAirports,
        MFDPage.new(mfd, myCanvas, device, svg, "NearestAirports", "NRST - NEAREST AIRPORTS")
      ],
    };

    obj.controller = fg1000.NearestAirportsController.new(obj, svg);

    # Dynamic elements.  There are 4 different sets of dynamic elements:
    #
    # Nearest Airports - this is a scrolling list of up to 25 airports within 200nm, shown 5 at a time.
    # Runways - just a single scroll element
    # Frequencies - 3 displayed in a scrolling list
    # Approaches - 3 displayed in a scrolling list
    #
    # Selection is via softkeys, the FMS knob, or via the page menu.

    obj.airportSelect = PFD.GroupElement.new(
      obj.pageName,
      svg,
      [ "Arrow", "ID", "CRS", "DST"],
      5,
      "Arrow",
      1
    );

    obj.runwaySelect = PFD.ScrollElement.new(obj.pageName, svg, "RunwayID", [36,18]); # Dummy values

    obj.freqSelect = PFD.GroupElement.new(
      obj.pageName,
      svg,
      ["FreqLabel", "Freq"],
      3,
      "Freq"
    );

    obj.approachSelect = PFD.GroupElement.new(
      obj.pageName,
      svg,
      ["Approach"],
      3,
      "Approach"
    );

    # Other dynamic text elements
    obj.addTextElements(["Name", "Alt", "RunwaySurface", "RunwayDimensions"]);

    var topMenu = func(device, pg, menuitem) {
      pg.clearMenu();
      pg.resetMenuColors(device);
      pg.addMenuItem(4, "APT", pg,
        func(dev, pg, mi) { pg.controller.selectAirports(); device.updateMenus(); }, # callback
        func(svg, mi) { pg.display_toggle(device, svg, mi, NearestAirportsController.UIGROUP.APT); }
      );

      pg.addMenuItem(5, "RNWY", pg,
        func(dev, pg, mi) { pg.controller.selectRunways(); device.updateMenus(); }, # callback
        func(svg, mi) { pg.display_toggle(device, svg, mi, NearestAirportsController.UIGROUP.RNWY); }
      );

      pg.addMenuItem(6, "FREQ", pg,
        func(dev, pg, mi) { pg.controller.selectFrequencies(); device.updateMenus(); }, # callback
        func(svg, mi) { pg.display_toggle(device, svg, mi, NearestAirportsController.UIGROUP.FREQ); }
      );

      pg.addMenuItem(7, "APR", pg,
        func(dev, pg, mi) { pg.controller.selectApproaches(); device.updateMenus(); }, # callback
        func(svg, mi) { pg.display_toggle(device, svg, mi, NearestAirportsController.UIGROUP.APR); }
      );

      device.updateMenus();
    };


    topMenu(device, obj, nil);

    return obj;
  },

  # Indicate which group is selected by colour of the softkeys
  display_toggle : func(device, svg, mi, group) {
    var bg_name = sprintf("SoftKey%d-bg",mi.menu_id);
    if (me.controller.getSelectedGroup() == group) {
      device.svg.getElementById(bg_name).setColorFill(0.5,0.5,0.5);
      svg.setColor(0.0,0.0,0.0);
    } else {
      device.svg.getElementById(bg_name).setColorFill(0.0,0.0,0.0);
      svg.setColor(1.0,1.0,1.0);
    }
    svg.setText(mi.title);
    svg.setVisible(1); # display function
  },

  # Function to highlight the APT softkey - used when CRSR is pressed to indicate
  # that we're editing the airports selection.
  selectAirports : func() {
    me.resetMenuColors(me.device);
    var bg_name = sprintf("SoftKey%d-bg",4);
    var tname = sprintf("SoftKey%d",4);
    me.device.svg.getElementById(bg_name).setColorFill(0.5,0.5,0.5);
    me.device.svg.getElementById(tname).setColor(0.0,0.0,0.0);
  },

  # Clear any cursor, highlights.  Used when exiting from CRSR mode
  resetCRSR : func() {
    me.runwaySelect.unhighlightElement();
    me.freqSelect.hideCRSR();
    me.approachSelect.hideCRSR();
    me.resetMenuColors(me.device);
  },

  # Function to undo any colors set by display_toggle when loading a new menu
  resetMenuColors : func(device) {
    for(var i = 0; i < 12; i +=1) {
      var name = sprintf("SoftKey%d",i);
      device.svg.getElementById(name ~ "-bg").setColorFill(0.0,0.0,0.0);
      device.svg.getElementById(name).setColor(1.0,1.0,1.0);
    }
  },

  offdisplay : func() {
    # The Nearest... pages use the underlying navigation map.
    me.mfd.NavigationMap.offdisplayPartial();

    # Reset the menu colours.  Shouldn't have to do this here, but
    # there's not currently an obvious other location to do so.
    me.resetMenuColors(me.device);

    me.controller.offdisplay();
  },
  ondisplay : func() {
    me.controller.ondisplay();

    # The Nearest... pages use the underlying navigation map.
    me.mfd.NavigationMap.ondisplayPartial();

    me.mfd.setPageTitle(me.title);

  },
  updateAirports : func(apts) {

    var airportlist = [];
    for (var i = 0; i < size(apts); i = i + 1) {
      var apt = apts[i];
      var crsAndDst = courseAndDistance(apt);
      var crs = sprintf("%i", crsAndDst[0]);
      var dst = sprintf("%.1fnm", crsAndDst[1]);

      # Convert into something we can pass straight to the UIGroup.
      append(airportlist, {
        Arrow : apt.id,
        ID: apt.id,
        CRS: crs,
        DST: dst,
      });
    }

    me.airportSelect.setValues(airportlist);

    if (size(airportlist) > 0) {
      me.updateAirportData(apts[0]);
      me.airportSelect.showCRSR();
    } else {
      me.airportSelect.hideCRSR();
      me.setTextElement("Name", "NONE WITHIN 200NM");
      me.setTextElement("Alt", "");
    }
  },
  updateAirportData : func(apt) {
    me.setTextElement("Name", apt.name);
    me.setTextElement("Alt", sprintf("%ift", M2FT * apt.elevation));

    var runwaylist = keys(apt.runways);

    if (size(runwaylist) > 0) {
      me.runwaySelect.setValues(runwaylist);
      me.updateRunwayInfo(apt.runways[runwaylist[0]]);
    } else {
      me.runwaySelect.setValues([""]);
      me.updateRunwayInfo(nil);
    }

    var freqarray = [];
    var apt_comms = apt.comms();
    if (size(apt_comms) > 0) {
      # Airport has one or more frequencies assigned to it.
      var freqs = {};
      foreach (var c; apt_comms) {
        freqs[c.ident] = sprintf("%.3f", c.frequency);;
      }

      foreach (var c; sort(keys(freqs), string.icmp)) {
        append(freqarray, {FreqLabel: c, Freq: freqs[c]});
      }
    }

    me.freqSelect.setValues(freqarray);

    # Approaches
    var approachList = apt.getApproachList();
    me.approachSelect.setValues(approachList);
  },
  updateRunwayInfo : func(rwy_info) {
    if (rwy_info != nil ) {
      var dim = sprintf("%ift x %ift", 3.28 * rwy_info.length, 3.28 * rwy_info.width);
      me.setTextElement("RunwayDimensions", dim);
      me.setTextElement("RunwaySurface", SURFACE_TYPES[rwy_info.surface]);
    } else {
      me.setTextElement("RunwayDimensions", "");
      me.setTextElement("RunwaySurface", "");
    }
  },
  getSelectedAirportID : func() {
    return me.airportSelect.getValue();
  },
  getSelectedRunway : func() {
    return me.runwaySelect.getValue();
  },
  getSelectedFreq : func() {
    return me.freqSelect.getValue();
  },
  getSelectedApproach : func() {
    return me.approachSelect.getValue();
  },
};
