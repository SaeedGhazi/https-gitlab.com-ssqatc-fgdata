import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: pilotOffsetDialog

    width: 400
    height: 400
    position: Qt.point(80, 80)

    windowId: pilotOffsetDialog.id
    title: "Adjust View Position"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            Item {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width

                    Label {
                        text: qsTr("Left/Right")
                    }

                    Dial {
                        Layout.fillWidth: true
                        // property*: /sim/current-view/x-offset-m
                        // binding*: "dialog-apply"
                    }

                    Button {
                        text: qsTr("Zero")
                        // binding*: " property-assign /sim/current-view/x-offset-m 0 "
                    }

                    Label {
                        text: qsTr("-100.00")
                        // format*: %-0.2f m
                        // live*: true
                        // property*: /sim/current-view/x-offset-m
                    }
                } // ColumnLayout
            }

            Item {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width

                    Label {
                        text: qsTr("Down/Up")
                    }

                    Dial {
                        Layout.fillWidth: true
                        // property*: /sim/current-view/y-offset-m
                        // binding*: "dialog-apply"
                    }

                    Button {
                        text: qsTr("Zero")
                        // binding*: " property-assign /sim/current-view/y-offset-m 0 "
                    }

                    Label {
                        text: qsTr("-100.00")
                        // format*: %-0.2f m
                        // live*: true
                        // property*: /sim/current-view/y-offset-m
                    }
                } // ColumnLayout
            }

            Item {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width

                    Label {
                        text: qsTr("Fwd/Back")
                    }

                    Dial {
                        Layout.fillWidth: true
                        // property*: /sim/current-view/z-offset-m
                        // binding*: "dialog-apply"
                    }

                    Button {
                        text: qsTr("Zero")
                        // binding*: " property-assign /sim/current-view/z-offset-m 0 "
                    }

                    Label {
                        text: qsTr("-100.00")
                        // format*: %-0.2f m
                        // live*: true
                        // property*: /sim/current-view/z-offset-m
                    }
                } // ColumnLayout
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                pilotOffsetDialog.closed(pilotOffsetDialog.id);
            }
        }
    } // buttons
}
