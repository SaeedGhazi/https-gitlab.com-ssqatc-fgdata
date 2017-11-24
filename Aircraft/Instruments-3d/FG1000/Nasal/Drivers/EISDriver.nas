# FG1000 Engine Information Display Default Driver
#
# Driver values in the EIS.

var PropMap =
{
  new : func(name, property)
  {
    var obj = { parents : [ PropMap ] };
    obj._name = name;
    obj._val = 0;
    obj._prop = globals.props.getNode(property, 1);
    obj._val = obj._prop.getValue();
    return obj;
  },

  update : func()
  {
    me._val = me._prop.getValue();
  },

  getValue : func()
  {
    return me._val;
  }

};

var EISDriver =
{
  new : func()
  {
    var obj = { parents : [ EISDriver ] };

    # Hack to handle most aircraft not having proper engine hours
    setprop("/engines/engine[0]/hours", 157.0);

    obj._propmap = {
      "RPM" : PropMap.new("RPM", "/engines/engine[0]/rpm"),
      "MBusVolts" : PropMap.new("MBusVolts", "/systems/electrical/volts"),
      "EngineHours" : PropMap.new("EngineHours", "/engines/engine[0]/hours"),
      "FuelFlowGPH" : PropMap.new("FuelFlowGPH", "/engines/engine[0]/fuel-flow-gph"),
      "OilPressurePSI" : PropMap.new("OilPressurePSI", "/engines/engine[0]/oil-pressure-psi"),
      "OilTemperatureF" : PropMap.new("OilTemperatureF", "/engines/engine[0]/oil-temperature-degf"),
      "EGTNorm" : PropMap.new("EGTNorm", "/engines/engine[0]/egt-norm"),
      "VacuumSuctionInHG" : PropMap.new("VacuumSuctionInHG", "/systems/vacuum/suction-inhg"),

      "LeftFuelUSGal" : PropMap.new("LeftFuelUSGal", "/consumables/fuel/tank[0]/indicated-level-gal_us"),
      "RightFuelUSGal" : PropMap.new("RightFuelUSGal", "/consumables/fuel/tank[1]/indicated-level-gal_us"),


    };
    return obj;
  },

  getValue : func(name)
  {
    if (me._propmap[name] == nil) print("Unknown Driver Key in EISDriver.nas " ~ name);
    return me._propmap[name].getValue();
  },

  update: func () {

    foreach (var tp; keys(me._propmap)) {
      me._propmap[tp].update();
    }
  }
};
