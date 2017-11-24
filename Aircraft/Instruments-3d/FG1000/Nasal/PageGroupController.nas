# Controller for the PageGroup navigation, displayed in the bottom right of the
# FMS, and controlled by the FMS knob

# Set of pages, references by SVG ID
var PAGE_GROUPS = [

  { label: "MapPageGroupLabel",
          group: "MapPageGroup",
          pages: [ "NavigationMap", "TrafficMap", "Stormscope", "WeatherDataLink", "TAWSB"],
  },
  { label: "WPTGroupLabel",
          group: "WPTPageGroup",
          pages: [ "AirportInformation", "IntersectionInformation", "NDBInformation", "VORInformation", "UserWPTInformation"],
  },

  { label: "AuxGroupLabel",
          group: "AuxPageGroup",
          pages: [ "TripPlanning", "Utility", "GPSStatus", "XMRadio", "SystemStatus"],
  },

  { label: "FPLGroupLabel",
          group: "FPLPageGroup",
          pages: [ "ActiveFlightPlan", "FlightPlanCatalog", "StoredFlightPlan"],
  },

  { label: "LstGroupLabel",
          group: "LstPageGroup",
          pages: [ "Checklist1", "Checklist2", "Checklist3", "Checklist4", "Checklist5"],
  },

  { label: "NrstGroupLabel",
          group: "NrstPageGroup",
          pages: [ "NearestAirports", "NearestIntersections", "NearestNDB", "NearestVOR", "NearestUserWaypoints", "NearestFrequencies", "NearestAirspaces"],
  }
];

var PageGroupController =
{
  new : func (myCanvas, svg, device)
  {
    var obj = { parents : [ PageGroupController ] };
    obj._canvas = myCanvas;
    obj._svg = svg;
    obj._device = device;
    obj._menuVisible = 0;
    obj._selectedPageGroup = 0;
    obj._selectedPage = 0;

    # List of pages to be controllers.  Keys are the pages in PAGE_GROUPS;
    obj._pageList = {};

    # Timers to controll when to hide the menu after inactivity, and when to load
    # a new page.
    obj._hideMenuTimer = maketimer(5, obj, obj.hideMenu);
    obj._hideMenuTimer.singleShot = 1;

    obj._loadPageTimer = maketimer(0.5, obj, obj.loadPage);
    obj._loadPageTimer.singleShot = 1;

    # Emesary
    obj._recipient = nil;

    obj.hideMenu();
    return obj;
  },

  addPage : func(name, page)
  {
    me._pageList[name] = page;
  },

  getPage : func(name)
  {
    return me._pageList[name];
  },

  hideMenu : func()
  {
    foreach(var pageGroup; PAGE_GROUPS)
    {
      me._svg.getElementById(pageGroup.group).setVisible(0);
      me._svg.getElementById(pageGroup.label).setVisible(0);
    }
    me._menuVisible = 0;
  },

  # Function to change a page based on the selection
  loadPage : func()
  {
    var pageToLoad = PAGE_GROUPS[me._selectedPageGroup].pages[me._selectedPage];
    var page = me._pageList[pageToLoad];

    if (page != nil) {
      me._device.selectPage(page);
    } else {
      printf("Unable to find page " ~ pageToLoad);
    }
  },

  showMenu : func()
  {
    foreach(var pageGroup; PAGE_GROUPS)
    {
      if (PAGE_GROUPS[me._selectedPageGroup].label == pageGroup.label)
      {
        # Display the page group and highlight the label
        me._svg.getElementById(pageGroup.group).setVisible(1);
        me._svg.getElementById(pageGroup.label).setVisible(1);
        me._svg.getElementById(pageGroup.label).setColor(0.7,0.7,1.0);

        foreach (var page; pageGroup.pages)
        {
          # Highlight the current page.
          if (pageGroup.pages[me._selectedPage] == page) {
            me._svg.getElementById(page).setColor(0.7,0.7,1.0);
          } else {
            me._svg.getElementById(page).setColor(0.7,0.7,0.7);
          }
        }
      }
      else
      {
        # Hide the pagegroup and unhighlight the label on the bottom
        me._svg.getElementById(pageGroup.group).setVisible(0);
        me._svg.getElementById(pageGroup.label).setVisible(1);
        me._svg.getElementById(pageGroup.label).setColor(0.7,0.7,0.7);
      }
    }
    me._menuVisible = 1;
    me._hideMenuTimer.stop();
    me._hideMenuTimer.restart(5);
    me._loadPageTimer.stop();
    me._loadPageTimer.restart(0.5);

  },

  FMSOuter : func(val)
  {
    if (me._menuVisible == 1) {
      # Change page group
      var incr_or_decr = (val > 0) ? 1 : -1;
      me._selectedPageGroup = math.mod(me._selectedPageGroup + incr_or_decr, size(PAGE_GROUPS));
      me._selectedPage = 0;
    }
    me.showMenu();
  },

  FMSInner : func(val)
  {
    if (me._menuVisible == 1) {
      # Change page group
      var incr_or_decr = (val > 0) ? 1 : -1;
      me._selectedPage = math.mod(me._selectedPage + incr_or_decr, size(PAGE_GROUPS[me._selectedPageGroup].pages));
    }
    me.showMenu();
  },
  RegisterWithEmesary : func(transmitter = nil){
    if (transmitter == nil)
      transmitter = emesary.GlobalTransmitter;

    if (me._recipient == nil){
      me._recipient = emesary.Recipient.new("PageController_" ~ me._device.designation);
      var pfd_obj = me._device;
      var controller = me;
      me._recipient.Receive = func(notification)
      {
        if (notification.Device_Id == pfd_obj.device_id
            and notification.NotificationType == notifications.PFDEventNotification.DefaultType) {
          if (notification.Event_Id == notifications.PFDEventNotification.HardKeyPushed
              and notification.EventParameter != nil)
          {
            var id = notification.EventParameter.Id;
            var value = notification.EventParameter.Value;
            #printf("Button pressed " ~ id ~ " " ~ value);
            if (id == fg1000.MFD.FASCIA.FMS_OUTER) controller.FMSOuter(value);
            if (id == fg1000.MFD.FASCIA.FMS_INNER) controller.FMSInner(value);
            if (id == fg1000.MFD.FASCIA.RANGE)     { if (pfd_obj.current_page.controller.zoom != nil) pfd_obj.current_page.controller.zoom(value); }
          }

          return emesary.Transmitter.ReceiptStatus_OK;
        }
        return emesary.Transmitter.ReceiptStatus_NotProcessed;
      };
      transmitter.Register(me._recipient);
      me.transmitter = transmitter;
    }
  },
  DeRegisterWithEmesary : func(transmitter = nil){
      # remove registration from transmitter; but keep the recipient once it is created.
      if (me.transmitter != nil)
        me.transmitter.DeRegister(me._recipient);
      me.transmitter = nil;
  },

};
