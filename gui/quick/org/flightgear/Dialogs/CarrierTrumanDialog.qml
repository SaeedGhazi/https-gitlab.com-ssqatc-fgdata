import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: trumanDialog

    width: 640
    height: 350
    position: Qt.point(80, 80)

    windowId: trumanDialog.id
    title: "USS Harry S. Truman Controls"

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
            columns: 5

            Label {
                text: qsTr("Course")
            }

            Label {
                text: qsTr("Turn to launch course")
                horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/turn-to-launch-hdg
                // live*: true
                // binding*: " dialog-apply "
                // binding*: " nasal var v = getprop("/controls/truman/turn-to-launch-hdg"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ if (c.getNode("name").getValue() == "Truman") { c.getNode("controls/turn-to-launch-hdg").setBoolValue(v); c.getNode("controls/turn-to-recovery-hdg").setBoolValue(0); c.getNode("controls/turn-to-base-course").setBoolValue(0); } } setprop("/controls/truman/turn-to-base-course", 0); setprop("/controls/truman/turn-to-recovery-hdg", 0); "
            }

            Label {
                text: qsTr("Turn to recovery course")
                horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/turn-to-recovery-hdg
                // live*: true
                // binding*: " dialog-apply "
                // binding*: " nasal var v = getprop("/controls/truman/turn-to-recovery-hdg"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ if (c.getNode("name").getValue() == "Truman") { c.getNode("controls/turn-to-recovery-hdg").setBoolValue(v); c.getNode("controls/turn-to-launch-hdg").setBoolValue(0); c.getNode("controls/turn-to-base-course").setBoolValue(0); } } setprop("/controls/truman/turn-to-base-course", 0); setprop("/controls/truman/turn-to-launch-hdg", 0); "
            }

            Label {
                text: qsTr("Turn to base course")
                horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/turn-to-base-course
                // live*: true
                // binding*: " dialog-apply "
                // binding*: " nasal var v = getprop("/controls/truman/turn-to-base-course"); foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){ if (c.getNode("name").getValue() == "Truman") { c.getNode("controls/turn-to-base-course").setBoolValue(v); c.getNode("controls/turn-to-recovery-hdg").setBoolValue(0); c.getNode("controls/turn-to-launch-hdg").setBoolValue(0); } } setprop("/controls/truman/turn-to-launch-hdg", 0); setprop("/controls/truman/turn-to-recovery-hdg", 0); "
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
                // property*: /controls/truman/elevator[0]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Elevator 2")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/elevator[1]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Elevator 3")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/elevator[2]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Elevator 4")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/elevator[3]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Door 1")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/door[0]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Door 2")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/door[1]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Door 3")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/door[2]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Door 4")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/door[3]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("JBD 1")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/jbd[0]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("JBD 2")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/jbd[1]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("JBD 3")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/jbd[2]/state
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("JBD 4")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/jbd[3]/state
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
                text: qsTr("Enable Deck Park")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/deck-park
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Enable Crew")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/crew
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Deck lights")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/lights
                // binding*: " dialog-apply "
            }

            CheckBox {
                text: qsTr("Enable Wave motion")
                //horizontalAlignment: Text.AlignLeft
                // property*: /controls/truman/wave-motion
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
                aiCarrierDialog.closed(aiCarrierDialog.id);
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
                aiCarrierDialog.closed(aiCarrierDialog.id);
            }
        }
    } // buttons
}
