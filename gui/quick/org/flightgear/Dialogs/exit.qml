import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: exit
    width: 300
    height: 115

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
                    text: qsTr("Exit FlightGear?")
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

            RowLayout {
                Layout.fillWidth: true
                // padding: 10

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Exit")
                    destructiveAction: true
                    focus: true
                    //default*: true
                    //equal*: true
                    //binding*: " exit "
                    //binding*: " dialog-close "
                }

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Cancel")
                    //equal*: true
                    //key*: qsTr("Esc")
                    //binding*: " dialog-close "
                }

                Label {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
