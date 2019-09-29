import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: cockpitViewDialog

    width: 400
    height: 400
    position: Qt.point(80, 80)

    windowId: cockpitViewDialog.id
    title: "Cockpit View Options"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    Component.onCompleted: {}

    // ======= content

    ColumnLayout {
        width: parent.width

        RowLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width
                // padding*: 1

                Label {
                    text: qsTr(" ")
                }
            } // ColumnLayout

            ColumnLayout {
                width: parent.width

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Enable dynamic Cockpit View")
                    // property*: /sim/current-view/dynamic-view
                    // live*: true
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Enable View Movement due to G-Force")
                    // property*: /sim/rendering/headshake/enabled
                    // live*: true
                    // binding*: " dialog-apply "
                }

                CheckBox {
                    //horizontalAlignment: Text.AlignLeft
                    text: qsTr("Enable Blackout and Redout due to G-Force")
                    // property*: /sim/rendering/redout/enabled
                    // live*: true
                    // binding*: " dialog-apply "
                }
            } // ColumnLayout
        } // RowLayout

        HorizontalLine {}

        Label {
            text: qsTr("Blackout")
        }

        GridLayout {
            width: parent.width
            columns: 3

            Label {
                text: qsTr("Onset")
            }

            Label {
                text: qsTr("15.0")
                // format*: %2.1f
                // live*: true
                // property*: /sim/rendering/redout/parameters/blackout-onset-g
            }

            Slider {
                width: 150
                // property*: /sim/rendering/redout/parameters/blackout-onset-g
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr("Complete")
            }

            Label {
                text: qsTr("15.0")
                // format*: %2.1f
                // live*: true
                // property*: /sim/rendering/redout/parameters/blackout-complete-g
            }

            Slider {
                width: 150
                // property*: /sim/rendering/redout/parameters/blackout-complete-g
                // binding*: " dialog-apply "
            }
        } // GridLayout

        HorizontalLine {}

        Label {
            text: qsTr("Redout")
        }

        GridLayout {
            width: parent.width
            columns: 3

            Label {
                text: qsTr("Onset")
            }

            Label {
                text: qsTr("15.0")
                // format*: %2.1f
                // live*: true
                // property*: /sim/rendering/redout/parameters/redout-onset-g
            }

            Slider {
                width: 150
                // property*: /sim/rendering/redout/parameters/redout-onset-g
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr("Complete")
            }

            Label {
                text: qsTr("15.0")
                // format*: %2.1f
                // live*: true
                // property*: /sim/rendering/redout/parameters/redout-complete-g
            }

            Slider {
                width: 150
                // property*: /sim/rendering/redout/parameters/redout-complete-g
                // binding*: " dialog-apply "
            }
        } // GridLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Close")

            onClicked: {
                cockpitViewDialog.closed(cockpitViewDialog.id);
            }
        }
    } // buttons
}
