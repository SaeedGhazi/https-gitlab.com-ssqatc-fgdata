import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: atcFreqDialog

    width: 400
    height: 155
    position: Qt.point(80, 80)

    windowId: atcFreqDialog.id
    title: "ICAO Frequencies"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

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

    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                atcFreqDialog.closed(atcFreqDialog.id);
            }
        }
    } // buttons
}
