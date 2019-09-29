import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: atcFreqSearchDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: atcFreqSearchDialog.id
    title: "Display Airport Frequencies"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            id: no_atc_in_range
            // enabled*: false
            text: qsTr("No ATC in range 50 nm.")
        }

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Airport identifier:")
                }

                TextInput {
                    Layout.fillWidth: true
                    // property*: /sim/atc/freq-airport
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // binding*: " dialog-apply "
            // binding*: " ATC-freq-display "
            onClicked: {
                atcFreqSearchDialog.closed(atcFreqSearchDialog.id);
            }
        }

        Button {
            text: qsTr("Cancel")

            onClicked: {
                atcFreqSearchDialog.closed(atcFreqSearchDialog.id);
            }
        }
    } // buttons
}
