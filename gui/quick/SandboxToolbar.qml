import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: sandbox_toolbar
    width: 250
    height: 350

    Rectangle {
        anchors.fill: parent
        border.width: 1
        border.color: Style.frameColor
        color: Style.windowColor
        opacity: Style.panelOpacity
    }

    GridLayout {
        columnSpacing: 10
        rows: 10
        flow: GridLayout.TopToBottom
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.fillWidth: true

        Button {
            text: qsTr("AI Carrier")
            onClicked: {
                ai_carrier_dialog.visible = !ai_carrier_dialog.visible;
            }
        }

        Button {
            text: qsTr("AI Objects")
            onClicked: {
                ai_objects_dialog.visible = !ai_objects_dialog.visible;
            }
        }

        Button {
            text: qsTr("Air")
            onClicked: {
                air_dialog.visible = !air_dialog.visible
            }
        }

        Button {
            text: qsTr("Aircraft")
            onClicked: {
                aircraft_dialog.visible = !aircraft_dialog.visible
            }
        }

        Button {
            text: qsTr("Airports")
            onClicked: {
                airports_dialog.visible = !airports_dialog.visible;
            }
        }

        Button {
            text: qsTr("ATC Frequencies")
            onClicked: {
                atc_freq_dialog.visible = !atc_freq_dialog.visible;
            }
        }

        Button {
            text: qsTr("Exit")
            onClicked: {
                exit_dialog.visible = !exit_dialog.visible;
            }
        }

        Button {
            text: qsTr("FPS")
            onClicked: {
                fps_dialog.visible = !fps_dialog.visible;
            }
        }

        Button {
            text: qsTr("Frame Latency")
            onClicked: {
                frame_latency_dialog.visible = !frame_latency_dialog.visible;
            }
        }

        Button {
            text: qsTr("Overlay Select")
            onClicked: {
                overlay_select_dialog.visible = !overlay_select_dialog.visible;
            }
        }

        Button {
            text: qsTr("Scenery Loading")
            onClicked: {
                scenery_loading_dialog.visible = !scenery_loading_dialog.visible;
            }
        }

        Button {
            text: qsTr("")
        }
    }
}

