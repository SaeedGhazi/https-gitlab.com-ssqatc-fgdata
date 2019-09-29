import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: swiftConnectionDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: swiftConnectionDialog.id
    title: "Swift Connection Settings"

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
            // padding*: 10

            Button {
                text: qsTr("Start server")
                // equal*: true
                // binding*: " nasal fgcommand("swiftStart", props.Node.new({ "message": getprop("/controls/lighting/landing-lights")})); "
            }

            Button {
                text: qsTr("Stop server")
                // equal*: true
                // binding*: " nasal fgcommand("swiftStop", props.Node.new({ "message": getprop("/controls/lighting/landing-lights")})); "
            }
        } // RowLayout

        RowLayout {
            width: parent.width

            Label {
                width: 2
                horizontalAlignment: Text.AlignRight
                text: qsTr("Adress")
            }

            TextInput {
                width: 150
                horizontalAlignment: Text.AlignLeft
                // property*: /sim/swift/adress
            }

            Label {
                width: 2
                horizontalAlignment: Text.AlignRight
                text: qsTr("Port")
            }

            TextInput {
                width: 55
                horizontalAlignment: Text.AlignLeft
                // property*: /sim/swift/port
            }
        } // RowLayout
    } // ColumnLayout

    // ======= content end

    buttons: Row {
        anchors.centerIn: parent
        spacing: 20
        height: childrenRect.implicitHeight

        Button {
            text: qsTr("Apply setting changes")
            // binding*: " dialog-apply "
        }
    } // buttons
}
