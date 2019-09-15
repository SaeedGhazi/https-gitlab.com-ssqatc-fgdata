import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: aircraft
    width: 350
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
                    text: qsTr("Select aircraft")
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

        ListView {
            width: 230
            height: 25
            // property*: /sim/aircraft
            model: "/sim/aircraft-types"
        }

        HorizontalLine {}

        GroupBox {
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
                    // binding*: " load-aircraft "
                    // binding*: " dialog-close "
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
