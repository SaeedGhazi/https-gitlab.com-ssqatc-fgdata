# EIS Controller
var EISController =
{
  new : func (page, svg)
  {
    var obj = {
      parents : [ EISController ],
      _crsrToggle : 0,
      _recipient : nil,
      _page : page,
    };

    return obj;
  },


  # Function to handle the data provided from the EngineData Emesary Notification.
  # This implementation assumes a vector containing a single engine.
  handleEngineData : func (engineData) {
    assert(size(engineData) > 0, "handleEngineData expects vector of hash");
    var data = engineData[0];

    # Sanitize data
    var elements = [
      "RPM",
      "MBusVolts",
      "EngineHours",
      "FuelFlowGPH",
      "OilPressurePSI",
      "OilTemperatureF",
      "EGTNorm",
      "VacuumSuctionInHG",
      "LeftFuelUSGal",
      "RightFuelUSGal"];

    foreach (var val; elements) {
      if (data[val] == nil) data[val] = 0;
    }

    # Display it
    me._page.updateData(data);
    return emesary.Transmitter.ReceiptStatus_OK;
  },

  RegisterWithEmesary : func(transmitter = nil){
    if (transmitter == nil)
      transmitter = emesary.GlobalTransmitter;

    if (me._recipient == nil){
      me._recipient = emesary.Recipient.new("AirportInfoController_" ~ me._page.device.designation);
      var pfd_obj = me._page.device;
      var controller = me;
      me._recipient.Receive = func(notification)
      {
        if (notification.NotificationType == notifications.PFDEventNotification.DefaultType and
            notification.Event_Id == notifications.PFDEventNotification.EngineData and
            notification.EventParameter != nil)
        {
          return controller.handleEngineData(notification.EventParameter);
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
