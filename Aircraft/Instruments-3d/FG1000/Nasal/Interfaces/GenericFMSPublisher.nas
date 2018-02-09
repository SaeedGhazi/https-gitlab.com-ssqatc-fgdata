# Copyright 2018 Stuart Buchanan
# This file is part of FlightGear.
#
# Foobar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
# FMS Driver using Emesary to publish data from the inbuilt FMS properties
var GenericFMSPublisher =
{

  new : func (frequency=0.5) {
    var obj = {
      parents : [
        GenericFMSPublisher,
        PeriodicPropertyPublisher.new(notifications.PFDEventNotification.FMSData, frequency)
      ],
    };

    obj.addPropMap("FMSLegBearing", "/instrumentation/gps/wp/wp[1]/bearing-mag-deg");
    obj.addPropMap("FMSLegCourseError", "/instrumentation/gps/wp/wp[1]/course-error-nm");
    obj.addPropMap("FMSLegDesiredTrack", "/instrumentation/gps/indicated-track-magnetic-deg");
    obj.addPropMap("FMSLegTrackErrorAngle", "/instrumentation/gps/wp/wp[1]/course-deviation-deg");
    obj.addPropMap("FMSLegTrack", "/instrumentation/gps/indicated-track-magnetic-deg");
    obj.addPropMap("FMSGroundspeed",  "/instrumentation/gps/indicated-ground-speed-kt");
    obj.addPropMap("FMSWayPointCourseError", "/instrumentation/gps/wp/wp[1]/course-error-nm");

    return obj;
  },

  # Custom publish method as we need to calculate some particular values manually.
  publish : func() {
    var gpsdata = {};

    foreach (var propmap; me._propmaps) {
      var name = propmap.getName();
      gpsdata[name] = propmap.getValue();
    }

    # A couple of calculated values used by the MFD Header display
    var total_fuel = getprop("/consumables/fuel/tank[0]/indicated-level-gal_us") or 0.0;
    total_fuel = total_fuel  + (getprop("/consumables/fuel/tank[1]/indicated-level-gal_us") or 0.0);
    var fuel_flow = getprop("/engines/engine[0]/fuel-flow-gph") or 1.0;
    gpsdata["FuelOnBoard"] = total_fuel;
    gpsdata["EnduranceHrs"] = total_fuel /  fuel_flow;

    var plan = flightplan();

    var dst = 0.0;
    if (plan.getPlanSize() > 0) {
      # Determine the distance to travel, based on
      # - current distance to the next WP,
      # - length of each subsequent leg.
      dst = getprop("/instrumentation/gps/wp/wp[1]/distance-nm") or 0.0;

      if (plan.indexOfWP(plan.currentWP()) <  (plan.getPlanSize() -1)) {
        for(var i=plan.indexOfWP(plan.currentWP()) + 1; i < plan.getPlanSize(); i = i+1) {
          var leg = plan.getWP(i);
          if (leg != nil ) dst = dst + leg.leg_distance;
        }
      }
    }

    gpsdata["FMSDistance"] = dst;
    var spd = getprop("/instrumentation/gps/indicated-ground-speed-kt") or 1.0;
    var time_hrs = dst / spd;

    gpsdata["FMSEstimatedTimeEnroute"] = time_hrs;
    gpsdata["FMSFuelOverDestination"] = total_fuel - time_hrs * fuel_flow;

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notifications.PFDEventNotification.FMSData,
      gpsdata);

    me._transmitter.NotifyAll(notification);
  },

};
