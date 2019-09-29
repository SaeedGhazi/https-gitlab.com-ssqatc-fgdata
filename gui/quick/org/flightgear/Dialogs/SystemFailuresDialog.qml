import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: systemFailuresDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: systemFailuresDialog.id
    title: "System Failures"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         # Code to populate the engine entries.
        //         var groups = cmdarg().getChildren("group");
        //         var group = groups[1].getChildren("group")[2];
        //         var engines = props.globals.getNode("/engines");
        //         var row = 4;
        //         var engine = 0;
        //         var i = 0;

        //         group.removeChildren("checkbox");
        //         group.removeChildren("input");
        //         group.removeChildren("text");

        //         # Copy in the labels.
        //         var target = group.getNode("text[" ~ i ~ "]", 1);
        //         props.copy(group.getNode("engine-label"), target);
        //         i += 1;

        //         target = group.getNode("text[" ~ i ~ "]", 1);
        //         props.copy(group.getNode("mtbf-label"), target);
        //         i += 1;

        //         foreach (var e; engines.getChildren("engine")) {
        //             var starter = e.getChild("starter");
        //             var running = e.getChild("running");

        //             (starter != nil and starter != "" and starter.getType() != "NONE")
        //             or (running != nil and running != "" and running.getType() != "NONE")
        //             or continue;

        //             row = row + 1;

        //             # Set up the label
        //             target = group.getNode("text[" ~ i ~ "]", 1);
        //             props.copy(group.getNode("text-template"), target);
        //             target.getNode("row").setValue(row);

        //             if (size(engines.getChildren("engine")) == 1) {
        //                 target.getNode("label").setValue("Engine");
        //             } else {
        //                 # Engines are indexed from 1 in the GUI.
        //                 target.getNode("label").setValue("Engine " ~ (engine + 1));
        //             }

        //             # Now the checkbox
        //             target = group.getNode("checkbox[" ~ i ~ "]", 1);
        //             props.copy(group.getChild("checkbox-template"), target);
        //             target.getNode("row").setValue(row);

        //             var failure = "/sim/failure-manager/engines/engine[" ~ engine ~ "]/serviceable";
        //             target.getNode("property").setValue(failure);

        //             # Finally the MTBF
        //             target = group.getNode("input[" ~ i ~ "]", 1);
        //             props.copy(group.getChild("input-template"), target);
        //             target.getNode("row").setValue(row);
        //             i += 1;

        //             var mtbf = "/sim/failure-manager/engines/engine[" ~ engine ~ "]/mtbf";
        //             target.getNode("property").setValue(mtbf);
        //             engine += 1;
        //         }
        //     </open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            horizontalAlignment: Text.AlignLeft
            text: qsTr(" Uncheck a system to fail it, or set the Mean Time/Cycles Between Failures. ")
        }

        HorizontalLine {}

        GridLayout {
            width: parent.width

            Label {
                text: qsTr("System")
            }

            Label {
                text: qsTr("MTBF (sec)")
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Vacuum System")
            }

            CheckBox {
                // property*: /sim/failure-manager/systems/vacuum/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/systems/vacuum/mtbf
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Static System")
            }

            CheckBox {
                // property*: /sim/failure-manager/systems/static/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/systems/static/mtbf
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Pitot System")
            }

            CheckBox {
                // property*: /sim/failure-manager/systems/pitot/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/systems/pitot/mtbf
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr(" Electrical System")
            }

            CheckBox {
                // property*: /sim/failure-manager/systems/electrical/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/systems/electrical/mtbf
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Aileron")
            }

            CheckBox {
                // property*: /sim/failure-manager/controls/flight/aileron/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/controls/flight/aileron/mtbf
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Elevator")
            }

            CheckBox {
                // property*: /sim/failure-manager/controls/flight/elevator/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/controls/flight/elevator/mtbf
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Rudder")
            }

            CheckBox {
                // property*: /sim/failure-manager/controls/flight/rudder/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/controls/flight/rudder/mtbf
            }
        } // GridLayout

        HorizontalLine {}

        GridLayout {
            width: parent.width

            Label {
                text: qsTr("System")
            }

            Label {
                text: qsTr("MCBF")
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Landing Gear")
            }

            CheckBox {
                // property*: /sim/failure-manager/controls/gear/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/controls/gear/mcbf
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Flaps")
            }

            CheckBox {
                // property*: /sim/failure-manager/controls/flight/flaps/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/controls/flight/flaps/mcbf
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Speedbrake")
            }

            CheckBox {
                // property*: /sim/failure-manager/controls/flight/speedbrake/serviceable
            }

            TextInput {
                // property*: /sim/failure-manager/controls/flight/speedbrake/mcbf
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

            onClicked: {
                systemFailuresDialog.closed(systemFailuresDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")
            // binding*: " dialog-apply "
        }

        Button {
            text: qsTr("Refresh")
            // binding*: " dialog-update "
        }

        Button {
            text: qsTr("Cancel")
            // key*: qsTr("Esc")

            onClicked: {
                systemFailuresDialog.closed(systemFailuresDialog.id);
            }
        }
    } // buttons
}
