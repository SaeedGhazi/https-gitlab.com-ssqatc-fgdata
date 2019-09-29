import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: aiObjectsDialog

    width: 450
    height: 235
    position: Qt.point(80, 80)

    windowId: aiObjectsDialog.id
    title: "Control nearby AI objects"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GroupBox {
            Layout.fillWidth: true

            GridLayout {
                width: parent.width
                columns: 1

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
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            onClicked: {
                // binding*: " dialog-apply "
                // binding*: " nasal var obj_dlg_id = getprop("/ai/control/object-selected"); var dlg = gui.Dialog.new(obj_dlg_id); dlg.open(); "
                aiObjectsDialog.closed(aiObjectsDialog.id);
            }

        }

        Button {
            text: qsTr("Close")

            onClicked: {
                aiObjectsDialog.closed(aiObjectsDialog.id);
            }
        }
    } // buttons
}
