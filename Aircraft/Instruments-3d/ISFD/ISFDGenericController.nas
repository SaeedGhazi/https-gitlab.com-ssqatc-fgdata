

var GenericController =
{

#   COLORS : {
#       green : [0, 1, 0],
#       white : [1, 1, 1],
#       black : [0, 0, 0],
#       lightblue : [0, 1, 1],
#       darkblue : [0, 0, 1],
#       red : [1, 0, 0],
#       magenta : [1, 0, 1],
#   },

  new : func ()
  {
    var obj = {
        parents : [GenericController],
    };
      # IFSD does its own barometric altititde independant of the acft ADIRUs
      #me.altitudeProp = props.globals.getNode('/instruments/')

      return obj;
  },

  update : func()
  {

  },

  getAltitudeFt : func()
  {
    return getprop("/position/altitude-ft");
  },

  getIndicatedAirspeedKnots : func()
  {
    return getprop("/velocities/airspeed-kt");
  },

  getHeadingDeg : func()
  {
    # compass / gyro source for this?
    return getprop("/orientation/heading-deg");
  },

  getPitchDeg : func()
  {
      return getprop("/orientation/pitch-deg");
      #return getprop("/instrumentation/attitude-indicator/indicated-pitch-deg");
    # obj.addPropMap("ADCTurnRate", "/instrumentation/turn-indicator/indicated-turn-rate");
    # obj.addPropMap("ADCSlipSkid", "/instrumentation/slip-skid-ball/indicated-slip-skid");

  },

  getBankAngleDeg : func()
  {
    return getprop("/orientation/roll-deg");
    # return getprop("/instrumentation/attitude-indicator/indicated-roll-deg");
  },

  getBarometricPressureSetting : func()
  {

  }

  # also a setter
    # set inHg / hPA units
}