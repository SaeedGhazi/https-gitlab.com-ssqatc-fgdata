import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: frame_latency
    x: 2
    y: 2

    Rectangle {
        anchors.fill: parent
        color: "#6d6d6d"
    }

    RowLayout {
        // padding*: 0
        // font*: sim/gui/selected-style/fonts/gui-small
        // color: "#00000000"

        Label {
            text: qsTr("0000 ms")
            // property*: /sim/frame-latency-max-ms
            // format*: %4.0f ms
            // live*: true
            color: "#E66633FF"
        }
    }
}
