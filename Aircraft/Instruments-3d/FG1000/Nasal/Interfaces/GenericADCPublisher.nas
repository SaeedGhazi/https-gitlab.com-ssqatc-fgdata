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
