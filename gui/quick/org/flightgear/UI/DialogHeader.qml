import QtQuick 2.13
import QtQml 2.13

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Rectangle
{
    id: root

    width: parent.width
    implicitHeight: titleBar.height
    implicitWidth: titleBar.width
    clip: true

    border.width: 1
    border.color: Style.frameColor
    color: Style.windowColor
    //opacity: Style.panelOpacity

    property string windowId: ""
    property alias title: titleText.text

    signal popout(string evt_windowId)
    signal closed(string evt_windowId)

    MouseArea {
        id: mouseDragArea

        anchors.fill: parent

        drag.target: root.parent

        onReleased: {
            // set geometry back to the window manager
        }
    }

    Item {
        id: titleBar

        width: parent.width
        height: (Style.margin * 2) + titleText.implicitHeight

        Rectangle {
            id: popOutBox

            width: 20
            height: 20
            anchors.left: parent.left
            anchors.leftMargin: Style.margin
            anchors.verticalCenter: parent.verticalCenter

            color: mousePopOutBox.containsMouse ? Style.activeColor : Style.themeColor

            MouseArea {
                id: mousePopOutBox
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    root.popout(root.windowId);
                }
            }
        }

        Text {
            id: titleText
            text: "Header Title"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            font.pixelSize: Style.headingFontPixelSize
            color: Style.themeColor
        }

        Rectangle {
            id: closeBox

            width: 20
            height: 20
            anchors.right: parent.right
            anchors.rightMargin: Style.margin
            anchors.verticalCenter: parent.verticalCenter

            color: mouseCloseBox.containsMouse ? Style.activeColor : Style.themeColor

            MouseArea {
                id: mouseCloseBox
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    root.closed(root.windowId);
                }
            }
        }
    } // of title bar

} // of root
