import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: ntpsTargetDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: ntpsTargetDialog.id
    title: "Target Task Selection"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         p = props.globals.getNode("/sim/gui/dialogs/NTPS/task", 1);
        //         mode = {
        //             straight: p.getNode("straight", 1),
        //             turns:    p.getNode("turns", 1),
        //             pitch:    p.getNode("pitch", 1),
        //             both:     p.getNode("both", 1),
        //         };

        //         set_radio = func(m) {
        //             foreach (k; keys(mode)) {
        //                 mode[k].setBoolValue(m == k);
        //             }
        //         }

        //         initialized = 0;
        //         foreach (k; keys(mode)) {
        //             if (mode[k].getType() == "NONE") {
        //                 mode[k].setBoolValue(0);
        //             }
        //             initialized += mode[k].getBoolValue();
        //         }
        //         if (!initialized) {
        //             set_radio("straight");
        //         }
        //     </open>

        //     <close># just kept for educational purposes :-)</close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 8

            Item {
                Layout.fillWidth: true

                GridLayout {
                    width: parent.width

                    // property*: /sim/gui/dialogs/NTPS/task/straight
                    // live*: true
                    // binding*: " nasal set_radio("straight"); setprop("/autopilot/lead-target/task", "straight") "

                    Label {
                        text: qsTr("Straight and Level")
                        horizontalAlignment: Text.AlignLeft
                    }

                    // property*: /sim/gui/dialogs/NTPS/task/turns
                    // live*: true
                    // binding*: " nasal set_radio("turns"); setprop("/autopilot/lead-target/task", "turns"); "

                    Label {
                        text: qsTr("Level Turns")
                        horizontalAlignment: Text.AlignLeft
                    }

                    // property*: /sim/gui/dialogs/NTPS/task/pitch
                    // live*: true
                    // binding*: " nasal set_radio("pitch"); setprop("/autopilot/lead-target/task", "pitch"); "

                    Label {
                        text: qsTr("Straight Pitch Changes")
                        horizontalAlignment: Text.AlignLeft
                    }

                    // property*: /sim/gui/dialogs/NTPS/task/both
                    // live*: true
                    // binding*: " nasal set_radio("both"); setprop("/autopilot/lead-target/task", "lazy-eights"); "

                    Label {
                        text: qsTr("Lazy Eights")
                        horizontalAlignment: Text.AlignLeft
                    }
                } // GridLayout
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
                ntpsTargetDialog.closed(ntpsTargetDialog.id);
            }
        }
    } // buttons
}
