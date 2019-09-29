import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: buttonAxisConfigDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: buttonAxisConfigDialog.id
    title: "Joystick Axis Configuration"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var assignAxis = func(cmd) {

        //         var i = getprop("/sim/gui/dialogs/joystick-config/current-axis");
        //         setprop("/sim/gui/dialogs/joystick-config/axis[" ~ i ~ "]/binding", cmd);

        //         joystick.writeConfig();
        //         fgcommand("reinit", props.Node.new({"subsystem": "input"}));
        //         fgcommand("dialog-close", props.Node.new({"dialog-name": "button-axis-config"}));
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
            text: qsTr("Select the operation to assign to this axis.")
            horizontalAlignment: Text.AlignLeft
        }

        HorizontalLine {}

        GridLayout {
            width: parent.width

            Label {
                text: qsTr("Flight Controls")
            }

            Button {
                text: qsTr("Aileron")
                // binding*: " nasal assignAxis("Aileron"); "
            }

            Button {
                text: qsTr("Elevator")
                // binding*: " nasal assignAxis("Elevator"); "
            }

            Button {
                text: qsTr("Rudder")
                // binding*: " nasal assignAxis("Rudder"); "
            }

            Button {
                text: qsTr("Brake Left")
                // binding*: " nasal assignAxis("Brake Left"); "
            }

            Button {
                text: qsTr("Brake Right")
                // binding*: " nasal assignAxis("Brake Right"); "
            }

            Button {
                text: qsTr("Flaps")
                // binding*: " nasal assignAxis("Flaps"); "
            }

            Button {
                text: qsTr("Wings")
                // binding*: " nasal assignAxis("Wings"); "
            }

            Label {
                text: qsTr("Trim")
            }

            Button {
                text: qsTr("Aileron Trim to position")
                // binding*: " nasal assignAxis("Aileron Trim"); "
            }

            Button {
                text: qsTr("Elevator Trim to position")
                // binding*: " nasal assignAxis("Elevator Trim"); "
            }

            Button {
                text: qsTr("Rudder Trim to position")
                // binding*: " nasal assignAxis("Rudder Trim"); "
            }

            Button {
                text: qsTr("Aileron Trim inc.")
                // binding*: " nasal assignAxis("Aileron Trim inc."); "
            }

            Button {
                text: qsTr("Elevator Trim inc.")
                // binding*: " nasal assignAxis("Elevator Trim inc."); "
            }

            Button {
                text: qsTr("Rudder Trim inc.")
                // binding*: " nasal assignAxis("Rudder Trim inc."); "
            }

            Label {
                text: qsTr("Engines")
            }

            Button {
                text: qsTr("Throttle All Engines")
                // binding*: " nasal assignAxis("Throttle All Engines"); "
            }

            Button {
                text: qsTr("Mixture All Engines")
                // binding*: " nasal assignAxis("Mixture All Engines"); "
            }

            Button {
                text: qsTr("Propeller All Engines")
                // binding*: " nasal assignAxis("Propeller All Engines"); "
            }

            Button {
                text: qsTr("Throttle Engine 0")
                // binding*: " nasal assignAxis("Throttle Engine 0"); "
            }

            Button {
                text: qsTr("Mixture Engine 0")
                // binding*: " nasal assignAxis("Mixture Engine 0"); "
            }

            Button {
                text: qsTr("Propeller Pitch Engine 0")
                // binding*: " nasal assignAxis("Propeller Pitch Engine 0"); "
            }

            Button {
                text: qsTr("Throttle Engine 1")
                // binding*: " nasal assignAxis("Throttle Engine 1"); "
            }

            Button {
                text: qsTr("Mixture Engine 1")
                // binding*: " nasal assignAxis("Mixture Engine 1"); "
            }

            Button {
                text: qsTr("Propeller Pitch Engine 1")
                // binding*: " nasal assignAxis("Propeller Pitch Engine 1"); "
            }

            Button {
                text: qsTr("Reverser All Engines")
                // binding*: " nasal assignAxis("Reverser All Engines"); "
            }

            Label {
                text: qsTr("Other")
            }

            Button {
                text: qsTr("View (horizontal)")
                // binding*: " nasal assignAxis("View (horizontal)"); "
            }

            Button {
                text: qsTr("View (vertical)")
                // binding*: " nasal assignAxis("View (vertical)"); "
            }

            Button {
                text: qsTr("View Horizontal Axis")
                // binding*: " nasal assignAxis("View Horizontal Axis"); "
            }

            Button {
                text: qsTr("View Vertical Axis")
                // binding*: " nasal assignAxis("View Vertical Axis"); "
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
            // binding*: " nasal assignAxis("None"); "
        }

        Button {
            text: qsTr("Close")

            onClicked: {
                buttonAxisConfigDialog.closed(buttonAxisConfigDialog.id);
            }
        }
    } // buttons
}
