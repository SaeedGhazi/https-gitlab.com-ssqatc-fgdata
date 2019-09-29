import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: atcDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: atcDialog.id
    title: "ATC Communication"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Item {
            Layout.fillWidth: true
            id: transmission_choice

            ColumnLayout {
                width: parent.width
            } // ColumnLayout
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Cancel")

            onClicked: {
                // binding*: " ATC-dialog "
                atcDialog.closed(atcDialog.id);
            }
        }
    } // buttons
}
