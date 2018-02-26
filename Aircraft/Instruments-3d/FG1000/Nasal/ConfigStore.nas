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
# Copyright (C) 2018 Stuart Buchanan
# FG1000 Configuration store
#
# This only stores configuration with pre-defined values
#

var ConfigStore = {

  configValues : {
    "DisplayUnitsNavAngle": ["MAGNETIC", "TRUE"] ,
    "DisplayUnitsDistanceAndSpeed": ["NAUTICAL", "METRIC"] ,
    "DisplayUnitsAltitude": ["FEET", "METERS"] ,
    "DisplayUnitsTemperature": ["CELCIUS", "FAHRENHEIT"] ,

    "BaroTransitionAlert": ["ON", "OFF"] ,
    "BaroTransitionAltitude": ["6000", "18000"] ,

    "AirspaceAlertBuffer": ["100", "200", "300", "400", "500", "750", "1000"] ,
    "AirspaceAlertClassB": ["OFF", "ON"] ,
    "AirspaceAlertClassC": ["OFF", "ON"] ,
    "AirspaceAlertClassD": ["OFF", "ON"] ,
    "AirspaceAlertRestricted": ["OFF", "ON"] ,
    "AirspaceAlertMOA": ["OFF", "ON"] ,
    "AirspaceAlertOther": ["OFF", "ON"] ,

    "ArrivalAlert": ["OFF", "ON"] ,
    "ArrivalDistance": ["0.0", "1.0", "2.0", "3.0", "4.0", "6.0", "8.0", "10.0"] ,
    "AudioAlertVoice": ["MALE", "FEMALE"] ,

    "PageNavigationChangeOnFirstClick": ["OFF", "ON"] ,
    "PageNavigationTimeout" : [0.5, 1.0, 2.0, 3.0] ,


    # MFD Header Fields
    #
    # Bearing (BRG)
    # Crosstrack Error (XTK)
    #	Distance (DIS)
    #	Desired Track (DTK)
    #	Endurance (END)
    #	En Route Safe Altitude (ESA)
    # Estimated Time of Arrival (ETA)
    #	Estimated Time En Route (ETE)
    # Fuel Over Destination (FOD)
    # Fuel On Board (FOB)
    # Ground Speed (GS)
    # Minimum Safe Altitude (MSA)
    # True Air Speed (TAS)
    # Track Angle Error (TKE)
    # Track (TRK)
    # Vertical Speed Required (VSR)

    "MFDHeader1": ["BRG", "XTK", "DIS", "DTK", "END", "ESA", "ETA", "ETE", "FOD", "FOB", "GS", "MSA", "TAS", "TKE", "TRK", "VSR"] ,
    "MFDHeader2": ["BRG", "XTK", "DIS", "DTK", "END", "ESA", "ETA", "ETE", "FOD", "FOB", "GS", "MSA", "TAS", "TKE", "TRK", "VSR"] ,
    "MFDHeader3": ["BRG", "XTK", "DIS", "DTK", "END", "ESA", "ETA", "ETE", "FOD", "FOB", "GS", "MSA", "TAS", "TKE", "TRK", "VSR"] ,
    "MFDHeader4": ["BRG", "XTK", "DIS", "DTK", "END", "ESA", "ETA", "ETE", "FOD", "FOB", "GS", "MSA", "TAS", "TKE", "TRK", "VSR"] ,

    # V-speeds (Cessna 182T)
    "Vx" : 54, # Short field takeoff, 2600lbs
    "Vy" : 78, # 4000ft, 3100lbs
    "Vr" : 78,
    "Vglide" : 70, # 2600lbs
    "Vne": 175,

    "Vx-visible" : 1,
    "Vy-visible" : 1,
    "Vr-visible" : 1,
    "Vglide-visible" : 1,
    "Vne-visible": 1,

  },

  new : func()
  {
    var obj ={
      parents : [ ConfigStore ],
      _values : {},
    };

    foreach (var i; keys(ConfigStore.configValues)) {
      var values = ConfigStore.configValues[i];
      if (typeof(values) == "vector") obj.set(i, values[0]);
      if (typeof(values) == "scalar") obj.set(i, values);
    }

    # Special case defaults
    obj.set("MFDHeader1", "GS");
    obj.set("MFDHeader2", "DIS");
    obj.set("MFDHeader3", "ETE");
    # ESA should be the default, but it's not implemented right now, so use FOD
    #obj.set("MFDHeader4", "ESA");
    obj.set("MFDHeader4", "FOD");

    return obj;
  },

  set : func(name, value) {
    # Validate name is something we know.
    assert(contains(ConfigStore.configValues, name), "ConfigStore does not contain name " ~ name);

    if (typeof(ConfigStore.configValues[name]) == "vector") {
      # Validate the value is part of the set of acceptable values
      var found = 0;
      foreach(var val; ConfigStore.configValues[name]) {
        if (value == val) {
          found =1;
          break;
        }
      }

      assert(found == 1,
        "Invalid value for " ~ name ~ ": " ~ value ~
        "(Should be one of " ~ string.join(", ", ConfigStore.configValues[name]) ~ ")");

      me._values[name] = value;
    }elsif (typeof(ConfigStore.configValues[name]) == "scalar") {
      # If not valid values, then anything goes.
      me._values[name] = value;
    } else {
      die("Unknown ConfigStore type " ~ typeof(ConfigStore.configValues[name]));
    }
  },

  get : func(name) {
    return me._values[name];
  },
};
