var PropertyChangeListenerObjects = {
  _ws: null,
  _listeners: new Array()
};

var PropertyChangeListener = function( callback ) {
  PropertyChangeListenerObjects._ws = new WebSocket('ws://' + location.host + '/PropertyListener');
  PropertyChangeListenerObjects._ws.onopen = callback;
  PropertyChangeListenerObjects._ws.onclose = function(ev) {
    console.log("websocket closed");
    PropertyChangeListenerObjects._ws = null;
  };
  PropertyChangeListenerObjects._ws.onmessage = function(ev) {
//    console.log("websocket message:" + ev.data);
    try {
      var node = JSON.parse(ev.data);
      var cb = PropertyChangeListenerObjects._listeners[node.path];
      for( var i = 0; i < cb.length; i++ )
        cb[i](node);
    } catch (e) {
    }
  };
};

var SetListener = function( path, callback ) {
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

