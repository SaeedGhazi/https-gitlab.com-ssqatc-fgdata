import QtQuick 2.13
import QtQml 2.13

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Rectangle
{
    id: root

    implicitHeight: titleBar.height + contentPlaceholder.implicitHeight
    implicitWidth: contentPlaceholder.implicitWidth
    //anchors.fill: parent
    clip: true

    border.width: 1
    border.color: Style.frameColor
    color: Style.windowColor
    opacity: Style.windowOpacity

    property string windowId: ""
    property alias title: titleBar.title
    property point position: Qt.point(0, 0)
    default property alias contents: contentPlaceholder.data
    property alias buttons: buttonTray.contents

    signal popout(string windowId)
    signal closed(string windowId)

    onPositionChanged: {
        root.x = position.x;
        root.y = position.y;
    }

    state: "normal"

    states: [
        State {
            name: "normal"
            AnchorChanges {
                target: resizeDragArea
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        },

        State {
            name: "resizing"
        }
    ]

    Component.onCompleted: {
        console.info("Opened window: " + root.title);
    }

    DialogHeader {
        id: titleBar;
        windowId: root.windowId

        title: "Dialog"

        onPopout: {
            console.log("popout: windowId: " + evt_windowId);
            root.popout(evt_windowId);
        }
        onClosed: {
            console.log("closed: windowId: " + evt_windowId);
            root.closed(evt_windowId)
        }
    }
    HorizontalLine { id: dividerHeader; anchors.top: titleBar.bottom }

    // content area
    Item {
        id: contentPlaceholder

        anchors.top: dividerHeader.bottom 
        anchors.bottom: dividerButtonTray.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.margin
    }

    HorizontalLine { id: dividerButtonTray; anchors.bottom: buttonTray.top }
    DialogButtonTray {
        id: buttonTray;
        windowId: root.windowId

        anchors.bottom: parent.bottom
    }

    // resize area (top layer)

    MouseArea {
        id: resizeDragArea
        width: Style.margin
        height: Style.margin
        cursorShape: Qt.SizeFDiagCursor

        onPressed: {
            // capture current pos since we offset from that
            var dragStart = Qt.point(x, y);
            root.state = "resizing";
            x = dragStart.x
            y = dragStart.y
        }

        onReleased: root.state = "normal";

        drag.target: resizeDragArea

        onXChanged: {
            if (root.state == "resizing") {
                root.width = Math.max(x, root.implicitWidth);
            }
        }

        onYChanged: {
            if (root.state == "resizing") {
                root.height = Math.max(y, root.implicitHeight);
            }
        }
    } // resizeDragArea

} // root
