import QtQuick 2.4
import FlightGear 1.0
import org.flightgear.UI 1.0

Rectangle {
    id: root

    property string text
  //  property string hoverText: ""
    property bool enabled: true
    property bool active: false

    readonly property string __baseColor:Style.themeColor
    signal selected

    // width is done this way so we can set a width from outside and have
    // the tab do eliding
    implicitWidth: buttonText.implicitWidth  + Style.margin * 2
    height: buttonText.implicitHeight + (Style.margin * 2)

    color: enabled ? (root.active || mouse.containsMouse ? Style.activeColor : __baseColor)
                   : Style.disabledThemeColor

    Text {
        id: buttonText
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            margins: Style.margin
        }

        color: "white"
        text: root.text
        font.pixelSize: Style.baseFontPixelSize
        elide: Text.ElideRight
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        onClicked: {
            root.selected();
        }

    }
}
