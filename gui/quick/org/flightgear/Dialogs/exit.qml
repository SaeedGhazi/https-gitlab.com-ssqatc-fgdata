import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: exit

    Rectangle {
        anchors.fill: parent
        color: "#6d6d6d"
    }

    //modal*: false
    ColumnLayout {

        Label {
            text: qsTr("Exit FlightGear?")
        }

        GroupBox {

            RowLayout {
                Layout.fillWidth: true
                // padding: 10

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Exit")
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
