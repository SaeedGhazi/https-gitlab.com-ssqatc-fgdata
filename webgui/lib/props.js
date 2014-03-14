var PropertyChangeListenerObjects = {
  _ws : null,
  _listeners : new Array()
};

var PropertyChangeListener = function(callback) {
  PropertyChangeListenerObjects._ws = new WebSocket('ws://' + location.host + '/PropertyListener');
  PropertyChangeListenerObjects._ws.onopen = callback;
  PropertyChangeListenerObjects._ws.onclose = function(ev) {
    alert('Lost connection to FlightGear. Please reload this page and/or restart FlightGear.');
    PropertyChangeListenerObjects._ws = null;
  };
  PropertyChangeListenerObjects._ws.onerror = function(ev) {
    alert('Error communicating with FlightGear. Please reload this page and/or restart FlightGear.');
    PropertyChangeListenerObjects._ws = null;
  };
  PropertyChangeListenerObjects._ws.onmessage = function(ev) {
    try {
      var node = JSON.parse(ev.data);
      var cb = PropertyChangeListenerObjects._listeners[node.path];
      for (var i = 0; i < cb.length; i++)
        cb[i](node);
    } catch (e) {
    }
  };
};

var SetListener = function(path, callback) {
  var o = PropertyChangeListenerObjects._listeners[path];
  if (typeof (o) == 'undefined') {
    o = new Array();
    PropertyChangeListenerObjects._listeners[path] = o;
    PropertyChangeListenerObjects._ws.send(JSON.stringify({
      command : 'addListener',
      node : path
    }));
  }
  o.push(callback);
};
