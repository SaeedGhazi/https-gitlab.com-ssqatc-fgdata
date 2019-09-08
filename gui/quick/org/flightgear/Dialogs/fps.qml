import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: fps
    x: -2
    y: 2

    Rectangle {
        anchors.fill: parent
        color: "#6d6d6d"
    }

    RowLayout {
        // padding*: 2
        // font*: sim/gui/selected-style/fonts/gui-small
        // color: "#00000000"

        Label {
            text: qsTr("000")
            // property*: /sim/frame-rate
            // format*: %3.0f
            // live*: true
            color: "#E66633FF"
        }
    }
}
