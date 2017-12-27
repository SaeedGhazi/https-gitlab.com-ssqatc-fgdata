# AirportInfo Controller
var AirportInfoController =
{
  # Vertical ranges, and labels.
  # Unlike some other map displays, we keep the range constant at 4nm an change
  # the ScreenRange to zoom in.  Otherwise as we zoom in, the center of the
  # runways moves out of the range of the display and they are not drawn.
  # Ranges are scaled to the display height with range 1 displaying 4nm vertically.
  # 2000nm = 12,152,000ft.
  RANGES : [{range: 4/500/6076.12, label: "500ft"},
            {range: 4/750/6076.12, label: "750ft"},
            {range: 4/1000/6076.12, label: "1000ft"},
            {range: 4/1500/6076.12, label: "1500ft"},
            {range: 4/2000/6076.12, label: "2000ft"},
            {range: 8, label: "0.5nm"},
            {range: 5.33, label: "0.75nm"},
            {range: 4, label: "1nm"},
            {range: 2, label: "2nm"},
            {range: 1.33, label: "3nm"},
            {range: 1, label: "4nm"},
            {range: 0.66, label: "6nm"},
            {range: 0.5, label: "8nm"},
            {range: 0.4, label: "10nm"} ],

  new : func (page, svg)
  {
    var obj = { parents : [ AirportInfoController ] };
    obj.airport = "";
    obj.runway = "";
    obj.runwayIdx = -1;
    obj.info = nil;
    obj.page = page;
    obj.crsrToggle = 0;
    obj.current_zoom = 7;

    # Emesary
    obj._recipient = nil;

    # Initial airport is our current location.
    var current_apt = airportinfo("airport");
    obj.setAirport(current_apt.id);
    obj.setZoom(7);

    return obj;
  },
  setAirport : func(id)
  {
    if (id == me.airport) return;
    var apt = airportinfo(id);

    if (apt != nil)  {
      me.airport = id;
      me.info= airportinfo(id);
    }

    # Reset airport display.  We do this irrespective of whether the id
    # is valid, as it allows us to clear any bad user input from the ID field
    me.page.displayAirport(me.info);
  },
  setRunway : func(runwayID)
  {
    me.page.displayRunway(me.info.runways[runwayID]);
  },

  # Control functions for Input
  zoomIn : func() {
    me.setZoom(me.current_zoom -1);
  },
  zoomOut : func() {
    me.setZoom(me.current_zoom +1);
  },
  zoom : func(val)
  {
    var incr_or_decr = (val > 0) ? 1 : -1;
    me.setZoom(me.current_zoom + incr_or_decr);
  },
  setZoom : func(zoom) {
    if ((zoom < 0) or (zoom > (size(me.RANGES) - 1))) return;
    me.current_zoom = zoom;
    me.page.setZoom(me.RANGES[zoom].range * fg1000.MAP_PARTIAL.HEIGHT, me.RANGES[zoom].label);
  },
  handleCRSR : func() {
    me.crsrToggle = (! me.crsrToggle);
    if (me.crsrToggle) {
      me.page.showCRSR();
    } else {
      me.page.hideCRSR();
    }
    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleFMSInner : func(value) {
    if (me.crsrToggle == 1) {
      var select = me.page.incrSmall(value);
      if ((select.name == "AirportInfoRunway") and (select.value != nil)) {
        # Selection values are of the form "06L-12R".  We need to set the
        # runway to the left half.
        var idx = find("-", select.value);
        if (idx != -1) {
          var rwy = substr(select.value, 0, idx);
          me.setRunway(rwy);
        }
      }

      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return me.page.mfd._pageGroupController.handleFMSInner(value);
    }
  },
  handleFMSOuter : func(value) {
    if (me.crsrToggle == 1) {
      me.page.moveCRSR(value);
      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return me.page.mfd._pageGroupController.handleFMSOuter(value);
    }
  },
  handleEnter : func(value) {
    if (me.crsrToggle == 1) {
      var select = me.page.handleEnter();
      if (select.name == "AirportInfoID") me.setAirport(select.value);
      if (substr(select.name, 0, 15) == "AirportInfoFreq") print("Enter pressed on frequency " ~ select.value);

      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return emesary.Transmitter.ReceiptStatus_NotProcessed;
    }
  },
  handleClear : func(value) {
    if (me.crsrToggle == 1) {
      # Cancel any data entry
      me.page.handleClear();
    } else {
      return emesary.Transmitter.ReceiptStatus_NotProcessed;
    }
  },
  RegisterWithEmesary : func(transmitter = nil){
    if (transmitter == nil)
      transmitter = emesary.GlobalTransmitter;

    if (me._recipient == nil){
      me._recipient = emesary.Recipient.new("AirportInfoController_" ~ me.page.device.designation);
      var pfd_obj = me.page.device;
      var controller = me;
      me._recipient.Receive = func(notification)
      {
        if (notification.Device_Id == pfd_obj.device_id
            and notification.NotificationType == notifications.PFDEventNotification.DefaultType) {
          if (notification.Event_Id == notifications.PFDEventNotification.HardKeyPushed
              and notification.EventParameter != nil)
          {
            var id = notification.EventParameter.Id;
            var value = notification.EventParameter.Value;
            #printf("Button pressed " ~ id ~ " " ~ value);
            if (id == fg1000.FASCIA.FMS_CRSR)   return controller.handleCRSR();
            if (id == fg1000.FASCIA.FMS_OUTER)  return controller.handleFMSOuter(value);
            if (id == fg1000.FASCIA.FMS_INNER)  return controller.handleFMSInner(value);
            if (id == fg1000.FASCIA.RANGE)      return controller.zoom(value);
            if (id == fg1000.FASCIA.ENT)        return controller.handleEnter(value);
            if (id == fg1000.FASCIA.CLR)        return controller.handleClear(value);
          }
        }
        return emesary.Transmitter.ReceiptStatus_NotProcessed;
      };
    }
    transmitter.Register(me._recipient);
    me.transmitter = transmitter;
  },
  DeRegisterWithEmesary : func(transmitter = nil){
      # remove registration from transmitter; but keep the recipient once it is created.
      if (me.transmitter != nil)
        me.transmitter.DeRegister(me._recipient);
      me.transmitter = nil;
  },

  # Reset controller if required when the page is displayed or hidden
  ondisplay : func() {
    me.RegisterWithEmesary();
  },
  offdisplay : func() {
    me.DeRegisterWithEmesary();
  },
};
