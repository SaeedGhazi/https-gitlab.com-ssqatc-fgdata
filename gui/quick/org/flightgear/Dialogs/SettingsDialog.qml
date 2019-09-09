import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Rectangle {
    width: 40
    height: 40

    Component.onCompleted: {
        stack.controller.push(Qt.resolvedUrl("RootSettingsPage.qml"), qsTr("Settings"));
    }

    Stack {
        id: stack
        anchors.fill: parent
    }
}
