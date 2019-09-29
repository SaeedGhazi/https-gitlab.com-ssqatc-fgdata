import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: windsDialog

    width: 500
    height: 210
    position: Qt.point(80, 80)

    windowId: windsDialog.id
    title: "Environment: Winds"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        TextInput {
            width: 200
            height: 25
            text: qsTr("wind direction (deg)")
            // property*: /environment/wind-from-heading-deg
        }

        TextInput {
            width: 200
            height: 25
            text: qsTr("base wind speed (kt)")
            // property*: /environment/params/base-wind-speed-kt
        }

        TextInput {
            width: 200
            height: 25
            text: qsTr("gust wind speed (kt)")
            // property*: /environment/params/gust-wind-speed-kt
        }

        Slider {
            width: 200
            height: 25
            label: qsTr("turbulence")
            // property*: /environment/turbulence/magnitude-norm
        }
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
                windsDialog.closed(windsDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")
            // binding*: " dialog-apply "
        }

        Button {
            text: qsTr("Reset")
            // binding*: " dialog-update "
        }

        Button {
            text: qsTr("Cancel")
            // key*: qsTr("Esc")

            onClicked: {
                windsDialog.closed(windsDialog.id);
            }
        }
    } // buttons
}
