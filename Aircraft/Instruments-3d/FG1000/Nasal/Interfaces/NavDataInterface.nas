#
# Emesary interface to access nav data such as airport information, fixes etc.
#

var NavDataInterface = {

new : func (device)
{
  var obj = { parents : [ NavDataInterface ] };

  # Emesary
  obj._recipient = nil;
  obj._transmitter = emesary.GlobalTransmitter;
  obj._registered = 0;
  obj._device = device;
  obj._currentDTO = "";

  # List of recently use waypoints
  obj._recentWaypoints = std.Vector.new();

  return obj;
},

# Find the airports within 200nm and return them.
getNearestAirports : func()
{
  # To make this more efficient for areas with a high density of airports, we'll try
  # a small radius first and expand until we have reached 200nm or have 25 airports.
  var radius = 0;
  var apts = [];

  while ((radius <= 200) and (size(apts) < 25)) {
    radius = radius + 50;
    apts = findAirportsWithinRange(radius);
  }

  if (size(apts) > 25) {
    apts = subvec(apts, 0, 25);
  }

  return apts;
},

# Find a specific airport by ID.  Return an array of airport objects
getAirportById : func(id)
{
  var apt = findAirportsByICAO(id, "airport");

  if ((apt != nil) and (! me._recentWaypoints.contains(id))) {
    me._recentWaypoints.insert(0, id);
  }

  return apt;
},

# Find an arbritrary piece of nav data by ID.  This searches based on the
# current location and returns an array of objects that match the id.
getNavDataById : func (id)
{
  # Check for airport first
  var navdata = findAirportsByICAO(id, "airport");

  # Check for Navaids.
  if (size(navdata) == 0) navdata = findNavaidsByID(id);

  # Check for fix.
  if (size(navdata) == 0) navdata = findFixesByID(id);

  # Check for a pseudo-fix in the flightplan
  if (size(navdata) == 0) {
    var fp = flightplan();
    if (fp != nil) {
      for (var i = 0; i < fp.getPlanSize(); i = i +1) {
        var wp = fp.getWP(i);
        if (wp.wp_name == id) {
          append(navdata, wp);
        }
      }
    }
  }

  if ((size(navdata) > 0) and (! me._recentWaypoints.contains(id))) {
    me._recentWaypoints.insert(0, id);
  }

  return navdata;
},

# Retrieve the current flightplan and return it
getFlightplan : func ()
{
  return flightplan();
},

# Retrieve the Airway waypoints on the current leg.
getAirwayWaypoints : func() {
  var fp = flightplan();
  if (fp != nil) {
    var current_wp = fp.currentWP();
    if ((current_wp != nil) and (fp.indexOfWP(current_wp) > 0)) {
      var last_wp = fp.getWP(fp.indexOfWP(current_wp) -1);
      return airwaysRoute(last_wp, current_wp);
    }
  }
  return nil;
},

# Return the recently seen waypoints, collected from previous calls to
# other nav data functions
getRecentWaypoints : func()
{
  return me._recentWaypoints.vector;
},

# Add an ID to the list of recent waypoints
addRecentWaypoint : func(id)
{
  if ((id != nil) and (! me._recentWaypoints.contains(id))) {
    me._recentWaypoints.insert(0, id);
  }
},

# Return the array of user waypoints.  TODO
getUserWaypoints : func()
{
  return [];
},

# Set up a DirectTo a given ID, with optional VNAV altitude offset.
setDirectTo : func(param)
{
  var id = param.id;
  var alt_ft = param.alt_ft;
  var offset_nm = param.offset_nm;

  var fp = flightplan();
  var wp_idx = -1;

  if (fp != nil) {
    # We've already got a flightplan, so see if this WP already exists.

    for (var i = 0; i < fp.getPlanSize(); i = i + 1) {
      var wp = fp.getWP(i);
      if ((wp.wp_name != nil) and (wp.wp_name == id)) {
        # OK, we're assuming that if the names actually match, then
        # they refer to the same ID.  So direct to that index.
        wp_idx = i;
        break;
      }
    }
  }

  if (wp_idx != -1) {
    # Found the waypoint in the plan, so use that as the DTO.
    var wp = fp.getWP(wp_idx);
    setprop("/instrumentation/gps/scratch/ident", wp.wp_name);
    setprop("/instrumentation/gps/scratch/altitude-ft", 0);
    setprop("/instrumentation/gps/scratch/latitude-deg", wp.lat);
    setprop("/instrumentation/gps/scratch/longitude-deg", wp.lon);
  } else {
    # No flightplan, or waypoint not found, so use the GPS DTO function.
    # Hokey property-based interface.
    setprop("/instrumentation/gps/scratch/ident", id);
    setprop("/instrumentation/gps/scratch/altitude-ft", 0);
    setprop("/instrumentation/gps/scratch/latitude-deg", 0);
    setprop("/instrumentation/gps/scratch/longitude-deg", 0);
  }

  # Switch the GPS to DTO mode.
  setprop("/instrumentation/gps/command", "direct");
},

# Return the current DTO location to use
getCurrentDTO : func()
{
  return me._currentDTO;
},

# Set the current DTO location to use
setCurrentDTO : func(id)
{
  me._currentDTO = id;
},

RegisterWithEmesary : func()
{
  if (me._recipient == nil){
    me._recipient = emesary.Recipient.new("DataInterface");
    var pfd_obj = me._device;
    var controller = me;
    me._recipient.Receive = func(notification)
    {
      if (notification.Device_Id == pfd_obj.device_id
          and notification.NotificationType == notifications.PFDEventNotification.DefaultType) {
        if (notification.Event_Id == notifications.PFDEventNotification.NavData
            and notification.EventParameter != nil)
        {
          var id = notification.EventParameter.Id;

          if (id == "NearestAirports") {
            notification.EventParameter.Value = controller.getNearestAirports();
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "AirportByID") {
            notification.EventParameter.Value = controller.getAirportById(notification.EventParameter.Value);
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "NavDataByID") {
            notification.EventParameter.Value = controller.getNavDataById(notification.EventParameter.Value);
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "Flightplan") {
            notification.EventParameter.Value = controller.getFlightplan();
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "RecentWaypoints") {
            notification.EventParameter.Value = controller.getRecentWaypoints();
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "AddRecentWaypoint") {
            controller.addRecentWaypoint(notification.EventParameter.Value);
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "AirwayWaypoints") {
            notification.EventParameter.Value = controller.getAirwayWaypoints();
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "UserWaypoints") {
            notification.EventParameter.Value = controller.getUserWaypoints();
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "CurrentDTO") {
            notification.EventParameter.Value = controller.getCurrentDTO();
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
          if (id == "SetDirectTo") {
            controller.setDirectTo(notification.EventParameter.Value);
            return emesary.Transmitter.ReceiptStatus_Finished;
          }
        }
      }
      return emesary.Transmitter.ReceiptStatus_NotProcessed;
    };
  }

  me._transmitter.Register(me._recipient);
  me._registered = 1;
},

DeRegisterWithEmesary : func()
{
  # remove registration from transmitter; but keep the recipient once it is created.
  if (me._registered == 1) me._transmitter.DeRegister(me._recipient);
  me._registered = 0;
},


start : func() {
  me.RegisterWithEmesary();
},
stop : func() {
  me.DeRegisterWithEmesary();
},



};
