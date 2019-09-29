import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: joystickConfigDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: joystickConfigDialog.id
    title: "Joystick Configuration"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         <![CDATA[
        //         var dlgRoot = cmdarg();

        //         var DIALOG_ROOT  = "/sim/gui/dialogs/joystick-config";

        //         # Read the current bindings
        //         joystick.readConfig();

        //         # Fill in the joystick names combo box.
        //         var joysticks = props.globals.getNode("/input/joysticks").getChildren("js");

        //         if (size(joysticks) == 0) {
        //             # No joysticks found - no point filling in rest of dialog
        //             setprop(DIALOG_ROOT ~ "joystick-count", 0);  
        //         } else {
        //             var jsselect = gui.findElementByName(dlgRoot, "jsselect" );

        //             forindex (var joystick_index; joysticks) {
        //                 var js = joysticks[joystick_index];
        //                 var js_id = "unknown";
        //                 if ((js.getNode("id") != nil) and (js.getNode("id").getValue() != nil))
        //                 {  
        //                     js_id = js.getNode("id").getValue();
        //                 }

        //                 jsselect.getNode("value[" ~ joystick_index ~ "]", 1).setValue(js_id);
        //             }

        //             var joystick_index = getprop(DIALOG_ROOT ~ "/selected-joystick-index");

        //             var table = gui.findElementByName(dlgRoot, "axistable");
        //             table.removeChildren("checkbox");
        //             table.removeChildren("combo");

        //             # Fill in the valid axis bindings
        //             for (var i = 0; i < joystick.MAX_AXES; i = i + 1) {

        //                 # Label      
        //                 var t = table.getChild("text", 2*i + 4, 1);

        //                 t.getNode("row", 1).setValue(i + 1);

        //                 t.getNode("col", 1).setValue(0);
        //                 t.getNode("label", 1).setValue("Axis " ~ i);

        //                 # Raw data
        //                 t = table.getChild("text", 2*i + 5, 1);
        //                 t.getNode("property", 1).setValue("/devices/status/joysticks/joystick[" ~ joystick_index ~ "]/axis[" ~ i ~ "]");
        //                 t.getNode("row", 1).setValue(i +1 );
        //                 t.getNode("col", 1).setValue(1);
        //                 t.getNode("label", 1).setValue("01234");
        //                 t.getNode("format", 1).setValue("%2.2f");
        //                 t.getNode("halign", 1).setValue("right");
        //                 t.getNode("live", 1).setValue(1);

        //                 # Axis Binding. Changed for 2018.1 to have a button rather than a dropdown as this
        //                 # allows us to have a nicer UI and to keep compatible with the old engine bindings 
        //                 t = table.getChild("button", i, 1);
        //                 t.getNode("name", 1).setValue("axis" ~ i ~ "binding");
        //                 t.getNode("row", 1).setValue(i + 1);
        //                 t.getNode("col", 1).setValue("2");
        //                 t.getNode("halign", 1).setValue("fill");
        //                 t.getNode("pref-width", 1).setValue("150");
        //                 t.getNode("live", 1).setValue(1);
        //                 t.getNode("property", 1).setValue(DIALOG_ROOT ~ "/axis[" ~ i ~ "]/binding");
        //                 t.getNode("legend", 1).setValue(getprop(DIALOG_ROOT ~ "/axis[" ~ i ~ "]/binding"));

        //                 var b = t.getChild("binding", 0, 1);
        //                 b.getNode("command", 1).setValue("property-assign");
        //                 b.getNode("property", 1).setValue("/sim/gui/dialogs/joystick-config/current-axis");
        //                 b.getNode("value", 1).setValue(i);  

        //                 b = t.getChild("binding", 1, 1);
        //                 b.getNode("command", 1).setValue("dialog-show");
        //                 b.getNode("dialog-name", 1).setValue("button-axis-config");

        //                 # Inverted
        //                 t = table.getChild("checkbox", i, 1);
        //                 t.getNode("name", 1).setValue("axis" ~ i ~ "inverted");
        //                 t.getNode("property", 1).setValue(DIALOG_ROOT ~ "/axis[" ~ i ~ "]/inverted");
        //                 t.getNode("row", 1).setValue(i +1 );
        //                 t.getNode("col", 1).setValue(3);
        //                 t.getNode("visible", 1).getNode("property", 1).setValue(DIALOG_ROOT ~ "/axis[" ~ i ~ "]/invertable");
        //                 t.getNode("live", 1).setValue(1);

        //                 var b = t.getChild("binding", 0, 1);
        //                 b.getNode("command", 1).setValue("dialog-apply");
        //                 b.getNode("object-name", 1).setValue("axis" ~ i ~ "inverted");

        //                 b = t.getChild("binding", 1, 1);
        //                 b.getNode("command", 1).setValue("nasal");
        //                 b.getNode("script", 1).setValue("updateConfig();");
        //             }

        //             # Set up the buttons.
        //             table = gui.findElementByName(dlgRoot, "buttontable");
        //             table.removeChildren("checkbox");
        //             table.removeChildren("button");
        //             var row = 1;
        //             var col = 0;

        //             for (var button = 0; button < joystick.MAX_BUTTONS; button = button + 1) {

        //                 t = table.getChild("checkbox", button, 1);  
        //                 t.getNode("property", 1).setValue("/devices/status/joysticks/joystick[" ~ joystick_index ~ "]/button[" ~ button ~ "]");
        //                 t.getNode("row", 1).setValue(row );
        //                 t.getNode("col", 1).setValue(col);
        //                 t.getNode("live", 1).setValue(1);

        //                 t = table.getChild("button", button, 1);  
        //                 t.getNode("name", 1).setValue("button" ~ button);
        //                 t.getNode("pref-width", 1).setValue(140);
        //                 t.getNode("halign", 1).setValue("fill");
        //                 t.getNode("live", 1).setValue("fill");
        //                 t.getNode("row", 1).setValue(row );
        //                 t.getNode("col", 1).setValue(col +1);
        //                 t.getNode("legend", 1).setValue(getprop(DIALOG_ROOT ~ "/button[" ~ button ~ "]/binding"));

        //                 var b = t.getChild("binding", 0, 1);
        //                 b.getNode("command", 1).setValue("property-assign");
        //                 b.getNode("property", 1).setValue("/sim/gui/dialogs/joystick-config/current-button");
        //                 b.getNode("value", 1).setValue(button);  

        //                 b = t.getChild("binding", 1, 1);
        //                 b.getNode("command", 1).setValue("dialog-show");
        //                 b.getNode("dialog-name", 1).setValue("button-config");

        //                 col = col + 2;

        //                 if (col > 5) {
        //                     row = row +1;
        //                     col = 0;  
        //                 }  
        //             }
        //         }

        //         var updateConfig = func() {
        //             joystick.writeConfig();
        //             fgcommand("reinit", props.Node.new({"subsystem": "input"}));
        //             fgcommand("dialog-close", props.Node.new({"dialog-name": "joystick-config"}));
        //             fgcommand("dialog-show", props.Node.new({"dialog-name": "joystick-config"}));
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
            text: qsTr(" To configure your joystick/yoke/pedals:")
            horizontalAlignment: Text.AlignLeft
        }

        Label {
            text: qsTr(" 1) Select the device your wish to configure from the drop-down.")
            horizontalAlignment: Text.AlignLeft
        }

        Label {
            text: qsTr(" 2) Identify the control you wish to configure by moving the joystick or pressing the button. The result is shown in the Input column.")
            horizontalAlignment: Text.AlignLeft
        }

        Label {
            text: qsTr(" 3) Using the drop-down or dialog button, select what you want the control to do. \"Custom\" indicates a manually configured command.")
            horizontalAlignment: Text.AlignLeft
        }

        Label {
            text: qsTr(" Your selection will take effect immediately.")
            horizontalAlignment: Text.AlignLeft
        }

        Label {
            text: qsTr(" 4) Test your control. Some joystick controls can be \"inverted\" if you wish the control to take effect in the opposite direction.")
            horizontalAlignment: Text.AlignLeft
        }

        Label {
            text: qsTr(" Your modified joystick configuration is saved automatically. You can reset the configuration to the default by pressing Reset Configuration. ")
            horizontalAlignment: Text.AlignLeft
        }

        HorizontalLine {}

        GridLayout {
            width: parent.width
            columns: 5
            //horizontalAlignment: Text.AlignLeft

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Joystick:")
            }

            ComboBox {
                id: jsselect
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/gui/dialogs/joystick-config/selected-joystick
                width: 350
                // binding*: " dialog-apply jsselect "
                // binding*: " nasal fgcommand("dialog-close", props.Node.new({"dialog-name": "joystick-config"})); fgcommand("dialog-show", props.Node.new({"dialog-name": "joystick-config"})); "
            }

            Button {
                text: qsTr("Reset Configuration")
                // binding*: " nasal joystick.resetConfig(); fgcommand("reinit", props.Node.new({"subsystem": "input"})); fgcommand("dialog-close", props.Node.new({"dialog-name": "joystick-config"})); fgcommand("dialog-show", props.Node.new({"dialog-name": "joystick-config"})); "
            }

            Button {
                text: qsTr("Refresh Joysticks")
                // binding*: " nasal fgcommand("reinit", props.Node.new({"subsystem": "input"})); fgcommand("dialog-close", props.Node.new({"dialog-name": "joystick-config"})); fgcommand("dialog-show", props.Node.new({"dialog-name": "joystick-config"})); "
            }

            Label {
                text: qsTr(" Configuration File:")
                horizontalAlignment: Text.AlignRight
            }

            Label {
                text: qsTr("Joystick Confgig")
                horizontalAlignment: Text.AlignLeft
                // property*: /sim/gui/dialogs/joystick-config/selected-joystick-config
            }
        } // GridLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            GridLayout {
                id: axistable
                width: parent.width

                Label {
                    text: qsTr("Axis")
                }

                Label {
                    text: qsTr("Input")
                }

                Label {
                    text: qsTr("Control")
                }

                Label {
                    text: qsTr("Inverted?")
                }
            } // GridLayout

            HorizontalLine {}

            GridLayout {
                id: buttontable
                width: parent.width

                Label {
                    text: qsTr("Input")
                }

                Label {
                    text: qsTr("Control")
                }

                Label {
                    text: qsTr("Input")
                }

                Label {
                    text: qsTr("Control")
                }

                Label {
                    text: qsTr("Input")
                }

                Label {
                    text: qsTr("Control")
                }
            } // GridLayout
        } // RowLayout

        HorizontalLine {}

        GridLayout {
            width: parent.width
            columns: 5
            // padding*: 2

            Label {
                width: 150
            }

            Label {
                text: qsTr("Aileron: ")
                horizontalAlignment: Text.AlignRight
            }

            Label {
                text: qsTr("-0.00000")
                horizontalAlignment: Text.AlignLeft
                // format*: %.5f
                // property*: /controls/flight/aileron
                // live*: 1
            }

            Label {
                text: qsTr("Elevator: ")
                horizontalAlignment: Text.AlignRight
            }

            Label {
                text: qsTr("-0.00000")
                horizontalAlignment: Text.AlignLeft
                // format*: %.5f
                // property*: /controls/flight/elevator
                // live*: 1
            }

            Label {
                text: qsTr("Rudder: ")
                horizontalAlignment: Text.AlignRight
            }

            Label {
                text: qsTr("-0.00000")
                horizontalAlignment: Text.AlignLeft
                // format*: %.5f
                // property*: /controls/flight/rudder
                // live*: 1
            }

            Label {
                text: qsTr("Throttle: ")
                horizontalAlignment: Text.AlignRight
            }

            Label {
                text: qsTr("-0.00000")
                horizontalAlignment: Text.AlignLeft
                // format*: %.5f
                // property*: /controls/engines/engine/throttle
                // live*: 1
            }

            Label {
                width: 150
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
                joystickConfigDialog.closed(joystickConfigDialog.id);
            }
        }
    } // buttons
}
