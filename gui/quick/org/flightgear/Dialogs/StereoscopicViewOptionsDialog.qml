import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: stereoscopicViewDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: stereoscopicViewDialog.id
    title: "Stereoscopic View Options"

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
            // padding*: 1

            Label {
                text: qsTr(" Stereo Mode")
            }

            Label {
                Layout.fillWidth: true
            }

            ComboBox {
                width: 250
                // live*: true
                // property*: /sim/rendering/osg-displaysettings/stereo-mode
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr(" ")
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 1

            Label {
                text: qsTr(" Screen Distance")
            }

            Label {
                Layout.fillWidth: true
            }

            Slider {
                // property*: /sim/rendering/osg-displaysettings/screen-distance
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr("12345678")
                // format*: %.2f m
                // live*: true
                // property*: /sim/rendering/osg-displaysettings/screen-distance
            }
        } // RowLayout

        RowLayout {
            width: parent.width
            // padding*: 1

            Label {
                text: qsTr(" Eye Separation")
            }

            Label {
                Layout.fillWidth: true
            }

            Slider {
                // property*: /sim/rendering/osg-displaysettings/eye-separation
                // binding*: " dialog-apply "
            }

            Label {
                text: qsTr("12345678")
                // format*: %.2f m
                // live*: true
                // property*: /sim/rendering/osg-displaysettings/eye-separation
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
                stereoscopicViewDialog.closed(stereoscopicViewDialog.id);
            }
        }
    } // buttons
}
