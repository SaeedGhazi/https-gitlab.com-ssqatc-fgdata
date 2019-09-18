import QtQuick 2.12

Rectangle {
    id: control
    width: 190
    height: 30
    radius: 8
    border.width: 1
    color: index < 8 ? "lightsteelblue" : "#d9d9d9"

    property string menuId: ""
    property alias text: label.text

    signal clicked

    Text {
        id: label
        anchors.centerIn: parent
        text: index
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            control.clicked();
        }
    }
}
