import QtQuick 2.4
import FlightGear 1.0
import org.flightgear.UI 1.0

Item
{
    id: uiGlobalRoot

    width: 400
    height: 400

    // focus recovery mouse-area
    // this is used to ensure clicks which miss all other QtQuick content
    // force loss of focus, since PUI/Canvas might gain it
    MouseArea {
        anchors.fill: parent
        onPressed: {
            mouse.accepted = false; // don't consume the event

            for (var i = 0; i < windowsRepeater.count; i++) {
                windowsRepeater.itemAt(i).focus = false;
            }
        }
    }

    Repeater {
        id: windowsRepeater
        model: WindowManager.windows

        delegate: DialogFrame
        {
            windowId: model.windowId
            content: model.windowContentSource
            title: model.windowTitle
            position: model.windowPosition
            width: model.windowSize.width
            height: model.windowSize.height
        }
    }

    Overlay {
        anchors.fill: parent
        z: 200

        Component.onCompleted: {
            OverlayShared.globalOverlay = this
        }
    }

    ListModel {
        id: menuBarModel

        ListElement { label: "Settings"; dialogId: "settings" }
        ListElement { label: "Autopilot"; dialogId: "autopilot" }
        ListElement { label: "Help"; dialogId: "help" }

    }

    ListView {
        x: 10
        y: 100
        model: menuBarModel
        height: 1000

        delegate: Rectangle {
            border.width: 1
            border.color: Style.frameColor
            color: mouse.containsMouse ? Style.themeColor : Style.windowColor
            height: 30
            width: 200

            Text {
                anchors.centerIn: parent
                text: model.label
                color: Style.themeColor
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: WindowManager.show(model.dialogId);
            }
        }
    }
}

