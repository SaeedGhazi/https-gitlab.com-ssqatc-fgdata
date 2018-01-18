# Air Data Computer Driver using Emesary to publish data such as
#
# Airspeed
# Orientation
# Rate of turn
# Heading
# Air Temperature
#
#
#  For the moment these are just taken directly from the raw properties.  They
# should probably come from aircraft-specific instrumentation.

var GenericADCPublisher =
{

  new : func (frequency=0.5) {
    var obj = {
      parents : [
        GenericADCPublisher,
        PeriodicPropertyPublisher.new(notifications.PFDEventNotification.ADCData, frequency)
      ],
    };

    obj.addPropMap("ADCTrueAirspeed", "/instrumentation/airspeed-indicator/true-speed-kt");

    return obj;
  },
};
