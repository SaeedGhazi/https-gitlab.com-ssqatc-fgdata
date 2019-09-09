import QtQuick 2.4
import FlightGear 1.0

import org.flightgear.UI 1.0

FocusScope
{
    id: root

    property string windowId: ""
    property alias title: titleText.text
    property alias content: contentLoader.source
    property point position: Qt.point(200, 200)


    clip: true
    implicitHeight: titleBar.height + contentLoader.implicitHeight
    implicitWidth: contentLoader.implicitWidth

    onPositionChanged: {
        root.x = position.x;
        root.y = position.y;
    }

    Rectangle {
        id: background
        anchors.fill: parent
        border.width: 1
        border.color: Style.frameColor
        color: Style.windowColor
        opacity: 0.8
    }

    MouseArea {
        id: dragDialogArea
        anchors.fill: parent
        drag.target: root

        onReleased: {
            // set geometry back to the window manager
        }
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
        console.info("Opened window:" + root.title);
    }

    Item {
        id: titleBar
        width: parent.width
        height: (Style.margin * 2) + titleText.implicitHeight

        Rectangle {
            id: popOutButton
            width: 20
            height: 20
            color: Style.themeColor

            anchors.left: parent.left
            anchors.leftMargin: Style.margin
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                id: popOutMouse
                anchors.fill: parent
                // needs hover feedback
                onClicked: {
                    console.info("pop out");
                    WindowManager.requestPopout(root.windowId);
                }
            }
        }

        Text {
            id: titleText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Style.headingFontPixelSize
            color: Style.themeColor
        }

        Rectangle {
            id: closeBox
            width: 20
            height: 20
            color: Style.themeColor
            anchors.right: parent.right
            anchors.rightMargin: Style.margin
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                // needs hover feedback
                onClicked: {
                    WindowManager.requestClose(root.windowId);
                }
            }

        }

    } // of title bar

    Item {
        id: divider
        height: Style.margin
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: titleBar.bottom

        Rectangle {
            color: Style.themeColor
            height: 1
            width: parent.width - Style.inset
            anchors.centerIn: parent
        }
    }

    // content area

    Loader {
        id: contentLoader

        readonly property string windowId: root.windowId

        anchors {
            top: divider.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 1
        }
    }

    // resize area on top

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
    }

} // of root (FocusScope)
