import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: airDialog

    width: 500
    height: 210
    position: Qt.point(80, 80)

    windowId: airDialog.id
    title: "Environment: root"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GroupBox {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width

                Text {
                    width: 200
                    height: 25
                    text: qsTr("visibility (m)")
                    // property*: /environment/visibility-m
                }

                Text {
                    width: 200
                    height: 25
                    text: qsTr("sea-level temperature (degC)")
                    // property*: /environment/temperature-sea-level-degc
                }

                Text {
                    width: 200
                    height: 25
                    text: qsTr("sea-level dewpoint (degC)")
                    // property*: /environment/dewpoint-sea-level-degc
                }

                Text {
                    width: 200
                    height: 25
                    text: qsTr("sea-level pressure (inHG)")
                    // property*: /environment/pressure-sea-level-inhg
                }
            }
        }
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("OK")

            onClicked: {
                // binding*: " dialog-apply "
                airDialog.closed(airDialog.id);
            }
        }

        Button {
            text: qsTr("Apply")

            onClicked: {
                // binding*: " dialog-apply "
            }
            
        }

        Button {
            text: qsTr("Reset")

            onClicked: {
                // binding*: " dialog-update "
            }
        }

        Button {
            text: qsTr("Cancel")

            onClicked: {
                airDialog.closed(airDialog.id);
            }
            
        }
    } // buttons
}
