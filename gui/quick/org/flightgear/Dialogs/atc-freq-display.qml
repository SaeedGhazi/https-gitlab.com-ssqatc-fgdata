import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: atc_freq_display
    width: 300
    height: 100

    ColumnLayout {
        width: parent.width

        Label {
            text: qsTr('TITLE ("ICAO Frequencies")')
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "#DFAC01"
        }

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
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("LABEL")
                        }

                        Label {
                            Layout.fillWidth: true
                        }

                        Label {
                            horizontalAlignment: Text.AlignRight
                            text: qsTr("FREQUENCY")
                        }
                    }
                }
            }
        }

        Button {
            text: qsTr("Close")
            // default*: true
            // key*: qsTr("Esc")
            // binding*: " dialog-close "
        }
    }
}
