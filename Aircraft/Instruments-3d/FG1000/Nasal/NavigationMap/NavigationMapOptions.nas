# Navigation Map Options
var NavigationMapOptions =
{
  new : func() {
    var obj = { parents : [NavigationMapOptions] };
    obj.Options= {};
    obj.loadOptions();
    return obj;
  },

  getOption : func(type) {
    return me.Options[type];
  },

  setOption : func(type, name, value) {
    me.Options[type][name] = value;
  },

  loadOptions : func() {
    me.clearOptions();
    me.Options.APS = {};
  },

  clearOptions : func() {
    me.Options = {};
  },

};
