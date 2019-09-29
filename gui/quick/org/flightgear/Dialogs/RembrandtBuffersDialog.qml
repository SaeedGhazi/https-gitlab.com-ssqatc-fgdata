import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import FlightGear 1.0
import org.flightgear.UI 1.0
import org.flightgear.Dialogs 1.0

DialogBase {
    id: rembrandtBuffersDialog

    width: 640
    height: 660
    position: Qt.point(80, 80)

    windowId: rembrandtBuffersDialog.id
    title: "Rendering buffers"

    onClosed: {
        root.visible = false
    }
    onPopout: {
    }

    // ======= content

    ColumnLayout {
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 3

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("North West buffer")
                id: buffer_nw_enabled
                // property*: /sim/rendering/rembrandt/debug-buffer[0]/enabled
                // binding*: " dialog-apply buffer-nw-enabled "
            }

            Label {
                text: qsTr("Buffer")
                horizontalAlignment: Text.AlignRight
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: buffer_nw_name
                // property*: /sim/rendering/rembrandt/debug-buffer[0]/name
                // binding*: " dialog-apply buffer-nw-name "
            }

            HorizontalLine {}

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("North East buffer")
                id: buffer_ne_enabled
                // property*: /sim/rendering/rembrandt/debug-buffer[1]/enabled
                // binding*: " dialog-apply buffer-ne-enabled "
            }

            Label {
                text: qsTr("Buffer")
                horizontalAlignment: Text.AlignRight
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: buffer_ne_name
                // property*: /sim/rendering/rembrandt/debug-buffer[1]/name
                // binding*: " dialog-apply buffer-ne-name "
            }

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("South West buffer")
                id: buffer_sw_enabled
                // property*: /sim/rendering/rembrandt/debug-buffer[2]/enabled
                // binding*: " dialog-apply buffer-sw-enabled "
            }

            Label {
                text: qsTr("Buffer")
                horizontalAlignment: Text.AlignRight
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: buffer_sw_name
                // property*: /sim/rendering/rembrandt/debug-buffer[2]/name
                // binding*: " dialog-apply buffer-sw-name "
            }

            HorizontalLine {}

            CheckBox {
                //horizontalAlignment: Text.AlignLeft
                text: qsTr("South East buffer")
                id: buffer_se_enabled
                // property*: /sim/rendering/rembrandt/debug-buffer[3]/enabled
                // binding*: " dialog-apply buffer-se-enabled "
            }

            Label {
                text: qsTr("Buffer")
                horizontalAlignment: Text.AlignRight
            }

            ComboBox {
                //horizontalAlignment: Text.AlignLeft
                id: buffer_se_name
                // property*: /sim/rendering/rembrandt/debug-buffer[3]/name
                // binding*: " dialog-apply buffer-se-name "
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
                rembrandtBuffersDialog.closed(rembrandtBuffersDialog.id);
            }
        }
    } // buttons
}
