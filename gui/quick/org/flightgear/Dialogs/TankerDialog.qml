import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: tankerDialog

    width: 500
    height: 250
    position: Qt.point(80, 80)

    windowId: tankerDialog.id
    title: "Air-to-Air Refueling Tanker"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var dlgRoot = cmdarg();

        //         var tankers = props.globals.getNode("/sim/ai/tankers/", 1).getChildren("tanker");
        //         var types = props.globals.getNode("/systems/refuel/", 1).getChildren("type");
        //         var tanker_node = props.globals.getNode("/sim/gui/dialogs/tanker/tanker", 1);

        //         #  Force default speed of 250kts
        //         setprop("/sim/gui/dialogs/tanker/tanker/speed-kts", 250.0);

        //         if (size(types) == 0) {
        //             # This really shouldn't happen, as Nasal/tanker.nas disables this menu item
        //             # if no refueling type is available.        
        //             gui.popupTip("Air to air refueling unavailable in this aircraft", 5);
        //             fgcommand("dialog-close", props.Node.new({ "dialog-name" : "tanker"}));
        //         }


        //         if (size(tankers) > 0) {							
        //             var combo = gui.findElementByName(dlgRoot, "tanker-combo");
        //             var idx = 0;
        //             foreach (var t; tankers) {
        //                 foreach(var type; types) {				  
        //                     if (type.getValue() == t.getNode("type", 1).getValue()) {
        //                         combo.getChild("value", idx, 1).setValue(t.getNode("name", 1).getValue());
        //                         idx += 1;
        //                     }
        //                 }
        //             }
        //         }

        //         var select_tanker = func() {
        //             var name = getprop("/sim/gui/dialogs/tanker/selected-tanker");

        //             foreach (var t; tankers) {
        //                 if (name == t.getNode("name", 1).getValue()) {
        //                     props.copy(t, tanker_node);
        //                 }				
        //             }
        //         }

        //         var generate_tanker = func() {
        //             if (tanker_node.getNode("name", 1).getValue()) {
        //                 tanker.request_new(tanker_node);
        //             }
        //         }
        //     </open>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 5

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Tanker:")
            }

            ComboBox {
                id: tanker_combo
                //horizontalAlignment: Text.AlignLeft
                // property*: /sim/gui/dialogs/tanker/selected-tanker
                width: 200
                // binding*: " dialog-apply tanker-combo "
                // binding*: " nasal select_tanker(); "
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Type:")
            }

            Label {
                // visible*: /sim/gui/dialogs/tanker/tanker/type probe
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Drogue and Probe")
            }

            Label {
                // visible*: /sim/gui/dialogs/tanker/tanker/type boom
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Boom")
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Speed:")
            }

            Slider {
                id: tanker_speed
                // live*: true
                // property*: /sim/gui/dialogs/tanker/tanker/speed-kts
                // binding*: " dialog-apply tanker-speed "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                // format*: %2.0fkts
                text: qsTr("250")
                // property*: /sim/gui/dialogs/tanker/tanker/speed-kts
                // live*: true
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Contact radius:")
            }

            Slider {
                id: contact_radius
                // property*: /systems/refuel/contact-radius-m
                // binding*: " dialog-apply contact-radius "
            }

            Label {
                horizontalAlignment: Text.AlignLeft
                // format*: %2.0fm
                // property*: /systems/refuel/contact-radius-m
                // live*: true
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Report refueling:")
            }

            CheckBox {
                id: report_contact
                //horizontalAlignment: Text.AlignLeft
                // property*: /systems/refuel/report-contact
                // binding*: " dialog-apply report-contact "
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Request")
            // binding*: " nasal generate_tanker(); "
        }

        Button {
            text: qsTr("Get Position")
            // binding*: " nasal tanker.report() "
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                tankerDialog.closed(tankerDialog.id);
            }
        }

    } // buttons
}
