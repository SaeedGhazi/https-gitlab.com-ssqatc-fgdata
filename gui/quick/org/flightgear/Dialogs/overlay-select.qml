import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: overlay_select
    width: 300
    height: 280

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
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("$name")
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

        ListView {
            Layout.fillWidth: true
            height: 205
            // property*: $result
            // binding*: " dialog-apply "
            currentIndex: $value
        }

        HRule {}
    }
}
