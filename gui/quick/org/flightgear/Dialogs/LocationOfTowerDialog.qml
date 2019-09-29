import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: locationOfTowerDialog

    width: 400
    height: 300
    position: Qt.point(80, 80)

    windowId: locationOfTowerDialog.id
    title: "Tower Position"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            text: qsTr(" Select Position of Tower for the Tower Views ")
        }

        GridLayout {
            width: parent.width
            columns: 3

            CheckBox {
                id: auto_tower
                text: qsTr("Always use nearest tower")
                // property*: /sim/tower/auto-position
                // live*: true
                // binding*: " dialog-apply auto-tower "
            }

            Label {
                // visible*: /sim/tower/auto-position
                horizontalAlignment: Text.AlignRight
                text: qsTr("xxxxxxxx")
                // live*: true
                // format*: (%s)
                // property*: /sim/tower/airport-id
                Layout.columnSpan: 2
            }

            Label {
                horizontalAlignment: Text.AlignRight
                text: qsTr("Airport ID:")
                // visible*: /sim/tower/auto-position
            }

            TextInput {
                id: airport_id
                // property*: /sim/tower/airport-id
                // visible*: /sim/tower/auto-position
                Layout.columnSpan: 2
            }

            Button {
                text: qsTr("COM1")
                // binding*: " property-assign /sim/tower/airport-id /instrumentation/comm[0]/airport-id "
                // binding*: " dialog-update airport-id "
            }

            Label {
                text: qsTr("MHz")
                // live*: true
                // visible*: /instrumentation/comm[0]/serviceable /instrumentation/comm[0]/signal-quality-norm /instrumentation/comm[0]/cutoff-signal-quality
                // property*: /instrumentation/comm[0]/frequencies/selected-mhz
                // format*: %-0.2f
            }

            Label {
                // live*: true
                // visible*: /instrumentation/comm[0]/serviceable /instrumentation/comm[0]/signal-quality-norm /instrumentation/comm[0]/cutoff-signal-quality
                // property*: /instrumentation/comm[0]/airport-id
            }

            Button {
                text: qsTr("COM2")
                // binding*: " property-assign /sim/tower/airport-id /instrumentation/comm[1]/airport-id "
                // binding*: " dialog-update airport-id "
            }

            Label {
                text: qsTr("MHz")
                // live*: true
                // visible*: /instrumentation/comm[1]/serviceable /instrumentation/comm[1]/signal-quality-norm /instrumentation/comm[1]/cutoff-signal-quality
                // property*: /instrumentation/comm[1]/frequencies/selected-mhz
                // format*: %-0.2f
            }

            Label {
                // live*: true
                // visible*: /instrumentation/comm[1]/serviceable /instrumentation/comm[1]/signal-quality-norm /instrumentation/comm[1]/cutoff-signal-quality /instrumentation/comm[1]/power-btn /instrumentation/comm[1]/power-good 0
                // property*: /instrumentation/comm[1]/airport-id
            }

            Button {
                text: qsTr("Preset")
                // binding*: " property-assign /sim/tower/airport-id /sim/presets/airport-id "
                // binding*: " dialog-update airport-id "
            }

            Label {
                // property*: /sim/presets/airport-id
            }

            Label {
                Layout.fillWidth: true
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // binding*: " dialog-apply "

            onClicked: {
                locationOfTowerDialog.closed(locationOfTowerDialog.id);
            }
        }

        Button {
            text: qsTr("Cancel")
            // key*: qsTr("Esc")

            onClicked: {
                locationOfTowerDialog.closed(locationOfTowerDialog.id);
            }
        }
    } // buttons
}
