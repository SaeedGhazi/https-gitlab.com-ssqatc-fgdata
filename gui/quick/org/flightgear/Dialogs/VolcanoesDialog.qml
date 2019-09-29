import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: volcanoesDialog

    width: 500
    height: 250
    position: Qt.point(80, 80)

    windowId: volcanoesDialog.id
    title: "Nearby volcanic activity"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        CheckBox {
            id: enable_volcanoes
            //horizontalAlignment: Text.AlignLeft
            // property*: /environment/volcanoes/enable-volcanoes
            text: qsTr("enable volcanic activity")
            // live*: true
            // binding*: " dialog-apply enable-volcanoes "
        }

        Label {
            height: 8
        }

        Label {
            text: qsTr("Select a nearby volcano from the list to set its activity")
            horizontalAlignment: Text.AlignLeft
        }

        ComboBox {
            id: object_selection
            Layout.fillWidth: true
            //horizontalAlignment: Text.AlignLeft
            // property*: /environment/volcanoes/volcano-selected
            // binding*: " dialog-apply object-selection "
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // binding*: " dialog-apply "
            // binding*: " nasal var obj_dlg_id = getprop("/environment/volcanoes/volcano-selected"); var dlg = gui.Dialog.new(obj_dlg_id); dlg.open(); "

            onClicked: {
                volcanoesDialog.closed(volcanoesDialog.id);
            }
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                volcanoesDialog.closed(volcanoesDialog.id);
            }
        }

    } // buttons
}
