import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: locationInAirDialog

    width: 400
    height: 450
    position: Qt.point(80, 80)

    windowId: locationInAirDialog.id
    title: "Position Aircraft In Air"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var p = props.globals.getNode("/sim/gui/dialogs/location-in-air/", 1);
        //         var mode = {
        //             airport: p.getNode("airport", 1),
        //             lonlat:  p.getNode("lonlat", 1),
        //             vor:     p.getNode("vor", 1),
        //             ndb:     p.getNode("ndb", 1),
        //             fix:     p.getNode("fix", 1),
        //         };

        //         var set_radio = func(m) {
        //             foreach (var k; keys(mode)) {
        //                 mode[k].setBoolValue(m == k);
        //             }
        //         }

        //         var initialized = 0;
        //         foreach (var k; keys(mode)) {
        //             if (mode[k].getType() == "NONE") {
        //                 mode[k].setBoolValue(0);
        //             }
        //             initialized += mode[k].getBoolValue();
        //         }
        //         if (!initialized) {
        //             set_radio("airport");
        //         }
        //         var pickNearest = func(type,propname,freqpropname) {
        //             var found = navinfo(type,getprop(propname));
        //             if( found == nil or size(found) == 0 ) {
        //                 print(type, " ", getprop(propname), " NOT found");
        //                 setprop(propname, "");
        //                 setprop(freqpropname, "");
        //                 return;
        //             }
        //             setprop(propname, found[0].id);
        //             setprop(freqpropname, found[0].frequency / 100.0);
        //         }
        //     </open>

        //     <close># just kept for educational purposes :-)</close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            text: qsTr("Surface Point")
        }

        GridLayout {
            width: parent.width
            columns: 5

            RadioButton {
                // live*: true
                // property*: /sim/gui/dialogs/location-in-air/airport
                // binding*: " dialog-apply "
                // binding*: " nasal set_radio("airport") "
            }

            Label {
                text: qsTr("Airport:")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/airport-id
                // binding*: " nasal set_radio("airport") "
            }

            Label {
                text: qsTr(" Runway:")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/runway
                // binding*: " nasal set_radio("airport") "
            }

            RadioButton {
                // live*: true
                // property*: /sim/gui/dialogs/location-in-air/lonlat
                // binding*: " dialog-apply "
                // binding*: " nasal set_radio("lonlat") "
            }

            Label {
                text: qsTr("Longitude:")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/longitude-deg
                // binding*: " nasal set_radio("lonlat") "
            }

            Label {
                text: qsTr(" Latitude:")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/latitude-deg
                // binding*: " nasal set_radio("lonlat") "
            }

            RadioButton {
                // live*: true
                // property*: /sim/gui/dialogs/location-in-air/vor
                // binding*: " dialog-apply "
                // binding*: " nasal set_radio("vor") "
            }

            Label {
                text: qsTr("VOR:")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/vor-id
                // binding*: " nasal set_radio("vor") "
            }

            Label {
                text: qsTr(" ")
                Layout.columnSpan: 2
            }

            RadioButton {
                // live*: true
                // horizontalAlignment: Text.AlignLeft
                // property*: /sim/gui/dialogs/location-in-air/ndb
                // binding*: " dialog-apply "
                // binding*: " nasal set_radio("ndb") "
            }

            Label {
                text: qsTr("NDB:")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/ndb-id
                // binding*: " nasal set_radio("ndb") "
            }

            Label {
                text: qsTr(" ")
                Layout.columnSpan: 2
            }

            RadioButton {
                // live*: true
                // property*: /sim/gui/dialogs/location-in-air/fix
                // horizontalAlignment: Text.AlignLeft
                // binding*: " dialog-apply "
                // binding*: " nasal set_radio("fix") "
            }

            Label {
                text: qsTr("Fix:")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/fix
                // binding*: " nasal set_radio("fix") "
            }

            Label {
                text: qsTr(" ")
                Layout.columnSpan: 2
            }
        } // GridLayout

        HorizontalLine {}

        Label {
            text: qsTr("Relative Position")
        }

        GridLayout {
            width: parent.width
            columns: 4

            Label {
                text: qsTr(" Distance (nm):")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/offset-distance-nm
            }

            Label {
                text: qsTr("Azimuth (deg):")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/offset-azimuth-deg
            }

            Label {
                text: qsTr("Altitude (ft):")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/altitude-ft
            }

            Label {
                text: qsTr(" Glidepath (deg):")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/glideslope-deg
            }

            Label {
                text: qsTr("Airspeed (kt):")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/airspeed-kt
            }

            Label {
                text: qsTr("Heading (deg):")
                horizontalAlignment: Text.AlignRight
            }

            TextInput {
                // property*: /sim/presets/heading-deg
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // binding*: " dialog-apply "
            // binding*: " nasal setprop("/sim/presets/parkpos", ""); if (!mode.airport.getBoolValue()) { setprop("/sim/presets/airport-id", ""); setprop("/sim/presets/runway", ""); setprop("/sim/presets/runway-requested", 0); } else { var runway = getprop("/sim/presets/runway"); if (runway != "") { setprop("/sim/presets/runway-requested", 1); } } if (!mode.lonlat.getBoolValue()) { setprop("/sim/presets/longitude-deg", -9999); setprop("/sim/presets/latitude-deg", -9999); } if (!mode.vor.getBoolValue()) { setprop("/sim/presets/vor-id", ""); } else { pickNearest("vor","/sim/presets/vor-id","/sim/presets/vor-freq"); } if (!mode.ndb.getBoolValue()) { setprop("/sim/presets/ndb-id", ""); } else { pickNearest("ndb","/sim/presets/ndb-id","/sim/presets/ndb-freq"); } if (!mode.fix.getBoolValue()) { setprop("/sim/presets/fix", ""); } var speedRequested = getprop("/sim/presets/airspeed-kt"); if (speedRequested > 0) { setprop("/sim/presets/speed-set", "knots"); } "
            // binding*: " reposition "
            // binding*: " nasal ac = getprop("/sim/aircraft"); if (ac == "ufo") { return } var eng = props.globals.getNode("/controls/engines"); if (eng != nil) { foreach (c; eng.getChildren("engine")) { c.getNode("magnetos", 1).setIntValue(3); c.getNode("throttle", 1).setDoubleValue(0.5); } } "

            onClicked: {
                locationInAirDialog.closed(locationInAirDialog.id);
            }
        }

        Button {
            text: qsTr("Cancel")
            // key*: qsTr("Esc")

            onClicked: {
                locationInAirDialog.closed(locationInAirDialog.id);
            }
        }
    } // buttons
}
