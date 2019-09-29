import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: vinsonDialog

    width: 640
    height: 300
    position: Qt.point(80, 80)

    windowId: vinsonDialog.id
    title: "USS Carl Vinson Controls"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 1
            rows: 5

            Label {
                text: qsTr("Course")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Turn to launch course")
                // property*: /controls/vinson/turn-to-launch-hdg
                // live*: true
                // binding*: " dialog-apply "
                // binding*: " nasal var v = getprop("/controls/vinson/turn-to-launch-hdg"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ if (c.getNode("name").getValue() == "Vinson") { c.getNode("controls/turn-to-launch-hdg").setBoolValue(v); c.getNode("controls/turn-to-recovery-hdg").setBoolValue(0); c.getNode("controls/turn-to-base-course").setBoolValue(0); } } setprop("/controls/vinson/turn-to-base-course", 0); setprop("/controls/vinson/turn-to-recovery-hdg", 0); "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Turn to recovery course")
                // property*: /controls/vinson/turn-to-recovery-hdg
                // live*: true
                // binding*: " dialog-apply "
                // binding*: " nasal var v = getprop("/controls/vinson/turn-to-recovery-hdg"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ if (c.getNode("name").getValue() == "Vinson") { c.getNode("controls/turn-to-recovery-hdg").setBoolValue(v); c.getNode("controls/turn-to-launch-hdg").setBoolValue(0); c.getNode("controls/turn-to-base-course").setBoolValue(0); } } setprop("/controls/vinson/turn-to-base-course", 0); setprop("/controls/vinson/turn-to-launch-hdg", 0); "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Turn to base course")
                // property*: /controls/vinson/turn-to-base-course
                // live*: true
                // binding*: " dialog-apply "
                // binding*: " nasal var v = getprop("/controls/vinson/turn-to-base-course"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ if (c.getNode("name").getValue() == "Vinson") { c.getNode("controls/turn-to-base-course").setBoolValue(v); c.getNode("controls/turn-to-recovery-hdg").setBoolValue(0); c.getNode("controls/turn-to-launch-hdg").setBoolValue(0); } } setprop("/controls/vinson/turn-to-launch-hdg", 0); setprop("/controls/vinson/turn-to-recovery-hdg", 0); "
            }
        } // GridLayout

        HorizontalLine {}

        GridLayout {
            width: parent.width
            columns: 5

            Label {
                text: qsTr("Equipment")
            }

            CheckBox {
                text: qsTr("Elevator 1")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/vinson/elevator[0]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Elevator 2")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/vinson/elevator[1]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("JBD 1")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/vinson/jbd[0]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("JBD 2")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/vinson/jbd[1]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("JBD 3")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/vinson/jbd[2]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("JBD 4")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/vinson/jbd[3]/state
                // binding*: " dialog-apply "
            }
        } // GridLayout

        HorizontalLine {}

        GridLayout {
            width: parent.width
            columns: 5

            Label {
                text: qsTr("Options")
            }

            CheckBox {
                text: qsTr("Enable Crew")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/vinson/crew
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Deck lights")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/vinson/lights
                // binding*: " dialog-apply "
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

            onClicked: {
                vinsonDialog.closed(vinsonDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")

            onClicked: {
                // binding*: " dialog-apply "
            }
        }

        Button {
            text: qsTr("Reset")

            onClicked: {
                // binding*: " dialog-update "
            }
        }

        Button {
            text: qsTr("Cancel")

            onClicked: {
                vinsonDialog.closed(vinsonDialog.id);
            }
        }
    } // buttons
}
