import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: volcanoStromboliDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: volcanoStromboliDialog.id
    title: "Stromboli activity"

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
                text: qsTr("Central crater activity")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("dormant")
            }

            Slider {
                id: central
                // live*: true
                // property*: /environment/volcanoes/stromboli/central-activity
                // binding*: " dialog-apply central "
            }

            Label {
                text: qsTr("active")
            }

            Label {
                text: qsTr("Side crater activity")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("dormant")
            }

            Slider {
                id: side
                // live*: true
                // property*: /environment/volcanoes/stromboli/side-activity
                // binding*: " dialog-apply side "
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
                volcanoStromboliDialog.closed(volcanoStromboliDialog.id);
            }
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                volcanoStromboliDialog.closed(volcanoStromboliDialog.id);
            }
        }

    } // buttons
}
