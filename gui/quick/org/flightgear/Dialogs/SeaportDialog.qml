import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: seaportDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: seaportDialog.id
    title: "Seaport"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <!--
        //         Our coastlines are too unrealiable to just teleport to the nearest seaport.
        //         We may have to search around its reported location until we actually find water.
        //     -->
        //     <open>
        //         var label = cmdarg().getNode("text/label");
        //         var apt = airportinfo("seaport");
        //         var rwys = apt.runways;
        //         var lat = apt.lat;
        //         var lon = apt.lon;

        //         label.setValue("  The nearest seaport is \"" ~ apt.name ~ "\" (" ~ apt.id ~ ")  ");

        //         var goto_seaport = func {
        //             var rwyid = keys(rwys)[0];
        //             var rwy = rwys[rwyid];
        //             print("SP: going to seaport ", apt.id, "/", rwyid, "  (\"", apt.name, "\")");
        //             setprop("/sim/presets/airport-id", apt.id);
        //             teleport(rwy.lat, rwy.lon);
        //             settimer(verify, 4);
        //         }

        //         var verify = func {
        //             var p = geo.aircraft_position();
        //             if (on_water(p.lat(), p.lon())) {
        //                 print("SP: seaport center is on water");
        //                 return;
        //             }

        //             foreach (var r; keys(rwys)) {
        //                 print("SP: trying runway ", r);
        //                 var lat = rwys[r].lat;
        //                 var lon = rwys[r].lon;
        //                 if (on_water(lat, lon)) {
        //                     setprop("/sim/presets/runway", r);
        //                     setprop("/sim/presets/heading-deg", rwys[r].heading);
        //                     print("SP: runway ", r, " is on water");
        //                     return teleport(lat, lon);
        //                 }
        //             }

        //             print("SP: trying circle");
        //             for (var dist = 500; dist &lt;= 1500; dist += 500) {
        //                 print("SP:\tat distance ", dist, " m");

        //                 for (var course = 0; course &lt; 360; course += 60) {
        //                     print("SP:\t\tat course ", course, " degree");

        //                     p.set_latlon(apt.lat, apt.lon);
        //                     p.apply_course_distance(course, dist);
        //                     if (on_water(p.lat(), p.lon())) {
        //                         print("SP: found water");
        //                         setprop("/sim/presets/heading-deg", course);
        //                         return teleport(p.lat(), p.lon());
        //                     }
        //                 }
        //             }

        //             print("SP: no water found");
        //         }

        //         var teleport = func(lat, lon) {
        //             setprop("/sim/presets/latitude-deg", lat);
        //             setprop("/sim/presets/longitude-deg", lon);
        //             fgcommand("reposition");
        //         }

        //         var on_water = func(lat, lon) {
        //             var g = geodinfo(lat, lon);
        //             return g != nil and g[1] != nil and !g[1].solid;
        //         }
        //     </open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            Label {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Location inappropriate for a seaplane")
            }

            Label {
                Layout.fillWidth: true
            }
        } // RowLayout

        HorizontalLine {}

        Label {
            text: qsTr("")
        }

        RowLayout {
            width: parent.width

            Button {
                text: qsTr("Stay anyway")
                // equal*: 1
                // key*: qsTr("Esc")
                onClicked: {
                    seaportDialog.closed(seaportDialog.id);
                }
            }

            Button {
                text: qsTr("Go to seaport")
                // default*: 1
                // equal*: 1
                // binding*: " nasal goto_seaport() "
                onClicked: {
                    seaportDialog.closed(seaportDialog.id);
                }
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
                seaportDialog.closed(seaportDialog.id);
            }
        }
    } // buttons
}
