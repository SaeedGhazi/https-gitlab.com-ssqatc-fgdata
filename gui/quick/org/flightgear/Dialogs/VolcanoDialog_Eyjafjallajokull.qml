import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: volcanoEyjafjallajokullDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: volcanoEyjafjallajokullDialog.id
    title: "Eyjafjallajokull activity"

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
                text: qsTr("Main crater activity")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: qsTr("dormant")
            }

            Slider {
                id: main
                // live*: true
                // property*: /environment/volcanoes/eyjafjallajokull/main-activity
                // binding*: " dialog-apply main "
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
                volcanoEyjafjallajokullDialog.closed(volcanoEyjafjallajokullDialog.id);
            }
        }

        Button {
            text: qsTr("Close")
            // key*: qsTr("Esc")

            onClicked: {
                volcanoEyjafjallajokullDialog.closed(volcanoEyjafjallajokullDialog.id);
            }
        }

    } // buttons
}
