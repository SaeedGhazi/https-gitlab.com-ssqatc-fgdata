# NavCom Interface using Emesary for a simple dual Nav/Com system using standard properties
var GenericNavComPublisher =
{
  new : func (frequency=0.25, transmitter = nil) {
    var obj = {
      parents : [ GenericNavComPublisher, PropertyPublisher.new(frequency, transmitter) ],
    };

    # Hack to handle cases where there is no selected COMM or NAV frequency
    if (getprop("/instrumentation/com-selected") == nil) setprop("/instrumentation/com-selected", 1);
    if (getprop("/instrumentation/nav-selected") == nil) setprop("/instrumentation/nav-selected", 1);

    obj.addPropMap("Comm1SelectedFreq", "/instrumentation/comm/frequencies/selected-mhz");
    obj.addPropMap("Comm1StandbyFreq", "/instrumentation/comm/frequencies/selected-mhz");
    obj.addPropMap("Comm1AirportID", "/instrumentation/comm/airport-id");
    obj.addPropMap("Comm1StationName", "/instrumentation/comm/station-name");
    obj.addPropMap("Comm1StationType", "/instrumentation/comm/station-type");
    obj.addPropMap("Comm1Volume", "/instrumentation/comm/volume");
    obj.addPropMap("Comm1Serviceable", "/instrumentation/comm/serviceable");

    obj.addPropMap("Comm2SelectedFreq", "/instrumentation/comm[1]/frequencies/selected-mhz");
    obj.addPropMap("Comm2StandbyFreq", "/instrumentation/comm[1]/frequencies/selected-mhz");
    obj.addPropMap("Comm2AirportID", "/instrumentation/comm[1]/airport-id");
    obj.addPropMap("Comm2StationName", "/instrumentation/comm[1]/station-name");
    obj.addPropMap("Comm2StationType", "/instrumentation/comm[1]/station-type");
    obj.addPropMap("Comm2Volume", "/instrumentation/comm[1]/volume");
    obj.addPropMap("Comm2Serviceable", "/instrumentation/comm[1]/serviceable");

    obj.addPropMap("CommSelected", "/instrumentation/com-selected");

    obj.addPropMap("Nav1SelectedFreq", "/instrumentation/nav/frequencies/selected-mhz");
    obj.addPropMap("Nav1StandbyFreq", "/instrumentation/nav/frequencies/selected-mhz");
    obj.addPropMap("Nav1ID", "/instrumentation/nav/nav-id");
    obj.addPropMap("Nav1Serviceable", "/instrumentation/nav/serviceable");

    obj.addPropMap("Nav2SelectedFreq", "/instrumentation/nav[1]/frequencies/selected-mhz");
    obj.addPropMap("Nav2StandbyFreq", "/instrumentation/nav[1]/frequencies/selected-mhz");
    obj.addPropMap("Nav2ID", "/instrumentation/nav[1]/nav-id");
    obj.addPropMap("Nav2Serviceable", "/instrumentation/nav[1]/serviceable");

    obj.addPropMap("NavSelected", "/instrumentation/nav-selected");


    return obj;
  },

  publish : func() {
    var data = {};

    foreach (var propmap; me._propmaps) {
      var name = propmap.getName();
      data[name] = propmap.getValue();
    }

    me.notify(notifications.PFDEventNotification.NavComData, data);
  },
};
