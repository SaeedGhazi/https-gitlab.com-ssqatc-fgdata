import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: exitDialog

    width: 300
    height: 115
    position: Qt.point(80, 80)

    windowId: exitDialog.id
    title: "Exit FlightGear?"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width


    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Exit")
            destructiveAction: true
            focus: true

            onClicked: {
                //binding*: " exit "
                exitDialog.closed(exitDialog.id);
            }
        }

        Button {
            text: qsTr("Cancel")

            onClicked: {
                exitDialog.closed(exitDialog.id);
            }
        }
    } // buttons
}
