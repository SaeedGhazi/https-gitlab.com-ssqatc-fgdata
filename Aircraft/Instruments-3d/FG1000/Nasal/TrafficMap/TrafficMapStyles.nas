# Traffic Map Styles
var TrafficMapStyles =
{
  new : func() {
    var obj = { parents : [ TrafficMapStyles ]};
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

    me.Styles.TFC = {};
    me.Styles.TFC.scale_factor = 1.0; # 40% (applied to whole group)

    me.Styles.APS = {};
    me.Styles.APS.scale_factor = 0.25;
  },

  clearStyles : func() {
    me.Styles = {};
  },

};
