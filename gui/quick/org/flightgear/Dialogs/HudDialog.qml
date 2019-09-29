import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: hudDialog

    width: 640
    height: 900
    position: Qt.point(80, 80)

    windowId: hudDialog.id
    title: "HUD Configuration"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open><![CDATA[
        //         gui.enable_widgets(cmdarg(), "devel-stuff", getprop("/sim/gui/devel-widgets"));
        //         var radios = cmdarg().getChildren("group")[2].getChildren("group")[1].getChildren("radio");
        //         var set_radio = func(n) {
        //             for (var i = 0; i < size(radios); i +=1) {
        //                 var prop = radios[i].getChild("property").getValue();
        //                 setprop(prop, (n == radios[i].getChild("value").getValue()));
        //             }

        //             setprop("/sim/lon-lat-format", n);
        //         };

        //         set_radio(getprop("/sim/lon-lat-format"));
        //     ]]></open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        CheckBox {
            text: qsTr("Enable 3D")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/hud/enable3d[1]
            // binding*: " dialog-apply "
        }

        CheckBox {
            text: qsTr("Transparent")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/hud/color/transparent
            // binding*: " dialog-apply "
        }

        CheckBox {
            text: qsTr("Antialiased")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/hud/color/antialiased
            // binding*: " dialog-apply "
        }

        HorizontalLine {}

        Label {
            text: qsTr("Lat/Lon Format")
        }

        RadioButton {
            text: qsTr("DDD format (37.618890N 122.375000W)")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-0
            // live*: true
            // binding*: " nasal set_radio(0); "
        }

        RadioButton {
            text: qsTr("DMM format (37*37.133'N 122*22.500'W)")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-1
            // live*: true
            // binding*: " nasal set_radio(1); "
        }

        RadioButton {
            text: qsTr("DMS format (37*37'08.0\"N 122*22'30.0\"W)")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-2
            // live*: true
            // binding*: " nasal set_radio(2); "
        }

        RadioButton {
            text: qsTr("Signed DDD format (37.618890 -122.375000)")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-3
            // live*: true
            // binding*: " nasal set_radio(3); "
        }

        RadioButton {
            text: qsTr("Signed DMM format (37*37.133' -122*22.500')")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-4
            // live*: true
            // binding*: " nasal set_radio(4); "
        }

        RadioButton {
            text: qsTr("Signed DMS format (37*37'08.0\" -122*22'30.0\")")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-5
            // live*: true
            // binding*: " nasal set_radio(5); "
        }

        RadioButton {
            text: qsTr("Zero padded DDD (51.477500N 000.461389W)")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-6
            // live*: true
            // binding*: " nasal set_radio(6); "
        }

        RadioButton {
            text: qsTr("Zero padded DMM (51*28.650'N 000*27.683'W)")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-7
            // live*: true
            // binding*: " nasal set_radio(7); "
        }

        RadioButton {
            text: qsTr("Zero padded DMS (51*28'39.0\"N 000*27'41.0\"W)")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-8
            // live*: true
            // binding*: " nasal set_radio(8); "
        }

        RadioButton {
            text: qsTr("Trinity House Navigation (51* 28'.650N 000* 27'.683W)")
            //horizontalAlignment: Text.AlignLeft
            // property*: /sim/gui/dialogs/hud/lon-lat-format-9
            // live*: true
            // binding*: " nasal set_radio(9); "
        }

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Label {
                text: qsTr(" Alpha:")
            }

            Slider {
                width: 300
                // property*: /sim/hud/color/alpha
                // live*: true
                // binding*: " dialog-apply "
            }
        } // RowLayout

        RowLayout {
            id: devel_stuff
            width: parent.width

            Label {
                text: qsTr(" Clamp:")
            }

            Slider {
                width: 300
                // property*: /sim/hud/color/alpha-clamp
                // live*: true
                // binding*: " dialog-apply "
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            Label {
                text: qsTr(" Brightness:")
            }

            Slider {
                width: 300
                // property*: /sim/hud/color/brightness
                // live*: true
                // binding*: " dialog-apply "
            }
        } // RowLayout

        RowLayout {
            id: devel_stuff_red
            width: parent.width

            Label {
                text: qsTr(" Red:")
            }

            Slider {
                width: 300
                // property*: /sim/hud/color/red
                // live*: true
                // binding*: " dialog-apply "
                //color: "#FF77"
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            id: devel_stuff_green
            width: parent.width

            Label {
                text: qsTr(" Green:")
            }

            Slider {
                width: 300
                // property*: /sim/hud/color/green
                // live*: true
                // binding*: " dialog-apply "
                //color: "#7FF7"
            }
        } // RowLayout

        RowLayout {
            id: devel_stuff_blue
            width: parent.width

            Label {
                text: qsTr(" Blue:")
            }

            Slider {
                width: 300
                // property*: /sim/hud/color/blue
                // live*: true
                // binding*: " dialog-apply "
                //color: "#77FF"
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                hudDialog.closed(hudDialog.id);
            }
        }
    } // buttons
}
