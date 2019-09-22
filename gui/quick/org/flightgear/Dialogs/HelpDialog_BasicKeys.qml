import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: helpDialog_BasicKeys

    width: 640
    height: 400
    position: Qt.point(80, 80)

    windowId: helpDialog_BasicKeys.id
    title: "Basic Keys"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

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
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                helpDialog_BasicKeys.closed(helpDialog_BasicKeys.id);
            }
        }
    } // buttons
}
