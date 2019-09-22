import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: overlaySelectDialog

    width: 300
    height: 280
    position: Qt.point(80, 80)

    windowId: overlaySelectDialog.id
    title: "$name"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        ListView {
            Layout.fillWidth: true
            height: 205
            // property*: $result
            // binding*: " dialog-apply "
            currentIndex: $value
        }
    } // ColumnLayout

    // ======= content end
}
