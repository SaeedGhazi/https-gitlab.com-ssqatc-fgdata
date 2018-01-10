# Generic PropertyPublisher classes for the FG1000 MFD using Emesary
# Publishes property values to Emesary for consumption by the MFD
#
#  Two variants:
#  - TriggeredPropertyPublisher which publishes based on listening to properties
#  - PeriodicPropertyPublisher which publishes on a periodic basis
#
#
#

var PropMap = {
  new : func(name, property)
  {
    var obj = { parents : [ PropMap ] };
    obj._name = name;
    obj._prop = globals.props.getNode(property, 1);
    return obj;
  },

  getName : func() { return me._name; },
  getPropPath : func() { return me._prop.getPath(); },
  getValue : func() { return me._prop.getValue(); },
  getProp: func() { return me._prop; },
};

var PeriodicPropertyPublisher =
{

  new : func (notification, frequency=0.25) {
    var obj = {
      parents : [ PeriodicPropertyPublisher ],
      _notification : notification,
      _frequency : frequency,
      _propmaps : [],
      _timer: nil,
    };

    obj._transmitter = emesary.GlobalTransmitter;
    obj._publishTimer = nil;

    return obj;
  },

  addPropMap : func(name, prop) {
    append(me._propmaps, PropMap.new(name, prop));
  },

  publish : func() {
    var data = {};

    foreach (var propmap; me._propmaps) {
      var name = propmap.getName();
      data[name] = propmap.getValue();
    }

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      me._notification,
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

var TriggeredPropertyPublisher =
{
  new : func (notification) {
    var obj = {
      parents : [ TriggeredPropertyPublisher ],
      _notification : notification,
      _propmaps : {},
      _listeners : [],
    };

    obj._transmitter = emesary.GlobalTransmitter;

    return obj;
  },

  addPropMap : func(name, prop) {
    me._propmaps[prop] = name;
  },

  publish : func(propNode) {
    var data = {};
    var name = me._propmaps[propNode.getPath()];
    assert(name != nil, "Unable to find property map for " ~ name);
    data[name] = propNode.getValue();

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      me._notification,
      data);

    me._transmitter.NotifyAll(notification);
  },

  start : func() {
    foreach (var prop; keys(me._propmaps)) {
      # Set up a listener triggering on create (to ensure all values are set at
      # start of day) and only on changed values.  These are the last two
      # arguments to the setlistener call.
      var listener = setlistener(prop, func(p) { me.publish(p); }, 1, 0);
      append(me._listeners, listener);
    }
  },

  stop : func() {
    foreach (var l; me._listeners)
      removelistener(l);
  },
};
