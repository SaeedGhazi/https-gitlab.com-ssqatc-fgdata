import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Rectangle {
    id: root

    width: 300
    height: 280
    anchors.centerIn: parent
    border.width: 1
    border.color: Style.frameColor
    color: Style.windowColor
    opacity: Style.panelOpacity

    signal closed(string windowId)

    ColumnLayout {
        width: parent.width

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("$name")
                    font.pointSize: Style.headingFontPixelSize
                    font.bold: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    id: closeBox
                    width: 20
                    height: 20
                    color: mouseClose.containsMouse ? Style.activeColor : Style.themeColor
                    anchors.right: parent.right
                    anchors.rightMargin: Style.margin
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        id: mouseClose
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.closed(root.id);
                        }
                    }
                }
            } // RowLayout
        }

        HorizontalLine {}

        ListView {
            Layout.fillWidth: true
            height: 205
            // property*: $result
            // binding*: " dialog-apply "
            currentIndex: $value
        }

        HorizontalLine {}
    }
}
