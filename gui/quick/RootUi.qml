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

    Rectangle {
        x: 40
        y: 200
        width: 200
        height: 80
        color: mouse.containsMouse ? "red" : "yellow"

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                console.warn("HI");
                WindowManager.show("settings");
            }
        }
    }
}

