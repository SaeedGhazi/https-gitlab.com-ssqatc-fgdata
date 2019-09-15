import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: air
    width: 500
    height: 210

    Rectangle {
        anchors.fill: parent
        border.width: 1
        border.color: Style.frameColor
        color: Style.windowColor
        opacity: Style.panelOpacity
    }

    ColumnLayout {
        width: parent.width

        GroupBox {
            id: groupBox
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("Environment: Air")
                    font.pointSize: Style.headingFontPixelSize
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: qsTr("")
                    // key*: qsTr("Esc")
                    width: 20
                    height: 20
                    // border*: 2
                    // binding*: " dialog-close "
                }
            } // RowLayout
        }

        HorizontalLine {}

        GroupBox {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width

                Text {
                    width: 200
                    height: 25
                    text: qsTr("visibility (m)")
                    // property*: /environment/visibility-m
                }

                Text {
                    width: 200
                    height: 25
                    text: qsTr("sea-level temperature (degC)")
                    // property*: /environment/temperature-sea-level-degc
                }

                Text {
                    width: 200
                    height: 25
                    text: qsTr("sea-level dewpoint (degC)")
                    // property*: /environment/dewpoint-sea-level-degc
                }

                Text {
                    width: 200
                    height: 25
                    text: qsTr("sea-level pressure (inHG)")
                    // property*: /environment/pressure-sea-level-inhg
                }
            }
        }

        HorizontalLine {}

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("OK")
                    // default*: true
                    // equal*: true
                    // binding*: " dialog-apply "
                    // binding*: " dialog-close "
                }

                Button {
                    text: qsTr("Apply")
                    // equal*: true
                    // binding*: " dialog-apply "
                }

                Button {
                    text: qsTr("Reset")
                    // equal*: true
                    // binding*: " dialog-update "
                }

                Button {
                    text: qsTr("Cancel")
                    // equal*: true
                    // key*: qsTr("Esc")
                    // binding*: " dialog-close "
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        }
    } // ColumnLayout
}
