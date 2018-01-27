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

  # List of recently use waypoints
  obj._recentWaypoints = std.Vector.new();

  # Current DirectTo ID.
  var nearest = obj.getNearestAirports();
  if (size(nearest) > 0) {
    nearest = nearest[0];
    obj._currentDTO = nearest.id;
  }

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

# Return the current DTO location to use
getCurrentDTO : func()
{
  return me._currentDTO;
},

# Set  the current DTO location to use
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
