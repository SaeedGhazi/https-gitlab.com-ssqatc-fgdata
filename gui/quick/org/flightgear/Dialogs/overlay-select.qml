import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: overlay_select
    // resizable*: true
    x: -20
    width: 200

    Rectangle {
        anchors.fill: parent
        color: "#6d6d6d"
    }

    ColumnLayout {
        width: parent.width

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("$name")
                }

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    width: 16
                    height: 16
                    text: qsTr("")
                    // default*: 1
                    // keynum*: 27
                    // border*: 2
                    // binding*: " nasal $close "
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "#DFAC01"
        }

        ListView {
            Layout.fillWidth: true
            height: 205
            // property*: $result
            // binding*: " dialog-apply "
            currentIndex: $value
        }
    }
}
