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
      _from :0,
      _leg_id : "",
      _leg_bearing  : 0,
      _leg_distance_nm : 0,
      _leg_deviation_deg : 0,
      _deflection_dots : 0.0,
      _leg_xtrk_nm : 0,
      _leg_valid : 0,

      _nav1_id : "",
      _nav1_freq : 0.0,
      _nav1_radial_deg : 0,
      _nav1_heading_deg :0.0,
      _nav1_in_range : 0,
      _nav1_distance_m :0,

      _nav2_id : "",
      _nav2_freq : 0.0,
      _nav2_radial_deg :0,
      _nav2_heading_deg : 0.0,
      _nav2_in_range : 0,
      _nav2_distance_m :0,

      _adf_freq : 0.0,
      _adf_in_range : 0,
      _adf_heading_deg : 0.0,
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

  handleRange : func(val)
  {
    var incr_or_decr = (val > 0) ? me.page.insetMap.zoomIn() : me.page.insetMap.zoomOut();
  },

  # Set the STD BARO to 29.92 in Hg
  setStdBaro : func() {
    var data = {};
    data["FMSPressureSettingInHG"] = 29.92;

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      me._page.mfd.getDeviceID(),
      notifications.PFDEventNotification.FMSData,
      data);

    me.transmitter.NotifyAll(notification);
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

    # If we're "flying" at < 10kts, then we won't have sufficient delta between
    # airspeed and groundspeed to determine wind
    me.page.updateWindData(
      hdg : data["ADCHeadingDeg"],
      wind_hdg : data["ADCWindHeadingDeg"],
      wind_spd : data ["ADCWindSpeedKt"],
      no_data: (data["ADCIndicatedAirspeed"] < 1.0)
    );

    return emesary.Transmitter.ReceiptStatus_OK;
  },

  # Handle update to the FMS information.  Note that there is no guarantee
  # that the entire set of FMS data will be available.
  handleFMSData : func(data) {

    if (data["FMSHeadingBug"] != nil) me.page.updateHDG(data["FMSHeadingBug"]);
    if (data["FMSSelectedAlt"] != nil) {
      me.page.updateSelectedALT(data["FMSSelectedAlt"]);
      me._selected_alt_ft = data["FMSSelectedAlt"];
    }

    if (data["FMSLegValid"] != nil) me._leg_valid = data["FMSLegValid"];

    if (me._leg_valid == 0) {
      # No valid leg data, likely because there's no GPS course set
      me.page.updateCRS(0);
      me.page.updateCDI(
        heading: me._heading,
        course: 0,
        waypoint_valid: 0,
        course_deviation_deg : 0,
        deflection_dots : 0.0,
        xtrk_nm : 0,
        from: 0,
        annun: "NO DATA",
      );
    } else {

      if (data["FMSLegBearing"] != nil) me.page.updateCRS(data["FMSLegBearing"]);

      if (me._navSelected == 1) {
        if (data["FMSNav1From"] != nil) me._from = data["FMSNav1From"];
      } else {
        if (data["FMSNav2From"] != nil) me._from = data["FMSNav2From"];
      }

      if (data["FMSLegID"] != nil) me._leg_id = data["FMSLegID"];
      if (data["FMSLegBearing"] != nil) me._leg_bearing = data["FMSLegBearing"];
      if (data["FMSLegDistanceNM"] != nil) me._leg_distance_nm = data["FMSLegDistanceNM"];
      if (data["FMSLegTrackErrorAngle"] != nil) me._leg_deviation_deg = data["FMSLegTrackErrorAngle"];

      # TODO:  Proper cross-track error based on source and flight phase.
      if (data["FMSLegCourseError"] != nil) me._deflection_dots = data["FMSLegCourseError"] /2.0;
      if (data["FMSLegCourseError"] != nil) me._leg_xtrk_nm = data["FMSLegCourseError"];

      me.page.updateCDI(
        heading: me._heading,
        course: me._leg_bearing,
        waypoint_valid: me._leg_valid,
        course_deviation_deg : me._leg_deviation_deg,
        deflection_dots : me._deflection_dots,
        xtrk_nm : me._leg_xtrk_nm,
        from: me._from,
        annun: "ENR"
      );
    }

    # Update the bearing indicators with GPS data if that's what we're displaying.
    if (me.page.getBRG1() == "GPS") me.page.updateBRG1(me._leg_valid, me._leg_id, me._leg_distance_nm, me._heading, me._leg_bearing);
    if (me.page.getBRG2() == "GPS") me.page.updateBRG2(me._leg_valid, me._leg_id, me._leg_distance_nm, me._heading, me._leg_bearing);

    return emesary.Transmitter.ReceiptStatus_OK;
  },

  # Handle update of the NavCom data.
  # Note that this updated on a property by property basis, so we need to check
  # that the data we want exists in this notification, unlike the periodic
  # publishers
  handleNavComData : func(data) {
    if (data["NavSelected"] != nil) me._navSelected = data["NavSelected"];
    if (data["Nav1SelectedFreq"] != nil) me._nav1_freq = data["Nav1SelectedFreq"];
    if (data["Nav1ID"] != nil) me._nav1_id = data["Nav1ID"];
    if (data["Nav1HeadingDeg"] != nil) me._nav1_heading_deg = data["Nav1HeadingDeg"];
    if (data["Nav1RadialDeg"] != nil) me._nav1_radial_deg = data["Nav1RadialDeg"];
    if (data["Nav1InRange"] != nil) me._nav1_in_range = data["Nav1InRange"];
    if (data["Nav1DistanceMeters"] != nil) me._nav1_distance_m = data["Nav1DistanceMeters"];


    if (data["Nav2SelectedFreq"] != nil) me._nav2_freq = data["Nav2SelectedFreq"];
    if (data["Nav2ID"] != nil) me._nav2_id = data["Nav2ID"];
    if (data["Nav2HeadingDeg"] != nil) me._nav2_heading_deg = data["Nav2HeadingDeg"];
    if (data["Nav2RadialDeg"] != nil) me._nav2_radial_deg = data["Nav2RadialDeg"];
    if (data["Nav2InRange"] != nil) me._nav2_in_range = data["Nav2InRange"];
    if (data["Nav2DistanceMeters"] != nil) me._nav2_distance_m = data["Nav2DistanceMeters"];

    if (data["ADFSelectedFreq"] != nil) me._adf_freq = data["ADFSelectedFreq"];
    if (data["ADFInRange"] != nil) me._adf_in_range = data["ADFInRange"];
    if (data["ADFHeadingDeg"] !=nil) me._adf_heading_deg = data["ADFInRange"];

    if (me.page.getBRG1() == "NAV1") me.page.updateBRG1(me._nav1_in_range, me._nav1_id, me._nav1_distance_m * M2NM, me._heading, me._nav1_heading_deg);
    if (me.page.getBRG1() == "NAV2") me.page.updateBRG1(me._nav2_in_range, me._nav2_id, me._nav2_distance_m * M2NM, me._heading, me._nav2_heading_deg);
    if (me.page.getBRG1() == "ADF") me.page.updateBRG1(me._adf_in_range, sprintf("%.1f", me._adf_freq), 0, me._heading, me._adf_heading_deg);

    if (me.page.getBRG2() == "NAV1") me.page.updateBRG2(me._nav1_in_range, me._nav1_id, me._nav1_distance_m * M2NM, me._heading, me._nav1_heading_deg);
    if (me.page.getBRG2() == "NAV2") me.page.updateBRG2(me._nav2_in_range, me._nav2_id, me._nav2_distance_m * M2NM, me._heading, me._nav2_heading_deg);
    if (me.page.getBRG2() == "ADF") me.page.updateBRG2(me._adf_in_range, sprintf("%.1f", me._adf_freq), 0, me._heading, me._adf_heading_deg);
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
