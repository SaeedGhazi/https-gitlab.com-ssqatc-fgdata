# Generic class to update properties from Emesary for the MFD
#
# In the simplest cases where the Emesary EventParameter for the specified
# Event ID is a hash whose values can be mapped directly to property values,
# it can be used directly.  For more complex cases, the handleNotificationEvent
# method should be over-ridden, and should return
# emesary.Transmitter.ReceiptStatus_OK or equivalent ReceiptStatus value.

var PropertyUpdater =
{

  PropMap : {
    new : func(name, property)
    {
      var obj = { parents : [ PropertyUpdater.PropMap ] };
      obj._name = name;
      obj._prop = globals.props.getNode(property, 1);
      return obj;
    },

    getName  : func() { return me._name; },
    getValue : func() { return me._prop.getValue(); },
  },

  new : func (device, notificationType, eventID, transmitter = nil) {
    var obj = {
      parents : [ Interface ],
      _device : device,
      _notificationType : notificationType,
      _transmitter : transmitter,
      _recipient : recipient,
      _propmaps : {},
    };

    if (obj._transmitter == nil) obj._transmitter = emesary.GlobalTransmitter;

    return obj;
  },

  addPropMap : func(name, prop) {
    me._propmaps[name] = PropertyPublisher.PropMap.new(name, prop);
  },

  handleNotificationEvent : func(eventParameter) {

    var retval = emesary.Transmitter.ReceiptStatus_NotProcessed;
    foreach(var name; keys(eventParameters)) {
      if (me._propmaps[name] != nil) {
        me._propmaps[name].setValue(eventParameters[name])
        retval = emesary.Transmitter.ReceiptStatus_OK;
      }
    }

    return retval;
  },

  RegisterWithEmesary : func(){

    if (me._recipient == nil){
      me._recipient = emesary.Recipient.new("PropertyUpdater_" ~ me._page.device.designation);
      var pfd_obj = me._device;
      var controller = me;
      me._recipient.Receive = func(notification)
      {
        if (notification.Device_Id == pfd_obj.device_id
            and notification.NotificationType == me._notificationType) {
          if (notification.Event_Id == me._eventID
              and notification.EventParameter != nil)
          {
            return me.handleNotificationEvent(notification.EventParameter);
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

  start : func() {
    me.RegisterWithEmesary();
  },
  stop : func() {
    me.DeRegisterWithEmesary();
  },

};
