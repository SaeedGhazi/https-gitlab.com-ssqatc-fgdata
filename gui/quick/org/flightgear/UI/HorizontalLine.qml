import QtQuick 2.4
import org.flightgear.UI 1.0

Item {
    height: Style.margin
    implicitWidth: parent.width

    Rectangle {
        x: Style.margin
        width: parent.width - (Style.margin * 2)
        anchors.top: parent.verticalCenter
    }
}