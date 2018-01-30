# DirectTo Controller
var DirectToController =
{
  # Vertical ranges, and labels.
  # Unlike some other map displays, we keep the range constant at 4nm an change
  # the ScreenRange to zoom in.  Otherwise as we zoom in, the center of the
  # runways moves out of the range of the display and they are not drawn.
  # Ranges are scaled to the display height with range 1 displaying 4nm vertically.
  # 2000nm = 12,152,000ft.
  RANGES : [{range: 500/6076.12, label: "500ft"},
            {range: 750/6076.12, label: "750ft"},
            {range: 1000/6076.12, label: "1000ft"},
            {range: 1500/6076.12, label: "1500ft"},
            {range: 2000/6076.12, label: "2000ft"},
            {range: 0.5, label: "0.5nm"},
            {range: 0.75, label: "0.75nm"},
            {range: 1, label: "1nm"},
            {range: 2, label: "2nm"},
            {range: 3, label: "3nm"},
            {range: 4, label: "4nm"},
            {range: 6, label: "6nm"},
            {range: 8, label: "8nm"},
            {range: 10, label: "10nm"},
            {range: 12, label: "12nm"},
            {range: 15, label: "15nm"},
            {range: 20, label: "20nm"},
            {range: 25, label: "25nm"},
            {range: 30, label: "30nm"},
            {range: 40, label: "40nm"},
            {range: 50, label: "50nm"},
            {range: 75, label: "75nm"},
            {range: 100, label: "100nm"},
            {range: 200, label: "200nm"},
            {range: 500, label: "500nm"},
            {range: 1000, label: "1000nm"},
            {range: 1500, label: "1500nm"},
            {range: 2000, label: "2000nm"}, ],

  new : func (page, svg)
  {
    var obj = { parents : [ DirectToController, MFDPageController.new(page)] };
    obj.id = "";
    obj.page = page;
    obj.current_zoom = 13;

    obj.setZoom(obj.current_zoom);

    obj._cursorElements = [
      obj.page.IDEntry,
      obj.page.VNVAltEntry,
      obj.page.VNVOffsetEntry,
      obj.page.CourseEntry,
      obj.page.Activate
    ];

    obj._activateIndex = size(obj._cursorElements) - 1;

    obj._selectedElement = 0;

    # Whether the WaypointSubmenuGroup is enabled
    obj._waypointSubmenuVisible = 0;

    return obj;
  },

  setCursorElement : func(value) {

    for (var i = 0; i < size(me._cursorElements); i = i+1) {
      me._cursorElements[i].unhighlightElement();
    }

    if (value < 0) value = 0;
    if (value > (size(me._cursorElements) -1)) value = size(me._cursorElements) -1;
    me._selectedElement = value;
    me._cursorElements[me._selectedElement].highlightElement();
  },

  nextCursorElement : func(value) {
    var incr_or_decr = (value > 0) ? 1 : -1;
    me.setCursorElement(me._selectedElement + incr_or_decr);
  },

  # Control functions for Input
  zoomIn : func() {
    me.setZoom(me.current_zoom -1);
  },
  zoomOut : func() {
    me.setZoom(me.current_zoom +1);
  },
  handleRange : func(val)
  {
    var incr_or_decr = (val > 0) ? 1 : -1;
    me.setZoom(me.current_zoom + incr_or_decr);
  },
  setZoom : func(zoom) {
    if ((zoom < 0) or (zoom > (size(me.RANGES) - 1))) return;
    me.current_zoom = zoom;
    me.page.setRange(me.RANGES[zoom].range, me.RANGES[zoom].label);
  },
  handleCRSR : func() {
    # No effect, but shouldn't be passed to underlying page?
    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  updateWaypointSubmenu : func() {
    var type = me.page.WaypointSubmenuSelect.getValue();

    var items = [];

    if (type == "FPL") {
      # Get the contents of the flightplan and display the list of waypoints.
      var fp = me.getNavData("Flightplan");

      for (var i = 0; i < fp.getPlanSize(); i = i + 1) {
        var wp = fp.getWP(i);
        if (wp.wp_name != nil) append(items, wp.wp_name);
      }
    }

    if (type == "NRST") {
      # Get the nearest airports
      var apts = me.getNavData("NearestAirports");

      for (var i = 0; i < size(apts); i = i + 1) {
        var apt = apts[i];
        if (apt.id != nil) append(items, apt.id);
      }
    }

    if (type == "RECENT") {
      # Get the set of recent waypoints
      items = me.getNavData("RecentWaypoints");
    }

    if (type == "USER") {
      items = me.getNavData("UserWaypoints");
    }

    if (type == "AIRWAY") {
      var fp  = me.getNavData("AirwayWaypoints");
      if (fp != nil) {
        for (var i = 0; i < fp.getPlanSize(); i = i + 1) {
          var wp = fp.getWP(i);
          if (wp.wp_name != nil) append(items, wp.wp_name);
        }
      }
    }

    if ((items != nil) and (size(items) > 0)) {
      # At this point we have a vector of waypoint names. We need to convert
      # this into a vector of { "WaypointSubmenuScroll" : [name] } hashes for consumption by the
      # list of waypoints
      var groupitems = [];
      foreach (var item; items) {
        append(groupitems, { "WaypointSubmenuScroll" : item } );
      }

      # Now display them!
      me.page.WaypointSubmenuScroll.setValues(groupitems);
    } else {
      # Nothing to display
      me.page.WaypointSubmenuScroll.setValues([]);
    }
  },

  getNavData : func(type, value=nil) {
    # Use Emesary to get a piece from the NavData system, using the provided
    # type and value;
    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notifications.PFDEventNotification.NavData,
      {Id: type, Value: value});

    var response = me._transmitter.NotifyAll(notification);

    if (! me._transmitter.IsFailed(response)) {
      return notification.EventParameter.Value;
    } else {
      return nil;
    }
  },

  setNavData : func(type, value=nil) {
    # Use Emesary to set a piece of data in the NavData system, using the provided
    # type and value;
    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notifications.PFDEventNotification.NavData,
      {Id: type, Value: value});

    var response = me._transmitter.NotifyAll(notification);

    if (me._transmitter.IsFailed(response)) {
      print("DirectToController.setNavData() : Failed to set Nav Data " ~ value);
      debug.dump(value);
    }
  },

  handleFMSInner : func(value) {

    if (me._waypointSubmenuVisible) {
      # We're in the Waypoint Submenu, in which case the inner FMS knob
      # selects between the different waypoint types.
      me.page.WaypointSubmenuSelect.highlightElement();
      me.page.WaypointSubmenuSelect.incrSmall(value);
      # Now update the Scroll group with the new type of waypoints
      me.updateWaypointSubmenu();
    } else if ((me._selectedElement == 0) and (! me.page.IDEntry.isInEdit()) and (value == -1)) {
      # The WaypointSubmenuGroup group is displayed if the small FMS knob is rotated
      # anti-clockwise as an initial rotation where the ID Entry is not being editted.
      me._cursorElements[0].unhighlightElement();

      me.page.WaypointSubmenuGroup.setVisible(1);
      me.page.WaypointSubmenuSelect.highlightElement();
      me._waypointSubmenuVisible = 1;
      me.updateWaypointSubmenu();
    } else {
      # We've already got something selected, and we're not in the
      # WaypointSubmenuGroup, so increment it.
      me._cursorElements[me._selectedElement].incrSmall(value);
    }

    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleFMSOuter : func(value) {
    if (me._waypointSubmenuVisible) {
      # We're in the Waypoint Submenu, in which case the outer FMS knob
      # selects between the different waypoints in the Waypoint Submenu.
      me.page.WaypointSubmenuSelect.unhighlightElement();
      me.page.WaypointSubmenuScroll.incrLarge(value);
    } else if (me._cursorElements[me._selectedElement].isInEdit()) {
      # If we're editing an element, then get on with it!
      me._cursorElements[me._selectedElement].incrLarge(value);
    } else {
      me.nextCursorElement(value);
    }

    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleEnter : func(value) {
    if (me._waypointSubmenuVisible) {
      # If we're in the Waypoint Submenu, then take whatever is highlighted
      # in the scroll list, load it and hide the Waypoint submenu
      var id = me.page.WaypointSubmenuScroll.getValue();
      if (id != nil) me.loadDestination(id);
      me.page.WaypointSubmenuGroup.setVisible(0);
      me._waypointSubmenuVisible = 0;

      # Select the activate ACTIVATE item.
      me.setCursorElement(me._activateIndex);
    } else {
      if (me._selectedElement == me._activateIndex) {
        # If we're on the Activate button, then set up the DirectTo and hide the
        # page.  We're finished
        var params = {};
        params.id = me.page.IDEntry.getValue();
        params.alt_ft = me.page.VNVAltEntry.getValue();
        params.offset_nm = me.page.VNVOffsetEntry.getValue();
        me.setNavData("SetDirectTo", params);

        var mappage = me._page.getMFD().getPage("NavigationMap");
        assert(mappage != nil, "Unable to find NavigationMap page");
        me._page.getDevice().selectPage(mappage);
        return emesary.Transmitter.ReceiptStatus_Finished;
      }

      # If we're editing an element, complete the data entry.
      if (me._cursorElements[me._selectedElement].isInEdit()) {
        me._cursorElements[me._selectedElement].enterElement();
      }

      if (me._cursorElements[me._selectedElement] == me.page.IDEntry) {
        # We've finished entering an ID, so load it.
        me.loadDestination(me.page.IDEntry.getValue());
      }

      # Determine where to highlight next.  In most cases, we go straight to ACTIVATE.
      # The exception is the VNV Alt field which goes to the VNV Distance field;
      if (me._cursorElements[me._selectedElement] == me.page.VNVAltEntry) {
        # VNV DIS entry is the next element
        me.nextCursorElement(1);
      } else {
        # ACTIVATE is the last element of the group
        me.setCursorElement(me._activateIndex);
      }
    }

    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleClear : func(value) {
    if (me._waypointSubmenuVisible) {
      # If we're in the Waypoint Submenu, then this clears it.
      me.page.WaypointSubmenuGroup.setVisible(0);
      me._waypointSubmenuVisible = 0;
    } else if (me._cursorElements[me._selectedElement].isInEdit()) {
      me._cursorElements[me._selectedElement].clearElement();
    } else {
      # Cancel the entire Direct To page, and go back to the Navigation Map.
      var mappage = me._page.getMFD().getPage("NavigationMap");
      assert(mappage != nil, "Unable to find NavigationMap page");
      me._page.getDevice().selectPage(mappage);
    }
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Reset controller if required when the page is displayed or hidden
  ondisplay : func() {
    me.RegisterWithEmesary();

    # Find the current DTO target, which may have been set by the page the
    # use was on.
    var id = me.getNavData("CurrentDTO");
    me.page.IDEntry.setValue(id);
    me.loadDestination(id);
    me.setCursorElement(0);
  },
  offdisplay : func() {
    me.DeRegisterWithEmesary();
  },

  loadDestination : func(id) {
    var d = {
      id: id,
      name: "",
      lat: 0,
      lon: 0,
      course : 0,
      range_nm : 0,
    };

    if ((id != nil) and size(id) > 1) {
      # Use Emesary to get the destination
      var notification = notifications.PFDEventNotification.new(
        "MFD",
        1,
        notifications.PFDEventNotification.NavData,
        {Id: "NavDataByID", Value: id});

      var response = me._transmitter.NotifyAll(notification);
      var retval = notification.EventParameter.Value;

      if ((! me._transmitter.IsFailed(response)) and (size(retval) > 0)) {
        var destination = retval[0];
        # set the course and distance to the destination if required

        # Some elements don't have names
        var name = destination.id;
        if (defined("destination.name")) name = destination.name;

        var point = { lat: destination.lat, lon: destination.lon };

        var (course, dist) = courseAndDistance(point);
        var d = {
          id: destination.id,
          name: name,
          lat: destination.lat,
          lon: destination.lon,
          course : course,
          range_nm : dist,
        };
      }
    }

    me.page.displayDestination(d);
  },
};
