# Set the global weather according to the defined
# scenario in /environment/weather-scenario
#
var initialize_weather_scenario = func {
  getprop( "/environment/params/metar-updates-environment", 0 ) == 0 and return;
  getprop( "/environment/realwx/enabled", 0 ) and return;
  getprop( "/environment/metar/data", "" ) != "" and return;

  # preset configured scenario
  var scn = getprop("/environment/weather-scenario", "");
  var wsn = props.globals.getNode( "/environment/weather-scenarios" );
  if( wsn != nil ) {
    var scenarios = wsn.getChildren("scenario");
    forindex (var i; scenarios ) {
      if( scenarios[i].getNode("name").getValue() == scn ) {
        setprop("/environment/metar/data", scenarios[i].getNode("metar").getValue() );
        break;
      }
    }
  }
};

_setlistener("/sim/signals/nasal-dir-initialized", func {
	initialize_weather_scenario();
	delete(globals, "weather_scenario");
});

