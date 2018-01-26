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
    obj.current_zoom = 7;

    obj.setZoom(obj.current_zoom);

    obj._cursorElements = [
      obj.page.IDEntry,
      obj.page.VNVAltEntry,
      obj.page.VNVOffsetEntry,
      obj.page.CourseEntry,
      obj.page.Activate
    ];

    # -1 indicates nothing selected at present
    obj._selectedElement = -1;

    return obj;
  },

  setCursorElement : func(value) {

    if (me._selectedElement != -1) {
      # Unhighlight the current element, if one is highlighted
      me._cursorElements[me._selectedElement ].unhighlightElement();
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
  handleFMSInner : func(value) {
    if (me._selectedElement == -1) {
      # TODO: handle display of waypoint submenu on anti-clockwise initial rotation!
      # If no element is selected, then the inner FMS knob selects the ID field
      me.nextCursorElement(1);
    }

    me._cursorElements[me._selectedElement].incrSmall(value);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleFMSOuter : func(value) {
    if (me._selectedElement == -1) {
      # If no element is selected, then the Outer FMS knob has no effect
      return emesary.Transmitter.ReceiptStatus_Finished;
    }

    if (me._cursorElements[me._selectedElement].isInEdit()) {
      me._cursorElements[me._selectedElement].incrLarge(value);
    } else {
      me.nextCursorElement(value);
    }

    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleEnter : func(value) {
    if (me._selectedElement == -1) {
      # If no element is selected, then the ENT key has no effect
      return emesary.Transmitter.ReceiptStatus_Finished;
    }

    # If we're on the Activate button, then set up the DirectTo and hide the
    # page.  We're finished
    if (me._cursorElements[me._selectedElement] == me.page.Activate) {
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
      var destination = me.getDestination(me.page.IDEntry.getValue());
      if (destination != nil) {

        # set the course and distance to the destination if required
        var (course, dist) = courseAndDistance(destination);
        var d = {
          id: destination.id,
          name: destination.name,
          lat: destination.lat,
          lon: destination.lon,
          course : course,
          range_nm : dist,
        };
        me.page.displayDestination(d);
      }
    }

    # Determine where to highlight next.  In most cases, we go straight to ACTIVATE.
    # The exception is the VNV Alt field which goes to the VNV Distance field;
    if (me._cursorElements[me._selectedElement] == me.page.VNVAltEntry) {
      # VNV DIS entry is the next element
      me.nextCursorElement(1);
    } else {
      # ACTIVATE is the last element of the group
      me.setCursorElement(size(me._cursorElements) - 1);
    }

    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleClear : func(value) {
    var mappage = me._page.getMFD().getPage("NavigationMap");
    assert(mappage != nil, "Unable to find NavigationMap page");
    me._page.getDevice().selectPage(mappage);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  handleSoftKey : func(key) {
    # DirectTo has no softkeys, but if the user presses one from the underlying
    # page we should switch outselves off.
    me.page.setVisible(0);
    return emesary.Transmitter.ReceiptStatus_OK;
  },

  # Reset controller if required when the page is displayed or hidden
  ondisplay : func() {
    me.RegisterWithEmesary();
    for (var i = 0; i < size(me._cursorElements); i = i+1) {
      me._cursorElements[i].unhighlightElement();
    }

    me.setCursorElement(0);

    me.page.IDEntry.setValue("KHAF");

    var destination = me.getDestination(me.page.IDEntry.getValue());
    if (destination != nil) {

      # set the course and distance to the destination if required
      var (course, dist) = courseAndDistance(destination);
      var d = {
        id: destination.id,
        name: destination.name,
        lat: destination.lat,
        lon: destination.lon,
        course : course,
        range_nm : dist,
      };
      me.page.displayDestination(d);
    }


  },
  offdisplay : func() {
    me.DeRegisterWithEmesary();
  },

  getDestination : func(id) {
    # Use Emesary to get the destination
    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notifications.PFDEventNotification.NavData,
      {Id: "NavDataByID", Value: id});

    var response = me._transmitter.NotifyAll(notification);
    var retval = notification.EventParameter.Value;

    if ((! me._transmitter.IsFailed(response)) and (size(retval) > 0)) {
      return retval[0];
    } else {
      return nil;
    }
  },
};
