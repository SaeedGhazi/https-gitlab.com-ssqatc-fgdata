import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: instrumentFailuresDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: instrumentFailuresDialog.id
    title: "Instrument Failures"

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

            Label {
                text: qsTr(" Uncheck an instrument to fail it, or set the Mean Time Between Failures. ")
            }
        } // RowLayout

        HorizontalLine {}

        RowLayout {
            width: parent.width

            GridLayout {
                width: parent.width
                columns: 5

                Label {
                    text: qsTr("Instrument")
                }

                Label {
                    text: qsTr("MTBF (sec)")
                }

                Label {
                    text: qsTr(" ")
                }

                Label {
                    text: qsTr("Instrument")
                }

                Label {
                    text: qsTr("MTBF (sec)")
                }

                Label {
                    text: qsTr("Nav 1 CDI")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/nav[0]/cdi/serviceable
                }

                TextInput {
                    width: 80
                    height: 20
                    // property*: /sim/failure-manager/instrumentation/nav[0]/cdi/mtbf
                }

                Label {
                    text: qsTr("Nav 2 CDI")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/nav[1]/cdi/serviceable
                }

                TextInput {
                    width: 80
                    height: 20
                    // property*: /sim/failure-manager/instrumentation/nav[1]/cdi/mtbf
                }

                Label {
                    text: qsTr("Nav 1 GS")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/nav[0]/gs/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/nav[0]/gs/mtbf
                }

                Label {
                    text: qsTr("Nav 2 GS")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/nav[1]/gs/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/nav[1]/gs/mtbf
                }

                Label {
                    text: qsTr("DME")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/dme/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/dme/mtbf
                }

                Label {
                    text: qsTr("ADF")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/adf/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/adf/mtbf
                }

                Label {
                    text: qsTr(" Airspeed Indicator")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/airspeed-indicator/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/airspeed-indicator/mtbf
                }

                Label {
                    text: qsTr("Attitude Indicator")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/attitude-indicator/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/attitude-indicator/mtbf
                }

                Label {
                    text: qsTr("Altimeter")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/altimeter/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/altimeter/mtbf
                }

                Label {
                    text: qsTr("Turn Indicator")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/turn-indicator/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/turn-indicator/mtbf
                }

                Label {
                    text: qsTr("Slip/Skid Ball")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/slip-skid-ball/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/slip-skid-ball/mtbf
                }

                Label {
                    text: qsTr("Heading Indicator")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/heading-indicator/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/heading-indicator/mtbf
                }

                Label {
                    text: qsTr(" Vertical Speed Ind.")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/vertical-speed-indicator/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/vertical-speed-indicator/mtbf
                }

                Label {
                    text: qsTr("Magnetic Compass")
                    horizontalAlignment: Text.AlignRight
                }

                CheckBox {
                    // property*: /sim/failure-manager/instrumentation/magnetic-compass/serviceable
                }

                TextInput {
                    // property*: /sim/failure-manager/instrumentation/magnetic-compass/mtbf
                }
            } // GridLayout
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")
            // default*: true
            // equal*: true
            // binding*: " dialog-apply "
            // binding*: " nasal setprop("/instrumentation/heading-indicator-fg/serviceable", getprop("/instrumentation/heading-indicator/serviceable")); "

            onClicked: {
                instrumentFailuresDialog.closed(instrumentFailuresDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")
            // equal*: true
            // binding*: " dialog-apply "
            // binding*: " nasal setprop("/instrumentation/heading-indicator-fg/serviceable", getprop("/instrumentation/heading-indicator/serviceable")); "
        }

        Button {
            text: qsTr("Refresh")
            // equal*: true
            // binding*: " dialog-update "
        }

        Button {
            text: qsTr("Cancel")
            // equal*: true
            // key*: qsTr("Esc")

            onClicked: {
                instrumentFailuresDialog.closed(instrumentFailuresDialog.id);
            }
        }
    } // buttons
}
