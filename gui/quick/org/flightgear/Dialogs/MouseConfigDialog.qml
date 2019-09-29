import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: mouseConfigDialog

    width: 480
    height: 420
    position: Qt.point(80, 80)

    windowId: mouseConfigDialog.id
    title: "Mouse Input Options"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var syncRadioState = func()
        //         {
        //             var cycle = getprop("/sim/mouse/right-button-mode-cycle-enabled");
        //             setprop("/sim/gui/dialogs/input-config/right-mouse-look", !cycle);
        //             setprop("/sim/gui/dialogs/input-config/right-mouse-cycle", cycle);
        //         }

        //         var rightMouseMode = func(newMode)
        //         {
        //             var doCycle = (newMode == "cycle");
        //             setprop("/sim/mouse/right-button-mode-cycle-enabled", doCycle);
        //             syncRadioState();
        //         }

        //         syncRadioState();
        //     </open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 1

            Label {
                text: qsTr("Pressing TAB cycles the mouse mode through different behaviours ")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("normal / flight-controls / view direction")
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr(" ")
            }

            Label {
                text: qsTr("The right-mouse button can be used in two different ways:")
                horizontalAlignment: Text.AlignLeft
            }
        } // GridLayout

        GridLayout {
            width: parent.width
            columns: 1

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr(" ")
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Press and hold right mouse to look around")
                // property*: /sim/gui/dialogs/input-config/right-mouse-look
                // live*: true
                // binding*: " nasal rightMouseMode("look") "
            }

            RadioButton {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Click right mouse to cycle mouse behaviour")
                // property*: /sim/gui/dialogs/input-config/right-mouse-cycle
                // live*: true
                // binding*: " nasal rightMouseMode("cycle") "
            }

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignLeft
            }
        } // GridLayout

        GridLayout {
            width: parent.width

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr(" ")
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Disable flight-controls via mouse")
                // property*: /sim/mouse/skip-flight-controls-mode
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignLeft
            }
        } // GridLayout

        GridLayout {
            width: parent.width

            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr(" ")
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr(" Reverse mouse wheel direction")
                // property*: /sim/mouse/invert-mouse-wheel
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr(" ")
                horizontalAlignment: Text.AlignLeft
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                mouseConfigDialog.closed(mouseConfigDialog.id);
            }
        }
    } // buttons
}
