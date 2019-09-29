import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: chatDialog

    width: 640
    height: 400
    position: Qt.point(80, 80)

    windowId: chatDialog.id
    title: "Chat"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width
            // padding*: 5
            //color: "#07774D"

            Button {
                text: qsTr("Close")
                width: 45
                height: 30
                // equal*: true
                onClicked: {
                    chatDialog.closed(chatDialog.id);
                }
                color: "#07774D"
            }

            Button {
                text: qsTr("More")
                // equal*: true
                width: 45
                height: 30
                // binding*: " dialog-show chat-full "
                onClicked: {
                    chatDialog.closed(chatDialog.id);
                }
                color: "#07774D"
            }
        } // RowLayout

        TextInput {
            id: compose
            width: 500
            Layout.fillWidth: true
            // property*: /sim/multiplay/chat-compose
            color: "#07774D"
            // font*: sim/gui/selected-style/fonts/gui-small
        }

        Button {
            text: qsTr("Send")
            width: 45
            height: 30
            // binding*: " dialog-apply "
            // binding*: " nasal var lchat = getprop("/sim/multiplay/chat-compose"); if (lchat != "") { setprop("/sim/multiplay/chat", lchat); setprop("/sim/multiplay/chat-compose", ""); gui.dialog_update("chat", "compose"); } "
            color: "#07774D"
        }
    } // ColumnLayout

    // ======= content end
}
