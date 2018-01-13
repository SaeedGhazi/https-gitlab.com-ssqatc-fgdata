# Surround Controller
var SurroundController =
{
  new : func (page, svg)
  {
    var obj = {
      parents : [ SurroundController ],
      _recipient : nil,
      _page : page,
      _comselected : 1,
      _navselected : 1,
      _com1active  : 0.0,
      _com1standby : 0.0,
      _com2active  : 0.0,
      _com2standby : 0.0,
      _nav1active  : 0.0,
      _nav1standby : 0.0,
      _nav2active  : 0.0,
      _nav2standby : 0.0,
    };



    obj.RegisterWithEmesary();
    return obj;
  },

  del : func() {
    me.DeRegisterWithEmesary();
  },

  # Helper function to notify the Emesary bridge of a NavComData update.
  sendNavComDataNotification : func(data) {
    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notifications.PFDEventNotification.NavComData,
      data);

    me.transmitter.NotifyAll(notification);
  },

  handleNavComData : func(data) {

    # Store off particularly important data for control.
    if (data["CommSelected"] != nil) me._comselected = data["CommSelected"];
    if (data["NavSelected"] != nil)  me._navselected = data["NavSelected"];

    if (data["Comm1SelectedFreq"] != nil) me._com1active  = data["Comm1SelectedFreq"];
    if (data["Comm1StandbyFreq"] != nil)  me._com1standby = data["Comm1StandbyFreq"];
    if (data["Comm2SelectedFreq"] != nil) me._com2active  = data["Comm2SelectedFreq"];
    if (data["Comm2StandbyFreq"] != nil)  me._com2standby = data["Comm2StandbyFreq"];

    if (data["Nav1SelectedFreq"] != nil) me._nav1active  = data["Nav1SelectedFreq"];
    if (data["Nav1StandbyFreq"] != nil)  me._nav1standby = data["Nav1StandbyFreq"];
    if (data["Nav2SelectedFreq"] != nil) me._nav2active  = data["Nav2SelectedFreq"];
    if (data["Nav2StandbyFreq"] != nil)  me._nav2standby = data["Nav2StandbyFreq"];

    # pass through to the page
    me._page.handleNavComData(data);
    return emesary.Transmitter.ReceiptStatus_OK;
  },


  #
  # Handle the various COM and NAV controls at the top left and top right of the Fascia
  #
  handleNavVol : func (value) {
    var data={};

    if (me._navselected == 1) {
      data["Nav1Volume"] = value;
    } else {
      data["Nav2Volume"] = value;
    }

    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  handleNavVolToggle : func (value) {
    var data={};

    if (me._navselected == 1) {
      data["Nav1AudioID"] = value;
    } else {
      data["Nav1AudioID"] = value;
    }

    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Swap active and standby Nav frequencies.  Note that we don't update internal state here - we
  # instead pass updated NavComData notification data which will be picked up by the underlying
  # updaters to map to properties, and this controller itself.
  handleNavFreqTransfer : func (value)
  {
    var data={};

    if (me._navselected == 1) {
      data["Nav1SelectedFreq"] = me._nav1standby;
      data["Nav1StandbyFreq"] = me._nav1active;
    } else {
      data["Nav2SelectedFreq"] = me._nav2standby;
      data["Nav2StandbyFreq"] = me._nav2active;
    }

    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Outer Nav dial updates the integer portion of the selected standby
  # NAV frequency only, and wrap on limits - leaving the fractional part unchanged.
  handleNavOuter : func (value) {
    var incr_or_decr = (value > 0) ? 1000.0 : -1000.0;
    var data={};

    # Determine the new value, wrapping within the limits.
    var datakey = "";
    var freq = 0;
    var old_freq = 0;

    if (me._navselected == 1) {
      datakey = "Nav1StandbyFreq";
      old_freq = me._nav1standby;
    } else {
      datakey = "Nav2StandbyFreq";
      old_freq = me._nav2standby;
    }

    old_freq = math.round(old_freq * 1000);
    freq = old_freq + incr_or_decr;

    # Wrap if out of bounds
    if (freq > (fg1000.MAX_NAV_FREQ * 1000)) freq = freq - (fg1000.MAX_NAV_FREQ - fg1000.MIN_NAV_FREQ) * 1000;
    if (freq < (fg1000.MIN_NAV_FREQ * 1000)) freq = freq + (fg1000.MAX_NAV_FREQ - fg1000.MIN_NAV_FREQ) * 1000;

    # Convert back to a frequency to 3 decimal places.
    data[datakey] = sprintf("%.3f", freq/1000.0);
    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Inner Nav dial updates the fractional portion of the selected standby
  # NAV frequency only - leaving the integer part unchanged.  Even if it
  # increments past 0.975.
  handleNavInner  : func (value) {
    var incr_or_decr = (value > 0) ? 25 : -25;
    var data={};

    # Determine the new value, wrapping within the limits.
    var datakey = "";
    var freq = 0;
    var old_freq = 0;
    if (me._navselected == 1) {
      datakey = "Nav1StandbyFreq";
      old_freq = me._nav1standby;
    } else {
      datakey = "Nav2StandbyFreq";
      old_freq = me._nav2standby;
    }

    old_freq = math.round(old_freq * 1000);
    freq = old_freq + incr_or_decr;

    # Wrap on decimal by handling case where the integer part has changed
    if (int(old_freq/1000) < int(freq/1000)) freq = freq - 1000;
    if (int(old_freq/1000) > int(freq/1000)) freq = freq + 1000;

    data[datakey] = sprintf("%.3f", freq/1000.0);
    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Switch between Nav1 and Nav2.
  handleNavToggle : func (value)
  {
    var data={};

    if (me._navselected == 1) {
      data["NavSelected"] = 2;
    } else {
      data["NavSelected"] = 1;
    }

    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Outer COM dial changes the integer value of the standby selected COM
  # frequency, wrapping on limits.  Leaves the fractional part unchanged
  handleComOuter : func (value) {
    var incr_or_decr = (value > 0) ? 1000.0 : -1000.0;
    var data={};

    # Determine the new value, wrapping within the limits.
    var datakey = "";
    var freq = 0;
    var old_freq = 0;

    if (me._comselected == 1) {
      datakey = "Comm1StandbyFreq";
      old_freq = me._com1standby;
    } else {
      datakey = "Comm2StandbyFreq";
      old_freq = me._com2standby;
    }

    old_freq = math.round(old_freq * 1000);
    freq = old_freq + incr_or_decr;

    # Wrap if out of bounds
    if (freq > (fg1000.MAX_COM_FREQ * 1000)) freq = freq - (fg1000.MAX_COM_FREQ - fg1000.MIN_COM_FREQ) * 1000;
    if (freq < (fg1000.MIN_COM_FREQ * 1000)) freq = freq + (fg1000.MAX_COM_FREQ - fg1000.MIN_COM_FREQ) * 1000;

    # Convert back to a frequency to 3 decimal places.
    data[datakey] = sprintf("%.3f", freq/1000.0);
    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Inner COM dial changes the fractional part of the standby selected COM frequency,
  # wrapping on limits and leaving the integer part unchanged.
  handleComInner  : func (value) {
    var incr_or_decr = (value > 0) ? 1 : -1;
    var data={};

    var datakey = "";
    var freq = 0;
    var old_freq = 0;
    if (me._comselected == 1) {
      datakey = "Comm1StandbyFreq";
      old_freq = me._com1standby;
    } else {
      datakey = "Comm2StandbyFreq";
      old_freq = me._com2standby;
    }

    old_freq = math.round(old_freq * 1000);
    var integer_part = int(old_freq / 1000) * 1000;
    var fractional_part = old_freq - integer_part;

    # 8.33kHz frequencies are complicated - we need to do a lookup to find
    # the current and next frequencies
    var idx = 0;
    for (var i=0; i < size(fg1000.COM_833_SPACING); i = i + 1) {
      if (math.round(fg1000.COM_833_SPACING[i] * 1000) == fractional_part) {
        idx = i;
        break;
      }
    }

    idx = math.mod(idx + incr_or_decr, size(fg1000.COM_833_SPACING));
    freq = integer_part + fg1000.COM_833_SPACING[idx] * 1000;
    data[datakey] = sprintf("%.3f", freq/1000.0);
    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Switch between COM1 and COM2
  handleComToggle : func (value) {
    var data={};

    if (me._comselected == 1) {
      data["CommSelected"] = 2;
    } else {
      data["CommSelected"] = 1;
    }

    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Swap active and standby Com frequencies.  Note that we don't update internal state here - we
  # instead pass updated NavComData notification data which will be picked up by the underlying
  # updaters to map to properties, and this controller itself.
  handleComFreqTransfer : func (value) {
    var data={};

    if (me._comselected == 1) {
      data["Comm1SelectedFreq"] = me._com1standby;
      data["Comm1StandbyFreq"] = me._com1active;
    } else {
      data["Comm2SelectedFreq"] = me._com2standby;
      data["Comm2StandbyFreq"] = me._com2active;
    }

    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  # Auto-tunes the ACTIVE COM channel to 121.2 when pressed for 2 seconds
  handleComFreqTransferHold : func (value) {
    var data={};

    if (me._comselected == 1) {
      data["Comm1SelectedFreq"] = 121.00;
    } else {
      data["Comm2SelectedFreq"] = 121.00;
    }

    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  handleComVol : func (value) {
    var data={};

    if (me._comselected == 1) {
      data["Comm1Volume"] = value;
    } else {
      data["Comm2Volume"] = value;
    }

    me.sendNavComDataNotification(data);
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  handleComVolToggle : func (value) {
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

  # Used by other pages to set the current standby COM frequency by pressing ENT
  setStandbyComFreq : func(value) {
    var data={};

    if (value > fg1000.MAX_COM_FREQ) return;
    if (value < fg1000.MIN_COM_FREQ) return;

    if (me._comselected == 1) {
      data["Comm1StandbyFreq"] = value;
    } else {
      data["Comm2StandbyFreq"] = value;
    }

    me.sendNavComDataNotification(data);
  },

  # Used by other pages to set the current standby NAV frequency by pressing ENT
  setStandbyNavFreq : func(value) {
    var data={};

    if (value > fg1000.MAX_NAV_FREQ) return;
    if (value < fg1000.MIN_NAV_FREQ) return;

    if (me._navselected == 1) {
      data["Nav1StandbyFreq"] = value;
    } else {
      data["Nav2StandbyFreq"] = value;
    }

    me.sendNavComDataNotification(data);
  },
};
