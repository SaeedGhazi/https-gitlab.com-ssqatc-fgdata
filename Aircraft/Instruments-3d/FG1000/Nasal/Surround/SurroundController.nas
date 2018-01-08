# Surround Controller
var SurroundController =
{
  new : func (page, svg)
  {
    var obj = {
      parents : [ SurroundController ],
      _recipient : nil,
      _page : page,
    };

    obj.RegisterWithEmesary();
    return obj;
  },

  del : func() {
    me.DeRegisterWithEmesary();
  },

  handleNavComData : func(values) {
    # pass straight through the to page - we have nothing to do.
    me._page.handleNavComData(values);
    return emesary.Transmitter.ReceiptStatus_OK;
  },

  # These methods are slightly unusual in that they are called by other
  # controllers when the CRSR is not active.  Hence they aren't referenced
  # in the RegisterWithEmesary call below.
  #
  handleFMSOuter : func(val)
  {
    if (me._page.isMenuVisible()) {
      # Change page group
      me._page.incrPageGroup(val);
    }
    me._page.showMenu();
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  handleFMSInner : func(val)
  {
    if (me._page.isMenuVisible()) {
      # Change page group
      me._page.incrPage(val);
    }
    me._page.showMenu();
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  RegisterWithEmesary : func(transmitter = nil){
    if (transmitter == nil)
      transmitter = emesary.GlobalTransmitter;

    if (me._recipient == nil){
      me._recipient = emesary.Recipient.new("PageGroupController_" ~ me._page.device.designation);
      var pfd_obj = me._page.device;
      var controller = me;
      me._recipient.Receive = func(notification)
      {
        if (notification.Device_Id == pfd_obj.device_id
            and notification.NotificationType == notifications.PFDEventNotification.DefaultType) {
          if (notification.Event_Id == notifications.PFDEventNotification.NavComData
              and notification.EventParameter != nil)
          {
            return controller.handleNavComData(notification.EventParameter);
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

};
