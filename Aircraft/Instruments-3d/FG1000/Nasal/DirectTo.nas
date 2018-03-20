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
# DirectTo page
#
# Technically this is supposed to be an overlay page, sitting on top of
# whatever page the user was on already.  However, to simplify implementation,
# we will assume that the user was on the Map page, and simply display the
# NavigationMap page underneath.

var DirectTo =
{
  SHORTCUTS : [ "FPL", "NRST", "RECENT", "USER", "AIRWAY" ],

  new : func (mfd, myCanvas, device, svg)
  {
    var obj = {
      parents : [
        DirectTo,
        MFDPage.new(mfd, myCanvas, device, svg, "DirectTo", "DIRECT TO")
      ],
      symbols : {},
    };

    obj.crsrIdx = 0;

    # Dynamic text elements in the SVG file.  In the SVG these have an "DirectTo" prefix.
    textelements = [
         "Name",
         "City",
         "Region",
         "LocationBRG",
         "LocationDIS",
    ];

    obj.addTextElements(textelements);

    obj._SVGGroup.setInt("z-index", 9);

    # Data Entry information.  Keyed from the name of the element, which must
    # be one of the textelements above.  Each data element maps to a set of
    # text elements in the SVG of the form [PageName][TextElement]{0...n}, each
    # representing a single character for data entry.
    #
    # .size is the number of characters of data entry
    # .chars is the set of characters, used to scroll through using the small
    # FMS knob.
    obj.IDEntry = PFD.DataEntryElement.new(obj.pageName, svg, "ID", "", 4, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
    obj.VNVAltEntry = PFD.DataEntryElement.new(obj.pageName, svg, "VNVAlt", "", 5, "0123456789");
    obj.VNVOffsetEntry = PFD.DataEntryElement.new(obj.pageName, svg, "VNVOffset", "", 2, "0123456789");
    obj.CourseEntry = PFD.DataEntryElement.new(obj.pageName, svg, "Course", "", 3, "0123456789");
    obj.Activate = PFD.TextElement.new(obj.pageName, svg, "Activate", "ACTIVATE?");

    # The Shortcut window.  This allows the user to scroll through a set of lists
    # of waypoints.
    obj.WaypointSubmenuGroup = obj._SVGGroup.getElementById("DirectToWaypointSubmenuGroup");
    assert(obj.WaypointSubmenuGroup != nil, "Unable to find DirectToWaypointSubmenuGroup");
    obj.WaypointSubmenuGroup.setVisible(0);
    obj.WaypointSubmenuSelect = PFD.ScrollElement.new(obj.pageName, svg, "WaypointSubmenuSelect", DirectTo.SHORTCUTS);
    obj.WaypointSubmenuScroll = PFD.GroupElement.new(obj.pageName, svg, [ "WaypointSubmenuScroll" ] , 4, "WaypointSubmenuScroll", 0, "WaypointSubmenuScrollTrough" , "WaypointSubmenuScrollThumb", 60);

    # The Airport Chart
    if (obj.elementExists("Map")) {
      obj.DirectToChart = fg1000.NavMap.new(obj, obj.getElement("Map"), [860,440], "rect(-160px, 160px, 160px, -160px)", 0, 2, 1);
    }

    obj.setController(fg1000.DirectToController.new(obj, svg));
    return obj;
  },
  displayDestination : func(destination) {

    #me.IDEntry.clearElement();

    if (destination != nil) {
      # Display a given location
      if (me.DirectToChart) {
        me.DirectToChart.setVisible(1);
        me.DirectToChart.getController().setPosition(destination.lat,destination.lon);
      }
      me.setTextElement("Name", string.uc(destination.name));
      me.setTextElement("City", "CITY");
      me.setTextElement("Region", "REGION");
      me.setTextElement("LocationBRG", "" ~ sprintf("%03d°", destination.course));
      me.setTextElement("LocationDIS", sprintf("%d", destination.range_nm) ~ "nm");

      me.IDEntry.setValue(destination.id);
      me.VNVAltEntry.setValue("00000");
      me.VNVOffsetEntry.setValue("00");
      me.CourseEntry.setValue("" ~ sprintf("%03d°", destination.course));
    } else {
      if (me.DirectToChart) me.DirectToChart.setVisible(0);
      me.setTextElement("Name", "");
      me.setTextElement("City", "");
      me.setTextElement("Region", "");
      me.setTextElement("LocationBRG", "_");
      me.setTextElement("LocationDIS", "_");

      me.IDEntry.setValue("____");
      me.VNVAltEntry.setValue("00000");
      me.VNVOffsetEntry.setValue("00");
      me.CourseEntry.setValue(0);
    }
  },

  offdisplay : func() {
    me._group.setVisible(0);
    me.getController().offdisplay();
    me.mfd.NavigationMap.offdisplay(0);
  },
  ondisplay : func() {
    me._group.setVisible(1);
    # Display a false title, as underneath we're showing the navigation map.
    me.mfd.setPageTitle("MAP - NAVIGATION MAP");
    me.getElement("Map").setVisible(1);
    me.getElement("Map-bg").setVisible(1);
    if (me.DirectToChart) me.DirectToChart.setVisible(1);
    me.getController().ondisplay();

    # The DirectTo pages displays over the NavigationMap.  This is a hack
    # as the page should just magically sit ontop of whatever page the user was
    # on.  However, we also need to disable the NavMap's own controller so there's
    # no confusion.
    me.mfd.NavigationMap.ondisplay(0);
  },

  # When the Direct To display is enabled, nothing is displayed on the softkeys.
  topMenu : func(device, pg, menuitem) {
    pg.clearMenu();
    pg.resetMenuColors();
    device.updateMenus();
  },

};
