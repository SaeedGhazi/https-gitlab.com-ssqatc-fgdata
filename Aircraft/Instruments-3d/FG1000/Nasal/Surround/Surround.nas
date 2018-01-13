# MFD Surround
#
# Header fields at the top of the page
#
# PageGroup navigation, displayed in the bottom right of the
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

var Surround =
{
  new : func (mfd, myCanvas, device, svg)
  {
    var obj = { parents : [
      Surround,
      MFDPage.new(mfd, myCanvas, device, svg, "Surround", ""),
    ] };

    var textElements = [
      "Comm1StandbyFreq", "Comm1SelectedFreq",
      "Comm2StandbyFreq", "Comm2SelectedFreq",
      "Nav1StandbyFreq", "Nav1SelectedFreq",
      "Nav2StandbyFreq", "Nav2SelectedFreq",
      "Nav1ID", "Nav2ID"
    ];

    obj.addTextElements(textElements);

    obj._comm1selected = PFD.HighlightElement.new(obj.pageName, svg, "Comm1Selected", "Comm1");
    obj._comm2selected = PFD.HighlightElement.new(obj.pageName, svg, "Comm2Selected", "Comm2");

    obj._nav1selected = PFD.HighlightElement.new(obj.pageName, svg, "Nav1Selected", "Nav1");
    obj._nav2selected = PFD.HighlightElement.new(obj.pageName, svg, "Nav2Selected", "Nav2");

    obj._comm1failed = PFD.HighlightElement.new(obj.pageName, svg, "Comm1Failed", "Comm1");
    obj._comm2failed = PFD.HighlightElement.new(obj.pageName, svg, "Comm2Failed", "Comm2");

    obj._nav1failed = PFD.HighlightElement.new(obj.pageName, svg, "Nav1Failed", "Nav1");
    obj._nav2failed = PFD.HighlightElement.new(obj.pageName, svg, "Nav2Failed", "Nav2");

    obj._canvas = myCanvas;
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

    obj.controller = fg1000.SurroundController.new(obj, svg);
    return obj;
  },

  handleNavComData : func(data) {
    foreach(var name; keys(data)) {
      var val = data[name];

      if (name == "Comm1SelectedFreq") me.setTextElement("Comm1SelectedFreq", sprintf("%0.03f", val));
      if (name == "Comm1StandbyFreq") me.setTextElement("Comm1StandbyFreq", sprintf("%0.03f", val));
      if (name == "Comm1Serviceable") {
        if (val == 1) {
          me._comm1failed.unhighlightElement()
        } else {
          me._comm1failed.highlightElement();
        }
      }

      if (name == "Comm2SelectedFreq") me.setTextElement("Comm2SelectedFreq", sprintf("%0.03f", val));
      if (name == "Comm2StandbyFreq") me.setTextElement("Comm2StandbyFreq", sprintf("%0.03f", val));
      if (name == "Comm2Serviceable") {
        if (val == 1) {
          me._comm2failed.unhighlightElement();
        } else {
          me._comm2failed.highlightElement();
        }
      }

      if (name == "CommSelected") {
        if (val == 1) {
          me._comm1selected.highlightElement();
          me._comm2selected.unhighlightElement();
        } else {
          me._comm1selected.unhighlightElement();
          me._comm2selected.highlightElement();
        }
      }

      if (name == "Nav1SelectedFreq") me.setTextElement("Nav1SelectedFreq", sprintf("%0.03f", val));
      if (name == "Nav1StandbyFreq") me.setTextElement("Nav1StandbyFreq", sprintf("%0.03f", val));
      if (name == "Nav1Serviceable") {
        if (val == 1) {
          me._nav1failed.unhighlightElement();
        } else {
          me._nav1failed.highlightElement();
        }
      }

      if (name == "Nav2SelectedFreq") me.setTextElement("Nav2SelectedFreq", sprintf("%0.03f", val));
      if (name == "Nav2StandbyFreq") me.setTextElement("Nav2StandbyFreq", sprintf("%0.03f", val));
      if (name == "Nav2Serviceable") {
        if (val == 1) {
          me._nav2failed.unhighlightElement();
        } else {
          me._nav2failed.highlightElement();
        }
      }

      if (name == "NavSelected") {
        if (val == 1) {
          me._nav1selected.highlightElement();
          me._nav2selected.unhighlightElement();
        } else {
          me._nav1selected.unhighlightElement();
          me._nav2selected.highlightElement();
        }
      }

      if (name == "Nav1ID") me.setTextElement("Nav1ID", val);
      if (name == "Nav2ID") me.setTextElement("Nav2ID", val);

      # TODO - COM Volume - display the current volume for 2 seconds in place of the
      # standby frequency.


    }
  },

  addPage : func(name, page)
  {
    me._pageList[name] = page;
  },

  getPage : func(name)
  {
    return me._pageList[name];
  },

  # Function to change a page based on the selection
  loadPage : func()
  {
    var pageToLoad = PAGE_GROUPS[me._selectedPageGroup].pages[me._selectedPage];
    var page = me._pageList[pageToLoad];

    assert(page != nil, "Unable to find page " ~ pageToLoad);
    me.device.selectPage(page);
  },
  incrPageGroup : func(val) {
    var incr_or_decr = (val > 0) ? 1 : -1;
    me._selectedPageGroup = math.mod(me._selectedPageGroup + incr_or_decr, size(PAGE_GROUPS));
    me._selectedPage = 0;
  },
  incrPage : func(val) {
    var incr_or_decr = (val > 0) ? 1 : -1;
    me._selectedPage = math.mod(me._selectedPage + incr_or_decr, size(PAGE_GROUPS[me._selectedPageGroup].pages));
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
  hideMenu : func()
  {
    foreach(var pageGroup; PAGE_GROUPS)
    {
      me._elements[pageGroup.group].setVisible(0);
      me._elements[pageGroup.label].setVisible(0);
    }
    me._menuVisible = 0;
  },
  isMenuVisible : func()
  {
    return me._menuVisible;
  },


};
