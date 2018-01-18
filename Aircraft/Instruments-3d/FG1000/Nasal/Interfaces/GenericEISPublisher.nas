# EIS Driver using Emesary for a single engined aircraft, e.g. Cessna 172.
var GenericEISPublisher =
{

  new : func (frequency=0.25) {
    var obj = {
      parents : [
        GenericEISPublisher,
        PeriodicPropertyPublisher.new(notifications.PFDEventNotification.EngineData, frequency)
      ],
    };

    # Hack to handle most aircraft not having proper engine hours
    if (getprop("/engines/engine[0]/hours") == nil) setprop("/engines/engine[0]/hours", 157.0);

    obj.addPropMap("RPM", "/engines/engine[0]/rpm");
    obj.addPropMap("MBusVolts", "/systems/electrical/volts");
    obj.addPropMap("EngineHours", "/engines/engine[0]/hours");
    obj.addPropMap("FuelFlowGPH", "/engines/engine[0]/fuel-flow-gph");
    obj.addPropMap("OilPressurePSI", "/engines/engine[0]/oil-pressure-psi");
    obj.addPropMap("OilTemperatureF", "/engines/engine[0]/oil-temperature-degf");
    obj.addPropMap("EGTNorm", "/engines/engine[0]/egt-norm");
    obj.addPropMap("VacuumSuctionInHG", "/systems/vacuum/suction-inhg");

    obj.addPropMap("LeftFuelUSGal", "/consumables/fuel/tank[0]/indicated-level-gal_us");
    obj.addPropMap("RightFuelUSGal", "/consumables/fuel/tank[1]/indicated-level-gal_us");

    return obj;
  },

  # Custom publish method as we package the values into an array of engines,
  # in this case, only one!
  publish : func() {
    var engineData0 = {};

    foreach (var propmap; me._propmaps) {
      var name = propmap.getName();
      engineData0[name] = propmap.getValue();
    }

    var engineData = [];
    append(engineData, engineData0);

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notifications.PFDEventNotification.EngineData,
      engineData);

    me._transmitter.NotifyAll(notification);
  },
};
