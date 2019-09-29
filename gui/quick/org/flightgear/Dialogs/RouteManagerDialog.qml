import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: routeManagerDialog

    width: 800
    height: 600
    position: Qt.point(80, 80)

    windowId: routeManagerDialog.id
    title: "Route Manager"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var ft = getprop("/sim/startup/units") == "feet";
        //         var dlg = props.globals.getNode("/sim/gui/dialogs/route-manager", 1);
        //         var selection = dlg.getNode("selection", 1);
        //         var input = dlg.getNode("input", 1);
        //         var routem = props.globals.getNode("/autopilot/route-manager", 1);

        //         selection.setIntValue(-1);
        //         input.setValue("");

        //         var list = cmdarg().getNode("list");
        //         var cmd = routem.getNode("input", 1);
        //         var route = routem.getNode("route", 1);
        //         var dep = routem.getNode("departure", 1);
        //         var dest = routem.getNode("destination", 1);

        //         var sel_index = func {
        //             return int(selection.getValue());
        //         }

        //         var clear = func {
        //             flightplan().cleanPlan();
        //             selection.setIntValue(-1);
        //         }

        //         var insert = func {
        //             var insertIndex = sel_index();
        //             var appending = (insertIndex < 0);

        //             # Input is a list of space-separated waypoint specifications
        //             var argv = split(" ", input.getValue());
        //             foreach (var arg; argv) {
        //                 # When argument is not empty (caused by multiple space
        //                 # separators) insert *after* waypoint
        //                 if (size(arg) > 0) {
        //                     if (appending) {
        //                         cmd.setValue(arg);
        //                     } else {
        //                         insertIndex += 1;
        //                         cmd.setValue("@insert" ~ insertIndex ~ ":" ~ arg);
        //                     }
        //                 }
        //             }

        //             input.setValue("");
        //             selection.setValue(insertIndex);
        //             gui.dialog_update("route-manager");
        //         }

        //         var remove = func {
        //             flightplan().deleteWP(sel_index());
        //         }

        //         var route = func {
        //             var fp = flightplan();
        //             var from = fp.getWP(sel_index() - 1);
        //             var to = fp.getWP(sel_index());

        //             if ((from  == nil ) or (to == nil)) {
        //                 printlog('info', 'unable to route, invalid start ad end points');
        //                 return;
        //             }

        //             var route = airwaysRoute(from, to);
        //             fp.insertWaypoints(route, sel_index());
        //         }

        //         var jump_to = func {
        //             flightplan().current = sel_index();
        //         }

        //         var load_route = func(path) {
        //             routem.getNode("file-path", 1).setValue(path.getValue());
        //             cmd.setValue("@load");
        //             gui.dialog_update("route-manager");
        //         }

        //         var save_route = func(path) {
        //             routem.getNode("file-path", 1).setValue(path.getValue());
        //             cmd.setValue("@save");
        //             gui.dialog_update("route-manager");
        //         }

        //         var defaultDirInFileSelector = getprop("/sim/fg-home") ~ "/Export";

        //         var file_selector = gui.FileSelector.new(
        //         callback: load_route, title: "Load flight-plan", button: "Load",
        //         dir: defaultDirInFileSelector, dotfiles: 1);
        //         var save_selector = gui.FileSelector.new(
        //         callback: save_route, title: "Save flight-plan", button: "Save",
        //         dir: defaultDirInFileSelector, dotfiles: 1);

        //         var activate_fp = func {
        //             fgcommand("activate-flightplan", props.Node.new({"activate": 1}));
        //         }

        //         var departureRunways = dlg.getNode("departure-runways", 1);
        //         var destRunways = dlg.getNode("destination-runways", 1);
        //         var sids = dlg.getNode("sids", 1);
        //         var stars = dlg.getNode("stars", 1);
        //         var approaches = dlg.getNode("approaches", 1);

        //         var updateRunways = func {
        //             departureRunways.removeChildren("value");
        //             destRunways.removeChildren("value");

        //             var apt = flightplan().departure;
        //             if (apt != nil) {
        //                 var i=0;
        //                 foreach (var rwy; keys(apt.runways)) {
        //                     departureRunways.getNode("value[" ~ i ~ "]", 1).setValue(rwy);
        //                     i += 1;
        //                 }
        //             }

        //             apt = flightplan().destination;
        //             if (apt != nil) {
        //                 var i=0;
        //                 foreach (var rwy; keys(apt.runways)) {
        //                     destRunways.getNode("value[" ~ i ~ "]", 1).setValue(rwy);
        //                     i += 1;
        //                 }
        //             }

        //             gui.dialog_update("route-manager");
        //         }

        //         var updateSIDs = func {
        //             sids.removeChildren("value");

        //             var apt = flightplan().departure;
        //             var rwy = flightplan().departure_runway;
        //             if (apt == nil) {
        //                 return;
        //             }

        //             if (size(apt.sids(rwy)) == 0) {
        //                 sids.getNode("value[0]", 1).setValue("DEFAULT");
        //                 sids.getNode("value[1]", 1).setValue("(none)");
        //                 gui.dialog_update("route-manager", "sid");
        //                 return;
        //             }

        //             var i=1;
        //             sids.getNode("value[0]", 1).setValue("(none)");
        //             foreach (var s; apt.sids(rwy)) {
        //                 var sid = apt.getSid(s);
        //                 var transVec = sid.transitions;

        //                 if (size(transVec) > 0) {
        //                     # list each transition of the SID
        //                     foreach (var trans; transVec) {
        //                         sids.getNode("value[" ~ i ~ "]", 1).setValue(s ~ "-" ~ trans);
        //                         i += 1;
        //                     }
        //                 } else {
        //                     # no transitions defined, simple case
        //                     sids.getNode("value[" ~ i ~ "]", 1).setValue(s);
        //                     i += 1;
        //                 }
        //             }

        //             gui.dialog_update("route-manager", "sid");
        //         }

        //         var updateSTARs = func {
        //             stars.removeChildren("value");
        //             var apt = flightplan().destination;
        //             var rwy = flightplan().destination_runway;
        //             if (apt == nil or apt.stars(rwy) == nil) {
        //                 return;
        //             }

        //             var i=1;
        //             stars.getNode("value[0]", 1).setValue("(none)");
        //             foreach (var s; apt.stars(rwy)) {
        //                 var star = apt.getStar(s);
        //                 var transVec = star.transitions;

        //                 if (size(transVec) > 0) {
        //                     # list each transition of the STAR
        //                     foreach (var trans; transVec) {
        //                         stars.getNode("value[" ~ i ~ "]", 1).setValue(s ~ "-" ~ trans);
        //                         i += 1;
        //                     }
        //                 } else {
        //                     # no transitions defined, simple case
        //                     stars.getNode("value[" ~ i ~ "]", 1).setValue(s);
        //                     i += 1;
        //                 }
        //             }

        //             gui.dialog_update("route-manager", "star");
        //         }

        //         var updateApproaches = func {
        //             approaches.removeChildren("value");
        //             var apt = flightplan().destination;
        //             var rwy = flightplan().destination_runway;

        //             if (apt == nil) {
        //                 return;
        //             }

        //             if (size(apt.getApproachList(rwy)) == 0) {
        //                 approaches.getNode("value[0]", 1).setValue("DEFAULT");
        //                 approaches.getNode("value[1]", 1).setValue("(none)");
        //                 gui.dialog_update("route-manager", "approach");
        //                 return;
        //             }

        //             var i=1;
        //             approaches.getNode("value[0]", 1).setValue("(none)");
        //             foreach (var s; apt.getApproachList(rwy)) {
        //                 approaches.getNode("value[" ~ i ~ "]", 1).setValue(s);
        //                 i += 1;
        //             }

        //             gui.dialog_update("route-manager", "approach");
        //         }

        //         var initPosition = func {
        //         var routeActive = routem.getNode("active").getValue();
        //         if (routeActive) return;

        //         # FIXME have user waypoints check
        //         var fp = flightplan();

        //         var airborne = getprop('/gear/gear[0]/wow') == 0;
        //         if (airborne) {
        //             printlog('info', 'route-manager dialog, init in-air, clearing departure settings');
        //             fp.departure = nil;
        //             return;
        //         }



        //         # we're on the ground, find the nearest airport to start from
        //         if (fp.departure == nil) {
        //             var apts = findAirportsWithinRange(25.0);
        //             if (size(apts) == 0) return; # no airports nearby
        //             fp.departure = apts[0]; # use the closest one
        //         }

        //         if (fp.departure_runway == nil) {
        //             printlog('info', 'selecting departure runway');
        //             var rwy = fp.departure.findBestRunwayForPos( geo.aircraft_position() );
        //             fp.departure_runway = rwy;
        //         }
        //         }

        //     # initialise departure values based on current position
        //         initPosition();

        //         updateRunways();
        //         updateSIDs();
        //         updateSTARs();
        //         updateApproaches();
        //     ]]></open>

        //     <close>
        //         file_selector.del();
        //         save_selector.del();
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 2

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr(" Departure:")
            }

            TextInput {
                horizontalAlignment: Text.AlignLeft
                id: departure_airport
                width: 70
                // property*: /autopilot/route-manager/departure/airport
                // live*: true
                // binding*: " dialog-apply departure-airport "
                // binding*: " nasal updateRunways(); "
            }

            Label {
                // format*: %s
                // property*: /autopilot/route-manager/departure/name
                // live*: true
                Layout.fillWidth: true
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Rwy:")
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: departure_runway
                // property*: /autopilot/route-manager/departure/runway
                // binding*: " dialog-apply departure-runway "
                // binding*: " nasal updateSIDs(); "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("SID:")
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: sid
                // property*: /autopilot/route-manager/departure/sid
                // binding*: " dialog-apply sid "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Arrival:")
            }

            TextInput {
                horizontalAlignment: Text.AlignLeft
                width: 70
                id: destination_airport
                // property*: /autopilot/route-manager/destination/airport
                // live*: true
                // binding*: " dialog-apply destination-airport "
                // binding*: " nasal updateRunways(); "
            }

            Label {
                Layout.fillWidth: true
                width: 200
                // format*: %s
                // property*: /autopilot/route-manager/destination/name
                // live*: true
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Rwy:")
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: destination_runway
                // property*: /autopilot/route-manager/destination/runway
                // binding*: " dialog-apply destination-runway "
                // binding*: " nasal updateSTARs(); updateApproaches(); "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Approach:")
            }

            ComboBox {
                width: 120
                //horizontalAlignment: Text.AlignLeft
                id: approach
                // property*: /autopilot/route-manager/destination/approach
                // binding*: " dialog-apply approach "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("STAR:")
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: star
                // property*: /autopilot/route-manager/destination/star
                // binding*: " dialog-apply star "
            }
        } // GridLayout


        RowLayout {
            width: parent.width

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr(" Cruise Speed (kts):")
            }

            TextInput {
                id: cruise_speed
                // live*: true
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
                width: 100
                // property*: /autopilot/route-manager/cruise/speed-kts
                // binding*: " dialog-apply cruise-speed "
            }

            Label {
                text: qsTr("Cruise Altitude (ft/FL):")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                id: cruise_alt
                // live*: true
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
                width: 100
                // property*: /autopilot/route-manager/cruise/altitude-ft
                // binding*: " dialog-apply cruise-alt "
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width
            // padding*: 2

            Label {
                text: qsTr("MMMMMMMMMMMMMMMM")
                // format*: Target: %s
                // property*: /autopilot/route-manager/wp[0]/id
                // live*: true
            }

            Label {
                text: qsTr("MMMMMMMMM")
                // format*: Dist: %.2f nm
                // property*: /autopilot/route-manager/wp[0]/dist
                // live*: true
            }

            Label {
                text: qsTr("MMMMMMMMM")
                // format*: ETA: %s
                // property*: /autopilot/route-manager/wp[0]/eta
                // live*: true
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 2
            Layout.fillWidth: true

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 4

            Label {
                text: qsTr(" Waypoint:")
            }

            TextInput {
                id: input
                Layout.fillWidth: true
                width: 220
                // property*: /sim/gui/dialogs/route-manager/input
            }

            Button {
                text: qsTr("Add")
                // default*: true
                // binding*: " dialog-apply input "
                // binding*: " nasal insert() "
                // binding*: " dialog-update "
            }

            Label {
                text: qsTr("")
            }
        } // RowLayout

        Label {
            padding: 1
            text: qsTr("Format: list of (airport|fix|nav|lon,lat) with optional @alt -- e.g. \"KSFO@900\", \"SAHEY CIITY@6000\"")
        }

        Label {
            padding: 1
            text: qsTr("Lon,lat can be entered signed, with NSEW, or as degrees and minutes, e.g. \"-2.5,51.3\", \"2.5W,51.3N\", \"11*47.17'E,48*21.23'N\"")
        }

        Label {
            padding: 1
            text: qsTr("Any location can be be offset by a radial and distance in Nm, e.g. DCS/45/10 or 18.5E,33.9S/290/4.5")
        }

        RowLayout {
            width: parent.width
            // padding*: 8

            Button {
                text: qsTr("Clear List")
                // equal*: true
                // binding*: " nasal clear() "
            }

            Button {
                text: qsTr("Remove")
                // equal*: true
                // binding*: " nasal remove() "
            }

            Button {
                text: qsTr("Route")
                // equal*: true
                // binding*: " nasal route() "
            }

            Button {
                text: qsTr("Jump To")
                // binding*: " nasal jump_to() "
            }

            Button {
                text: qsTr("Activate")
                // equal*: true
                // binding*: " dialog-apply "
                // binding*: " nasal activate_fp() "
            }

            Label {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("")
            }

            Button {
                text: qsTr("Load ...")
                // binding*: " nasal file_selector.open() "
            }

            Button {
                text: qsTr("Save ...")
                // binding*: " nasal save_selector.open(); "
            }

            Button {
                text: qsTr("Close")
                // key*: qsTr("Esc")
                onClicked: {
                    routeManagerDialog.closed(routeManagerDialog.id);
                }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                routeManagerDialog.closed(routeManagerDialog.id);
            }
        }
    } // buttons
}
