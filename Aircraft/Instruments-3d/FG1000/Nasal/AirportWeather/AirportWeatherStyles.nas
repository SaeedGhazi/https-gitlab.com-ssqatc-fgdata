# AirportWeather Styles
var AirportWeatherStyles =
{
  new : func() {
    var obj = { parents : [ AirportWeatherStyles ]};
    obj.Styles = {};
    obj.loadStyles();
    return obj;
  },

  getStyle : func(type) {
    return me.Styles[type];
  },

  setStyle : func(type, name, value) {
    me.Styles[type][name] = value;
  },

  loadStyles : func() {
    me. clearStyles();
    me.Styles.XXX = {};
  },

  clearStyles : func() {
    me.Styles = {};
  },

};
