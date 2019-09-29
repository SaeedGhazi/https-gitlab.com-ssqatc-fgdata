import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: soundDialog

    width: 450
    height: 500
    position: Qt.point(80, 80)

    windowId: soundDialog.id
    title: "Sound Configuration"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         var dlg_root = cmdarg();

        //         # Fill the sound device combo box
        //         var combo = gui.findElementByName( dlg_root, "source-selection" );
        //         var wsn = props.globals.getNode( "sim/sound/devices" );
        //         if( wsn != nil ) {
        //             var devices = wsn.getChildren("device");
        //             forindex (var i; devices )
        //                 combo.getChild("value", i, 1).setValue(devices[i].getValue());
        //         }

        //         var apply = func {
        //             var new = getprop("sim/gui/dialogs/sound-dialog/source-selection");
        //             var current = getprop("sim/sound/device-name");
        //             if (cmp(current, new) != 0) {
        //                 setprop("sim/sound/devices/name", new);
        //                 setprop("sim/sound/device-name", new);
        //                 if(getprop("/sim/fgcom/enabled")) {
        //                     setprop("/sim/fgcom/enabled", 0);
        //                     settimer( func { fgcommand("reinit", props.Node.new({ "subsystem" : "sound" })); }, 0.5 );
        //                     settimer( func { setprop("/sim/fgcom/enabled", 1); }, 1 );
        //                 } else {
        //                     fgcommand("reinit", props.Node.new({ "subsystem" : "sound" }));
        //                 }
        //             }
        //         }

        //         # initialization
        //         var default_device = getprop("sim/sound/device-name");
        //         setprop( "sim/gui/dialogs/sound-dialog/source-selection", default_device);

        //     ]]></open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            Label {
                text: qsTr("Sound Device:")
                horizontalAlignment: Text.AlignRight
            }

            ComboBox {
                id: source_selection

                Layout.fillWidth: true
                // property*: sim/gui/dialogs/sound-dialog/source-selection
                // binding*: " dialog-apply source-selection "
                // binding*: " dialog-update sound-dialog "
            }
        } // RowLayout

        HorizontalLine {}

        GridLayout {
            width: parent.width
            columns: 4

            Label {
                text: qsTr("Channel")
                padding: 10
            }

            Label {
                text: qsTr("Enabled")
                padding: 10
            }

            Label {
                text: qsTr("Volume")
                padding: 10
            }

            Label {
                text: qsTr("External")
                padding: 10
            }

            Label {
                text: qsTr("Master")
                horizontalAlignment: Text.AlignLeft
            }

            CheckBox {
                // property*: /sim/sound/enabled
                // binding*: " dialog-apply "
            }

            Slider {
                // property*: /sim/sound/volume
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Effects")
                horizontalAlignment: Text.AlignLeft
            }

            CheckBox {
                // property*: /sim/sound/effects/enabled
                // binding*: " dialog-apply "
            }

            Slider {
                // property*: /sim/sound/effects/volume
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr(" ")
            }

            Label {
                text: qsTr("Avionics")
                horizontalAlignment: Text.AlignLeft
            }

            CheckBox {
                // property*: /sim/sound/avionics/enabled
                // binding*: " dialog-apply "
            }

            Slider {
                // property*: /sim/sound/avionics/volume
                // binding*: " dialog-apply "
            }

            CheckBox {
                // property*: /sim/sound/avionics/external-view
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr("ATC")
                horizontalAlignment: Text.AlignLeft
            }

            CheckBox {
                // property*: /sim/sound/atc/enabled
                // binding*: " dialog-apply "
            }

            Slider {
                // property*: /sim/sound/atc/volume
                // binding*: " dialog-apply "
            }

            CheckBox {
                // property*: /sim/sound/atc/external-view
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr("AI/MP")
                horizontalAlignment: Text.AlignLeft
            }

            CheckBox {
                // property*: /sim/sound/aimodels/enabled
                // binding*: " dialog-apply "
            }

            Slider {
                // property*: /sim/sound/aimodels/volume
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr(" ")
            }

        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Use voice synthesis for tutorials and comms (requires restart)")
            }

            CheckBox {
                // property*: /sim/sound/voices/enabled
                // binding*: " dialog-apply "
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Apply")
            // key*: qsTr("Enter")
            // binding*: " nasal apply() "
            // binding*: " dialog-apply "

            onClicked: {
                soundDialog.closed(soundDialog.id);
            }
        }

        Button {
            text: qsTr("Close")

            onClicked: {
                soundDialog.closed(soundDialog.id);
            }        }
    } // buttons
}
