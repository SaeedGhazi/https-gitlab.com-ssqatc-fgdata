import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: sandbox_toolbar
    width: 130
    height: 350

    Rectangle {
        anchors.fill: parent
        border.width: 1
        border.color: Style.frameColor
        color: Style.windowColor
        opacity: Style.panelOpacity
    }

    ColumnLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.fillWidth: true

        Button {
            text: qsTr("About")
            onClicked: {
                this.tagged = about_dialog.visible = !about_dialog.visible
            }
        }

        Button {
            text: qsTr("AI Carrier")
            onClicked: {
                this.tagged = ai_carrier_dialog.visible = !ai_carrier_dialog.visible;
            }
        }

        Button {
            text: qsTr("AI Objects")
            onClicked: {
                this.tagged = ai_objects_dialog.visible = !ai_objects_dialog.visible;
            }
        }

        Button {
            text: qsTr("Aircraft")
            onClicked: {
                this.tagged = aircraft_dialog.visible = !aircraft_dialog.visible
            }
        }

        Button {
            text: qsTr("ATC Frequencies")
            onClicked: {
                this.tagged = atc_freq_dialog.visible = !atc_freq_dialog.visible;
            }
        }

        Button {
            text: qsTr("Exit")
            onClicked: {
                this.tagged = exit_dialog.visible = !exit_dialog.visible;
            }
        }

        Button {
            text: qsTr("FPS")
            onClicked: {
                this.tagged = fps_dialog.visible = !fps_dialog.visible;
            }
        }

        Button {
            text: qsTr("Frame Latency")
            onClicked: {
                this.tagged = frame_latency_dialog.visible = !frame_latency_dialog.visible;
            }
        }

        Button {
            text: qsTr("Overlay Select")
            onClicked: {
                this.tagged = overlay_select_dialog.visible = !overlay_select_dialog.visible;
            }
        }

        Button {
            text: qsTr("Scenery Loading")
            onClicked: {
                this.tagged = scenery_loading_dialog.visible = !scenery_loading_dialog.visible;
            }
        }
    }
}
