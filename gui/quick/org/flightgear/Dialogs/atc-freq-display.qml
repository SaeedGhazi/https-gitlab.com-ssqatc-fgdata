import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: atc_freq_display
    width: 400
    height: 155

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
                    text: qsTr("ICAO Frequencies")
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

        HRule {}

        GroupBox {
            id: frequency_list
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width

                TableView {
                    Layout.fillWidth: true

                    // enabled*: false
                    RowLayout {
                        width: parent.width

                        Label {
                            text: qsTr("Label")
                            horizontalAlignment: Text.AlignLeft
                        }

                        Label {
                            Layout.fillWidth: true
                        }

                        Label {
                            text: qsTr("Frequency")
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }

        HRule {}

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Close")
                    // default*: true
                    // key*: qsTr("Esc")
                    // binding*: " dialog-close "
                }

                Label {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
