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
          pages: [ "AirportInfo", "IntersectionInfo", "NDBInfo", "VORInfo", "UserWPTInfo"],
  },

  { label: "AuxGroupLabel",
          group: "AuxPageGroup",
          pages: [ "TripPlanning", "Utility", "GPSStatus", "XMRadio", "SystemStatus"],
  },

  { label: "FPLGroupLabel",
          group: "FPLPageGroup",
          pages: [ "ActiveFlightPlanWide", "FlightPlanCatalog", "StoredFlightPlan"],
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
    obj._elements = {};

    foreach (var pageGroup; PAGE_GROUPS) {
      var group = svg.getElementById(pageGroup.group);
      var label = svg.getElementById(pageGroup.label);
      assert(group != nil, "Unable to find element " ~ pageGroup.group);
      assert(label != nil, "Unable to find element " ~ pageGroup.label);
      obj._elements[pageGroup.group] = group;
      obj._elements[pageGroup.label] = label;

      foreach(var pg; pageGroup.pages) {
        var page = svg.getElementById(pg);
        assert(page != nil, "Unable to find element " ~ pg);
        obj._elements[pg] = page;
      }
    }

    # Timers to control when to hide the menu after inactivity, and when to load
    # a new page.
    obj._hideMenuTimer = maketimer(3, obj, obj.hideMenu);
    obj._hideMenuTimer.singleShot = 1;

    obj._loadPageTimer = maketimer(0.5, obj, obj.loadPage);
    obj._loadPageTimer.singleShot = 1;

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
      me._elements[pageGroup.group].setVisible(0);
      me._elements[pageGroup.label].setVisible(0);
    }
    me._menuVisible = 0;
  },

  # Function to change a page based on the selection
  loadPage : func()
  {
    var pageToLoad = PAGE_GROUPS[me._selectedPageGroup].pages[me._selectedPage];
    var page = me._pageList[pageToLoad];

    assert(page != nil, "Unable to find page " ~ pageToLoad);
    me._device.selectPage(page);
  },
  showMenu : func()
  {
    foreach(var pageGroup; PAGE_GROUPS)
    {
      if (PAGE_GROUPS[me._selectedPageGroup].label == pageGroup.label)
      {
        # Display the page group and highlight the label
        me._elements[pageGroup.group].setVisible(1);
        me._elements[pageGroup.label].setVisible(1);
        me._elements[pageGroup.label].setColor(0.7,0.7,1.0);

        foreach (var page; pageGroup.pages)
        {
          # Highlight the current page.
          if (pageGroup.pages[me._selectedPage] == page) {
            me._elements[page].setColor(0.7,0.7,1.0);
          } else {
            me._elements[page].setColor(0.7,0.7,0.7);
          }
        }
      }
      else
      {
        # Hide the pagegroup and unhighlight the label on the bottom
        me._elements[pageGroup.group].setVisible(0);
        me._elements[pageGroup.label].setVisible(1);
        me._elements[pageGroup.label].setColor(0.7,0.7,0.7);
      }
    }
    me._menuVisible = 1;
    me._hideMenuTimer.stop();
    me._hideMenuTimer.restart(3);
    me._loadPageTimer.stop();
    me._loadPageTimer.restart(0.5);

  },

  handleFMSOuter : func(val)
  {
    if (me._menuVisible == 1) {
      # Change page group
      var incr_or_decr = (val > 0) ? 1 : -1;
      me._selectedPageGroup = math.mod(me._selectedPageGroup + incr_or_decr, size(PAGE_GROUPS));
      me._selectedPage = 0;
    }
    me.showMenu();
    return emesary.Transmitter.ReceiptStatus_Finished;
  },

  handleFMSInner : func(val)
  {
    if (me._menuVisible == 1) {
      # Change page group
      var incr_or_decr = (val > 0) ? 1 : -1;
      me._selectedPage = math.mod(me._selectedPage + incr_or_decr, size(PAGE_GROUPS[me._selectedPageGroup].pages));
    }
    me.showMenu();
    return emesary.Transmitter.ReceiptStatus_Finished;

  },
};
