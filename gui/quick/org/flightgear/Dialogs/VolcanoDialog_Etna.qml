import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: volcanoEtnaDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: volcanoEtnaDialog.id
    title: "Etna activity"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width

            Label {
                text: qsTr("Southeast crater activity")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("dormant")
            }

            Slider {
                id: se
                // live*: true
                // property*: /environment/volcanoes/etna/southeast-activity
                // binding*: " dialog-apply se "
            }

            Label {
                text: qsTr("active")
            }

            Label {
                text: qsTr("Northeast crater activity")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("dormant")
            }

            Slider {
                id: ne
                // live*: true
                // property*: /environment/volcanoes/etna/northeast-activity
                // binding*: " dialog-apply ne "
            }

            Label {
                text: qsTr("active")
            }
        } // GridLayout

        Label {
            height: 12
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

            onClicked: {
                volcanoEtnaDialog.closed(volcanoEtnaDialog.id);
            }
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                volcanoEtnaDialog.closed(volcanoEtnaDialog.id);
            }
        }

    } // buttons
}
