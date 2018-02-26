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
# PFDInstruments Controller
var PFDInstrumentsController =
{
  new : func (page, svg)
  {
    var obj = {
      parents : [ PFDInstrumentsController, MFDPageController.new(page) ],
      _crsrToggle : 0,
      _pfdrecipient : nil,
      page : page,
      _last_ias_kt : 0,
      _last_alt_ft : 0,
      _last_trend : systime(),
      _selected_alt_ft : 0,
      _heading : 0,
      _source : "GPS",
    };

    return obj;
  },


  # Input Handling
  handleCRSR : func() {
    me._crsrToggle = (! me._crsrToggle);
    if (me._crsrToggle) {
    } else {
      me.page.hideCRSR();
    }
    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleFMSInner : func(value) {
    if (me._crsrToggle == 1) {
      # Scroll through whatever is the current list
      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      # Pass to the page group controller to display and scroll through the page group menu
      #return me.page.mfd.SurroundController.handleFMSInner(value);
    }
  },
  handleFMSOuter : func(value) {
    if (me._crsrToggle == 1) {
      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      # Pass to the page group controller to display and scroll through the page group menu
      #return me.page.mfd.SurroundController.handleFMSOuter(value);
    }
  },
  handleEnter : func(value) {
    if (me._crsrToggle == 1) {
      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return emesary.Transmitter.ReceiptStatus_NotProcessed;
    }
  },

  # Handle update of the airdata information.
  # ADC data is produced periodically as an entire set
  handleADCData : func(data) {
    var ias = data["ADCIndicatedAirspeed"];
    var alt = data["ADCAltitudeFT"];
    # estimated speed and altitude in 6s
    var now = systime();
    var lookahead_ias_6sec = 6 * (ias - me._last_ias_kt) / (now - me._last_trend);
    var lookahead_alt_6sec = .3 * (alt - me._last_alt_ft) / (now - me._last_trend); # scale = 1/20ft
    me.page.updateIAS(ias, lookahead_ias_6sec);
    me.page.updateALT(alt, lookahead_alt_6sec, me._selected_alt_ft);
    me._last_ias_kt = ias;
    me._last_alt_ft = alt;
    me._last_trend = now;

    var pitch = data["ADCPitchDeg"];
    var roll = data["ADCRollDeg"];
    var slip = data["ADCSlipSkid"];
    me.page.updateAI(pitch, roll, slip);

    me.page.updateVSI(data["ADCVerticalSpeedFPM"]);
    me.page.updateTAS(data["ADCTrueAirspeed"]);
    me.page.updateBARO(data["ADCPressureSettingInHG"]);
    me.page.updateOAT(data["ADCOutsideAirTemperatureC"]);
    me.page.updateHSI(data["ADCHeadingDeg"]);
    me._heading = data["ADCHeadingDeg"];

    me.page.updateWindData(
      hdg : data["ADCHeadingDeg"],
      wind_hdg : data["ADCWindHeadingDeg"],
      wind_spd : data ["ADCWindSpeedKt"]
    );

    return emesary.Transmitter.ReceiptStatus_OK;
  },

  # Handle update to the FMS information.
  handleFMSData : func(data) {

    me.page.updateHDG(data["FMSHeadingBug"]);
    me.page.updateSelectedALT(data["FMSSelectedAlt"]);
    me._selected_alt_ft = data["FMSSelectedAlt"];

    me.page.updateCRS(data["FMSLegBearing"]);

    var from = 0;
    if (me._navSelected == 1) {
      from = data["FMSNav1From"];
    } else {
      from = data["FMSNav2From"];
    }

    me.page.updateCDI(
      heading: me._heading,
      course: data["FMSLegBearing"],
      waypoint_valid: 1,
      course_deviation_deg : data["FMSLegTrackErrorAngle"],
      deflection_dots : data["FMSLegCourseError"], # TODO: proper conversion depending on source, environment
      xtrk_nm : data["FMSLegCourseError"],
      from: from,
    );

    return emesary.Transmitter.ReceiptStatus_OK;
  },

  # Handle update of the NavCom data.
  # Note that this updated on a property by property basis, so we need to check
  # that the data we want exists in this notification, unlike the periodic
  # publishers
  handleNavComData : func(data) {
    if (data["NavSelected"] != nil) {
      me._navSelected = data["NavSelected"];
    }
  },

  PFDRegisterWithEmesary : func(transmitter = nil){
    if (transmitter == nil)
      transmitter = emesary.GlobalTransmitter;

    if (me._pfdrecipient == nil){
      me._pfdrecipient = emesary.Recipient.new("PFDInstrumentsController_" ~ me._page.device.designation);
      var pfd_obj = me._page.device;
      var controller = me;
      me._pfdrecipient.Receive = func(notification)
      {
        if (notification.NotificationType == notifications.PFDEventNotification.DefaultType and
            notification.Event_Id == notifications.PFDEventNotification.ADCData and
            notification.EventParameter != nil)
        {
          return controller.handleADCData(notification.EventParameter);
        }

        if (notification.NotificationType == notifications.PFDEventNotification.DefaultType and
            notification.Event_Id == notifications.PFDEventNotification.FMSData and
            notification.EventParameter != nil)
        {
          return controller.handleFMSData(notification.EventParameter);
        }

        if (notification.NotificationType == notifications.PFDEventNotification.DefaultType and
            notification.Event_Id == notifications.PFDEventNotification.NavComData and
            notification.EventParameter != nil)
        {
          return controller.handleNavComData(notification.EventParameter);
        }

        return emesary.Transmitter.ReceiptStatus_NotProcessed;
      };
    }
    transmitter.Register(me._pfdrecipient);
    me.transmitter = transmitter;
  },
  PFDDeRegisterWithEmesary : func(transmitter = nil){
      # remove registration from transmitter; but keep the recipient once it is created.
      if (me.transmitter != nil)
        me.transmitter.DeRegister(me._pfdrecipient);
      me.transmitter = nil;
  },

  # Reset controller if required when the page is displayed or hidden
  ondisplay : func() {
    me.RegisterWithEmesary();
    me.PFDRegisterWithEmesary();
  },
  offdisplay : func() {
    me.DeRegisterWithEmesary();
    me.PFDDeRegisterWithEmesary();
  },
};
