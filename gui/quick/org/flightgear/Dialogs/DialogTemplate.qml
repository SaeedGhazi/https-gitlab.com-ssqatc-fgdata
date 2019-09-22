import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0


DialogBase {
    id: templateDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: templateDialog.id
    title: "Dialog Template"

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
            text: qsTr("Close")

            onClicked: {
                templateDialog.closed(templateDialog.id);
            }
        }
    } // buttons
}
