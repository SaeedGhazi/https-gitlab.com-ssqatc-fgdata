import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Item {
    id: sandbox

    width: 1024
    height: 800

    Row {
        spacing: 20

        Button {
            text: "Show Dialog"

            onClicked: {
                dialogTest.visible = true
                statusMessage.text = "status: dialog shown"
                delay.running = true
            }
        }

        Text {
            id: statusMessage
            text: ""
        }

        Timer {
            id: delay
            interval: 1500; running: false; repeat: false
            onTriggered: {
                statusMessage.text = "status: ready"
            }
        }
    }

    DialogBase {
        id: dialogTest

        width: 800
        height: 600
        position: Qt.point(80, 80)

        windowId: "TestDialog"
        title: "Test Dialog"
        onClosed: {
            dialogTest.visible = false
            statusMessage.text = "status: dialog closed"
            delay.running = true
        }
        onPopout: {
            statusMessage.text = "status: dialog popout"
            delay.running = true
        }

        Rectangle {
            width: 100
            height: 100
            color: Style.frameColor
        }

        buttons: Row {
            anchors.centerIn: parent
            spacing: 20
            height: childrenRect.implicitHeight

            Button {
                text: "Close"
                onClicked: {
                    dialogTest.visible = false
                    statusMessage.text = "status: button Close clicked"
                    delay.running = true
                }
            }
            Button {
                text: "Save"
                onClicked: {
                    statusMessage.text = "status: button Save clicked"
                    delay.running = true
                }
            }
            Button {
                text: "Cancel"
                onClicked: {
                    dialogTest.visible = false
                    statusMessage.text = "status: button Cancel clicked"
                    delay.running = true
                }
            }
        }
    }
}
