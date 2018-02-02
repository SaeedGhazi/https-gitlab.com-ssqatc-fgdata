# NearestNDB
var NearestNDB =
{
  new : func (mfd, myCanvas, device, svg)
  {
    var obj = {
      parents : [
        NearestNDB,
        MFDPage.new(mfd, myCanvas, device, svg, "NearestNDB", "NRST - NEAREST NDB")
      ],
    };

    obj.setController(fg1000.NearestNDBController.new(obj, svg));

    # Dynamic elements.  There is a single dynamic element containing the list of
    # the 25 nearest intersections.
    obj.select = PFD.GroupElement.new(
      obj.pageName,
      svg,
      [ "Arrow", "ID", "CRS", "DST"],
      11,
      "Arrow",
      1,
      "ScrollTrough",
      "ScrollThumb",
      250 - 116
    );

    # Other dynamic text elements
    obj.addTextElements(["Lat", "Lon", "Name", "Freq"]);

    obj.topMenu(device, obj, nil);

    return obj;
  },

  # Indicate which group is selected by colour of the softkeys
  display_toggle : func(device, svg, mi, group) {
    var bg_name = sprintf("SoftKey%d-bg",mi.menu_id);
    if (me.getController().getSelectedGroup() == group) {
      device.svg.getElementById(bg_name).setColorFill(0.5,0.5,0.5);
      svg.setColor(0.0,0.0,0.0);
    } else {
      device.svg.getElementById(bg_name).setColorFill(0.0,0.0,0.0);
      svg.setColor(1.0,1.0,1.0);
    }
    svg.setText(mi.title);
    svg.setVisible(1); # display function
  },

  showCRSR : func() {
    me.select.showCRSR();
  },

  hideCRSR : func() {
    me.select.hideCRSR();
  },

  offdisplay : func() {
    # The Nearest... pages use the underlying navigation map.
    me.mfd.NavigationMap.offdisplayPartial();

    # Reset the menu colours.  Shouldn't have to do this here, but
    # there's not currently an obvious other location to do so.
    me.resetMenuColors();

    me.getController().offdisplay();
  },
  ondisplay : func() {
    me.getController().ondisplay();

    # The Nearest... pages use the underlying navigation map.
    me.mfd.NavigationMap.ondisplayPartial();

    me.mfd.setPageTitle(me.title);
  },
  updateNavData : func(navdata) {

    if ((navdata == nil) or (size(navdata) == 0)) return;

    var navDataList = [];
    for (var i = 0; i < size(navdata); i = i + 1) {
      var nav = navdata[i];
      var crsAndDst = courseAndDistance(nav);

      # Display the course and distance in NM .
      # 248 is the extended ASCII code for the degree symbol
      var crs = sprintf("%i%c", crsAndDst[0], 248);
      var dst = sprintf("%.1fnm", crsAndDst[1]);

      # Convert into something we can pass straight to the UIGroup.
      append(navDataList, {
        Arrow : nav.id,
        ID: nav.id,
        CRS: crs,
        DST: dst,
      });
    }

    me.select.setValues(navDataList);

    if (size(navDataList) > 0) {
      me.updateNavDataItem(navdata[0]);
    } else {
      me.setTextElement("Name", "NONE WITHIN 200NM");
      me.setTextElement("Lon", "");
      me.setTextElement("Lat", "");
      me.setTextElement("Frequency", "");
    }
  },
  updateNavDataItem : func(nav) {

    if (nav == nil) return;

    if (nav.lat < 0.0) {
      me.setTextElement("Lat", sprintf("S %.4f", -nav.lat));
    } else {
      me.setTextElement("Lat", sprintf("N %.4f", nav.lat));
    }

    if (nav.lon < 0.0) {
      me.setTextElement("Lon", sprintf("W%3.4f", -nav.lon));
    } else {
      me.setTextElement("Lon", sprintf("E%3.4f", nav.lon));
    }

    me.setTextElement("Freq", sprintf("%.2f", nav.frequency / 100.0));
    me.setTextElement("Name", nav.name);

    # Display the DTO line to the airport
    me.mfd.NavigationMap.getController().setDTOLineTarget(nav.lat, nav.lon);
  },

  topMenu : func(device, pg, menuitem) {
    pg.clearMenu();
    pg.resetMenuColors();
    pg.addMenuItem(0, "ENGINE", pg.mfd.EIS, pg.mfd.EIS.engineMenu);
    pg.addMenuItem(2, "MAP", pg.mfd.NavigationMap, pg.mfd.NavigationMap.mapMenu);

    device.updateMenus();
  },
};
