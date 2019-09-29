import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: markerAdjustDialog

    width: 400
    height: 250
    position: Qt.point(80, 80)

    windowId: markerAdjustDialog.id
    title: "Adjust marker"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var self = cmdarg();
        //         var dlgname = self.getNode("name").getValue();
        //         var kbdctrl = props.globals.getNode("/devices/status/keyboard/ctrl", 1);
        //         var kbdshift = props.globals.getNode("/devices/status/keyboard/shift", 1);

        //         var Value = {
        //             new : func(name, factor, init = 0) {
        //                 var m = { parents: [Value] };
        //                 m.name = name;
        //                 m.factor = factor;
        //                 m.init = init;
        //                 var n = props.globals.getNode("/sim/model/marker/" ~ m.name, 1);
        //                 m.sliderN = n.getNode("slider", 1);
        //                 m.offsetN = n.getNode("offset", 1);
        //                 m.valueN = n.getNode("value", 1);
        //                 m.offsetN.setDoubleValue(0);
        //                 m.sliderN.setDoubleValue(0);
        //                 m.valueN.setDoubleValue(m.init);
        //                 m.last_slider = 0;
        //                 m.center();
        //                 m.sliderL = setlistener(m.sliderN, func { m.update() });
        //                 return m;
        //             },
        //             del : func {
        //                 removelistener(me.sliderL);
        //             },
        //             reset : func {
        //                 me.center();
        //                 me.valueN.setDoubleValue(me.init);
        //             },
        //             update : func {
        //                 var offs = me.sliderN.getValue();
        //                 var v = me.offsetN.getValue() + me.sliderN.getValue() - me.last_slider;
        //                 var f = me.factor;
        //                 if (kbdctrl.getValue()) {
        //                     f *= 5;
        //                 } elsif (kbdshift.getValue()) {
        //                     f *= 0.1;
        //                 }
        //                 me.valueN.setValue(me.valueN.getValue() + v * f);
        //                 me.offsetN.setDoubleValue(0);
        //                 me.last_slider = offs;
        //             },
        //             center : func {
        //                 me.offsetN.setValue(me.offsetN.getValue() + me.sliderN.getValue());
        //                 me.sliderN.setDoubleValue(0);
        //             },
        //         };

        //         var values = [
        //             Value.new("x", 0.1),    # aft/fore
        //             Value.new("y", 0.1),    # left/right
        //             Value.new("z", 0.1),    # down/up
        //             Value.new("scale", 2, 1),
        //         ];

        //         var center = func {
        //             foreach (var v; values) {
        //                 v.center();
        //             }
        //         }

        //         var reset = func {
        //             foreach (var v; values) {
        //                 v.reset();
        //             }
        //         }

        //         var dump = func {
        //             var v = props.globals.getNode("/sim/current-view", 1);
        //             print("&lt;view>");
        //             foreach (var n; ["heading-offset-deg", "pitch-offset-deg", "roll-offset-deg",
        //                     "x-offset-m", "y-offset-m", "z-offset-m", "field-of-view"]) {
        //                 print(sprintf("    &lt;%s>%.1f&lt;/%s>", n, v.getNode(n, 1).getValue(), n));
        //             }
        //             print("&lt;/view>\n");

        //             print("&lt;marker>");
        //             foreach (var v; values) {
        //                 var tag = v.name == "scale" ? "scale" : v.name ~ "-m";
        //                 print(sprintf("    &lt;%s>%.4f&lt;/%s>", tag, v.valueN.getValue(), tag));
        //             }
        //             print("&lt;/marker>\n");
        //         }

        //         var update = func(w) {
        //             self.setValues({"dialog-name": dlgname, "object-name": w});
        //             fgcommand("dialog-update", self);
        //             center();
        //         }

        //         setprop("/sim/model/marker/arrow-enabled", 1);
        //         setprop("/sim/model/marker/cross-enabled", 1);
        //     </open>

        //     <close>
        //         setprop("/sim/model/marker/cross-enabled", 0);
        //         setprop("/sim/model/marker/arrow-enabled", 0);
        //         foreach (var v; values) {
        //             v.del();
        //         }
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/x/offset -10 "
                // binding*: " nasal update("x") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/x/offset -1 "
                // binding*: " nasal update("x") "
            }

            Slider {
                id: xField
                // property*: /sim/model/marker/x/slider
                //text: qsTr("fore/aft")
                width: 250
                // live*: 1
                //color: "#FF9999FF"
                // binding*: " dialog-apply x "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/x/offset 1 "
                // binding*: " nasal update("x") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/x/offset 10 "
                // binding*: " nasal update("x") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/y/offset -10 "
                // binding*: " nasal update("y") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/y/offset -1 "
                // binding*: " nasal update("y") "
            }

            Slider {
                id: yField
                // property*: /sim/model/marker/y/slider
                //text: qsTr("left/right")
                width: 250
                // live*: 1
                //color: "#99FF99FF"
                // binding*: " dialog-apply y "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/y/offset 1 "
                // binding*: " nasal update("y") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/y/offset 10 "
                // binding*: " nasal update("y") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim//model/marker/z/offset -10 "
                // binding*: " nasal update("z") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/z/offset -1 "
                // binding*: " nasal update("z") "
            }

            Slider {
                id: z
                // property*: /sim/model/marker/z/slider
                //text: qsTr("down/up")
                width: 250
                // live*: 1
                //color: "#9999FFFF"
                // binding*: " dialog-apply z "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/z/offset 1 "
                // binding*: " nasal update("z") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/z/offset 10 "
                // binding*: " nasal update("z") "
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 0

            Button {
                text: qsTr("<<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim//model/marker/scale/offset -10 "
                // binding*: " nasal update("scale") "
            }

            Button {
                text: qsTr("<")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/scale/offset -1 "
                // binding*: " nasal update("scale") "
            }

            Slider {
                id: scaleField
                // property*: /sim/model/marker/scale/slider
                //text: qsTr("size")
                width: 250
                // live*: 1
                //color: "#FF99FFFF"
                // binding*: " dialog-apply scale "
            }

            Button {
                text: qsTr(">")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/scale/offset 1 "
                // binding*: " nasal update("scale") "
            }

            Button {
                text: qsTr(">>")
                width: 22
                height: 22
                // binding*: " property-adjust /sim/model/marker/scale/offset 10 "
                // binding*: " nasal update("scale") "
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            //horizontalAlignment: Text.AlignLeft
            text: qsTr("Reset")
            height: 22
            width: 60
            // binding*: " nasal reset() "
        }

        Button {

            text: qsTr("Center")
            height: 22
            width: 60
            // binding*: " nasal center() "
        }

        Button {
            //horizontalAlignment: Text.AlignRight
            text: qsTr("Dump")
            height: 22
            width: 60
            // binding*: " nasal dump() "
        }
    } // buttons
}
