import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: loggingDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: loggingDialog.id
    title: "Logging"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        Item {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                Label {
                    text: qsTr("Log File:")
                }

                TextInput {
                    Layout.fillWidth: true
                    // property*: /logging/log[0]/filename
                }

                Label {
                    text: qsTr("Interval (ms):")
                }

                TextInput {
                    // property*: /logging/log[0]/interval-ms
                }
            } // RowLayout
        }

        Item {
            Layout.fillWidth: true

            GridLayout {
                width: parent.width

                Label {
                    text: qsTr("Title")
                }

                Label {
                    text: qsTr("Property")
                }

                Label {
                    text: qsTr("1")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[0]/enabled
                }

                TextInput {
                    width: 120
                    // property*: /logging/log[0]/entry[0]/title
                }

                TextInput {
                    width: 240
                    // property*: /logging/log[0]/entry[0]/property
                }

                Label {
                    text: qsTr("2")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[1]/enabled
                }

                TextInput {
                    // property*: /logging/log[0]/entry[1]/title
                }

                TextInput {
                    // property*: /logging/log[0]/entry[1]/property
                }

                Label {
                    text: qsTr("3")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[2]/enabled
                }

                TextInput {
                    // property*: /logging/log[0]/entry[2]/title
                }

                TextInput {
                    // property*: /logging/log[0]/entry[2]/property
                }

                Label {
                    text: qsTr("4")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[3]/enabled
                }

                TextInput {
                    // property*: /logging/log[0]/entry[3]/title
                }

                TextInput {
                    // property*: /logging/log[0]/entry[3]/property
                }

                Label {
                    text: qsTr("5")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[4]/enabled
                }

                TextInput {
                    // property*: /logging/log[0]/entry[4]/title
                }

                TextInput {
                    // property*: /logging/log[0]/entry[4]/property
                }

                Label {
                    text: qsTr("6")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[5]/enabled
                }

                TextInput {
                    // property*: /logging/log[0]/entry[5]/title
                }

                TextInput {
                    // property*: /logging/log[0]/entry[5]/property
                }

                Label {
                    text: qsTr("7")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[6]/enabled
                }

                TextInput {
                    // property*: /logging/log[0]/entry[6]/title
                }

                TextInput {
                    // property*: /logging/log[0]/entry[6]/property
                }

                Label {
                    text: qsTr("8")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[7]/enabled
                }

                TextInput {
                    // property*: /logging/log[0]/entry[7]/title
                }

                TextInput {
                    // property*: /logging/log[0]/entry[7]/property
                }

                Label {
                    text: qsTr("9")
                }

                CheckBox {
                    // property*: /logging/log[0]/entry[8]/enabled
                }

                TextInput {
                    // property*: /logging/log[0]/entry[8]/title
                }

                TextInput {
                    // property*: /logging/log[0]/entry[8]/property
                }
            } // GridLayout
        }

        CheckBox {
            // property*: /logging/log[0]/enabled
            text: qsTr("Logging Enabled")
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // binding*: "dialog-apply"
            // binding*: "reinitlogger"

            onClicked: {
                loggingDialog.closed(loggingDialog.id);
            }
        }

        Button {
            text: qsTr("Cancel")
            // key*: qsTr("Esc")

            onClicked: {
                loggingDialog.closed(loggingDialog.id);
            }
        }
    } // buttons
}
