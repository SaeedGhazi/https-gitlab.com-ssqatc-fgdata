import QtQuick 2.4
import org.flightgear.UI 1.0

Rectangle {
    id: headerRect
    height: headerTitle.height + (Style.margin * 2)
    implicitWidth: parent.width

    property alias text: headerTitle.text

    color: Style.themeColor
    border.width: 1
    border.color: Style.frameColor

    Text {
        id: headerTitle
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        font.bold: true
        font.pixelSize: Style.subHeadingFontPixelSize
        anchors.left: parent.left
        anchors.leftMargin: Style.inset
    }
}