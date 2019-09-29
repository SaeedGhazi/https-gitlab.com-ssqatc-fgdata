import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: volcanoKilaueaDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: volcanoKilaueaDialog.id
    title: "Kilauea activity"

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
                text: qsTr("Halemaumau activity")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("dormant")
            }

            Slider {
                id: halemaumau
                // live*: true
                // property*: /environment/volcanoes/kilauea/halemaumau-activity
                // binding*: " dialog-apply halemaumau "
            }

            Label {
                text: qsTr("active")
            }

            Label {
                text: qsTr("Puu Oo activity")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("dormant")
            }

            Slider {
                id: puu_oo
                // live*: true
                // property*: /environment/volcanoes/kilauea/puu-oo-activity
                // binding*: " dialog-apply puu-oo "
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
                volcanoKilaueaDialog.closed(volcanoKilaueaDialog.id);
            }
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                volcanoKilaueaDialog.closed(volcanoKilaueaDialog.id);
            }
        }

    } // buttons
}
