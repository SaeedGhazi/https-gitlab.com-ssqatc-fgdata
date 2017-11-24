# Traffic Map Options
var TrafficMapOptions =
{
  new : func() {
    var obj = { parents : [TrafficMapOptions] };
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

    me.Options.TFC = {
      ceiling_ft : 2700,  # Display targets up to this height above the aircraft
      floor_ft : 2700,    # Display target from this height below the aircraft
      display_id: 0,
    };
  },

  clearOptions : func() {
    me.Options = {};
  },

};
