import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: scenery_loading

    ColumnLayout {
        // modal*: true
        Label {
            text: qsTr("Scenery Loading...")
            padding: 30
        }
    }
}
