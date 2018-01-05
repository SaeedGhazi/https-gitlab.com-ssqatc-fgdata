# Generic PropertyPublisher class for the FG1000 MFD using Emesary
# Publishes property values to Emesary for consumption by the MFD

var PropertyPublisher =
{

  PropMap : {
    new : func(name, property)
    {
      var obj = { parents : [ PropertyPublisher.PropMap ] };
      obj._name = name;
      obj._prop = globals.props.getNode(property, 1);
      return obj;
    },

    getName : func() { return me._name; },
    getValue : func() { return me._prop.getValue(); },
  },

  new : func (frequency=0.25, transmitter = nil) {
    var obj = {
      parents : [ PropertyPublisher ],
      _transmitter : transmitter,
      _frequency : frequency,
      _propmaps : [],
    };

    if (obj._transmitter == nil) obj._transmitter = emesary.GlobalTransmitter;

    obj._publishTimer = nil;

    return obj;
  },

  addPropMap : func(name, prop) {
    append(me._propmaps, PropertyPublisher.PropMap.new(name, prop));
  },

  publish : func() {
  },

  notify : func(notification, data) {
    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notification,
      data);

    me._transmitter.NotifyAll(notification);
  },

  start : func() {
    me._timer = maketimer(me._frequency, me, me.publish);
    me._timer.start();
  },
  stop : func() {
    if(me._timer != nil) me._timer.stop();
    me._timer = nil;
  },
};
