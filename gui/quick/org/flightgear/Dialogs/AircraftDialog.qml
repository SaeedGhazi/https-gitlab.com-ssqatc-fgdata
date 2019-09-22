import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: aircraftDialog

    width: 350
    height: 155
    position: Qt.point(80, 80)

    windowId: aircraftDialog.id
    title: "Select aircraft"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        ListView {
            width: 230
            height: 25
            // property*: /sim/aircraft
            model: "/sim/aircraft-types"
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
                // binding*: " load-aircraft "
                aircraftDialog.closed(aircraftDialog.id);
            }
        }

        Button {
            text: qsTr("Cancel")

            onClicked: {
                aircraftDialog.closed(aircraftDialog.id);
            }
        }
    } // buttons
}
