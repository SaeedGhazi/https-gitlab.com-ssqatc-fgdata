import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: chatFullDialog

    width: 640
    height: 200
    position: Qt.point(80, 80)

    windowId: chatFullDialog.id
    title: "Multiplayer Chat"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        Label {
            Layout.fillWidth: true
            width: 350
            height: 150
            padding: 5

            Slider {
                //20
            }

            // live*: true
            // property*: /sim/multiplay/chat-history
        }

        RowLayout {
            width: parent.width
            //padding: 4

            TextInput {
                id: compose
                Layout.fillWidth: true
                // property*: /sim/multiplay/chat-compose
            }

            Button {
                text: qsTr("Send")
                // default*: true
                // binding*: " dialog-apply compose "
                // binding*: " nasal var lchat = getprop("/sim/multiplay/chat-compose"); if (lchat != "") { setprop("/sim/multiplay/chat", lchat); setprop("/sim/multiplay/chat-compose", ""); gui.dialog_update("chat-full", "compose"); } "
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end
}
