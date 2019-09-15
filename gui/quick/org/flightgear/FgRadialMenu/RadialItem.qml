import QtQuick 2.12

Rectangle {
    width: 150
    height: 30
    border.width: 1
    color: index < 8 ? "lightsteelblue" : "#d9d9d9"
    property alias text: label.text

    Text {
        id: label
        anchors.centerIn: parent
        text: index
    }
}
