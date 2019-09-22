import QtQuick 2.13
import QtQml 2.13

import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Rectangle
{
    id: root

    width: parent.width
    implicitHeight: buttonTray.height
    implicitWidth: buttonTray.width
    clip: true

    border.width: 1
    border.color: Style.frameColor
    color: Style.windowColor
    //opacity: Style.panelOpacity

    property string windowId: ""
    default property alias contents: contentPlaceholder.data

    Item {
        id: buttonTray
        width: parent.width
        height: (Style.margin * 2) + contentPlaceholder.childrenRect.height
        anchors.verticalCenter: root.verticalCenter

        // content area
        Item {
            id: contentPlaceholder
            anchors.centerIn: parent
        }
    } // button tray

} // root
