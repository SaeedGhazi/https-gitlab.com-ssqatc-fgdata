import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: messageDialog

    width: 400
    height: 200
    position: Qt.point(80, 80)

    windowId: messageDialog.id
    title: "Message"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {
        // <nasal>
        //     <open>
        //         var self = cmdarg();
        //         var dlgname = self.getNode("name").getValue();
        //         var dlg = props.globals.getNode("/sim/gui/dialogs/" ~ dlgname, 1);
        //         var msg = dlg.getNode("message", 1).getValue();
        //         var textgroup = self.getNode("group-template");

        //         self.getNode("group/group").removeChildren("group");

        //         var lines = split("\n", msg);
        //         forindex (var i; lines) {
        //             var target = self.getNode("group/group").getChild("group", i, 1);
        //             props.copy(textgroup, target);
        //             target.getNode("text/label").setValue(lines[i]);
        //             target.getNode("enabled").setValue(1);
        //         }
        //     </open>

        //     <close>
        //         dlg.getParent().removeChild(dlg.getName(), dlg.getIndex());
        //     </close>
        // </nasal>
    }

    // ======= content

    ColumnLayout {
        width: parent.width
        // padding*: 6

        TableView {
            Layout.fillWidth: true
            // enabled*: false

            RowLayout {
                width: parent.width
                // padding*: 0

                Label {
                    text: qsTr("MESSAGE")
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        }

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width
                // padding*: 8

                Item {
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width
                    } // ColumnLayout
                    // padding*: 0
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

            onClicked: {
                messageDialog.closed(messageDialog.id);
            }
        }
    } // buttons
}
