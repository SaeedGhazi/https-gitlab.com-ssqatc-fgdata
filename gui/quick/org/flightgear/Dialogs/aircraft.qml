import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: aircraft
    width: 250
    height: 95

    Rectangle {
        anchors.fill: parent
        color: "#6d6d6d"
    }

    // modal*: true
    Label {
        x: 10
        y: 65
        text: qsTr("Select aircraft")
    }

    ListView {
        x: 10
        y: 40
        width: 230
        height: 25
        // property*: /sim/aircraft
        model: "/sim/aircraft-types"
    }

    Button {
        x: 65
        y: 10
        text: qsTr("OK")
        // default*: true
        // equal*: true
        // binding*: " dialog-apply "
        // binding*: " load-aircraft "
        // binding*: " dialog-close "
    }

    Button {
        x: 125
        y: 10
        text: qsTr("Cancel")
        // equal*: true
        // key*: qsTr("Esc")
        // binding*: " dialog-close "
    }
}
