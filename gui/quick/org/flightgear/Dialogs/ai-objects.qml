import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: ai_objects
    // padding*: 1
    // modal*: false
    width: 400

    ColumnLayout {
        width: parent.width

        Label {
            height: 6
        }

        Label {
            text: qsTr("Control nearby AI objects")
        }

        Label {
            height: 4
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "#DFAC01"
        }

        GroupBox {
            Layout.fillWidth: true

            GridLayout {
                width: parent.width

                Label {
                    text: qsTr("Select an AI object to bring up its own control dialog")
                    horizontalAlignment: Text.AlignLeft
                }

                ComboBox {

                    id: object_selection
                    //horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                    width: 300
                    // property*: /ai/control/object-selected

                    // binding*: " dialog-apply object-selection "
                }
            } // GridLayout
        }

        Label {
            height: 12
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "#DFAC01"
        }

        Label {
            height: 20
        }

        GroupBox {
            Layout.fillWidth: true

            GridLayout {
                width: parent.width

                Button {

                    text: qsTr("OK")
                    // default*: true
                    // equal*: true
                    // binding*: " dialog-apply "
                    // binding*: " nasal var obj_dlg_id = getprop("/ai/control/object-selected"); var dlg = gui.Dialog.new(obj_dlg_id); dlg.open(); "
                    // binding*: " dialog-close "
                }

                Button {

                    text: qsTr("Close")
                    // default*: true
                    // key*: qsTr("Esc")
                    // binding*: " dialog-close "
                }
            } // GridLayout
        }
    } // ColumnLayout
}
