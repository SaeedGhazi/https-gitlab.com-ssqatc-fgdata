import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

Rectangle {
    id: root

    // padding*: 1
    // modal*: false
    width: 450
    height: 235
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
                    text: qsTr("Control nearby AI objects")
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

        GroupBox {
            Layout.fillWidth: true

            GridLayout {
                width: parent.width
                columns: 1

                Label {
                    text: qsTr("Select an AI object to bring up its own control dialog")
                    horizontalAlignment: Text.AlignLeft
                }

                ComboBox {

                    id: object_selection
                    //horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                    width: 300
                    // property*: /ai/control/object-selected

                    // binding*: " dialog-apply object-selection "
                }
            } // GridLayout
        }

        Label {
            height: 12
        }

        HorizontalLine {}

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("OK")
                    // default*: true
                    // equal*: true
                    // binding*: " dialog-apply "
                    // binding*: " nasal var obj_dlg_id = getprop("/ai/control/object-selected"); var dlg = gui.Dialog.new(obj_dlg_id); dlg.open(); "
                    // binding*: " dialog-close "
                }

                Button {
                    text: qsTr("Close")
                    // default*: true
                    // key*: qsTr("Esc")
                    // binding*: " dialog-close "
                }

                Label {
                    Layout.fillWidth: true
                }
            } // RowLayout
        }
    } // ColumnLayout
}
