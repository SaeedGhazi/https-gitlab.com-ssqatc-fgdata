import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: joystickInfoDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: joystickInfoDialog.id
    title: "Joystick Information"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var value = func(p, default = "") {
        //             return p != nil and (var v = p.getValue()) != nil ? v : default;
        //         }

        //         var items = func(it, name) {
        //             var t = "";
        //             foreach (var x; it) {
        //                 t ~= "    [";
        //                 t ~= value(x.getNode("name"), name ~ " #" ~ x.getIndex());
        //                 t ~= "] ... ";
        //                 t ~= value(x.getNode("desc"), "???");
        //                 t ~= "\n";
        //             }
        //             return t;
        //         }

        //         var t = "";
        //         var joysticks = props.globals.getNode("/input/joysticks").getChildren("js");
        //         var numjs = size(joysticks);
        //         forindex (var i; joysticks) {
        //             var js = joysticks[i];
        //             var id = value(js.getNode("id"), "[unnamed]");
        //             var source = value(js.getNode("source"), "[user defined]");
        //             var names = js.getChildren("name");

        //             t ~= "Joystick #" ~ js.getIndex() ~ ": \"" ~ id ~ "\"\n\n";
        //             t ~= "    Driver: " ~ source ~ "\n";
        //             if (size(names)) {
        //                 t ~= "    Used for: ";
        //                 var last = pop(names);
        //                 foreach (var n; names)
        //                     t ~= '"' ~ value(n) ~ '", ';

        //                 t ~= '"' ~ value(last) ~ '"';
        //             }
        //             t ~= "\n\n";
        //             t ~= items(js.getChildren("axis"), "Axis");
        //             t ~= "\n";
        //             t ~= items(js.getChildren("button"), "Button");

        //             var help = value(js.getNode("help"), nil);
        //             if (help != nil)
        //                 t ~= "\n\n" ~ help;

        //             if (numjs > 1 and i &lt; numjs - 1)
        //                 t ~= "\n\n\n----------------------------------------\n\n\n";
        //         }

        //         var text = props.globals.getNode("/sim/gui/dialogs/joystick-info/text", 1);
        //         text.setValue(t);
        //     </open>

        //     <close>
        //         text.setValue("");
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Item {
            Layout.fillWidth: true

            GridLayout {
                width: parent.width
            } // GridLayout
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
        }

        Label {
            padding: 5

            Layout.fillWidth: true
            width: 640
            height: 480

            Slider {
                //20
            }
            // property*: /sim/gui/dialogs/joystick-info/text
        }
    } // ColumnLayout

    // ======= content end
}
