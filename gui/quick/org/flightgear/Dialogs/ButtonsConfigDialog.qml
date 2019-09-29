import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: buttonsConfigDialog

    width: 800
    height: 400
    position: Qt.point(80, 80)

    windowId: buttonsConfigDialog.id
    title: "Button Configuration"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted {
        // <nasal>
        //     <open><![CDATA[
        //         var assignButton = func(cmd) {
        //         var i = getprop("/sim/gui/dialogs/joystick-config/current-button");
        //         setprop("/sim/gui/dialogs/joystick-config/button[" ~ i ~ "]/binding", cmd);
        //         joystick.writeConfig();
        //         fgcommand("reinit", props.Node.new({"subsystem": "input"}));
        //         fgcommand("dialog-close", props.Node.new({"dialog-name": "button-config"}));
        //         fgcommand("dialog-close", props.Node.new({"dialog-name": "joystick-config"}));
        //         fgcommand("dialog-show", props.Node.new({"dialog-name": "joystick-config"}));
        //         }
        //     ]]></open>
        //     <close><![CDATA[
        //     ]]></close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            text: qsTr("Select the command you wish to assign to this button.")
            //horizontalAlignment: Text.AlignLeft
        }

        HorizontalLine {}

        GridLayout {
            width: parent.width
            flow: GridLayout.TopToBottom
            rows: 12

            Label {
                text: qsTr("Flight Surface Trim")
            }

            Button {
                text: qsTr("Elevator Trim Up")
                // binding*: " nasal assignButton("Elevator Trim Up"); "
            }

            Button {
                text: qsTr("Elevator Trim Down")
                // binding*: " nasal assignButton("Elevator Trim Down"); "
            }

            Button {
                text: qsTr("Elevator Trim Pos")
                // binding*: " nasal assignButton("Elevator Trim Pos"); "
            }

            Button {
                text: qsTr("Rudder Trim Left")
                // binding*: " nasal assignButton("Rudder Trim Left"); "
            }

            Button {
                text: qsTr("Rudder Trim Right")
                // binding*: " nasal assignButton("Rudder Trim Right"); "
            }

            Button {
                text: qsTr("Aileron Trim Left")
                // binding*: " nasal assignButton("Aileron Trim Left"); "
            }

            Button {
                text: qsTr("Aileron Trim Right")
                // binding*: " nasal assignButton("Aileron Trim Right"); "
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Control Surfaces")
            }

            Button {
                text: qsTr("Flaps Up")
                // binding*: " nasal assignButton("Flaps Up"); "
            }

            Button {
                text: qsTr("Flaps Down")
                // binding*: " nasal assignButton("Flaps Down"); "
            }

            Button {
                text: qsTr("Gear Up")
                // binding*: " nasal assignButton("Gear Up"); "
            }

            Button {
                text: qsTr("Gear Down")
                // binding*: " nasal assignButton("Gear Down"); "
            }

            Button {
                text: qsTr("Gear Toggle")
                // binding*: " nasal assignButton("Gear Toggle"); "
            }

            Button {
                text: qsTr("Spoilers Retract")
                // binding*: " nasal assignButton("Spoilers Retract"); "
            }

            Button {
                text: qsTr("Spoilers Deploy")
                // binding*: " nasal assignButton("Spoilers Deploy"); "
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Powerplant Controls")
            }

            Button {
                text: qsTr("Throttle Up")
                // binding*: " nasal assignButton("Throttle Up"); "
            }

            Button {
                text: qsTr("Throttle Down")
                // binding*: " nasal assignButton("Throttle Down"); "
            }

            Button {
                text: qsTr("Mixture Rich")
                // binding*: " nasal assignButton("Mixture Rich"); "
            }

            Button {
                text: qsTr("Mixture Lean")
                // binding*: " nasal assignButton("Mixture Lean"); "
            }

            Button {
                text: qsTr("Propeller Fine")
                // binding*: " nasal assignButton("Propeller Fine"); "
            }

            Button {
                text: qsTr("Propeller Coarse")
                // binding*: " nasal assignButton("Propeller Coarse"); "
            }

            Button {
                text: qsTr("All Reverser Toggle")
                // binding*: " nasal assignButton("Reverser Toggle"); "
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Other Aircraft Controls")
            }

            Button {
                text: qsTr("Brakes")
                // binding*: " nasal assignButton("Brakes"); "
            }

            Button {
                text: qsTr("Auto air/ground brakes")
                // binding*: " nasal assignButton("Brakes (air/wheel)"); "
            }

            Button {
                text: qsTr("Brakes (air/wheel)")
                // binding*: " nasal assignButton("Brakes (air/wheel)"); "
            }

            Button {
                text: qsTr("Parking brakes")
                // binding*: " nasal assignButton("Parking brakes"); "
            }

            Button {
                text: qsTr("FGCom PTT(1)")
                // binding*: " nasal assignButton("FGCom PTT"); "
            }

            Button {
                text: qsTr("FGCom PTT(2)")
                // binding*: " nasal assignButton("FGCom PTT(2)"); "
            }

            Button {
                text: qsTr("Trigger")
                // binding*: " nasal assignButton("Trigger"); "
            }

            Button {
                text: qsTr("Custom")
                // binding*: " nasal assignButton("Custom"); "
            }

            Button {
                text: qsTr("NWS toggle")
                // binding*: " nasal assignButton("NWS toggle"); "
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Simulator Controls")
            }

            Button {
                text: qsTr("View Decrease")
                // binding*: " nasal assignButton("View Decrease"); "
            }

            Button {
                text: qsTr("View Increase")
                // binding*: " nasal assignButton("View Increase"); "
            }

            Button {
                text: qsTr("View Cycle Forwards")
                // binding*: " nasal assignButton("View Cycle Forwards"); "
            }

            Button {
                text: qsTr("View Cycle Backwards")
                // binding*: " nasal assignButton("View Cycle Backwards"); "
            }

            Button {
                text: qsTr("View Left")
                // binding*: " nasal assignButton("View Left"); "
            }

            Button {
                text: qsTr("View Right")
                // binding*: " nasal assignButton("View Right"); "
            }

            Button {
                text: qsTr("View Up")
                // binding*: " nasal assignButton("View Up"); "
            }

            Button {
                text: qsTr("View Down")
                // binding*: " nasal assignButton("View Down"); "
            }

            Button {
                text: qsTr("Total Freeze")
                // binding*: " nasal assignButton("Total Freeze"); "
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Military")
            }

            Button {
                text: qsTr("Trigger")
                // binding*: " nasal assignButton("Trigger"); "
            }

            Button {
                text: qsTr("Pickle")
                // binding*: " nasal assignButton("Pickle"); "
            }

            Button {
                text: qsTr("Target next")
                // binding*: " nasal assignButton("Target next"); "
            }

            Button {
                text: qsTr("Target previous")
                // binding*: " nasal assignButton("Target previous"); "
            }

            Button {
                text: qsTr("Weapon next")
                // binding*: " nasal assignButton("Weapon next"); "
            }

            Button {
                text: qsTr("Weapon previous")
                // binding*: " nasal assignButton("Weapon previous"); "
            }

            Button {
                text: qsTr("Azimuth left")
                // binding*: " nasal assignButton("Azimuth left"); "
            }

            Button {
                text: qsTr("Azimuth right")
                // binding*: " nasal assignButton("Azimuth right"); "
            }

            Button {
                text: qsTr("Elevation up")
                // binding*: " nasal assignButton("Elevation up"); "
            }

            Button {
                text: qsTr("Elevation down")
                // binding*: " nasal assignButton("Elevation down"); "
            }

            Button {
                text: qsTr("Missile Reject")
                // binding*: " nasal assignButton("Missile Reject"); "
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Remove assignment")
            // binding*: " nasal assignButton("None"); "
        }

        Button {
            text: qsTr("Close")

            onClicked: {
                buttonsConfigDialog.closed(buttonsConfigDialog.id);
            }
        }
    } // buttons
}
