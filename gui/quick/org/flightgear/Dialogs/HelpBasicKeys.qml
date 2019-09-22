import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Rectangle {
    id: root

    width: 640
    height: 400
    anchors.centerIn: parent
    border.width: 1
    border.color: Style.frameColor
    color: Style.windowColor
    opacity: Style.panelOpacity

    signal closed(string windowId)

    ColumnLayout {
        width: parent.width

        GroupBox {
            id: groupBox
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("Basic Keys")
                    font.pointSize: Style.headingFontPixelSize
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    id: closeBox
                    width: 20
                    height: 20
                    color: mouseClose.containsMouse ? Style.activeColor : Style.themeColor
                    anchors.right: parent.right
                    anchors.rightMargin: Style.margin
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        id: mouseClose
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.closed(root.id);
                        }
                    }
                }
            } // RowLayout
        }

        HorizontalLine {}

        ListModel {
            id: shortcutKeysModel

            ListElement { name: "?";         desc: "show/hide aircraft help dialog" }
            ListElement { name: "Esc";       desc: "quit FlightGear" }
            ListElement { name: "Shift-Esc"; desc: "reset FlightGear" }
            ListElement { name: "a/A";       desc: "increase/decrease speed-up" }
            ListElement { name: "c";         desc: "toggle 3D/2D cockpit" }
            ListElement { name: "Ctrl-C";    desc: "toggle clickable panel hotspots" }
            ListElement { name: "p";         desc: "pause/continue sim" }
            ListElement { name: "Ctrl-R";    desc: "activate instant replay system" }
            ListElement { name: "t/T";       desc: "adjust time of day forward/backward" }
            ListElement { name: "v/V";       desc: "cycle views (forward/backward)" }
            ListElement { name: "Ctrl-V";    desc: "select cockpit view" }
            ListElement { name: "x/X";       desc: "zoom in/out" }
            ListElement { name: "Ctrl-X";    desc: "reset zoom to default" }
            ListElement { name: "z/Z";       desc: "increase/decrease visibility" }
            ListElement { name: "Ctrl-Z";    desc: "reset visibility to default" }
            ListElement { name: "'";         desc: "display ATC setting dialog" }
            ListElement { name: "+";         desc: "let ATC/instructor repeat last message" }
            ListElement { name: "-";         desc: "open chat dialog" }
            ListElement { name: "_";         desc: "compose chat message" }
            ListElement { name: "F3";        desc: "capture screen" }
            ListElement { name: "F10";       desc: "toggle menubar" }
            ListElement { name: "Shift-F10"; desc: "cycle through GUI styles" }
        }

        Column {
            id: column
            Layout.fillHeight: true
            Layout.fillWidth: true
            anchors.fill: parent

            GridLayout {
                columnSpacing: 10
                columns: 2
                rows: 11
                flow: GridLayout.TopToBottom
                Layout.fillWidth: true

                ListView {
                    model: shortcutKeysModel
                    height: 1000

                    delegate: Label {
                        text: model.name + " ... " + model.desc
                        color: Style.themeColor
                    }
                }
            }
        }

        HorizontalLine {}

        GroupBox {
            id: buttonTray
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Close")
                    // equal*: true
                    // default*: true
                    // key*: qsTr("Esc")
                    // binding*: " dialog-close "

                    onClicked: {
                        root.closed(root.id);
                    }
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        }
    } // ColumnLayout
}
