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

  CRSR_ELEMENTS : [
    "ID",
    "Name",
    "Runway",
    "Freq1",
    "Freq2",
    "Freq3",
    "Freq4",
    "Freq5",
    "Freq6",
    "Freq7",
    "Freq8",
  ],

  new : func (page, svg)
  {
    var obj = { parents : [ AirportInfoController ] };
    obj.airport = "";
    obj.runway = "";
    obj.runway_index = -1;
    obj.info = nil;
    obj.page = page;
    obj.crsr_toggle = 0;
    obj.crsrIdx = 0;
    obj.current_zoom = 7;
    obj.current_id_entry = "";


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
    me.airport = id;
    me.info= airportinfo(id);
    me.page.displayAirport(me.info);

    # Display the first runway.
    me.setRunway(0);
  },
  setRunway : func(runway_index)
  {
    if (runway_index == me.runway_index) return;
    var rwys = keys(me.info.runways);
    if (runway_index < 0) runway_index = 0;
    if (runway_index > (size(rwys) - 1)) runway_index = size(rwys) - 1;
    me.runway_index = runway_index;
    me.page.displayRunway(me.info.runways[rwys[runway_index]]);
  },
  incrRunway : func(value)
  {
    var incr_or_decr = (value > 0) ? 1 : -1;
    me.setRunway(me.runway_index + incr_or_decr);
  },

  # Control functions for Input
  incrAirportID : func(value)
  {
    var incr_or_decr = (value > 0) ? 1 : -1;
    if (me.current_id_entry == "") {
      me.current_id_entry = "A";
    } else {
      var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      var fixed = substr(me.current_id_entry, 0, size(current_id_entry) - 2);
      var lastchar = substr(me.current_id_entry, -1);
      var char = math.mod(find(lastchar, alphabet) + incr_or_decr, 26);
      var nextchar = substr(alphabet, char, 1);
      me.current_id_entry = fixed + nextchar;
    }
  },


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
  showCRSR : func() {
    me.page.highlightElement(me.CRSR_ELEMENTS[me.crsrIdx]);
  },
  hideCRSR : func() {
    me.page.unhighlightElement(me.CRSR_ELEMENTS[me.crsrIdx]);
    me.crsrIdx = 0;
  },
  moveCRSR : func(val) {
    var incr_or_decr = (val > 0) ? 1 : -1;

    me.page.unhighlightElement(me.CRSR_ELEMENTS[me.crsrIdx]);
    me.crsrIdx = math.mod(me.crsrIdx + incr_or_decr, size(me.CRSR_ELEMENTS) -1);
    me.page.highlightElement(me.CRSR_ELEMENTS[me.crsrIdx]);
  },
  handleCRSR : func() {
    me.crsr_toggle = (! me.crsr_toggle);
    print("CRSR pressed " ~ me.crsr_toggle);
    if (me.crsr_toggle) {
      me.showCRSR();
    } else {
      me.hideCRSR();
    }
    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleFMSInner : func(value) {
    if (me.crsr_toggle == 1) {
      print("FMSInner for AirportInfoController called " ~ me.crsr_toggle);
      if (me.CRSR_ELEMENTS[me.crsrIdx] == "Runway") {
        me.incrRunway(value);
      }
      if (me.CRSR_ELEMENTS[me.crsrIdx] == "ID") {
        me.incrAirportID(value);
      }
      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return me.page.mfd._pageGroupController.handleFMSInner(value);
    }
  },
  handleFMSOuter : func(value) {
    if (me.crsr_toggle == 1) {
      print("FMSOuter for AirportInfoController called " ~ me.crsr_toggle);
      me.moveCRSR(value);
      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return me.page.mfd._pageGroupController.handleFMSOuter(value);
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
            if (id == fg1000.MFD.FASCIA.FMS_CRSR)   return controller.handleCRSR();
            if (id == fg1000.MFD.FASCIA.FMS_OUTER)  return controller.handleFMSOuter(value);
            if (id == fg1000.MFD.FASCIA.FMS_INNER)  return controller.handleFMSInner(value);
            if (id == fg1000.MFD.FASCIA.RANGE)      return controller.zoom(value);
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
